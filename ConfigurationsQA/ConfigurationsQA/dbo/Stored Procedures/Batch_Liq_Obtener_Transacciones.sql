
CREATE PROCEDURE [dbo].[Batch_Liq_Obtener_Transacciones]
AS
DECLARE @rows INT = 0;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		TRUNCATE TABLE Configurations.dbo.Liquidacion_Tmp;

		BEGIN TRANSACTION;

		INSERT INTO Configurations.dbo.Liquidacion_Tmp
		SELECT ROW_NUMBER() OVER (
				ORDER BY CreateTimestamp
				) AS I,
			mov.*
		FROM (
			-- Transacciones            
			SELECT trn.Id,
				trn.CreateTimestamp,
				trn.LocationIdentification,
				trn.ProductIdentification,
				trn.OperationName,
				trn.Amount,
				NULL AS FeeAmount,
				NULL AS TaxAmount,
				trn.CashoutTimestamp,
				trn.FilingDeadline,
				trn.PaymentTimestamp,
				trn.FacilitiesPayments,
				trn.LiquidationStatus,
				trn.LiquidationTimestamp,
				trn.PromotionIdentification,
				(
					SELECT LTRIM(RTRIM(tpo.codigo))
					FROM Configurations.dbo.Boton btn
					INNER JOIN Configurations.dbo.Tipo tpo
						ON btn.id_tipo_concepto_boton = tpo.id_tipo
					WHERE trn.ButtonId = btn.id_boton
						AND tpo.id_grupo_tipo = 12
						AND LTRIM(RTRIM(tpo.codigo)) IN (
							'CPTO_BTN_VTA',
							'CPTO_BTN_AJ_CTGO',
							'CPTO_BTN_VAL_MP'
							)
					) AS ButtonCode,
				0 AS Flag_Ok,
				trn.TransactionStatus,
				trn.BuyerAccountIdentification,
				trn.AdditionalData,
				trn.CredentialDocumentType,
				trn.CredentialDocumentNumber,
				trn.CredentialMask,
				trn.OriginalOperationId,
			    trn.Channel,  
			    NULL as ProviderTransactionID,  
			    NULL as SaleConcept,  
			    NULL as CredentialEmailAddress    
			FROM Transactions.dbo.Transactions trn
			INNER JOIN Configurations.dbo.Medio_De_Pago mdp
				ON trn.ProductIdentification = mdp.id_medio_pago
			INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp
				ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
			WHERE LTRIM(RTRIM(UPPER(trn.OperationName))) IN (
					'COMPRA_OFFLINE',
					'COMPRA_ONLINE'
					)
				AND trn.ResultCode = - 1
				AND trn.LiquidationTimestamp IS NULL
				AND (
					trn.LiquidationStatus IS NULL
					OR trn.LiquidationStatus BETWEEN 0
						AND 50
					)
				AND trn.TransactionStatus = 'TX_PROCESADA'
				AND mdp.flag_habilitado > 0
				AND (
					LTRIM(RTRIM(tmp.codigo)) <> 'EFECTIVO'
					OR (
						LTRIM(RTRIM(tmp.codigo)) = 'EFECTIVO'
						AND trn.PaymentTimestamp IS NOT NULL
						)
					)
			
			UNION ALL
			
			-- Devoluciones            
			SELECT trn.Id,
				trn.CreateTimestamp,
				trn.LocationIdentification,
				trn.ProductIdentification,
				trn.OperationName,
				trn.Amount,
				trn.FeeAmount,
				trn.TaxAmount,
				trn.CashoutTimestamp,
				trn.FilingDeadline,
				trn.PaymentTimestamp,
				trn.FacilitiesPayments,
				trn.LiquidationStatus,
				trn.LiquidationTimestamp,
				trn.PromotionIdentification,
				NULL AS ButtonCode,
				0 AS Flag_Ok,
				trn.TransactionStatus,
				trn.BuyerAccountIdentification,
				trn.AdditionalData,
				trn.CredentialDocumentType,
				trn.CredentialDocumentNumber,
				trn.CredentialMask,
				trn.OriginalOperationId,
			    trn.Channel,  
			    NULL as ProviderTransactionID,  
			    NULL as SaleConcept,  
			    NULL as CredentialEmailAddress    
			FROM Transactions.dbo.Transactions trn
			WHERE LTRIM(RTRIM(UPPER(trn.OperationName))) = 'DEVOLUCION'
				AND trn.ResultCode = - 1
				AND trn.LiquidationTimestamp IS NULL
				AND (
					trn.LiquidationStatus IS NULL
					OR trn.LiquidationStatus BETWEEN 0
						AND 50
					)
				AND trn.TransactionStatus IN (
					'TX_APROBADA',
					'TX_DISPONIBLE'
					)
				AND trn.FeeAmount IS NOT NULL
				AND trn.TaxAmount IS NOT NULL
			) mov
		WHERE (
				mov.ButtonCode IS NULL
				OR mov.ButtonCode <> 'CPTO_BTN_VAL_MP'
				);

		SET @rows = @@ROWCOUNT;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
	END CATCH

	RETURN @rows;
END

