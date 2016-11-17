
CREATE PROCEDURE Batch_Liq_Actualizar_Saldo_En_Cuenta_old (  
 @LocationIdentification INT = NULL,  
 @Amount DECIMAL(12,2) = 0,  
 @FeeAmount DECIMAL(12,2) = 0,  
 @TaxAmount DECIMAL(12,2) = 0,  
 @id_log_proceso INT = NULL,  
 @usuario VARCHAR(20)  
)  
AS  
 DECLARE @id_tipo_movimiento INT;  
 DECLARE @id_tipo_origen_movimiento INT;  
 DECLARE @monto_saldo_en_cuenta DECIMAL(12,2) = 0;  
 DECLARE @ret_code_cv INT;  
 DECLARE @msg VARCHAR(MAX);  
BEGIN  
 SET NOCOUNT ON;  
   
 BEGIN TRANSACTION;  
   
 BEGIN TRY  
  SELECT @id_tipo_movimiento = tpo.id_tipo  
  FROM dbo.Tipo tpo  
  WHERE tpo.codigo = 'MOV_CRED'  
    AND tpo.id_grupo_tipo = 16;  
  
  SELECT @id_tipo_origen_movimiento = tpo.id_tipo  
  FROM dbo.Tipo tpo  
  WHERE tpo.codigo = 'ORIG_PROCESO'  
    AND tpo.id_grupo_tipo = 17;  
    
  IF (@LocationIdentification IS NULL)  
   THROW 51000, 'Id Cuenta Nulo', 1;  
    
  IF (@id_log_proceso IS NULL)  
   THROW 51000, 'Id Log Proceso Nulo', 1;  
  
  SET @monto_saldo_en_cuenta = @Amount - @FeeAmount - @TaxAmount;  
    
  EXECUTE @ret_code_cv =   
   Configurations.dbo.Actualizar_Cuenta_Virtual  
    NULL,  
    NULL,  
    @monto_saldo_en_cuenta,  
    NULL,  
    NULL,  
    NULL,  
    @LocationIdentification,  
    @usuario,  
    @id_tipo_movimiento,  
    @id_tipo_origen_movimiento,  
    @id_log_proceso;  
          
  IF (@ret_code_cv <> 1)          
   THROW 51000, 'El proceso actualizacion de Saldo en Cuenta finalizado con error.', 1;  
  
 END TRY  
   
 BEGIN CATCH  
  ROLLBACK TRANSACTION;  
  SELECT @msg  = ERROR_MESSAGE();  
  THROW  51000, @Msg , 1;  
 END CATCH  
   
 COMMIT TRANSACTION;  
   
 RETURN 0;  
END  
