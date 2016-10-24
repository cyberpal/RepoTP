    
CREATE PROCEDURE [dbo].[Batch_Actualizar_Control_Liquidacion_Disponible_old]    
 @id_log_proceso INT = NULL,    
 @id_transaccion CHAR(36) = NULL,    
 @fecha_base_de_cashout DATE = NULL,    
 @fecha_de_cashout DATE = NULL,    
 @id_cuenta INT = NULL,    
 @id_codigo_operacion INT = NULL,    
 @importe DECIMAL(12, 2) = NULL    
AS    
 DECLARE @ret INT = 1;    
 DECLARE @msg VARCHAR(MAX);    
BEGIN    
 SET NOCOUNT ON;    
    
 BEGIN TRY    
    
  MERGE    
   Configurations.dbo.Control_Liquidacion_Disponible AS destino    
   USING (    
    SELECT    
     @fecha_base_de_cashout,    
     @fecha_de_cashout,    
     @id_cuenta,    
     @id_codigo_operacion,    
     (CASE WHEN cop.signo = '-' THEN @importe * -1 ELSE @importe END) AS importe    
    FROM Configurations.dbo.Codigo_Operacion cop    
    WHERE cop.id_codigo_operacion = @id_codigo_operacion    
   ) AS origen (    
     fecha_base_de_cashout,    
     fecha_de_cashout,    
     id_cuenta,    
     id_codigo_operacion,    
     importe    
   )    
   ON (destino.fecha_base_de_cashout = origen.fecha_base_de_cashout    
   AND destino.fecha_de_cashout = origen.fecha_de_cashout    
   AND destino.id_cuenta = origen.id_cuenta    
   AND destino.id_codigo_operacion = origen.id_codigo_operacion)    
  WHEN MATCHED THEN    
   UPDATE SET destino.importe = destino.importe + origen.importe    
  WHEN NOT MATCHED THEN    
   INSERT (fecha_base_de_cashout,    
     fecha_de_cashout,    
     id_cuenta,    
     id_codigo_operacion,    
     importe)    
   VALUES (origen.fecha_base_de_cashout,    
     origen.fecha_de_cashout,    
     origen.id_cuenta,    
     origen.id_codigo_operacion,    
     origen.importe);    
    
  INSERT INTO Configurations.dbo.Log_Control_Liquidacion_Disponible (    
   id_log_proceso,    
   id_transaccion,    
   importe    
  ) VALUES (    
   @id_log_proceso,    
   @id_transaccion,    
   @importe    
  );    
    
 END TRY    
    
 BEGIN CATCH    
  SELECT @msg  = ERROR_MESSAGE();    
  THROW  51000, @msg , 1;    
 END CATCH;    
    
 RETURN @ret;    
END; 