
CREATE PROCEDURE [dbo].[Saldos_Resumir_Cuenta] (@p_id_cuenta INT = NULL)
AS
DECLARE @inserted TABLE (id_resumen INT);

BEGIN
	SET NOCOUNT ON;

	IF (@p_id_cuenta IS NULL)
		RETURN 0;

	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO Configurations.dbo.Resumen_Analisis_De_Saldo (
			id_cuenta,
			fecha_de_analisis,
			cantidad_ventas,
			importe_ventas,
			cantidad_devoluciones,
			importe_devoluciones,
			cantidad_cashout,
			importe_cashout,
			cantidad_ajustes,
			importe_ajustes,
			cantidad_contracargos,
			importe_contracargos,
			cantidad_total_movimientos,
			importe_total_movimientos,
			saldo_en_cuenta,
			diferencia_de_saldo,
			log_movimientos_cuenta_ok,
			flag_generar_detalle,
			detalle_generado_ok
			)
		OUTPUT inserted.id_resumen
		INTO @inserted
		SELECT mov.id_cuenta,
			getdate(),
			mov.cantidad_ventas,
			mov.importe_ventas,
			mov.cantidad_devoluciones,
			mov.importe_devoluciones,
			mov.cantidad_cashout,
			mov.importe_cashout,
			mov.cantidad_ajustes,
			mov.importe_ajustes,
			mov.cantidad_contracargos,
			mov.importe_contracargos,
			(mov.cantidad_ventas + mov.cantidad_devoluciones + mov.cantidad_cashout + mov.cantidad_ajustes + mov.cantidad_contracargos),
			(mov.importe_ventas + mov.importe_devoluciones + mov.importe_cashout + mov.importe_ajustes + mov.importe_contracargos),
			mov.saldo_en_cuenta,
			(mov.importe_ventas + mov.importe_devoluciones + mov.importe_cashout + mov.importe_ajustes + mov.importe_contracargos) - mov.saldo_en_cuenta,
			0,
			0,
			NULL
		FROM (
			SELECT cta.id_cuenta,
				isnull(vta.cantidad_ventas, 0) AS cantidad_ventas,
				isnull(vta.importe_ventas, 0) AS importe_ventas,
				isnull(dev.cantidad_devoluciones, 0) AS cantidad_devoluciones,
				isnull(dev.importe_devoluciones, 0) AS importe_devoluciones,
				isnull(cas.cantidad_cashout, 0) AS cantidad_cashout,
				isnull(cas.importe_cashout, 0) AS importe_cashout,
				isnull(aju.cantidad_ajustes, 0) AS cantidad_ajustes,
				isnull(aju.importe_ajustes, 0) AS importe_ajustes,
				isnull(cco.cantidad_contracargos, 0) AS cantidad_contracargos,
				isnull(cco.importe_contracargos, 0) AS importe_contracargos,
				isnull(sec.saldo_en_cuenta, 0) AS saldo_en_cuenta
			FROM Configurations.dbo.Cuenta cta
			-- ventas
			LEFT JOIN (
				SELECT trn.LocationIdentification AS id_cuenta,
					count(1) AS cantidad_ventas,
					sum(trn.Amount - trn.FeeAmount - trn.TaxAmount) AS importe_ventas
				FROM Transactions.dbo.transactions trn
				WHERE trn.ResultCode = - 1
					AND trn.LiquidationStatus = - 1
					AND trn.OperationName <> 'devolucion'
					AND trn.LocationIdentification = @p_id_cuenta
				GROUP BY trn.LocationIdentification
				) vta
				ON cta.id_cuenta = vta.id_cuenta
			-- devoluciones
			LEFT JOIN (
				SELECT trn.LocationIdentification AS id_cuenta,
					count(1) AS cantidad_devoluciones,
					sum(trn.Amount - isnull(trn.FeeAmount, 0) - isnull(trn.TaxAmount, 0)) * - 1 AS importe_devoluciones
				FROM Transactions.dbo.transactions trn
				WHERE trn.ResultCode = - 1
					AND trn.OperationName = 'devolucion'
					AND trn.LocationIdentification = @p_id_cuenta
				GROUP BY trn.LocationIdentification
				) dev
				ON cta.id_cuenta = dev.id_cuenta
			-- cashout
			LEFT JOIN (
				SELECT rdo.id_cuenta,
					count(1) AS cantidad_cashout,
					sum(rdo.monto) * - 1 AS importe_cashout
				FROM Configurations.dbo.Retiro_Dinero rdo
				WHERE rdo.estado_transaccion = 'TX_APROBADA'
					AND rdo.id_cuenta = @p_id_cuenta
				GROUP BY rdo.id_cuenta
				) cas
				ON cta.id_cuenta = cas.id_cuenta
			-- ajustes
			LEFT JOIN (
				SELECT aje.id_cuenta,
					count(1) AS cantidad_ajustes,
					sum(CASE 
							WHEN cop.signo = '+'
								THEN aje.monto
							ELSE (aje.monto * - 1)
							END) AS importe_ajustes
				FROM Configurations.dbo.Ajuste aje
				INNER JOIN Configurations.dbo.Codigo_Operacion cop
					ON cop.id_codigo_operacion = aje.id_codigo_operacion
				WHERE aje.id_cuenta = @p_id_cuenta
				GROUP BY aje.id_cuenta
				) aju
				ON cta.id_cuenta = aju.id_cuenta
			-- contracargos
			LEFT JOIN (
				SELECT dta.id_cuenta,
					count(1) AS cantidad_contracargos,
					sum(trn.Amount * - 1) AS importe_contracargos
				FROM Configurations.dbo.Disputa dta
				INNER JOIN Transactions.dbo.transactions trn
					ON dta.id_transaccion = trn.Id
				WHERE dta.id_estado_resolucion_cuenta = 38
					AND dta.id_estado_resolucion_mp = 38
					AND trn.ChargebackStatus = 1
					AND dta.id_cuenta = @p_id_cuenta
				GROUP BY dta.id_cuenta
				) cco
				ON cta.id_cuenta = cco.id_cuenta
			-- saldo en cuenta
			LEFT JOIN (
				SELECT cvt.id_cuenta,
					cvt.saldo_en_cuenta
				FROM Configurations.dbo.Cuenta_Virtual cvt
				WHERE cvt.id_cuenta = @p_id_cuenta
				) sec
				ON cta.id_cuenta = sec.id_cuenta
			WHERE cta.id_cuenta = @p_id_cuenta
			) mov;

		UPDATE Configurations.dbo.Resumen_Analisis_De_Saldo
		SET log_movimientos_cuenta_ok = (
				SELECT CASE 
						WHEN l.errores = 0
							THEN 1
						ELSE 0
						END
				FROM (
					SELECT count(1) AS errores
					FROM (
						SELECT lmcv.id_log_movimiento,
							lag(lmcv.disponible_actual, 1, 0) OVER (
								ORDER BY lmcv.fecha_alta
								) AS disponible_registro_anterior,
							lmcv.disponible_anterior,
							lmcv.disponible_actual,
							lag(lmcv.saldo_cuenta_actual, 1, 0) OVER (
								ORDER BY lmcv.fecha_alta
								) AS saldo_cuenta_registro_anterior,
							lmcv.saldo_cuenta_anterior,
							lmcv.saldo_cuenta_actual,
							lag(lmcv.saldo_revision_actual, 1, 0) OVER (
								ORDER BY lmcv.fecha_alta
								) AS saldo_revision_registro_anterior,
							lmcv.saldo_revision_anterior,
							lmcv.saldo_revision_actual
						FROM dbo.Log_Movimiento_Cuenta_Virtual lmcv
						WHERE lmcv.id_cuenta = @p_id_cuenta
						) logs
					WHERE logs.disponible_registro_anterior <> logs.disponible_anterior
						OR logs.saldo_cuenta_registro_anterior <> logs.saldo_cuenta_anterior
						OR logs.saldo_revision_registro_anterior <> logs.saldo_revision_anterior
					) l
				)
		WHERE id_resumen = (
				SELECT TOP 1 id_resumen
				FROM @inserted
				);

		UPDATE Configurations.dbo.Resumen_Analisis_De_Saldo
		SET flag_generar_detalle = (
				SELECT CASE 
						WHEN ras.diferencia_de_saldo <> 0
							OR ras.log_movimientos_cuenta_ok = 0
							THEN 1
						ELSE 0
						END
				FROM Configurations.dbo.Resumen_Analisis_De_Saldo ras
				WHERE ras.id_resumen = (
						SELECT TOP 1 id_resumen
						FROM @inserted
						)
				)
		WHERE id_resumen = (
				SELECT TOP 1 id_resumen
				FROM @inserted
				);

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		throw;
	END CATCH;

	RETURN 1;
END

