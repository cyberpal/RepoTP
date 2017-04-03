
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Cargos] (
	@Id CHAR(36),
	@CreateTimestamp DATETIME,
	@LocationIdentification INT,
	@ProductIdentification INT,
	@Amount DECIMAL(12, 2),
	@PromotionIdentification INT,
	@FacilitiesPayments INT,
	@ButtonCode VARCHAR(20),
	@Usuario VARCHAR(20),
	@Channel VARCHAR(36),
	@FeeAmount DECIMAL(12, 2) OUTPUT
	)
AS
DECLARE @id_base_de_calculo INT;
DECLARE @Cargos TABLE (
	id INT PRIMARY KEY IDENTITY(1, 1),
	id_cargo INT,
	monto_calculado DECIMAL(12, 2),
	valor_aplicado DECIMAL(12, 2),
	id_tipo_aplicacion INT,
	codigo_aplicacion VARCHAR(20),
	codigo_tipo_cargo VARCHAR(20)
	);
DECLARE @i INT;
DECLARE @cargos_count INT;
DECLARE @id_cargo INT;
DECLARE @codigo_tipo_cargo VARCHAR(20);
DECLARE @valor_aplicado DECIMAL(12, 2);
DECLARE @id_tipo_aplicacion INT;
DECLARE @codigo_aplicacion VARCHAR(20);
DECLARE @bonificacion_cf_vendedor DECIMAL(5, 2) = NULL;
DECLARE @tasa_directa DECIMAL(5, 2);
DECLARE @ret_code INT;
DECLARE @monto_total_tx DECIMAL(12, 2);
DECLARE @monto_calculado_cargos DECIMAL(12, 2);
DECLARE @valor_aplicado_cargos DECIMAL(12, 2);
DECLARE @codigo_tipo_promocion VARCHAR(20);
DECLARE @id_promocion INT;
DECLARE @flag_tasa_directa BIT;
DECLARE @id_canal INT = 0;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF (@ButtonCode = 'CPTO_BTN_AJ_CTGO')
			SET @FeeAmount = 0;
		ELSE
		BEGIN
			-- Obtener Base de Calculo
			SELECT @id_base_de_calculo = tpo.id_tipo
			FROM Configurations.dbo.Tipo tpo
			WHERE tpo.Codigo = (
					CASE 
						WHEN @FacilitiesPayments = 1
							THEN 'BC_TX_PAGO'
						ELSE 'BC_TX_CUOTAS'
						END
					);

			-- Obtener Canal mPOS si corresponde (sino queda en cero)
			IF (@Channel = 'mPOS')
				SELECT @id_canal = can.id_canal
				FROM Configurations.dbo.Canal_Adhesion can
				WHERE can.Nombre = 'mPOS';

			-- Obtener Cargos default
			INSERT INTO @Cargos (
				id_cargo,
				monto_calculado,
				valor_aplicado,
				id_tipo_aplicacion,
				codigo_aplicacion,
				codigo_tipo_cargo
				)
			SELECT cgo.id_cargo,
				0 AS monto_calculado,
				vco.valor AS valor_aplicado,
				vco.id_tipo_aplicacion,
				tpo.codigo AS codigo_aplicacion,
				tcg.codigo AS codigo_tipo_cargo
			FROM Configurations.dbo.Cargo cgo
			INNER JOIN Configurations.dbo.Valor_Cargo vco
				ON cgo.id_cargo = vco.id_cargo
			LEFT JOIN Configurations.dbo.Tipo tpo
				ON vco.id_tipo_aplicacion = tpo.id_tipo
			INNER JOIN Configurations.dbo.Cuenta cta
				ON cgo.id_tipo_cuenta = cta.id_tipo_cuenta
			INNER JOIN Configurations.dbo.Medio_De_Pago mdp
				ON cgo.id_tipo_medio_pago = mdp.id_tipo_medio_pago
			INNER JOIN Configurations.dbo.Tipo_Cargo tcg
				ON cgo.id_tipo_cargo = tcg.id_tipo_cargo
			WHERE cgo.id_base_de_calculo = @id_base_de_calculo
				AND cta.id_cuenta = @LocationIdentification
				AND mdp.id_medio_pago = @ProductIdentification
				AND (
					cgo.id_canal = @id_canal
					OR cgo.id_canal IS NULL
					)
				AND vco.fecha_inicio_vigencia <= @CreateTimestamp
				AND (
					vco.fecha_fin_vigencia >= @CreateTimestamp
					OR vco.fecha_fin_vigencia IS NULL
					);

			-- Obtener cantidad de Cargos activos
			SET @cargos_count = @@ROWCOUNT;

			-- Obtener configuración específica de Cargos por Grupo de Rubro
			UPDATE @Cargos
			SET valor_aplicado = cgr.valor,
				id_tipo_aplicacion = cgr.id_tipo_aplicacion,
				codigo_aplicacion = tpo.codigo
			FROM @Cargos cgo
			INNER JOIN Configurations.dbo.Cargo_Grupo_Rubro cgr
				ON cgo.id_cargo = cgr.id_cargo
			INNER JOIN Configurations.dbo.Rubro_GrupoRubro rgr
				ON cgr.id_grupo_rubro = rgr.id_grupo_rubro
			INNER JOIN Configurations.dbo.Actividad_Cuenta aca
				ON rgr.id_rubro = aca.id_rubro
			LEFT JOIN Configurations.dbo.Tipo tpo
				ON cgr.id_tipo_aplicacion = tpo.id_tipo
			WHERE   cgr.fecha_baja IS NULL								--bug fix <AM> 29-03-2017 -------------
			    AND cgr.fecha_inicio_vigencia <= @CreateTimestamp
				AND (
					cgr.fecha_fin_vigencia >= @CreateTimestamp
					OR cgr.fecha_fin_vigencia IS NULL
					)
				AND rgr.fecha_inicio_vigencia <= @CreateTimestamp
				AND (
					rgr.fecha_fin_vigencia >= @CreateTimestamp
					OR rgr.fecha_fin_vigencia IS NULL
					)
				AND aca.id_cuenta = @LocationIdentification
				AND aca.flag_vigente = 1;

			-- Obtener configuración específica de Cargos por Cuenta
			UPDATE @Cargos
			SET valor_aplicado = cca.valor,
				id_tipo_aplicacion = cca.id_tipo_aplicacion,
				codigo_aplicacion = tpo.codigo
			FROM @Cargos cgo
			INNER JOIN Configurations.dbo.Cargo_Cuenta cca
				ON cgo.id_cargo = cca.id_cargo
			LEFT JOIN Configurations.dbo.Tipo tpo
				ON cca.id_tipo_aplicacion = tpo.id_tipo
			WHERE cca.id_cuenta = @LocationIdentification
				AND cca.fecha_inicio_vigencia <= @CreateTimestamp
				AND (
					cca.fecha_fin_vigencia IS NULL
					OR cca.fecha_fin_vigencia >= @CreateTimestamp
					);

			SET @i = 1;

			WHILE (@i <= @cargos_count)
			BEGIN
				SELECT @id_cargo = id_cargo,
					@codigo_tipo_cargo = codigo_tipo_cargo,
					@valor_aplicado = valor_aplicado,
					@codigo_aplicacion = codigo_aplicacion
				FROM @Cargos
				WHERE id = @i;

				IF (@codigo_tipo_cargo = 'COMISION')
				BEGIN
					UPDATE @Cargos
					SET monto_calculado = (
							CASE 
								WHEN @codigo_aplicacion = 'AP_PORCENTAJE'
									THEN @Amount * (@valor_aplicado / 100)
								WHEN @codigo_aplicacion = 'AP_FIJO'
									THEN @valor_aplicado
								ELSE 0
								END
							)
					WHERE id = @i;
				END
				ELSE IF (@codigo_tipo_cargo = 'COSTO_FIN_V')
				BEGIN
					--Validar si aplica tasa directa
					SELECT @flag_tasa_directa = ISNULL(rbn.flag_tasa_directa, 0),
						@tasa_directa = rbn.tasa_directa_ingresada
					FROM Configurations.dbo.Regla_Bonificacion rbn
					WHERE rbn.id_regla_bonificacion = @PromotionIdentification;

					IF (@flag_tasa_directa = 0)
					BEGIN
						--Sin tasa directa
						SELECT @bonificacion_cf_vendedor = rbn.bonificacion_cf_vendedor,
							@tasa_directa = tmp.tasa_directa,
							@codigo_tipo_promocion = tpo.codigo,
							@id_promocion = pmn.id_promocion
						FROM Configurations.dbo.Regla_Bonificacion rbn
						INNER JOIN Configurations.dbo.Tasa_MP AS tmp
							ON rbn.id_tasa_mp = tmp.id_tasa_mp
						INNER JOIN Configurations.dbo.Promocion AS pmn
							ON rbn.id_promocion = pmn.id_promocion
						INNER JOIN Configurations.dbo.Tipo AS tpo
							ON pmn.id_tipo_aplicacion = tpo.id_tipo
								AND tpo.id_grupo_tipo = 25
								AND rbn.id_regla_bonificacion = @PromotionIdentification;
					END
					ELSE
					BEGIN
						--Con tasa directa	
						SELECT @codigo_tipo_promocion = tpo.codigo,
							@id_promocion = pmn.id_promocion
						FROM Configurations.dbo.Regla_Bonificacion rbn
						INNER JOIN Configurations.dbo.Promocion AS pmn
							ON rbn.id_promocion = pmn.id_promocion
						INNER JOIN Configurations.dbo.Tipo AS tpo
							ON pmn.id_tipo_aplicacion = tpo.id_tipo
								AND tpo.id_grupo_tipo = 25
								AND rbn.id_regla_bonificacion = @PromotionIdentification;
					END;

					--Si id_promocion = NULL se calculara PROMO_CTAS x default
					SET @codigo_tipo_promocion = ISNULL(@codigo_tipo_promocion, 'PROMO_CTAS');

					IF (
							@PromotionIdentification IS NULL
							OR @bonificacion_cf_vendedor = 100
							)
					BEGIN
						UPDATE @Cargos
						SET monto_calculado = 0,
							valor_aplicado = 0
						WHERE id = @i;
					END
					ELSE IF (@codigo_tipo_promocion <> 'PROMO_CTAS')
					BEGIN
						IF (@codigo_tipo_promocion = 'PROMO_VTA_MES_CTA')
						BEGIN
							SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)
							FROM Configurations.dbo.Acumulador_Promociones aps
							WHERE CAST(aps.fecha_transaccion AS DATE) >= DATEADD(month, DATEDIFF(month, 0, CAST(@CreateTimestamp AS DATE)), 0)
								AND CAST(aps.fecha_transaccion AS DATE) <= CAST(@CreateTimestamp AS DATE)
								AND aps.cuenta_transaccion = @LocationIdentification
								AND aps.id_promocion = @id_promocion;
						END
						ELSE IF (@codigo_tipo_promocion = 'PROMO_VTA_TOTAL_CTA')
						BEGIN
							SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)
							FROM Configurations.dbo.Acumulador_Promociones aps
							WHERE aps.cuenta_transaccion = @LocationIdentification
								AND aps.id_promocion = @id_promocion;
						END
						ELSE IF (@codigo_tipo_promocion = 'PROMO_VTA_TOTAL')
						BEGIN
							SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)
							FROM Configurations.dbo.Acumulador_Promociones aps
							WHERE aps.id_promocion = @id_promocion;
						END

						IF (@flag_tasa_directa = 0)
						BEGIN
							--Sin tasa directa
							SELECT @bonificacion_cf_vendedor = v.bonificacion_cf_vendedor,
								@tasa_directa = tmp.tasa_directa
							FROM Configurations.dbo.Regla_Bonificacion rb
							INNER JOIN Configurations.dbo.Volumen_Regla_Promocion v
								ON rb.id_regla_promocion = v.id_regla_promocion
							INNER JOIN Configurations.dbo.Tasa_MP tmp
								ON rb.id_tasa_mp = tmp.id_tasa_mp
							WHERE rb.id_regla_bonificacion = @PromotionIdentification
								AND (
									(
										v.volumen_vta_desde = 0
										AND v.volumen_vta_hasta >= @monto_total_tx
										)
									OR (
										v.volumen_vta_desde > 0
										AND v.volumen_vta_desde < @monto_total_tx
										AND (
											v.volumen_vta_hasta IS NULL
											OR v.volumen_vta_hasta >= @monto_total_tx
											)
										)
									);
						END
						ELSE
						BEGIN
							--Con tasa directa
							--Buscar en Regla_Bonificacion
							SELECT @tasa_directa = rb.tasa_directa_ingresada
							FROM Configurations.dbo.Regla_Bonificacion rb
							WHERE rb.id_regla_bonificacion = @PromotionIdentification;

							IF (@tasa_directa IS NULL)
							BEGIN
								--Buscar en Volumen_Regla_Promocion
								SELECT @tasa_directa = ISNULL(v.tasa_directa_ingresada, 0)
								FROM Configurations.dbo.Regla_Bonificacion rb
								INNER JOIN Configurations.dbo.Volumen_Regla_Promocion v
									ON rb.id_regla_promocion = v.id_regla_promocion
								WHERE rb.id_regla_bonificacion = @PromotionIdentification
									AND (
										(
											v.volumen_vta_desde = 0
											AND v.volumen_vta_hasta >= @monto_total_tx
											)
										OR (
											v.volumen_vta_desde > 0
											AND v.volumen_vta_desde < @monto_total_tx
											AND (
												v.volumen_vta_hasta IS NULL
												OR v.volumen_vta_hasta >= @monto_total_tx
												)
											)
										);
							END;
						END;
					END;

					IF (@flag_tasa_directa = 0)
					BEGIN
						SET @monto_calculado_cargos = CAST(@Amount * (@tasa_directa / 100) * ((100 - ISNULL(@bonificacion_cf_vendedor, 0)) / 100) AS DECIMAL(12, 2));
						SET @valor_aplicado_cargos = IIF(@bonificacion_cf_vendedor IS NULL, 0, 100 - @bonificacion_cf_vendedor);
					END
					ELSE
					BEGIN
						--Por tasa directa
						SET @monto_calculado_cargos = CAST(@Amount * (@tasa_directa / 100) AS DECIMAL(12, 2));
						SET @valor_aplicado_cargos = @tasa_directa;
					END;

					UPDATE @Cargos
					SET monto_calculado = ISNULL(@monto_calculado_cargos, 0),
						valor_aplicado = ISNULL(@valor_aplicado_cargos, 0)
					WHERE id = @i;
				END

				INSERT INTO Configurations.dbo.Cargos_Por_Transaccion (
					id_cargo,
					id_transaccion,
					monto_calculado,
					valor_aplicado,
					id_tipo_aplicacion,
					fecha_alta,
					usuario_alta,
					version
					)
				SELECT id_cargo,
					@Id,
					monto_calculado,
					valor_aplicado,
					id_tipo_aplicacion,
					GETDATE(),
					@Usuario,
					0
				FROM @Cargos
				WHERE id = @i;

				SET @i += 1;
			END

			SELECT @FeeAmount = ISNULL(SUM(monto_calculado), 0)
			FROM @Cargos;
		END

		SET @ret_code = 1;
	END TRY

	BEGIN CATCH
		SET @ret_code = 0;

		PRINT ERROR_MESSAGE();
	END CATCH

	RETURN @ret_code;
END

