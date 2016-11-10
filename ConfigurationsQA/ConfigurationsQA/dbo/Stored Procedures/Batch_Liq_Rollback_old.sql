    
CREATE PROCEDURE [dbo].[Batch_Liq_Rollback_old](@LocIdentification INT = NULL)    
AS    
DECLARE @msg VARCHAR(300);    
DECLARE @tx_count INT;    
DECLARE @cantidad_tx INT;    
DECLARE @i INT;    
DECLARE @id_tx CHAR(36);    
DECLARE @LocationIdentification INT;    
DECLARE @PromotionIdentification INT;    
DECLARE @Amount DECIMAL(12,2);    
DECLARE @CreateTimestamp DATETIME;    
    
DECLARE @TXLiq TABLE (    
 id INT PRIMARY KEY IDENTITY(1, 1),    
 id_tx CHAR(36),    
 LocationIdentification INT,    
 PromotionIdentification INT,    
 Amount DECIMAL(12,2),    
 CreateTimestamp DATETIME    
 );    
    
SET NOCOUNT ON;    
    
BEGIN TRY    
    
   INSERT INTO @TXLiq (    
 id_tx,    
 LocationIdentification,    
 PromotionIdentification,    
 Amount,    
 CreateTimestamp    
    )    
   SELECT     
    trn.Id,    
 trn.LocationIdentification,    
 trn.PromotionIdentification,    
 trn.Amount,    
 trn.CreateTimestamp    
   FROM    
   Configurations.dbo.Liquidacion_Tmp trn    
   --WHERE trn.Flag_Ok = 0 AND (@LocIdentification IS NULL OR trn.LocationIdentification = @LocIdentification);    
   WHERE trn.Flag_Ok = 0;     
    
   BEGIN TRANSACTION;    
    
   SELECT @tx_count = COUNT(*)    
   FROM @TXLiq;    
    
   SET @i = 1;    
    
   WHILE (@i <= @tx_count)    
   BEGIN    
    SELECT     
  @id_tx = id_tx,    
  @LocationIdentification = LocationIdentification,    
  @PromotionIdentification = PromotionIdentification,    
  @Amount = Amount,    
  @CreateTimestamp = CreateTimestamp    
 FROM @TXLiq    
 WHERE id = @i;    
    
 --Eliminar TX - Cargos_Por_Transaccion    
 DELETE FROM Configurations.dbo.Cargos_Por_Transaccion    
 WHERE id_transaccion = @id_tx;    
    
 --Eliminar TX - Impuesto_Por_Transaccion    
 DELETE FROM Configurations.dbo.Impuesto_Por_Transaccion    
 WHERE id_transaccion = @id_tx;    
    
 --Eliminar/restar promociones - Acumulador_Promociones    
 MERGE Configurations.dbo.Acumulador_Promociones AS destino    
 USING (    
 SELECT rbn.id_promocion AS id_promocion    
 ,@CreateTimestamp AS fecha_transaccion    
 ,@LocationIdentification AS cuenta_transaccion    
 ,@Amount AS importe_total_tx    
     
 FROM Configurations.dbo.Regla_Bonificacion rbn    
 WHERE rbn.id_regla_bonificacion = @PromotionIdentification    
 ) AS origen(id_promocion, fecha_transaccion, cuenta_transaccion, importe_total_tx)    
 ON (    
  destino.id_promocion = origen.id_promocion    
  AND CAST(destino.fecha_transaccion AS DATE) = CAST(origen.fecha_transaccion AS DATE)    
  AND destino.cuenta_transaccion = origen.cuenta_transaccion    
  )    
 WHEN MATCHED AND (destino.cantidad_tx - 1 = 0)    
 THEN DELETE    
 WHEN MATCHED     
 THEN UPDATE SET destino.importe_total_tx = destino.importe_total_tx - @Amount    
     ,destino.cantidad_tx = destino.cantidad_tx - 1;    
    
 SET @i += 1;    
   END;    
    
   COMMIT TRANSACTION;    
END TRY    
    
BEGIN CATCH    
 ROLLBACK TRANSACTION;    
    
 SELECT @msg = ERROR_MESSAGE();    
    
 THROW 51000    
  ,@msg    
  ,1;    
END CATCH; 
