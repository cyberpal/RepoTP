CREATE PROCEDURE [dbo].[Batch_VencMediosDePago_Main]             
(            
 @id_log_proceso INT = NULL,            
 @usuario VARCHAR(20) = NULL            
             
)                    
                
AS            
            
--Variables nuevas            
DECLARE @v_tarjetas_count INT;            
DECLARE @v_tarjetas_i INT;            
declare @v_id_estado_vencido INT;          
declare @Total_ConErrores INT;            
declare @Total_Procesados INT;              
            
--Variables flags            
DECLARE @Flag_OK_While INT;            
DECLARE @Flag_rangoBin_count INT;            
DECLARE @Flag_OK_LogPaso INT;             
            
--Variables de uso temporal            
DECLARE @v_id_medio_pago_cuenta INT;            
DECLARE @v_Cuenta INT;            
DECLARE @v_mascara_numero_tarjeta VARCHAR(20);            
DECLARE @v_fecha_vencimiento VARCHAR(6);            
DECLARE @v_id_medio_pago INT;            
DECLARE @v_id_tipo_medio_pago INT;            
DECLARE @v_codigo VARCHAR(20);            
DECLARE @v_flag_tipo_de_medio VARCHAR(20);            
            
DECLARE @id_paso_proceso INT = NULL;            
DECLARE @msg VARCHAR(255) = NULL;            
DECLARE @id_log_paso INT = NULL            
            
            
            
SET NOCOUNT ON;            
            
BEGIN TRANSACTION;            
            
BEGIN TRY            
            
  SET @id_paso_proceso = 1;            
            
  BEGIN            
  -- Inicio Log paso proceso             
            
  EXEC  @id_log_paso = Configurations.dbo.Iniciar_Log_Paso_Proceso             
        @id_log_proceso,            
        @id_paso_proceso,            
        'MP-ProcesarVencimientos',            
        NULL,            
        @usuario;            
  END            
            
  BEGIN            
                 
   --Inicio de carga de datos            
  EXEC  @v_tarjetas_count=Configurations.dbo.Batch_VencMediosDePago_ObtenerRegistros            
        @Usuario;            
  END         
        
COMMIT TRANSACTION        
            
END TRY                    
              
BEGIN CATCH              
              
  IF (@@TRANCOUNT > 0)              
  ROLLBACK TRANSACTION;              
  RETURN 0;            
                   
END CATCH            
                
            
IF (@v_tarjetas_count<>0)            
                          
                           
                             
 SET @v_tarjetas_i = 1;             
            
 SELECT @v_id_estado_vencido=id_estado             
 FROM Configurations.dbo.Estado where Codigo='MP_VENCIDO'            
                    
 WHILE (@v_tarjetas_i <= @v_tarjetas_count)              
                       
 BEGIN            
                       
  BEGIN TRY            
            
  BEGIN TRANSACTION            
            
  -- Asumir error            
  SET @Flag_OK_While = 0;            
            
  SELECT            
   @v_id_medio_pago_cuenta=tmp.id_medio_pago_cuenta,            
   @v_Cuenta = tmp.id_cuenta,              
   @v_mascara_numero_tarjeta = tmp.mascara_numero_tarjeta,              
   @v_fecha_vencimiento = tmp.fecha_vencimiento,            
   @v_codigo=tmp.codigo,            
   @v_flag_tipo_de_medio=tmp.flag_tipo_de_medio            
   FROM Configurations.dbo.VencMediosDePago_tmp tmp             
   WHERE tmp.i = @v_tarjetas_i;            
               
   BEGIN            
              
    --Obtener el rango BIN            
   EXEC  @Flag_rangoBin_count=Configurations.dbo.Batch_VencMediosDePago_ObtenerRangoBin            
      @v_id_medio_pago_cuenta,            
      @v_mascara_numero_tarjeta,            
      @usuario,            
      @v_id_estado_vencido,            
      @v_flag_tipo_de_medio;            
   END              
            
   COMMIT TRANSACTION;            
            
   END TRY            
            
   BEGIN CATCH            
                                     
     IF (@@TRANCOUNT > 0)              
     ROLLBACK TRANSACTION;              
     RETURN 0;            
                       
   END CATCH            
                       
   -- Incrementar contador            
   SET @v_tarjetas_i += 1;             
                       
 END       
            
            
            
BEGIN            
                       
  BEGIN TRY            
            
  BEGIN TRANSACTION           
            
  SELECT @Total_ConErrores=ROUND(SUM(trn.RegistrosConError),2),@Total_Procesados=ROUND(SUM(trn.RegistrosProcesados),2)          
  FROM(          
  SELECT count(tmp.id_cuenta) as RegistrosConError,          
  0 as RegistrosProcesados          
  FROM Configurations.dbo.VencMediosDePago_tmp tmp          
  WHERE tmp.flag_error_informado=1          
  UNION          
  SELECT 0 as RegistrosConError,          
  count(tmp.id_cuenta) as RegistrosProcesados          
  FROM Configurations.dbo.VencMediosDePago_tmp tmp          
  WHERE tmp.flag_error_informado=0          
  )trn          
            
  EXEC @Flag_OK_LogPaso=Configurations.dbo.Finalizar_Log_Paso_Proceso            
    @id_log_paso,            
    null,            
    1,            
    null,            
    @v_tarjetas_count,            
    NULL,            
    @Total_Procesados,            
    NULL,            
    @Total_ConErrores,            
   NULL,            
    null,            
    null,            
    @Usuario;            
              
            
  COMMIT TRANSACTION;            
            
  RETURN 1;            
            
  END TRY            
            
  BEGIN CATCH            
            
    IF (@@TRANCOUNT > 0)              
    ROLLBACK TRANSACTION;              
    RETURN 0;            
              
  END CATCH            
END 

------------------


