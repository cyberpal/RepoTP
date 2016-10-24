
CREATE  PROCEDURE [dbo].[Batch_Generacion_Arch_Disp_ActualizarTxs] (          
	@cantidad_registros INT,
	@fecha_cashout DATE,
	@usuario VARCHAR(20)
)
AS 
    
	DECLARE @id_log_proceso INT;
	DECLARE @Msg VARCHAR(80);
	

BEGIN          
	
	SET NOCOUNT ON;          
	              
    BEGIN TRANSACTION 
	
	BEGIN TRY
	   
	   TRUNCATE TABLE Configurations.dbo.Disponible_control_txs_tmp;


       INSERT INTO Configurations.dbo.Disponible_control_txs_tmp
                   (Id, 
                    LocationIdentification,
                    CashoutTimestamp,
                    Amount)
       SELECT Id, 
              LocationIdentification,
              CashoutTimestamp,
	          Amount
       FROM Transactions.dbo.transactions
       WHERE CAST(CashoutTimestamp AS DATE) <= @fecha_cashout
             AND (CashoutReleaseStatus <> -1  
                  OR
                  CashoutReleaseStatus IS NULL)
			 AND liquidationstatus = - 1
			 AND AvailableTimestamp IS NULL
			 AND (
				   availablestatus <> - 1
				   OR 
				   availablestatus IS NULL
				  )
			 AND TransactionStatus = 'TX_APROBADA'
			 AND LocationIdentification IS NOT NULL;


       MERGE Transactions.dbo.transactions AS trg
       USING Configurations.dbo.Disponible_control_txs_tmp AS src 
       ON (trg.Id = src.Id)
       WHEN MATCHED THEN 
            UPDATE SET CashoutReleaseStatus = -1,
                       CashoutReleaseTimestamp = GETDATE(),
                       SyncStatus = 0;
       

	   SET @id_log_proceso = (SELECT MAX(id_log_proceso) 
	                          FROM log_proceso 
							  WHERE id_proceso = 14);


       EXEC configurations.dbo.Finalizar_Log_Proceso
	        @id_log_proceso,
			@cantidad_registros,
			@usuario;
	        
	     
	COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT @msg = ERROR_MESSAGE();

		THROW 51000,
			@Msg,
			1;
	END CATCH;

	RETURN 1;
END;