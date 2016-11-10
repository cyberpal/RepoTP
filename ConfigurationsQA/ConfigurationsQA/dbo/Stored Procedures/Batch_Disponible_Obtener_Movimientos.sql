
CREATE PROCEDURE [dbo].[Batch_Disponible_Obtener_Movimientos] (@fecha_hasta_proceso DATETIME)
AS
DECLARE @id_codigo_operacion_bonificacion INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		TRUNCATE TABLE Configurations.dbo.Disponible_Detalle_Tmp;

		-- Obtener Transacciones
		INSERT INTO Configurations.dbo.Disponible_Detalle_Tmp (
			id_cuenta,
			id_codigo_operacion,
			importe,
			fecha_cashout,
			id_transaccion
			)
		SELECT trn.LocationIdentification,
			cop.id_codigo_operacion,
			(isnull(trn.Amount, 0) - isnull(trn.FeeAmount, 0) - isnull(trn.TaxAmount, 0)) * iif(trn.OperationName = 'Devolucion', - 1, 1),
			cast(trn.CashoutTimestamp AS DATE),
			trn.Id
		FROM Transactions.dbo.transactions trn
		INNER JOIN Configurations.dbo.Codigo_Operacion cop
			ON cop.codigo_operacion = (
					CASE 
						WHEN trn.OperationName = 'Devolucion'
							THEN 'DEV'
						ELSE 'COM'
						END
					)
		WHERE trn.OperationName IN (
				'Compra_offline',
				'Compra_online',
				'Devolucion'
				)
			AND trn.LiquidationStatus = - 1
			AND (
				trn.AvailableStatus <> - 1
				OR trn.AvailableStatus IS NULL
				)
			AND trn.CashoutTimestamp <= @fecha_hasta_proceso
			AND trn.TransactionStatus = 'TX_APROBADA';

		-- Obtener Código de Operación de Bonificación
		SELECT @id_codigo_operacion_bonificacion = cop.id_codigo_operacion
		FROM Configurations.dbo.Codigo_Operacion cop
		WHERE cop.codigo_operacion = 'BON';

		-- Obtener Bonificaciones
		INSERT INTO Configurations.dbo.Disponible_Detalle_Tmp (
			id_cuenta,
			id_codigo_operacion,
			importe,
			fecha_cashout,
			id_bonificacion
			)
		SELECT bcn.id_cuenta,
			@id_codigo_operacion_bonificacion,
			bcn.importe_bonificacion,
			cast(bcn.fecha_liberacion AS DATE),
			bcn.id_bonificacion
		FROM Configurations.dbo.Bonificacion bcn
		WHERE bcn.flag_afectacion_disponible = 0
			AND bcn.fecha_liberacion <= @fecha_hasta_proceso;

		RETURN 1;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		RETURN 0;
	END CATCH;
END;

