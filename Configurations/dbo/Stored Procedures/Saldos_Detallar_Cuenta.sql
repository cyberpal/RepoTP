
CREATE PROCEDURE dbo.Saldos_Detallar_Cuenta (@p_id_cuenta INT)
AS
-- Constantes de tipo de movimientos
DECLARE @tipo_transaccion CHAR(3) = 'VEN';
DECLARE @tipo_devolucion CHAR(3) = 'DEV';
DECLARE @tipo_cashout CHAR(3) = 'CSH';
DECLARE @tipo_ajuste CHAR(3) = 'AJU';
DECLARE @tipo_contracargo CHAR(3) = 'CCG';
-- Variables
DECLARE @i INT;
DECLARE @count INT;
DECLARE @detalles TABLE (id_detalle INT);
DECLARE @tipo CHAR(3);
DECLARE @temp TABLE (
	i INT PRIMARY KEY identity(1, 1),
	id_cuenta INT,
	id_log_proceso INT
	);
DECLARE @id_cuenta INT;
DECLARE @id_log_proceso INT;

BEGIN
	-- Verificar que se haya indicado una Cuenta
	IF (@p_id_cuenta IS NULL)
	BEGIN
		PRINT 'Debe indicarse un ID de Cuenta.';

		RETURN 0;
	END;

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO Configurations.dbo.Detalle_Analisis_De_Saldo (
			fecha_de_analisis,
			tipo_movimiento,
			id_char,
			id_int,
			id_cuenta,
			importe_movimiento,
			fecha_movimiento,
			id_log_proceso,
			fecha_inicio_ejecucion,
			fecha_fin_ejecucion,
			id_log_movimiento,
			flag_impactar_en_saldo,
			impacto_en_saldo_ok
			)
		OUTPUT inserted.id_detalle
		INTO @detalles
		-- Ventas
		SELECT getdate() AS fecha_de_analisis,
			@tipo_transaccion AS tipo,
			transacciones.Id AS id_char,
			NULL AS id_int,
			transacciones.id_cuenta,
			transacciones.importe_movimiento,
			transacciones.LiquidationTimestamp AS fecha_movimiento,
			lpo.id_log_proceso,
			lpo.fecha_inicio_ejecucion,
			lpo.fecha_fin_ejecucion,
			NULL AS id_log_movimiento,
			1 AS flag_impactar_en_saldo,
			NULL AS impacto_en_saldo_ok
		FROM (
			SELECT trn.Id,
				trn.LocationIdentification AS id_cuenta,
				(trn.Amount - trn.FeeAmount - trn.TaxAmount) AS importe_movimiento,
				trn.LiquidationTimestamp
			FROM Transactions.dbo.transactions trn
			WHERE trn.ResultCode = - 1
				AND trn.OperationName <> 'devolucion'
				AND trn.LiquidationStatus = - 1
				AND trn.LocationIdentification = @p_id_cuenta
			) transacciones
		LEFT JOIN Configurations.dbo.Log_Proceso lpo
			ON transacciones.LiquidationTimestamp BETWEEN lpo.fecha_inicio_ejecucion
					AND lpo.fecha_fin_ejecucion
				AND lpo.id_proceso = 1
		
		UNION ALL
		
		-- Devoluciones
		SELECT getdate() AS fecha_de_analisis,
			@tipo_devolucion AS tipo,
			trn.Id AS id_char,
			NULL AS id_int,
			trn.LocationIdentification AS id_cuenta,
			((trn.Amount - isnull(trn.FeeAmount, 0) - isnull(trn.TaxAmount, 0)) * - 1) AS importe_movimiento,
			trn.CreateTimestamp AS fecha_movimiento,
			NULL AS id_log_proceso,
			NULL AS fecha_inicio_ejecucion,
			NULL AS fecha_fin_ejecucion,
			NULL AS id_log_movimiento,
			1 AS flag_impactar_en_saldo,
			NULL AS impacto_en_saldo_ok
		FROM Transactions.dbo.transactions trn
		WHERE trn.ResultCode = - 1
			AND trn.OperationName = 'devolucion'
			AND trn.LocationIdentification = @p_id_cuenta
		
		UNION ALL
		
		-- Cashout			
		SELECT getdate() AS fecha_de_analisis,
			@tipo_cashout AS tipo,
			NULL AS id_char,
			rdo.id_retiro_dinero AS id_int,
			rdo.id_cuenta,
			(rdo.monto * - 1) AS importe_movimiento,
			rdo.fecha_alta AS fecha_movimiento,
			NULL AS id_log_proceso,
			NULL AS fecha_inicio_ejecucion,
			NULL AS fecha_fin_ejecucion,
			NULL AS id_log_movimiento,
			1 AS flag_impactar_en_saldo,
			NULL AS impacto_en_saldo_ok
		FROM Configurations.dbo.Retiro_Dinero rdo
		WHERE rdo.estado_transaccion = 'TX_APROBADA'
			AND rdo.id_cuenta = @p_id_cuenta
		
		UNION ALL
		
		-- Ajustes
		SELECT getdate() AS fecha_de_analisis,
			@tipo_ajuste AS tipo,
			NULL AS id_char,
			aje.id_ajuste AS id_int,
			aje.id_cuenta,
			--(
			--	CASE 
			--		WHEN cop.signo = '+'
			--			THEN aje.monto_neto
			--		ELSE (aje.monto_neto * - 1)
			--		END
			--	) AS importe_movimiento,
			aje.monto_neto AS importe_movimiento,
			aje.fecha_alta AS fecha_movimiento,
			NULL AS id_log_proceso,
			NULL AS fecha_inicio_ejecucion,
			NULL AS fecha_fin_ejecucion,
			NULL AS id_log_movimiento,
			1 AS flag_impactar_en_saldo,
			NULL AS impacto_en_saldo_ok
		FROM Configurations.dbo.Ajuste aje
		--INNER JOIN Configurations.dbo.Codigo_Operacion cop
		--	ON cop.id_codigo_operacion = aje.id_codigo_operacion
		WHERE aje.id_cuenta = @p_id_cuenta
		
		UNION ALL
		
		-- Contracargos
		SELECT getdate() AS fecha_de_analisis,
			@tipo_contracargo AS tipo,
			dta.id_transaccion AS id_char,
			dta.id_disputa AS id_int,
			dta.id_cuenta,
			(trn.Amount * - 1) AS importe_movimiento,
			dta.fecha_resolucion_cuenta AS fecha_movimiento,
			lpo.id_log_proceso,
			lpo.fecha_inicio_ejecucion,
			lpo.fecha_fin_ejecucion,
			NULL AS id_log_movimiento,
			1 AS flag_impactar_en_saldo,
			NULL AS impacto_en_saldo_ok
		FROM Configurations.dbo.Disputa dta
		INNER JOIN Transactions.dbo.transactions trn
			ON dta.id_transaccion = trn.Id
		LEFT JOIN Configurations.dbo.Log_Proceso lpo
			ON dta.id_log_proceso = lpo.id_log_proceso
		WHERE dta.id_estado_resolucion_cuenta = 38
			AND dta.id_estado_resolucion_mp = 38
			AND trn.ChargebackStatus = 1
			AND dta.id_cuenta = @p_id_cuenta;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		PRINT 'Error buscando movimientos.';

		throw;
	END CATCH

	-- Asignar Log de Movimientos de Cuenta Virtual
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Para cada movimiento encontrado
		SELECT @i = min(id_detalle),
			@count = max(id_detalle)
		FROM @detalles;

		WHILE (@i <= @count)
		BEGIN
			-- Obtener el tipo de movimiento
			SELECT @tipo = das.tipo_movimiento
			FROM Configurations.dbo.Detalle_Analisis_De_Saldo das
			WHERE das.id_detalle = @i;

			-- Si es Transacción
			IF (@tipo = @tipo_transaccion)
				UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Detalle_Analisis_De_Saldo mov
							ON lmcv.id_log_proceso = mov.id_log_proceso
								AND lmcv.id_cuenta = mov.id_cuenta
								AND lmcv.monto_saldo_cuenta = mov.importe_movimiento
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE t_mov.codigo = 'MOV_CRED'
							AND t_ori.codigo IN (
								'ORIG_PROCESO',
								'ORIG_CORR_SALDO'
								)
							AND mov.id_detalle = @i
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
						ORDER BY lmcv.fecha_alta
						)
				WHERE id_detalle = @i;

			-- Si es Devolución
			IF (@tipo = @tipo_devolucion)
				UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Detalle_Analisis_De_Saldo mov
							ON lmcv.id_cuenta = mov.id_cuenta
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE lmcv.id_log_proceso IS NULL
							AND t_mov.codigo = 'MOV_DEB'
							AND t_ori.codigo IN (
								'ORIG_DEV',
								'ORIG_CORR_SALDO'
								)
							AND lmcv.monto_saldo_cuenta = mov.importe_movimiento
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND mov.id_detalle = @i
						ORDER BY lmcv.fecha_alta
						)
				WHERE id_detalle = @i;

			-- Si es Cashout
			IF (@tipo = @tipo_cashout)
				UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Detalle_Analisis_De_Saldo mov
							ON lmcv.id_cuenta = mov.id_cuenta
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE lmcv.id_log_proceso IS NULL
							AND t_mov.codigo = 'MOV_DEB'
							AND t_ori.codigo IN (
								'ORIG_CASHOUT',
								'ORIG_CORR_SALDO'
								)
							AND lmcv.monto_saldo_cuenta = mov.importe_movimiento
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND mov.id_detalle = @i
						ORDER BY lmcv.fecha_alta
						)
				WHERE id_detalle = @i;

			-- Si es Ajuste
			IF (@tipo = @tipo_ajuste)
				UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Detalle_Analisis_De_Saldo mov
							ON lmcv.id_cuenta = mov.id_cuenta
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE lmcv.id_log_proceso IS NULL
							AND t_mov.codigo = (
								CASE 
									WHEN mov.importe_movimiento > 0
										THEN 'MOV_CRED'
									ELSE 'MOV_DEB'
									END
								)
							AND t_ori.codigo IN (
								'ORIG_PROCESO',
								'ORIG_CORR_SALDO'
								)
							AND lmcv.monto_saldo_cuenta = mov.importe_movimiento
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND mov.id_detalle = @i
						ORDER BY lmcv.fecha_alta
						)
				WHERE id_detalle = @i;

			-- Si es Contracargo
			IF (@tipo = @tipo_contracargo)
				UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Detalle_Analisis_De_Saldo mov
							ON lmcv.id_cuenta = mov.id_cuenta
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE lmcv.id_log_proceso IS NULL
							AND t_mov.codigo = 'MOV_DEB'
							AND t_ori.codigo IN (
								'ORIG_CTCGO',
								'ORIG_CORR_SALDO'
								)
							AND lmcv.monto_saldo_cuenta = mov.importe_movimiento
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND mov.id_detalle = @i
						ORDER BY lmcv.fecha_alta
						)
				WHERE id_detalle = @i;

			SET @i += 1;
		END;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		PRINT 'Error buscando log de cuenta virtual.';

		throw;
	END CATCH

	-- Asignar Log de Movimientos de Cuenta Virtual para Ventas Liquidadas con el nuevo Liquidador
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Para cada movimiento encontrado
		SELECT @i = min(id_detalle),
			@count = max(id_detalle)
		FROM @detalles;

		INSERT INTO @temp (
			id_cuenta,
			id_log_proceso
			)
		SELECT DISTINCT das.id_cuenta,
			das.id_log_proceso
		FROM Configurations.dbo.Detalle_Analisis_De_Saldo das
		WHERE das.id_log_movimiento IS NULL
			AND das.id_detalle BETWEEN @i
				AND @count;

		SET @i = 1;

		SELECT @count = count(1)
		FROM @temp;

		WHILE (@i <= @count)
		BEGIN
			SELECT @id_cuenta = id_cuenta,
				@id_log_proceso = id_log_proceso
			FROM @temp
			WHERE i = @i;

			UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
			SET id_log_movimiento = (
					SELECT TOP 1 mov.id_log_movimiento
					FROM (
						SELECT das.id_cuenta,
							das.id_log_proceso,
							sum(das.importe_movimiento) AS importe_movimiento
						FROM Configurations.dbo.Detalle_Analisis_De_Saldo das
						WHERE das.tipo_movimiento = 'VEN'
							AND das.id_log_movimiento IS NULL
							AND das.id_cuenta = @id_cuenta
							AND das.id_log_proceso = @id_log_proceso
						GROUP BY das.id_cuenta,
							das.id_log_proceso
						) ven
					INNER JOIN (
						SELECT lmcv.id_cuenta,
							lmcv.id_log_proceso,
							lmcv.monto_saldo_cuenta AS importe_movimiento,
							lmcv.id_log_movimiento
						FROM Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Tipo t_mov
							ON lmcv.id_tipo_movimiento = t_mov.id_tipo
						INNER JOIN Configurations.dbo.Tipo t_ori
							ON lmcv.id_tipo_origen_movimiento = t_ori.id_tipo
						WHERE t_mov.codigo = 'MOV_CRED'
							AND t_ori.codigo IN (
								'ORIG_PROCESO',
								'ORIG_CORR_SALDO'
								)
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Detalle_Analisis_De_Saldo das
								WHERE das.id_log_movimiento = lmcv.id_log_movimiento
								)
						) mov
						ON ven.id_cuenta = mov.id_cuenta
							AND ven.id_log_proceso = mov.id_log_proceso
							AND ven.importe_movimiento = mov.importe_movimiento
					)
			WHERE id_cuenta = @id_cuenta
				AND id_log_proceso = @id_log_proceso;

			SET @i += 1;
		END;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		PRINT 'Error buscando log de cuenta virtual para ventas liquidadas con el nuevo liquidador.';

		throw;
	END CATCH

	-- No impactar en Saldos los movimientos ya impactados.
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Para cada movimiento encontrado
		SELECT @i = min(id_detalle),
			@count = max(id_detalle)
		FROM @detalles;

		UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo
		SET flag_impactar_en_saldo = 0
		WHERE id_log_movimiento IS NOT NULL
			AND id_detalle BETWEEN @i
				AND @count;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		PRINT 'Error actualizando el flag de impacto en Saldo.';

		throw;
	END CATCH

	RETURN 1;
END
