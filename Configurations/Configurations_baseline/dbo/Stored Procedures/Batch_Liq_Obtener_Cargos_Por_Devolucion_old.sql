  
CREATE PROCEDURE dbo.Batch_Liq_Obtener_Cargos_Por_Devolucion_old (  
 @p_Id CHAR(36)  
 ,@p_Amount DECIMAL(12, 2)  
 ,@p_ret_code INT OUTPUT  
 ,@p_FeeAmount DECIMAL(12, 2) OUTPUT  
 ,@p_TaxAmount DECIMAL(12, 2) OUTPUT  
 )  
AS  
DECLARE @Amount DECIMAL(12, 2);  
DECLARE @FeeAmount DECIMAL(12, 2);  
DECLARE @TaxAmount DECIMAL(12, 2);  
DECLARE @RefundAmount DECIMAL(12, 2);  
DECLARE @FeeDisponible DECIMAL(12, 2);  
DECLARE @TaxDisponible DECIMAL(12, 2);  
  
BEGIN  
 SET NOCOUNT ON;  
  
 BEGIN TRY  
  -- Buscar la Transacción sobre la que se efectúa la Devolución      
  SELECT @Amount = Amount  
   ,@FeeAmount = FeeAmount  
   ,@TaxAmount = TaxAmount  
   ,@RefundAmount = ISNULL(RefundAmount, 0)  
  FROM Transactions.dbo.transactions  
  WHERE Id = @p_Id;  
  
  -- Si no se encuentra la Transacción o está incompleta      
  IF (  
    @Amount IS NULL  
    OR @FeeAmount IS NULL  
    OR @TaxAmount IS NULL  
    )  
  BEGIN  
   throw 51000  
    ,'No existe la Transacción o está incompleta.'  
    ,1;  
  END;  
  
  -- Si la Devolución supera el monto disponible para devolver      
  IF (@Amount - @RefundAmount < @p_Amount)  
  BEGIN  
   throw 51000  
    ,'El monto de la Devolución es mayor al permitido para la Transacción.'  
    ,1;  
  END;  
  
  -- Calcular el porcentaje de Cargos e Impuestos correspondiente a la Devolución      
  SET @p_FeeAmount = @FeeAmount * (@p_Amount * 100 / @Amount) / 100;  
  SET @p_TaxAmount = @TaxAmount * (@p_Amount * 100 / @Amount) / 100;  
  
  -- Si hubo devoluciones parciales, verificar diferencias por redondeo en Cargos e Impuestos      
  SELECT @FeeDisponible = @FeeAmount - sum(FeeAmount)  
   ,@TaxDisponible = @TaxAmount - sum(TaxAmount)  
  FROM Transactions.dbo.transactions  
  WHERE OriginalOperationId = @p_Id  
   AND ResultCode = - 1;  
  
  -- Si el Fee calculado supera al disponible      
  IF (@p_FeeAmount > @FeeDisponible)  
   SET @p_FeeAmount = @FeeDisponible;  
  
  -- Si el Tax calculado supera al disponible      
  IF (@p_TaxAmount > @TaxDisponible)  
   SET @p_TaxAmount = @TaxDisponible;  
  -- Proceso OK      
  SET @p_ret_code = 1;  
 END TRY  
  
 BEGIN CATCH  
  SET @p_FeeAmount = NULL;  
  SET @p_TaxAmount = NULL;  
  SET @p_ret_code = 2013;  
 END CATCH;  
  
 RETURN @p_ret_code;  
END