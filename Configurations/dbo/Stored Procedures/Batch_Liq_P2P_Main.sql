
CREATE PROCEDURE [dbo].Batch_Liq_P2P_Main (@Usuario VARCHAR(20))
AS
DECLARE @ret_code BIT = 1;
DECLARE @ret_code_sp BIT;
DECLARE @flag_af_disp BIT = 0;
DECLARE @id_proceso INT = 26;--confirmar valor con amb.productivo
DECLARE @id_log_proceso INT;
DECLARE @i INT = 1;
DECLARE @id_p2p INT;
DECLARE @id_cuenta_origen INT;
DECLARE @id_cuenta_destino INT;
DECLARE @id_tipo_mov_debito INT;
DECLARE @id_tipo_mov_credito INT;
DECLARE @id_tipo_origen_mov INT;
DECLARE @id_estado_p2p INT;
DECLARE @id_codigo_op INT;
DECLARE @registros_afectados INT = 0;
DECLARE @row_count INT;
DECLARE @plazo INT;
DECLARE @monto DECIMAL(12, 2);
DECLARE @saldo DECIMAL(12, 2);
DECLARE @id_transaccion VARCHAR(36);
DECLARE @paso VARCHAR(100);
DECLARE @err_msg VARCHAR(300);
DECLARE @fecha_alta DATETIME;
DECLARE @fecha_cashout DATETIME;
DECLARE @fecha_af_disp DATETIME = NULL;
DECLARE @fecha_proceso DATETIME = GETDATE();

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  -- Iniciar Log        
  EXEC @id_log_proceso = Configurations.dbo.Iniciar_Log_Proceso @id_proceso
   ,NULL
   ,NULL
   ,@Usuario;

  --Cargar parámetros para saldo de ctas./fecha de liberación
  SELECT @id_tipo_mov_debito = tpo1.id_tipo
   ,@id_tipo_mov_credito = tpo2.id_tipo
   ,@id_tipo_origen_mov = tpo3.id_tipo
   ,@plazo = pmo.valor
   ,@id_estado_p2p = eto.id_estado
   ,@id_codigo_op = con.id_codigo_operacion
  FROM Configurations.dbo.Tipo tpo1
  INNER JOIN Configurations.dbo.Tipo tpo2 ON tpo2.codigo = 'MOV_CRED'
  INNER JOIN Configurations.dbo.Tipo tpo3 ON tpo3.codigo = 'ORIG_PROCESO'
  INNER JOIN Configurations.dbo.Parametro pmo ON pmo.codigo = 'PLZO_PAGO_P2P'
  INNER JOIN Configurations.dbo.Estado eto ON eto.codigo = 'P2P_ENVIO_APROBADO'
  INNER JOIN Configurations.dbo.Codigo_Operacion con ON con.codigo_operacion = 'P2P' --confirmar código final
  WHERE tpo1.codigo = 'MOV_DEB'
   AND tpo1.id_grupo_tipo = 16
   AND tpo2.id_grupo_tipo = 16
   AND tpo3.id_grupo_tipo = 17

  --Cargar datos en tabla temp.
  TRUNCATE TABLE Configurations.dbo.LiquidacionP2P_Tmp;

  INSERT INTO Configurations.dbo.LiquidacionP2P_Tmp
  SELECT ROW_NUMBER() OVER (
    ORDER BY id_p2p
    ) AS I
   ,p2p.*
  FROM (
   --SELECT trn.*
   SELECT 
   trn.id_p2p
   ,trn.id_cuenta_origen
   ,trn.id_cuenta_destino
   ,trn.monto
   ,trn.id_transaccion
   ,trn.fecha_alta
   FROM Configurations.dbo.Transacciones_P2P trn
   INNER JOIN Configurations.dbo.Estado eto ON eto.id_estado = trn.id_estado_p2p
   WHERE trn.flag_afectacion_saldo = 0
    AND eto.codigo = 'P2P_ENVIO_PROCESADO'
   ) p2p;

  SET @row_count = @@ROWCOUNT;

  --Procesar por tx
  WHILE (@i <= @row_count)
  BEGIN
   BEGIN TRY
    BEGIN TRANSACTION;

    SELECT @id_p2p = id_p2p
     ,@id_cuenta_origen = id_cuenta_origen
     ,@id_cuenta_destino = id_cuenta_destino
     ,@monto = monto
     ,@id_transaccion = id_transaccion
     ,@fecha_alta = fecha_alta
    FROM Configurations.dbo.LiquidacionP2P_Tmp
    WHERE id = @i;

    --Actualizar saldo de la cta.origen    
    SET @saldo = @monto * - 1;
    EXEC @ret_code_sp = Configurations.dbo.Actualizar_Cuenta_Virtual NULL
     ,NULL
     ,@saldo --saldo en cta.
     ,NULL
     ,NULL
     ,NULL
     ,@id_cuenta_origen
     ,@Usuario
     ,@id_tipo_mov_debito	 	 
     ,@id_tipo_origen_mov
     ,@id_log_proceso;

    IF (@ret_code_sp) <> 1
    BEGIN
     SET @err_msg = CONCAT('Error procesando la Transacción P2P: ',@id_transaccion,
	 ' - Actualizar_Cuenta_Virtual (Saldo Cuenta Origen)');
     THROW 51000,@err_msg,1;
    END;

    --Actualizar saldo de la cta.destino     
    SET @saldo = @monto;
    EXEC @ret_code_sp = Configurations.dbo.Actualizar_Cuenta_Virtual NULL
     ,NULL
     ,@saldo --saldo en cta.
     ,NULL
     ,NULL
     ,NULL
     ,@id_cuenta_destino
     ,@Usuario
     ,@id_tipo_mov_credito
     ,@id_tipo_origen_mov
     ,@id_log_proceso;

    IF (@ret_code_sp) <> 1
    BEGIN
     SET @err_msg = CONCAT ('Error procesando la Transacción P2P: ',@id_transaccion,
	 ' - Actualizar_Cuenta_Virtual (Saldo Cuenta Destino)');

     THROW 51000,@err_msg,1;
    END;

    --Si no hay plazo de espera se disponibiliza automáticamente
    IF (@plazo = 0)
    BEGIN
     SET @saldo = @monto;
     EXEC @ret_code_sp = Configurations.dbo.Actualizar_Cuenta_Virtual @saldo --saldo disponible
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,NULL
      ,@id_cuenta_destino
      ,@Usuario
      ,@id_tipo_mov_credito
      ,@id_tipo_origen_mov
      ,@id_log_proceso;
    END;

    IF (@ret_code_sp) <> 1
    BEGIN
     SET @err_msg = CONCAT ('Error procesando la Transacción P2P: ',@id_transaccion,
	 ' - Actualizar_Cuenta_Virtual (Cuenta Destino - Disponibilizar)');

     THROW 51000,@err_msg,1;
    END;

    --Calcular Fecha de Liberación
    EXEC @ret_code_sp = Configurations.dbo.Batch_Liq_P2P_Calcular_Fecha_Cashout
     @plazo
     ,@fecha_alta
     ,@fecha_cashout OUTPUT;

    IF (@ret_code_sp) <> 1
    BEGIN
     SET @err_msg = CONCAT ('Error procesando la Transacción P2P: ',@id_transaccion,
	 ' - Batch_Liq_P2P_Calcular_Fecha_Cashout');

     THROW 51000,@err_msg,1;
    END;

    --Acumular para control cruzado - Control Liq.Disponible
    EXEC @ret_code_sp = Configurations.dbo.Batch_Actualizar_Control_Liquidacion_Disponible @id_log_proceso
     ,@id_p2p
     ,@fecha_alta
     ,@fecha_cashout
     ,@id_cuenta_destino
     ,@id_codigo_op
     ,@saldo;

    IF (@ret_code_sp) <> 1
    BEGIN
     SET @err_msg = CONCAT ('Error procesando la Transacción P2P: ',@id_transaccion,
	 ' - Batch_Actualizar_Control_Liquidacion_Disponible');

     THROW 51000,@err_msg,1;
    END;

    --Actualizar tabla Transacciones_P2P
    IF (@plazo = 0)
    BEGIN
     SET @flag_af_disp = 1;
     SET @fecha_af_disp = @fecha_proceso;
    END;

    UPDATE Configurations.dbo.Transacciones_P2P
    SET id_estado_p2p = @id_estado_p2p
     ,fecha_liberacion = @fecha_cashout
     ,flag_afectacion_saldo = 1
     ,fecha_afectacion_saldo = @fecha_proceso
     ,flag_afectacion_disponible = @flag_af_disp
     ,fecha_afectacion_disponible = @fecha_af_disp
    WHERE id_p2p = @id_p2p;

    SET @registros_afectados += 1;

    COMMIT TRANSACTION;
   END TRY

   BEGIN CATCH
    PRINT ERROR_MESSAGE();

    IF (@@TRANCOUNT > 0)
     ROLLBACK TRANSACTION;
   END CATCH;

   SET @i += 1;
  END;--while

  -- Finalizar Log
  EXEC @ret_code_sp = Configurations.dbo.Finalizar_Log_Proceso @id_log_proceso
   ,@registros_afectados
   ,@Usuario;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END
