
CREATE PROCEDURE [dbo].[Batch_Disponible_Actualizar_Saldo] (
	@id_cuenta INT,
	@importe DECIMAL(12, 2),
	@id_tipo_movimiento INT,
	@id_origen_movimiento INT,
	@usuario VARCHAR(20),
	@id_log_proceso INT,
	@fecha_hasta_proceso DATETIME
	)
AS
DECLARE @disponible_anterior DECIMAL(12, 2);
DECLARE @disponible_actual DECIMAL(12, 2);
DECLARE @ret INT;

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener Saldo Disponible antes de actualizar
		SELECT @disponible_anterior = isnull(cvl.disponible, 0)
		FROM Configurations.dbo.Cuenta_Virtual cvl
		WHERE cvl.id_cuenta = @id_cuenta;

		-- Actualizar Saldo Disponible
		EXEC @ret = Configurations.dbo.Actualizar_Cuenta_Virtual @importe,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			@id_cuenta,
			@usuario,
			@id_tipo_movimiento,
			@id_origen_movimiento,
			@id_log_proceso;

		IF (@ret <> 1)
			RETURN 0;

		-- Obtener Saldo Disponible luego de actualizar
		SELECT @disponible_actual = isnull(cvl.disponible, 0)
		FROM Configurations.dbo.Cuenta_Virtual cvl
		WHERE cvl.id_cuenta = @id_cuenta;

		-- Actualizar estado de procesamiento de la Cuenta
		UPDATE Configurations.dbo.Disponible_Por_Cuenta_Tmp
		SET disponible_anterior = @disponible_anterior,
			disponible_actual = @disponible_actual,
			flag_disponible_ok = (
				CASE 
					WHEN @disponible_anterior + @importe = @disponible_actual
						THEN 1
					ELSE 0
					END
				)
		WHERE id_cuenta = @id_cuenta;

		-- Actualizar las Transacciones de la Cuenta
		UPDATE Transactions.dbo.transactions
		SET AvailableTimestamp = getdate(),
			AvailableStatus = - 1,
			SyncStatus = 0,
			TransactionStatus = 'TX_DISPONIBLE'
		FROM Transactions.dbo.transactions trn
		INNER JOIN Configurations.dbo.Disponible_Detalle_Tmp tmp
			ON trn.Id = tmp.id_transaccion
		WHERE tmp.id_cuenta = @id_cuenta
			AND tmp.id_transaccion IS NOT NULL;

		-- Actualizar las Bonificaciones de la Cuenta
		UPDATE Configurations.dbo.Bonificacion
		SET flag_afectacion_disponible = 1,
			fecha_afectacion_disponible = getdate()
		FROM Configurations.dbo.Bonificacion bcn
		INNER JOIN Configurations.dbo.Disponible_Detalle_Tmp tmp
			ON bcn.id_bonificacion = tmp.id_bonificacion
		WHERE tmp.id_cuenta = @id_cuenta
			AND tmp.id_bonificacion IS NOT NULL;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		RETURN 0;
	END CATCH;

	RETURN 1;
END;
