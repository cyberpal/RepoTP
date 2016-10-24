 
CREATE PROCEDURE [dbo].[Batch_PreConcil_Preconciliar_Movimiento] (
	@usuario CHAR(20),
	@id_log_paso INT,
	@id_movimiento_decidir INT,
	@ProviderTransactionID VARCHAR(64),
	@fecha_presentacion DATETIME,
	@id_nivel_detalle_global INT,
	@id_log_proceso INT
	)
AS
DECLARE @nombre_sp VARCHAR(MAX);
DECLARE @msg VARCHAR(MAX);


SET NOCOUNT ON;

BEGIN TRY
   BEGIN TRANSACTION;

    SET @nombre_sp = OBJECT_NAME(@@PROCID);
    
    UPDATE Transactions.dbo.transactions
	SET PresentationTimestamp = @fecha_presentacion,
	    SyncStatus = 0
	WHERE ProviderTransactionID = @ProviderTransactionID;

	
	INSERT Configurations.dbo.PreConciliacion
	VALUES(@ProviderTransactionID, @id_log_paso, 1, 0, GETDATE(), @usuario, NULL, NULL, NULL, NULL, 0, @id_movimiento_decidir );  
	
   COMMIT TRANSACTION;
END TRY

BEGIN CATCH   
     
 IF(@@TRANCOUNT > 0)   
  ROLLBACK TRANSACTION;   
    
 SELECT @msg = ERROR_MESSAGE();   
 
 EXEC configurations.dbo.Batch_Log_Detalle 
			@id_nivel_detalle_global,
 			@id_log_proceso,
			@nombre_sp,
			1,
			@msg;
 
   
 THROW 51000   
  ,@msg   
  ,1;   
 
END CATCH; 

RETURN 1;
