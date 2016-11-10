
CREATE PROCEDURE [dbo].[Batch_Fact_Actualizar_Procesados] (
	@fecha_finProceso DATETIME = NULL,
	@v_id_cuenta INT = NULL
	)

AS

SET NOCOUNT ON;

BEGIN
		
		UPDATE transactions.dbo.transactions
		SET BillingTimestamp = GETDATE(),
			BillingStatus = - 1,
			SyncStatus = 0
		WHERE LiquidationStatus = - 1
			AND LiquidationTimestamp IS NOT NULL
			AND BillingStatus <> - 1
			AND BillingTimestamp IS NULL
			AND CreateTimestamp <= @fecha_finProceso
			AND LocationIdentification=@v_id_cuenta
			AND LTRIM(RTRIM(OperationName)) IN (
				'Compra_offline',
				'Compra_online',
				'Devolucion')
		
RETURN 1;

END

