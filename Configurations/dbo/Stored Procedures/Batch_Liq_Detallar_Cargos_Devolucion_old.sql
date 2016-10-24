  
CREATE PROCEDURE dbo.Batch_Liq_Detallar_Cargos_Devolucion_old (  
 @Id CHAR(36)  
 ,@FeeAmount DECIMAL(12, 2)  
 ,@Usuario VARCHAR(20)  
 )  
AS  
DECLARE @tx_Id CHAR(36);  
DECLARE @tx_FeeAmount DECIMAL(12, 2);  
DECLARE @ret_code INT;  
  
BEGIN  
 SET NOCOUNT ON;  
  
 BEGIN TRY  
  -- Obtener ID y Cargo de la Transacción sobre la que se realiza la Devolución      
  SELECT @tx_Id = Id  
   ,@tx_FeeAmount = FeeAmount  
  FROM Transactions.dbo.transactions  
  WHERE Id = (  
    SELECT OriginalOperationId  
    FROM Transactions.dbo.transactions  
    WHERE Id = @Id  
    );  
  
  -- Insertar el detalle de Cargos de la Devolución basado en los Cargos de la Transacción      
  INSERT INTO Configurations.dbo.Cargos_Por_Transaccion (  
   id_cargo  
   ,id_transaccion  
   ,monto_calculado  
   ,valor_aplicado  
   ,id_tipo_aplicacion  
   ,fecha_alta  
   ,usuario_alta  
   ,version  
   )  
  SELECT id_cargo  
   ,@Id  
   ,monto_calculado * IIF(@tx_FeeAmount = 0, 0, (@FeeAmount * 100 / @tx_FeeAmount)) / 100  
   ,valor_aplicado  
   ,id_tipo_aplicacion  
   ,GETDATE()  
   ,@Usuario  
   ,0  
  FROM Configurations.dbo.Cargos_Por_Transaccion  
  WHERE id_transaccion = @tx_Id;  
  
  SET @ret_code = 1;  
 END TRY  
  
 BEGIN CATCH  
  SET @ret_code = 0;  
  
  PRINT ERROR_MESSAGE();  
 END CATCH  
  
 RETURN @ret_code;  
END