CREATE PROCEDURE [dbo].[Batch_VencMediosDePago_Actualizar_notificados] (                  
 @v_id_medio_pago_cuenta INT,      
 @usuario VARCHAR(20)             
                  
)                              
AS                   
    
DECLARE @CodRet INT    
                  
SET NOCOUNT ON;      
    
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;                  
                
BEGIN TRANSACTION                  
                  
BEGIN TRY                  
       
BEGIN    
  UPDATE Configurations.dbo.medio_pago_cuenta     
  SET     
  medio_notificado=1,    
  fecha_modificacion=getdate(),    
  usuario_modificacion=@usuario    
  WHERE id_medio_pago_cuenta=@v_id_medio_pago_cuenta;    
           
END                  
          
                  
COMMIT TRANSACTION;      
    
SET @CodRet=1;    
             
END TRY                  
    
BEGIN CATCH                  
     
 IF (@@TRANCOUNT > 0)    
                   
  ROLLBACK TRANSACTION;                   
  SET @CodRet=0;    
  RETURN @CodRet;         
    
END CATCH                  
                  
          
                  
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;                  
                  
RETURN @CodRet; 



