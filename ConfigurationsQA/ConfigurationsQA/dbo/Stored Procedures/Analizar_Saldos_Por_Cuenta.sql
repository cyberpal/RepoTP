
CREATE PROCEDURE [dbo].[Analizar_Saldos_Por_Cuenta] (@p_id_cuenta INT = NULL)
AS
/*
	ANALIZAR SALDOS POR CUENTA
	
	- Guarda un detalle de los movimientos (Ventas, Devoluciones, Cashout, Ajustes
	y Contracargos) de la Cuenta en la tabla Configurations.dbo.Analisis_Saldos_Tmp.
	
	- Busca un Log de Movimiento de Cuenta Virtual para cada ítem del detalle y lo
	agrega al registro correspondiente.
	
*/
-- Constantes de tipo de movimientos
DECLARE @tipo_transaccion CHAR(3) = 'VEN';
DECLARE @tipo_devolucion CHAR(3) = 'DEV';
DECLARE @tipo_cashout CHAR(3) = 'CSH';
DECLARE @tipo_ajuste CHAR(3) = 'AJU';
DECLARE @tipo_contracargo CHAR(3) = 'CCG';
-- Variables
DECLARE @i INT = 1;
DECLARE @count INT;
DECLARE @tipo CHAR(3);
DECLARE @temp TABLE (
	i INT PRIMARY KEY identity(1, 1),
	id_cuenta INT,
	id_log_proceso INT
	);
DECLARE @id_cuenta INT;
DECLARE @id_log_proceso INT;

BEGIN
	-- Verificar que se haya indicado una Cuenta existente
	IF (
			(
				SELECT count(1)
				FROM Configurations.dbo.Cuenta
				WHERE id_cuenta = @p_id_cuenta
				) <> 1
			)
	BEGIN
		throw 51000,
			'La Cuenta no existe.',
			1;
	END

	-- Vaciar tabla temporal
	--TRUNCATE TABLE Configurations.dbo.Analisis_Saldos_Tmp;

	-- Llenar tabla temporal con los movimientos
	BEGIN TRY
		BEGIN TRANSACTION;

		INSERT INTO Configurations.dbo.Analisis_Saldos_Tmp (
			i,
			tipo,
			id_char,
			id_int,
			id_cuenta,
			importe,
			fecha,
			id_log_proceso,
			fecha_inicio_ejecucion,
			fecha_fin_ejecucion,
			id_log_movimiento
			)
		SELECT ROW_NUMBER() OVER (
				ORDER BY m.tipo
				),
			m.*
		FROM (
			-- Ventas
			SELECT @tipo_transaccion AS tipo,
				transacciones.Id AS id_char,
				NULL AS id_int,
				transacciones.id_cuenta,
				transacciones.importe,
				transacciones.LiquidationTimestamp AS fecha,
				lpo.id_log_proceso,
				lpo.fecha_inicio_ejecucion,
				lpo.fecha_fin_ejecucion,
				NULL AS id_log_movimiento
			FROM (
				SELECT trn.Id,
					trn.LocationIdentification AS id_cuenta,
					(trn.Amount - trn.FeeAmount - trn.TaxAmount) AS importe,
					trn.LiquidationTimestamp
				FROM Transactions.dbo.transactions trn
				WHERE trn.ResultCode = - 1
					AND trn.OperationName <> 'devolucion'
					AND trn.LiquidationStatus = - 1
					AND (
						@p_id_cuenta IS NULL
						OR trn.LocationIdentification = @p_id_cuenta
						)
				) transacciones
			LEFT JOIN Configurations.dbo.Log_Proceso lpo
				ON transacciones.LiquidationTimestamp BETWEEN lpo.fecha_inicio_ejecucion
						AND lpo.fecha_fin_ejecucion
					AND lpo.id_proceso = 1
			
			UNION ALL
			
			-- Devoluciones
			SELECT @tipo_devolucion AS tipo,
				devoluciones.Id AS id_char,
				NULL AS id_int,
				devoluciones.id_cuenta,
				devoluciones.importe,
				devoluciones.CreateTimestamp AS fecha,
				NULL AS id_log_proceso,
				NULL AS fecha_inicio_ejecucion,
				NULL AS fecha_fin_ejecucion,
				NULL AS id_log_movimiento
			FROM (
				SELECT trn.Id,
					trn.LocationIdentification AS id_cuenta,
					((trn.Amount - isnull(trn.FeeAmount, 0) - isnull(trn.TaxAmount, 0)) * - 1) AS importe,
					trn.CreateTimestamp
				FROM Transactions.dbo.transactions trn
				WHERE trn.ResultCode = - 1
					AND trn.OperationName = 'devolucion'
					AND (
						@p_id_cuenta IS NULL
						OR trn.LocationIdentification = @p_id_cuenta
						)
				) devoluciones
			
			UNION ALL
			
			-- Cashout			
			SELECT @tipo_cashout AS tipo,
				NULL AS id_char,
				cashout.id_retiro_dinero AS id_int,
				cashout.id_cuenta,
				cashout.importe_cashout AS importe,
				cashout.fecha_alta AS fecha,
				NULL AS id_log_proceso,
				NULL AS fecha_inicio_ejecucion,
				NULL AS fecha_fin_ejecucion,
				NULL AS id_log_movimiento
			FROM (
				SELECT rdo.id_retiro_dinero,
					rdo.id_cuenta,
					(rdo.monto * - 1) AS importe_cashout,
					rdo.fecha_alta
				FROM Configurations.dbo.Retiro_Dinero rdo
				WHERE rdo.estado_transaccion = 'TX_APROBADA'
					AND (
						@p_id_cuenta IS NULL
						OR rdo.id_cuenta = @p_id_cuenta
						)
				) cashout
			
			UNION ALL
			
			-- Ajustes
			SELECT @tipo_ajuste AS tipo,
				NULL AS id_char,
				ajustes.id_ajuste AS id_int,
				ajustes.id_cuenta,
				ajustes.importe_ajuste AS importe,
				ajustes.fecha_alta AS fecha,
				NULL AS id_log_proceso,
				NULL AS fecha_inicio_ejecucion,
				NULL AS fecha_fin_ejecucion,
				NULL AS id_log_movimiento
			FROM (
				SELECT aje.id_ajuste,
					aje.id_cuenta,
					(
						CASE 
							WHEN cop.signo = '+'
								THEN aje.monto
							ELSE (aje.monto * - 1)
							END
						) AS importe_ajuste,
					aje.fecha_alta
				FROM Configurations.dbo.Ajuste aje
				INNER JOIN Configurations.dbo.Codigo_Operacion cop
					ON cop.id_codigo_operacion = aje.id_codigo_operacion
				WHERE @p_id_cuenta IS NULL
					OR aje.id_cuenta = @p_id_cuenta
				) ajustes
			
			UNION ALL
			
			-- Contracargos
			SELECT @tipo_contracargo AS tipo,
				contracargos.id_transaccion AS id_char,
				contracargos.id_disputa AS id_int,
				contracargos.id_cuenta,
				contracargos.importe_contracargo AS importe,
				contracargos.fecha_alta AS fecha,
				contracargos.id_log_proceso AS id_log_proceso,
				contracargos.fecha_inicio_ejecucion AS fecha_inicio_ejecucion,
				contracargos.fecha_fin_ejecucion AS fecha_fin_ejecucion,
				NULL AS id_log_movimiento
			FROM (
				SELECT dta.id_transaccion,
					dta.id_disputa,
					dta.id_cuenta,
					(trn.Amount * - 1) AS importe_contracargo,
					dta.fecha_resolucion_cuenta AS fecha_alta,
					lpo.id_log_proceso,
					lpo.fecha_inicio_ejecucion,
					lpo.fecha_fin_ejecucion
				FROM Configurations.dbo.Disputa dta
				INNER JOIN Transactions.dbo.transactions trn
					ON dta.id_transaccion = trn.Id
				LEFT JOIN Configurations.dbo.Log_Proceso lpo
					ON dta.id_log_proceso = lpo.id_log_proceso
				WHERE dta.id_estado_resolucion_cuenta = 38
					AND dta.id_estado_resolucion_mp = 38
					AND trn.ChargebackStatus = 1
					AND (
						@p_id_cuenta IS NULL
						OR dta.id_cuenta = @p_id_cuenta
						)
				) contracargos
			) m;

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
		SELECT @count = count(1)
		FROM Configurations.dbo.Analisis_Saldos_Tmp;

		WHILE (@i <= @count)
		BEGIN
			-- Obtener el tipo de movimiento
			SELECT @tipo = ast.tipo
			FROM Configurations.dbo.Analisis_Saldos_Tmp ast
			WHERE ast.i = @i;

			-- Si es Transacción
			IF (@tipo = @tipo_transaccion)
				UPDATE Configurations.dbo.Analisis_Saldos_Tmp
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Analisis_Saldos_Tmp trn
							ON lmcv.id_log_proceso = trn.id_log_proceso
								AND lmcv.id_cuenta = trn.id_cuenta
								AND lmcv.monto_saldo_cuenta = trn.importe
						WHERE trn.i = @i
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Analisis_Saldos_Tmp t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
						)
				WHERE i = @i;

			-- Si es Devolución
			IF (@tipo = @tipo_devolucion)
				UPDATE Configurations.dbo.Analisis_Saldos_Tmp
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Analisis_Saldos_Tmp trn
							ON lmcv.id_cuenta = trn.id_cuenta
						WHERE lmcv.id_log_proceso IS NULL
							AND lmcv.id_tipo_origen_movimiento = 60
							AND lmcv.monto_saldo_cuenta = trn.importe
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Analisis_Saldos_Tmp t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND trn.i = @i
						)
				WHERE i = @i;

			-- Si es Cashout
			IF (@tipo = @tipo_cashout)
				UPDATE Configurations.dbo.Analisis_Saldos_Tmp
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Analisis_Saldos_Tmp trn
							ON lmcv.id_cuenta = trn.id_cuenta
						WHERE lmcv.id_log_proceso IS NULL
							AND lmcv.id_tipo_origen_movimiento = 69
							AND lmcv.monto_saldo_cuenta = trn.importe
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Analisis_Saldos_Tmp t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND trn.i = @i
						)
				WHERE i = @i;

			-- Si es Contracargo
			IF (@tipo = @tipo_contracargo)
				UPDATE Configurations.dbo.Analisis_Saldos_Tmp
				SET id_log_movimiento = (
						SELECT TOP 1 lmcv.id_log_movimiento
						FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv
						INNER JOIN Configurations.dbo.Analisis_Saldos_Tmp trn
							ON lmcv.id_cuenta = trn.id_cuenta
						WHERE lmcv.id_tipo_movimiento = 58
							AND lmcv.id_tipo_origen_movimiento = 59
							AND lmcv.fecha_alta >= trn.fecha
							AND lmcv.monto_saldo_cuenta = trn.importe
							AND NOT EXISTS (
								SELECT 1
								FROM Configurations.dbo.Analisis_Saldos_Tmp t
								WHERE t.id_log_movimiento = lmcv.id_log_movimiento
								)
							AND trn.i = @i
						ORDER BY lmcv.fecha_alta
						)
				WHERE i = @i;

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

		INSERT INTO @temp (
			id_cuenta,
			id_log_proceso
			)
		SELECT DISTINCT ast.id_cuenta,
			ast.id_log_proceso
		FROM Configurations.dbo.Analisis_Saldos_Tmp ast
		WHERE ast.id_log_movimiento IS NULL;

		SET @i = 1;

		SELECT @count = count(1)
		FROM @temp;

		WHILE (@i <= @count)
		BEGIN
			SELECT @id_cuenta = id_cuenta,
				@id_log_proceso = id_log_proceso
			FROM @temp
			WHERE i = @i;

			UPDATE Configurations.dbo.Analisis_Saldos_Tmp
			SET id_log_movimiento = (
					SELECT TOP 1 mov.id_log_movimiento
					FROM (
						SELECT ast.id_cuenta,
							ast.id_log_proceso,
							sum(ast.importe) AS importe
						FROM Analisis_Saldos_Tmp ast
						WHERE ast.tipo = 'VEN'
							AND ast.id_log_movimiento IS NULL
							AND ast.id_cuenta = @id_cuenta
							AND ast.id_log_proceso = @id_log_proceso
						GROUP BY ast.id_cuenta,
							ast.id_log_proceso
						) ven
					INNER JOIN (
						SELECT lmcv.id_cuenta,
							lmcv.id_log_proceso,
							lmcv.monto_saldo_cuenta AS importe,
							lmcv.id_log_movimiento
						FROM Log_Movimiento_Cuenta_Virtual lmcv
						WHERE NOT EXISTS (
								SELECT 1
								FROM Analisis_Saldos_Tmp ast
								WHERE ast.id_log_movimiento = lmcv.id_log_movimiento
								)
						) mov
						ON ven.id_cuenta = mov.id_cuenta
							AND ven.id_log_proceso = mov.id_log_proceso
							AND ven.importe = mov.importe
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

	RETURN 1;
END

