
CREATE PROCEDURE [dbo].[Batch_Sincronizacion_Tx_OP]
AS
DECLARE @registros_afectados INT;
DECLARE @id_log_proceso INT;
DECLARE @msg VARCHAR(50);
DECLARE @id_proceso INT = 18;
DECLARE @id_nivel_detalle_global INT;
DECLARE @nombre_sp VARCHAR(50);
DECLARE @usuario VARCHAR(20) = 'bpbatch';
DECLARE @transactions_tmp TABLE (Id_tmp VARCHAR(36));

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	SET @nombre_sp = OBJECT_NAME(@@PROCID);

	-- Iniciar Log     
	EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso @id_proceso,
		NULL,
		NULL,
		@Usuario,
		@id_log_proceso = @id_log_proceso OUTPUT,
		@id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;

	-- Sincronizar Transacciones
	UPDATE OpTrn
	SET OpTrn.AvailableStatus = TxTrn.AvailableStatus,
		OpTrn.AvailableTimestamp = TxTrn.AvailableTimestamp,
		OpTrn.BillingStatus = TxTrn.BillingStatus,
		OpTrn.BillingTimestamp = TxTrn.BillingTimestamp,
		OpTrn.CashoutReleaseStatus = TxTrn.CashoutReleaseStatus,
		OpTrn.CashoutReleaseTimestamp = TxTrn.CashoutReleaseTimestamp,
		OpTrn.CashoutStatus = TxTrn.CashoutStatus,
		OpTrn.CashoutTimestamp = TxTrn.CashoutTimestamp,
		OpTrn.ChargebackStatus = TxTrn.ChargebackStatus,
		OpTrn.ChargebackTimestamp = TxTrn.ChargebackTimestamp,
		OpTrn.CouponStatus = TxTrn.CouponStatus,
		OpTrn.DocumentationTimestamp = TxTrn.DocumentationTimestamp,
		OpTrn.DocumentationURL = TxTrn.DocumentationURL,
		OpTrn.FeeAmount = TxTrn.FeeAmount,
		OpTrn.FeeAmountBuyer = TxTrn.FeeAmountBuyer,
		OpTrn.FilingDeadline = TxTrn.FilingDeadline,
		OpTrn.LiquidationStatus = TxTrn.LiquidationStatus,
		OpTrn.LiquidationTimestamp = TxTrn.LiquidationTimestamp,
		OpTrn.PaymentTimestamp = TxTrn.PaymentTimestamp,
		OpTrn.PresentationTimestamp = TxTrn.PresentationTimestamp,
		OpTrn.ReconciliationStatus = TxTrn.ReconciliationStatus,
		OpTrn.ReconciliationTimestamp = TxTrn.ReconciliationTimestamp,
		OpTrn.ReverseStatus = TxTrn.ReverseStatus,
		OpTrn.ReverseTimestamp = TxTrn.ReverseTimestamp,
		OpTrn.TaxAmount = TxTrn.TaxAmount,
		OpTrn.TaxAmountBuyer = TxTrn.TaxAmountBuyer,
		OpTrn.TransactionStatus = TxTrn.TransactionStatus
	OUTPUT deleted.Id
	INTO @transactions_tmp
	FROM Operations.dbo.transactions OpTrn
	INNER JOIN Transactions.dbo.transactions TxTrn
		ON OpTrn.Id = TxTrn.Id
	WHERE TxTrn.SyncStatus = 0;

	UPDATE TxTrn
	SET TxTrn.SyncStatus = 1,
		TxTrn.SyncTimestamp = GETDATE()
	FROM Transactions.dbo.transactions TxTrn
	INNER JOIN @transactions_tmp TmpTrn
		ON TxTrn.Id = TmpTrn.Id_tmp;

	SET @registros_afectados = @@ROWCOUNT;

	-- Completar Log de Proceso   
	EXEC configurations.dbo.Batch_Log_Finalizar_Proceso @id_log_proceso,
		@registros_afectados,
		@usuario;

	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;
