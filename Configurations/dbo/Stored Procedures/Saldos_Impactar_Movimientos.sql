  
CREATE PROCEDURE [dbo].[Saldos_Impactar_Movimientos]  
AS  
-- Constantes de tipo de movimientos  
DECLARE @tipo_transaccion CHAR(3) = 'VEN';  
DECLARE @tipo_devolucion CHAR(3) = 'DEV';  
DECLARE @tipo_cashout CHAR(3) = 'CSH';  
DECLARE @tipo_ajuste CHAR(3) = 'AJU';  
DECLARE @tipo_contracargo CHAR(3) = 'CCG';  
-- Variables  
DECLARE @id_tipo_origen_movimiento INT;  
DECLARE @id_tipo_mov_debito INT;  
DECLARE @id_tipo_mov_credito INT;  
DECLARE @i INT = 1;  
DECLARE @count INT;  
DECLARE @id_detalle INT;  
DECLARE @id_cuenta INT;  
DECLARE @tipo_movimiento CHAR(3);  
DECLARE @importe_movimiento DECIMAL(12, 2);  
DECLARE @id_log_proceso INT;  
DECLARE @monto_disponible DECIMAL(12, 2);  
DECLARE @validacion_disponible DECIMAL(12, 2);  
DECLARE @monto_saldo_en_cuenta DECIMAL(12, 2);  
DECLARE @validacion_saldo_en_cuenta DECIMAL(12, 2);  
DECLARE @monto_saldo_en_revision DECIMAL(12, 2);  
DECLARE @validacion_saldo_en_revision DECIMAL(12, 2);  
DECLARE @usuario_alta VARCHAR(20) = 'SP_ANALISIS_SALDOS';  
DECLARE @id_tipo_movimiento INT;  
DECLARE @flag_ok INT;  
  
BEGIN  
 SET NOCOUNT ON;  
  
  
    
 BEGIN TRY  
    
  BEGIN TRANSACTION;  
    
  Print 'Entroooooooooooooooooooooooooooooooooooooooooo'   
  
  TRUNCATE TABLE Configurations.[dbo].[Movimientos_Detalle];  
  
  SELECT @id_tipo_origen_movimiento = id_tipo  
  FROM Configurations.dbo.Tipo  
  WHERE codigo = 'ORIG_CORR_SALDO';  
  
  SELECT @id_tipo_mov_debito = id_tipo  
  FROM Configurations.dbo.Tipo  
  WHERE codigo = 'MOV_DEB';  
  
  SELECT @id_tipo_mov_credito = id_tipo  
  FROM Configurations.dbo.Tipo  
  WHERE codigo = 'MOV_CRED';  
/*  
  CREATE TABLE #Movimientos (  
   id_movimiento INT PRIMARY KEY identity(1, 1),  
   id_detalle INT  
   );  
*/  
  
  
  INSERT INTO Configurations.dbo.Movimientos_Detalle (id_detalle)  
  SELECT das.id_detalle  
  FROM Configurations.dbo.Detalle_Analisis_De_Saldo das  
  --WHERE das.id_cuenta in (7,3254)   
      WHERE das.flag_impactar_en_saldo = 1  
   AND (  
    das.impacto_en_saldo_ok <> 1  
    OR das.impacto_en_saldo_ok IS NULL  
    );  
  
  SELECT @count = count(1)  
  FROM Configurations.dbo.Movimientos_Detalle ;  
  
  WHILE (@i <= @count)  
  BEGIN  
   SELECT @id_detalle = das.id_detalle,  
    @id_cuenta = das.id_cuenta,  
    @tipo_movimiento = das.tipo_movimiento,  
    @importe_movimiento = das.importe_movimiento,  
    @id_log_proceso = das.id_log_proceso  
   FROM Configurations.dbo.Detalle_Analisis_De_Saldo das  
   INNER JOIN Configurations.dbo.Movimientos_Detalle  mov  
    ON das.id_detalle = mov.id_detalle  
   WHERE mov.id_movimiento = @i;  
  
  
   IF (@tipo_movimiento = @tipo_transaccion)  
   BEGIN  
    SET @monto_disponible = NULL;  
    SET @validacion_disponible = NULL;  
    SET @monto_saldo_en_cuenta = @importe_movimiento;  
    SET @validacion_saldo_en_cuenta = NULL;  
    SET @monto_saldo_en_revision = NULL;  
    SET @validacion_saldo_en_revision = NULL;  
    SET @id_tipo_movimiento = @id_tipo_mov_credito;  
   END;  
  
   IF (@tipo_movimiento = @tipo_devolucion)  
   BEGIN  
    SET @monto_disponible = @importe_movimiento;  
    SET @validacion_disponible = NULL;  
    SET @monto_saldo_en_cuenta = @importe_movimiento;  
    SET @validacion_saldo_en_cuenta = NULL;  
    SET @monto_saldo_en_revision = NULL;  
    SET @validacion_saldo_en_revision = NULL;  
    SET @id_tipo_movimiento = @id_tipo_mov_debito;  
   END;  
  
   IF (@tipo_movimiento = @tipo_cashout)  
   BEGIN  
    SET @monto_disponible = @importe_movimiento;  
    SET @validacion_disponible = NULL;  
    SET @monto_saldo_en_cuenta = @importe_movimiento;  
    SET @validacion_saldo_en_cuenta = NULL;  
    SET @monto_saldo_en_revision = NULL;  
    SET @validacion_saldo_en_revision = NULL;  
    SET @id_tipo_movimiento = @id_tipo_mov_debito;  
   END;  
  
   BEGIN TRY  
          
    EXECUTE @flag_ok = Configurations.dbo.Actualizar_Cuenta_Virtual   
        @monto_disponible,  
     @validacion_disponible,  
     @monto_saldo_en_cuenta,  
     @validacion_saldo_en_cuenta,  
     @monto_saldo_en_revision,  
     @validacion_saldo_en_revision,  
     @id_cuenta,  
     @usuario_alta,  
     @id_tipo_movimiento,  
     @id_tipo_origen_movimiento,  
     @id_log_proceso  
  
   END TRY  
  
   BEGIN CATCH  
       SET @flag_ok = 0;  
    SELECT 'Error al intentar impactar Saldo en la Cuenta' = @id_cuenta;  
   END CATCH;  
  
   UPDATE Configurations.dbo.Detalle_Analisis_De_Saldo  
   SET impacto_en_saldo_ok = (  
     CASE   
      WHEN @flag_ok = 1  
       THEN 1  
      ELSE 0  
      END  
     )  
   WHERE id_detalle = @id_detalle;  
  
   SET @i += 1;  
  END;  
  
  --DROP TABLE #Movimientos;  
  
  COMMIT TRANSACTION;  
 END TRY  
  
 BEGIN CATCH  
  IF (@@TRANCOUNT > 0)  
   ROLLBACK TRANSACTION;  
  
  throw;  
 END CATCH;  
  
 RETURN 1;  
END  
  
  