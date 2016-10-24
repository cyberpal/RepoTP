  
CREATE PROCEDURE [dbo].[Actualizar_procesados] (              
 @fecha_finProceso DATETIME = NULL,              
 @v_id_cuenta INT = NULL             
              
)                          
AS               

DECLARE @Msg VARCHAR(255); 
              
SET NOCOUNT ON;              
	           
BEGIN TRANSACTION              
              
BEGIN TRY              
   
BEGIN

 UPDATE transactions.dbo.transactions              
 SET              
  BillingTimestamp = GETDATE(),              
  BillingStatus = -1,              
  SyncStatus = 0               
 WHERE LiquidationStatus = -1              
  AND LiquidationTimestamp IS NOT NULL              
  AND BillingStatus <> -1              
  AND BillingTimestamp IS NULL              
  AND CreateTimestamp <= @fecha_finProceso             
  AND LocationIdentification = @v_id_cuenta; 


         
END              
      
         
END TRY              
BEGIN CATCH              
 ROLLBACK TRANSACTION               
 SELECT @Msg  = ERROR_MESSAGE();              
 THROW  51000, @Msg , 1;              
END CATCH              
              
COMMIT TRANSACTION;              
              
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;              
              
RETURN 1; 