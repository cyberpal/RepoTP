CREATE PROCEDURE [dbo].[Batch_Liq_Main_old_dos] (@Usuario VARCHAR(20))          
AS          
DECLARE @id_log_proceso INT;          
DECLARE @tx_count INT;          
DECLARE @tx_i INT;          
DECLARE @Id CHAR(36);          
DECLARE @CreateTimestamp DATETIME;          
DECLARE @LocationIdentification INT;          
DECLARE @ProductIdentification INT;          
DECLARE @OperationName VARCHAR(128);          
DECLARE @Amount DECIMAL(12, 2);          
DECLARE @FeeAmount DECIMAL(12, 2);          
DECLARE @TaxAmount DECIMAL(12, 2);          
DECLARE @CashoutTimestamp DATETIME;          
DECLARE @FilingDeadline DATETIME;          
DECLARE @PaymentTimestamp DATETIME;          
DECLARE @FacilitiesPayments INT;          
DECLARE @LiquidationStatus INT;          
DECLARE @LiquidationTimestamp DATETIME;          
DECLARE @PromotionIdentification INT;          
DECLARE @ButtonCode VARCHAR(20);          
DECLARE @flag_ok INT;          
DECLARE @TransactionStatus VARCHAR(20);          
DECLARE @i_cta INT;          
DECLARE @count_cta INT;          
DECLARE @id_tipo_movimiento INT;          
DECLARE @id_tipo_origen_movimiento INT;          
DECLARE @saldo DECIMAL(12, 2);          
DECLARE @cantidad_compras INT;          
DECLARE @registros_afectados INT;          
DECLARE @i_control INT;          
DECLARE @count_control INT;          
DECLARE @Control TABLE (          
 i INT PRIMARY KEY IDENTITY(1, 1)          
 ,id_transaccion CHAR(36)          
 ,fecha_base_de_cashout DATE          
 ,fecha_de_cashout DATE          
 ,id_cuenta INT          
 ,id_codigo_operacion INT          
 ,importe DECIMAL(12, 2)          
 );          
DECLARE @id_transaccion CHAR(36);          
DECLARE @fecha_base_de_cashout DATE;          
DECLARE @fecha_de_cashout DATE;          
DECLARE @id_cuenta INT;          
DECLARE @id_codigo_operacion INT;          
DECLARE @importe DECIMAL(12, 2);          
          
BEGIN          
 SET NOCOUNT ON;          
          
 BEGIN TRY          
  -- Iniciar Log                      
  EXEC @id_log_proceso = Configurations.dbo.Iniciar_Log_Proceso 1          
   ,NULL          
   ,NULL          
   ,@Usuario;          
          
  -- Obtener Transacciones a Liquidar                      
  EXEC @tx_count = Configurations.dbo.Batch_Liq_Obtener_Transacciones_old;          
          
  -- Para cada transacción                      
  SET @tx_i = 1;          
          
  WHILE (@tx_i <= @tx_count)          
  BEGIN          
   -- Asumir error                      
   SET @flag_ok = 0;          
          
   -- Leer Transacción                      
   SELECT @Id = tmp.Id          
    ,@CreateTimestamp = tmp.CreateTimestamp          
    ,@LocationIdentification = tmp.LocationIdentification          
    ,@ProductIdentification = tmp.ProductIdentification          
    ,@OperationName = tmp.OperationName          
    ,@Amount = tmp.Amount          
    ,@FeeAmount = tmp.FeeAmount          
    ,@TaxAmount = tmp.TaxAmount          
    ,@CashoutTimestamp = tmp.CashoutTimestamp          
    ,@FilingDeadline = tmp.FilingDeadline          
    ,@PaymentTimestamp = tmp.PaymentTimestamp          
    ,@FacilitiesPayments = tmp.FacilitiesPayments          
    ,@LiquidationStatus = tmp.LiquidationStatus          
    ,@LiquidationTimestamp = tmp.LiquidationTimestamp          
    ,@PromotionIdentification = tmp.PromotionIdentification          
    ,@ButtonCode = tmp.ButtonCode          
   FROM Configurations.dbo.Liquidacion_Tmp tmp          
   WHERE tmp.i = @tx_i;          
          
   IF (@Id IS NOT NULL)          
   BEGIN          
    SET @flag_ok = 1;          
   END          
   ELSE          
    SET @flag_ok = 0;          
          
   -- Si no hay error y es una Compra, Acumular en Promociones                      
   IF (          
     @flag_ok = 1          
     AND UPPER(@OperationName) IN (          
      'COMPRA_OFFLINE'          
      ,'COMPRA_ONLINE'          
      )          
     AND @PromotionIdentification IS NOT NULL          
     )          
   BEGIN          
    EXEC @flag_ok = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Promociones_old @CreateTimestamp          
     ,@LocationIdentification          
     ,@Amount          
     ,@PromotionIdentification;          
          
    IF (@flag_ok = 0)          
    BEGIN          
PRINT 'id= ' + @Id;          
     PRINT 'Batch_Liq_Actualizar_Acumulador_Promociones - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
    END;          
   END;          
          
          
   --test      
   PRINT 'ID-TRANSACCION= ' + CAST(@Id AS CHAR(36));         
          
   -- Si no hay error Calcular Cargos                      
   IF (@flag_ok = 1)          
   BEGIN -- Si es una Compra                      
    IF (          
      UPPER(@OperationName) IN (          
       'COMPRA_OFFLINE'          
       ,'COMPRA_ONLINE'          
       )          
      )          
    BEGIN          
     EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Cargos_old @Id          
      ,@CreateTimestamp          
      ,@LocationIdentification          
      ,@ProductIdentification          
      ,@Amount          
      ,@PromotionIdentification          
      ,@FacilitiesPayments          
      ,@ButtonCode          
      ,@Usuario          
      ,@FeeAmount OUTPUT;          
    END;          
          
    IF (@flag_ok = 0)          
    BEGIN          
     PRINT 'id= ' + @Id;          
     PRINT 'Batch_Liq_Calcular_Cargos - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
    END;          
          
    -- Si es una Devolución                      
    IF (          
      UPPER(@OperationName) = 'DEVOLUCION'          
      AND @FeeAmount IS NOT NULL          
      )          
    BEGIN          
     EXEC @flag_ok = Configurations.dbo.Batch_Liq_Detallar_Cargos_Devolucion_old @Id          
      ,@FeeAmount          
      ,@Usuario;          
          
     IF (@flag_ok = 0)          
     BEGIN          
      PRINT 'id= ' + @Id;          
      PRINT 'Batch_Liq_Detallar_Cargos_Devolucion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
     END;          
    END;          
   END;          
          
   -- Si no hay error calcular Impuestos                      
   IF (@flag_ok = 1)          
   BEGIN          
    -- Si es una Compra                      
    IF (          
      UPPER(@OperationName) IN (          
       'COMPRA_OFFLINE'          
       ,'COMPRA_ONLINE'          
       )          
      )          
    BEGIN          
     EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Impuestos_old @Id          
      ,@CreateTimestamp          
      ,@LocationIdentification          
      ,@Usuario          
      ,@TaxAmount OUTPUT;          
          
     IF (@flag_ok = 0)          
     BEGIN          
      PRINT 'id= ' + @Id;          
      PRINT 'Batch_Liq_Calcular_Impuestos - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
     END;          
    END;          
          
    -- Si es una Devolución                      
    IF (          
      UPPER(@OperationName) = 'DEVOLUCION'          
      AND @TaxAmount IS NOT NULL          
      )          
    BEGIN          
     EXEC @flag_ok = Configurations.dbo.Batch_Liq_Detallar_Impuestos_Devolucion_old @Id          
      ,@TaxAmount          
      ,@Usuario;          
          
     IF (@flag_ok = 0)          
     BEGIN          
      PRINT 'id= ' + @Id;          
      PRINT 'Batch_Liq_Detallar_Impuestos_Devolucion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
     END;          
    END;          
   END;          
          
   -- Si no hay error y es Compra, calcular Fecha de Cashout                      
   IF (          
     @flag_ok = 1          
     AND UPPER(@OperationName) IN (          
      'COMPRA_OFFLINE'          
      ,'COMPRA_ONLINE'          
      )          
     )          
    BEGIN      
    EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Fecha_Cashout_old @CreateTimestamp          
     ,@LocationIdentification          
     ,@ProductIdentification          
     ,@FacilitiesPayments          
     ,@PaymentTimestamp          
     ,@CashoutTimestamp OUTPUT;          
           
     IF (@flag_ok = 0)          
     BEGIN          
      PRINT 'id= ' + @Id;          
      PRINT 'Batch_Liq_Calcular_Fecha_Cashout - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
     END;          
     END;      
          
   -- Si no hay error calcular Fecha Tope de Presentación                      
   IF (@flag_ok = 1)        
   BEGIN      
    EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Fecha_Tope_Presentacion_old @ProductIdentification             ,@CreateTimestamp          
     ,@FilingDeadline OUTPUT;          
           
  IF (@flag_ok = 0)          
  BEGIN          
   PRINT 'id= ' + @Id;          
   PRINT 'Batch_Liq_Calcular_Fecha_Tope_Presentacion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
  END;              
           
   END;      
           
          
   -- Si no hay error actualizar la Transaccion en la tabla temporal                      
   IF (@flag_ok = 1)          
   BEGIN          
    -- Si es una Compra                      
    IF (          
  UPPER(@OperationName) IN (          
       'COMPRA_OFFLINE'          
       ,'COMPRA_ONLINE'          
       )          
      )          
    BEGIN          
     UPDATE Configurations.dbo.Liquidacion_Tmp          
     SET FeeAmount = @FeeAmount          
      ,TaxAmount = @TaxAmount          
      ,CashoutTimestamp = @CashoutTimestamp          
      ,FilingDeadline = @FilingDeadline          
      ,Flag_Ok = 1          
     WHERE i = @tx_i;          
    END;          
          
    -- Si es una Devolución                      
    IF (UPPER(@OperationName) = 'DEVOLUCION')          
    BEGIN          
     UPDATE Configurations.dbo.Liquidacion_Tmp          
     SET FilingDeadline = @FilingDeadline          
      ,Flag_Ok = 1          
     WHERE i = @tx_i;          
    END;          
   END          
   ELSE IF (@flag_ok = 0)          
   BEGIN          
    -- Si hay error, marcar la Transaccion en la tabla temporal                      
    UPDATE Configurations.dbo.Liquidacion_Tmp          
    SET Flag_Ok = 0          
    WHERE i = @tx_i;          
   END;          
          
   -- Incrementar contador                      
   SET @tx_i += 1;          
  END          
          
  -- Calcular los Saldos agrupados por Cuenta                      
  TRUNCATE TABLE Configurations.dbo.Saldo_De_Cuenta_Tmp;          
          
  INSERT INTO Configurations.dbo.Saldo_De_Cuenta_Tmp          
  SELECT ROW_NUMBER() OVER (          
    ORDER BY T.LocationIdentification          
    ) AS I          
   ,T.LocationIdentification          
   ,T.Saldo          
   ,T.CantidadCompras          
  FROM (          
   SELECT tmp.LocationIdentification          
    ,SUM(IIF(UPPER(tmp.OperationName) = 'DEVOLUCION', 0, tmp.Amount - tmp.FeeAmount - tmp.TaxAmount)) AS Saldo          
    ,SUM(IIF(UPPER(tmp.OperationName) IN (          
       'COMPRA_OFFLINE'          
      ,'COMPRA_ONLINE'          
       ), 1, 0)) AS CantidadCompras          
   FROM Configurations.dbo.Liquidacion_Tmp tmp          
   WHERE tmp.Flag_Ok = 1          
   GROUP BY tmp.LocationIdentification          
   ) T;          
          
  -- Obtener ID de tipo de movimiento                      
  SELECT @id_tipo_movimiento = tpo.id_tipo          
  FROM dbo.Tipo tpo          
  WHERE tpo.codigo = 'MOV_CRED'          
   AND tpo.id_grupo_tipo = 16;          
          
  -- Obtener ID de origen de movimiento                      
  SELECT @id_tipo_origen_movimiento = tpo.id_tipo          
  FROM dbo.Tipo tpo          
  WHERE tpo.codigo = 'ORIG_PROCESO'          
   AND tpo.id_grupo_tipo = 17;          
          
  -- Para cada Cuenta                      
  SET @i_cta = 1;          
          
  SELECT @count_cta = COUNT(1)          
  FROM Configurations.dbo.Saldo_De_Cuenta_Tmp;          
          
  WHILE (@i_cta <= @count_cta)          
  BEGIN          
   -- Obtener Saldo y Cuenta                      
   SELECT @LocationIdentification = tmp.LocationIdentification          
    ,@saldo = tmp.Saldo        
    ,@cantidad_compras = tmp.CantidadCompras          
   FROM Configurations.dbo.Saldo_De_Cuenta_Tmp tmp          
   WHERE tmp.I = @i_cta;          
          
   BEGIN TRY          
    -- Iniciar Transacción por Cuenta                      
    BEGIN TRANSACTION;    
          
    --el saldo de cta virtual se actualiza solo si al menos existe una compra online/offline            
    IF (@cantidad_compras > 0)          
    BEGIN          
     -- Actualizar Cuenta Virtual                      
     BEGIN TRY          
               
      EXEC @flag_ok = Configurations.dbo.Actualizar_Cuenta_Virtual NULL          
       ,NULL          
       ,@saldo          
       ,NULL          
       ,NULL          
       ,NULL          
       ,@LocationIdentification          
       ,@Usuario          
       ,@id_tipo_movimiento          
       ,@id_tipo_origen_movimiento          
       ,@id_log_proceso;          
             
  IF (@flag_ok = 0)          
  BEGIN          
   PRINT 'id= ' + @Id;          
   PRINT 'Actualizar_Cuenta_Virtual - @flag_ok: ' + cast(@flag_ok AS CHAR(1));          
  END;                   
             
     END TRY          
          
     BEGIN CATCH          
      SET @flag_ok = 0;          
                
      --TEST          
      PRINT 'Actualizar Cuenta Virtual - @flag_ok= ' + CAST(@flag_ok AS VARCHAR(20));          
                
      PRINT ERROR_MESSAGE();          
                
     END CATCH          
    END;              
          
    -- Si no hay error                      
    --IF (@flag_ok = 1)              
    --si es devolucion(@cantidad_compras = 0)/actualizar cta.virtual sin errores      
    IF(@cantidad_compras = 0 OR @flag_ok = 1)      
    BEGIN          
              
     -- Obtener datos para el Control de Disponible                      
     DELETE @Control;          
          
     INSERT INTO @Control (          
      id_transaccion          
      ,fecha_base_de_cashout          
      ,fecha_de_cashout          
      ,id_cuenta          
      ,id_codigo_operacion          
      ,importe          
      )          
     SELECT ltp.Id          
      ,CAST(CASE           
        WHEN tmp.codigo = 'EFECTIVO'          
         THEN ltp.PaymentTimestamp          
        ELSE ltp.CreateTimestamp          
        END AS DATE)          
      ,CAST(ltp.CashoutTimestamp AS DATE)          
      ,ltp.LocationIdentification          
      ,cop.id_codigo_operacion          
      ,(ltp.Amount - ltp.FeeAmount - ltp.TaxAmount)          
     FROM Configurations.dbo.Liquidacion_Tmp ltp          
     INNER JOIN Configurations.dbo.Medio_De_Pago mdp ON ltp.ProductIdentification = mdp.id_medio_pago          
     INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago          
     INNER JOIN Configurations.dbo.Codigo_Operacion cop ON cop.codigo_operacion = (          
       CASE           
        WHEN UPPER(ltp.OperationName) = 'DEVOLUCION'          
         THEN 'DEV'          
        ELSE 'COM'          
        END          
       )          
     WHERE ltp.LocationIdentification = @LocationIdentification          
      --no se incluye devolucion                      
      AND UPPER(ltp.OperationName) IN (          
       'COMPRA_OFFLINE'          
       ,'COMPRA_ONLINE'          
       )          
          
     -- Para cada Control de Disponible                      
     SET @i_control = 1;          
          
     SELECT @count_control = COUNT(1)          
     FROM @Control;          
          
     WHILE (@i_control <= @count_control)          
     BEGIN          
      -- Obtener el registro de Control                      
      SELECT @id_transaccion = id_transaccion          
       ,@fecha_base_de_cashout = fecha_base_de_cashout          
       ,@fecha_de_cashout = fecha_de_cashout          
       ,@id_cuenta = id_cuenta          
       ,@id_codigo_operacion = id_codigo_operacion          
       ,@importe = importe          
      FROM @Control          
      WHERE i = @i_control;          
          
      -- Actualizar Tabla                      
      EXEC Configurations.dbo.Batch_Actualizar_Control_Liquidacion_Disponible_old @id_log_proceso          
       ,@id_transaccion          
       ,@fecha_base_de_cashout          
       ,@fecha_de_cashout          
       ,@id_cuenta          
       ,@id_codigo_operacion          
       ,@importe;          
          
      SET @i_control += 1;          
     END;                
          
     -- Actualizar transacciones                      
     UPDATE Transactions.dbo.transactions          
     SET Transactions.dbo.transactions.FeeAmount = tmp.FeeAmount          
      ,Transactions.dbo.transactions.TaxAmount = tmp.TaxAmount          
      ,Transactions.dbo.transactions.CashoutTimestamp = tmp.CashoutTimestamp          
      ,Transactions.dbo.transactions.FilingDeadline = tmp.FilingDeadline          
      ,Transactions.dbo.transactions.LiquidationStatus = (          
       CASE           
      WHEN tmp.Flag_Ok = 1          
         THEN - 1          
        ELSE tx.LiquidationStatus + 1          
        END          
       )          
      ,Transactions.dbo.transactions.LiquidationTimestamp = (          
       CASE           
        WHEN tmp.Flag_Ok = 1          
         THEN GETDATE()          
        ELSE NULL          
        END          
       )          
      ,Transactions.dbo.transactions.TransactionStatus = (          
       CASE           
        WHEN tmp.Flag_Ok = 1          
         AND UPPER(tmp.OperationName) IN (          
          'COMPRA_OFFLINE'          
          ,'COMPRA_ONLINE'          
          )          
         THEN 'TX_APROBADA'          
        WHEN tmp.Flag_Ok = 0          
         AND UPPER(tmp.OperationName) IN (          
          'COMPRA_OFFLINE'          
          ,'COMPRA_ONLINE'          
          )          
         THEN 'TX_PROCESADA'          
        WHEN UPPER(tmp.OperationName) = 'DEVOLUCION'          
         THEN tmp.TransactionStatus          
        END          
       )          
      ,Transactions.dbo.transactions.SyncStatus = 0          
     FROM Transactions.dbo.transactions tx          
     INNER JOIN Configurations.dbo.Liquidacion_Tmp tmp ON tx.Id = tmp.Id          
     WHERE tmp.LocationIdentification = @LocationIdentification;               
               
     -- Confirmar transacción por Cuenta                      
     COMMIT TRANSACTION;               
          
    END--IF              
    ELSE          
    BEGIN             
              
     --TEST               
     --PRINT '@flag_ok= ' + CAST(@flag_ok AS CHAR(1));               
     --PRINT '@@TRANCOUNT= ' + CAST(@@TRANCOUNT AS VARCHAR(20));          
               
   IF (@@TRANCOUNT > 0)          
    ROLLBACK TRANSACTION;               
    END;          
          
   END TRY          
          
   BEGIN CATCH             
    --test          
    PRINT 'ROLLBACK TRANSACTION (BATCH_LIQ_MAIN)'          
             
    -- Deshacer transacción por Cuenta                      
    ROLLBACK TRANSACTION;             
          
          
    -- Marcar la Transacciones en la tabla temporal                      
    UPDATE Configurations.dbo.Liquidacion_Tmp          
    SET Flag_Ok = 0          
    WHERE LocationIdentification = @LocationIdentification;          
          
    --Deshacer Cargos/Impuestos/Promociones                      
    EXEC Configurations.dbo.Batch_Liq_Rollback_old @LocationIdentification;          
   END CATCH          
          
   -- Siguiente Cuenta                      
   SET @i_cta += 1;          
  END          
          
  -- Contar registros afectados                      
  SELECT @registros_afectados = COUNT(1)          
  FROM Configurations.dbo.Liquidacion_Tmp          
  WHERE Flag_Ok = 1;          
          
  -- Completar Log de Proceso                      
  EXEC @flag_ok = Configurations.dbo.Finalizar_Log_Proceso @id_log_proceso          
   ,@registros_afectados          
   ,@Usuario;          
          
  --Test         
  --Deshacer Cargos/Impuestos/Promociones                      
  EXEC Configurations.dbo.Batch_Liq_Rollback_old;          
          
  RETURN 1;          
 END TRY          
          
 BEGIN CATCH          
         
  --Test                      
  --Deshacer Cargos/Impuestos/Promociones                      
  EXEC Configurations.dbo.Batch_Liq_Rollback_old;          
         
         
  IF (@@TRANCOUNT > 0)          
   ROLLBACK TRANSACTION;          
          
  RETURN 0;          
 END CATCH          
END
