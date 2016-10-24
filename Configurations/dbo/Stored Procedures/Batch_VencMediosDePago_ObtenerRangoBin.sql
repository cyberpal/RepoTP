CREATE PROCEDURE [dbo].[Batch_VencMediosDePago_ObtenerRangoBin] (                
 @v_id_medio_pago_cuenta INT,                
 @v_mascara_numero_tarjeta VARCHAR(20),                
 @usuario VARCHAR(20),                
 @v_id_estado_vencido INT,                
 @v_tipo_de_medio VARCHAR(20)                
                
)                            
AS                
                
DECLARE @v_valor_flag INT;                
DECLARE @id_rango_bin INT;                
DECLARE @rango BIGINT;                
DECLARE @flag_controla_vencimiento BIT;                
DECLARE @v_count_ids INT;                
DECLARE @AcumuladoIds VARCHAR(max)                
                
                
SET NOCOUNT ON;                
                
BEGIN TRANSACTION;                
                
BEGIN TRY                
                 
  BEGIN                
                 
  SELECT TOP 1 @id_rango_bin = rb.id_rango_bin,                
               @rango = CAST(rb.bin_hasta AS BIGINT) - cast(rb.bin_desde AS BIGINT),                
               @flag_controla_vencimiento = rb.flag_controla_vencimiento                
      FROM Configurations.dbo.Rango_BIN rb                
      WHERE @v_mascara_numero_tarjeta BETWEEN rb.bin_desde AND rb.bin_hasta                
   AND rb.flag_controla_vencimiento IS NOT NULL                
   ORDER BY CAST(rb.bin_hasta AS BIGINT) - cast(rb.bin_desde AS BIGINT) ASC                
                
  SELECT @v_count_ids=count(1)                
      FROM Configurations.dbo.Rango_BIN rb                
      WHERE @v_mascara_numero_tarjeta BETWEEN rb.bin_desde AND rb.bin_hasta                
     AND rb.id_rango_bin <> @id_rango_bin                
     AND (CAST(rb.bin_hasta AS BIGINT) - cast(rb.bin_desde AS BIGINT)) = @rango                
     AND (rb.flag_controla_vencimiento <> @flag_controla_vencimiento OR rb.flag_controla_vencimiento IS NULL)                
          
  END                
          
          
  IF (@v_count_ids<>0)                
          
                   
  BEGIN                
                   
    SELECT @AcumuladoIds = COALESCE(@AcumuladoIds + '; ' + cast(rb.id_rango_bin as varchar(20)), cast(rb.id_rango_bin as varchar(20)))                
     FROM Configurations.dbo.Rango_BIN rb                
     WHERE @v_mascara_numero_tarjeta BETWEEN rb.bin_desde AND rb.bin_hasta                
     ORDER BY CAST(rb.bin_hasta AS BIGINT) - cast(rb.bin_desde AS BIGINT) ASC                
                
    UPDATE Configurations.dbo.VencMediosDePago_tmp                 
     SET                 
     flag_error_informado=1,                
     id_error_BIN=@AcumuladoIds                
     WHERE id_medio_pago_cuenta=@v_id_medio_pago_cuenta;                
          
  END        
                      
  ELSE                
           
  BEGIN        
           
   IF (@flag_controla_vencimiento=1 and @v_tipo_de_medio='Vencidos')                
                    
    BEGIN                
                                 
     UPDATE Configurations.dbo.VencMediosDePago_tmp                 
     SET                 
     flag_error_informado=0                
     WHERE id_medio_pago_cuenta=@v_id_medio_pago_cuenta;                
                        
                          
     UPDATE Configurations.dbo.medio_pago_cuenta                 
     SET                 
     id_estado_medio_pago=@v_id_estado_vencido,                
     fecha_modificacion=getdate(),                
     usuario_modificacion=@usuario                
     WHERE id_medio_pago_cuenta=@v_id_medio_pago_cuenta;                
                             
    END                
            
    ELSE        
               
       IF (@flag_controla_vencimiento=1 and @v_tipo_de_medio='AVencer')               
               
   BEGIN        
            
      UPDATE Configurations.dbo.VencMediosDePago_tmp                 
      SET                 
      flag_error_informado=0                
      WHERE id_medio_pago_cuenta=@v_id_medio_pago_cuenta;         
              
   END        
                       
   END            
           
        
END TRY                
        
                
BEGIN CATCH                
                
IF (@@TRANCOUNT > 0)          
  ROLLBACK TRANSACTION;        
  RETURN 0;        
                   
                
END CATCH;                
        
COMMIT TRANSACTION;                
              
RETURN 1; 


---------------------------------


