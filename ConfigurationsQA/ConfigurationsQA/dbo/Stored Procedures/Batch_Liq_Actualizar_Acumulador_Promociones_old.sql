
CREATE PROCEDURE [dbo].[Batch_Liq_Actualizar_Acumulador_Promociones_old] (    
 @CreateTimestamp DATETIME    
 ,@LocationIdentification INT    
 ,@Amount DECIMAL(12, 2)    
 ,@PromotionIdentification INT    
 )    
AS    
DECLARE @ret_code INT;    
DECLARE @cantidad_tx INT = 1;    
    
BEGIN    
 SET NOCOUNT ON;    
    
 BEGIN TRY    
  MERGE Configurations.dbo.Acumulador_Promociones AS destino    
  USING (    
   SELECT rbn.id_promocion AS id_promocion    
    ,@CreateTimestamp AS fecha_transaccion    
    ,@LocationIdentification AS cuenta_transaccion    
    ,@Amount AS importe_total_tx    
    ,@cantidad_tx AS cantidad_tx    
   FROM Configurations.dbo.Regla_Bonificacion rbn    
   WHERE rbn.id_regla_bonificacion = @PromotionIdentification    
   ) AS origen(id_promocion, fecha_transaccion, cuenta_transaccion, importe_total_tx, cantidad_tx)    
   ON (    
     destino.id_promocion = origen.id_promocion    
     AND CAST(destino.fecha_transaccion AS DATE) = CAST(origen.fecha_transaccion AS DATE)    
     AND destino.cuenta_transaccion = origen.cuenta_transaccion    
     )    
  WHEN MATCHED    
   THEN    
    UPDATE    
    SET destino.importe_total_tx = destino.importe_total_tx + @Amount    
     ,destino.cantidad_tx = destino.cantidad_tx + 1    
  WHEN NOT MATCHED    
   THEN    
    INSERT (    
     id_promocion    
     ,fecha_transaccion    
     ,cuenta_transaccion    
     ,importe_total_tx    
     ,cantidad_tx    
     )    
    VALUES (    
     origen.id_promocion    
     ,origen.fecha_transaccion    
     ,origen.cuenta_transaccion    
     ,origen.importe_total_tx    
     ,origen.cantidad_tx    
     );    
    
  SET @ret_code = 1;    
 END TRY    
    
 BEGIN CATCH    
  PRINT ERROR_MESSAGE();    
    
  SET @ret_code = 0;    
 END CATCH    
    
 RETURN @ret_code;    
END  
