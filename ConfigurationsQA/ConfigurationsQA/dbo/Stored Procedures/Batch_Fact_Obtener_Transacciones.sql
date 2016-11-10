
CREATE PROCEDURE [dbo].[Batch_Fact_Obtener_Transacciones] (
	@usuario VARCHAR(20),
	@fecha_finProceso DATETIME = NULL,
	@cantidad_registros INT OUTPUT
	)
AS
SET NOCOUNT ON;

BEGIN
	INSERT INTO [dbo].[Procesar_Facturacion_tmp] (
		[id],
		[LocationIdentification],
		[LiquidationTimeStamp],
		[LiquidationStatus],
		[BillingStatus],
		[BillingTimestamp],
		[CreateTimestamp],
		[FeeAmount],
		[TaxAmount],
		[OperationName],

		[ProviderTransactionID],	
		[saleConcept],
		[CredentialEmailAddress],
		[amount]
		)
	SELECT tx.id,
		tx.LocationIdentification,
		tx.LiquidationTimestamp,
		tx.LiquidationStatus,
		tx.BillingStatus,
		tx.BillingTimestamp,
		tx.CreateTimestamp,
		tx.FeeAmount,
		tx.TaxAmount,
		tx.OperationName,

		tx.ProviderTransactionID ,		
		tx.SaleConcept ,
		tx.CredentialEmailAddress ,
		tx.Amount 

	FROM Transactions.dbo.transactions tx
	WHERE LTRIM(RTRIM(tx.OperationName)) IN (
			'Compra_offline',
			'Compra_online',
			'Devolucion'
			)
		AND tx.LiquidationTimestamp IS NOT NULL
		AND tx.LiquidationStatus = - 1
		AND (
			tx.BillingStatus = 0
			OR tx.BillingStatus IS NULL
			)
		AND tx.BillingTimestamp IS NULL
		AND tx.CreateTimestamp <= @fecha_finProceso;

	SET @cantidad_registros = @@ROWCOUNT;

	RETURN 1;
END;

