  
CREATE PROCEDURE [dbo].[Actualizar_Cuenta_Virtual] (       
             @monto_disponible decimal (12,2) = NULL,      
             @validacion_disponible decimal (12,2) = NULL,      
             @monto_saldo_en_cuenta decimal (12,2) = NULL,      
             @validacion_saldo_en_cuenta decimal (12,2) = NULL,      
             @monto_saldo_en_revision decimal (12,2) = NULL,      
             @validacion_saldo_en_revision decimal (12,2) = NULL,      
             @id_cuenta int,      
             @usuario_alta varchar (20) = NULL,      
             @id_tipo_movimiento int,      
             @id_tipo_origen_movimiento int,      
             @id_log_proceso int = NULL      
)                  
AS       
DECLARE @RetCode    INT                
                   
SET NOCOUNT ON;      
      
--Ver como se comporta el sp con carga y concurrencia.      
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE      
      
declare @recupero_disponible decimal (12,2)      
declare @recupero_saldo_cuenta decimal (12,2)      
declare @recupero_saldo_revison decimal (12,2)      
declare @nuevo_disponible decimal (12,2)      
declare @nuevo_saldo_en_cuenta decimal (12,2)      
declare @nuevo_saldo_en_revision decimal (12,2)      
DECLARE @Msg        VARCHAR(255)      
      
BEGIN TRANSACTION      
      
BEGIN TRY      
      
-- Valido parametros ingresados. Deben existir para poder realizar la operacion.      
--@id_cuenta      
IF (@id_cuenta IS NULL)      
 BEGIN      
             SELECT  @RetCode = 401      
             ;THROW 51000, 'Id Cuenta Nulo', 1;      
 END      
--@id_tipo_movimiento       
IF (@id_tipo_movimiento IS NULL)      
 BEGIN      
             SELECT  @RetCode = 402      
             ;THROW 51000, 'Id Tipo Movimiento Nulo', 1;      
 END      
--@id_tipo_origen_movimiento       
IF (@id_tipo_origen_movimiento IS NULL)      
 BEGIN      
             SELECT  @RetCode = 403      
             ;THROW 51000, 'Id Tipo Origen Movimiento Nulo', 1;      
 END      
      
-- Al menos uno de estos parametros no debe ser nulo.      
--@id_log_proceso      
--@usuario_alta      
IF (@id_log_proceso IS NULL       
 AND @usuario_alta IS NULL)      
 BEGIN      
             SELECT  @RetCode = 404      
             ;THROW 51000, 'Debe informarse el parametro id_log_proceso o usuario_alta', 1;      
 END      
      
-- Al menos uno de estos parametros no debe ser nulo.      
--@monto_disponible      
--@monto_saldo_en_cuenta      
--@monto_saldo_en_revision      
IF (@monto_disponible IS NULL       
 AND @monto_saldo_en_cuenta IS NULL      
 AND @monto_saldo_en_revision IS NULL)      
 BEGIN      
             SELECT  @RetCode = 405      
             ;THROW 51000, 'Alguno de los montos debe ser distinto de nulo.', 1;      
 END      
      
-- Verifico que la cuenta exista. Si no existe salgo por       
IF (NOT EXISTS (SELECT 1 FROM Cuenta_Virtual WHERE id_cuenta = @id_cuenta))      
 BEGIN      
             SELECT  @RetCode = 400      
             --;THROW 51000, 'Cuenta Inexistente: ' + CAST(@id_cuenta AS VARCHAR(20)), 1;      
             --;THROW 51000, @Msg , 1;      
             
             
             SET @Msg = 'Cuenta Inexistente: ' + CAST(@id_cuenta AS VARCHAR(20));             
             ;THROW 51000, @Msg , 1;      
 END      
      
-- Recupero disponibles actuales para realizar las validaciones correspondientes.      
-- Ver si aca es necesario realizar la lectura con un hint de updlock, ya que la informacion se actualizara.      
SELECT  @recupero_disponible = disponible,      
        @recupero_saldo_cuenta = saldo_en_cuenta,      
        @recupero_saldo_revison = saldo_en_revision      
FROM    Cuenta_Virtual       
WHERE   id_cuenta = @id_cuenta;      
      
--Realizar las sumas una sola vez      
SET @nuevo_disponible = @recupero_disponible + ISNULL(@monto_disponible, 0);      
SET @nuevo_saldo_en_cuenta = @recupero_saldo_cuenta + ISNULL(@monto_saldo_en_cuenta,0);      
SET @nuevo_saldo_en_revision = @recupero_saldo_revison + ISNULL(@monto_saldo_en_revision, 0);      
      
-- Asumo que la version de SQL trabaja con short circuit, por esto pregunto primero si la validacion es distinto de nulo y luego por el calculo de la validacion      
IF (@validacion_disponible IS NOT NULL) AND (@nuevo_disponible < @validacion_disponible)      
    BEGIN      
             SELECT  @RetCode = 100      
             ;THROW 51000, 'Disponible Insuficiente', 1;      
    END       
      
-- Asumo que la version de SQL trabaja con short circuit, por esto pregunto primero si la validacion es distinto de nulo y luego por el calculo de la validacion      
IF (@validacion_saldo_en_cuenta IS NOT NULL) AND (@nuevo_saldo_en_cuenta < @validacion_saldo_en_cuenta)      
    BEGIN      
             SELECT  @RetCode = 200      
             ;THROW 51000, 'Saldo En Cuenta Insuficiente', 1;      
    END       
      
-- Asumo que la version de SQL trabaja con short circuit, por esto pregunto primero si la validacion es distinto de nulo y luego por el calculo de la validacion      
IF (@validacion_saldo_en_revision IS NOT NULL) AND (@nuevo_saldo_en_revision < @validacion_saldo_en_revision)      
    BEGIN      
             SELECT  @RetCode = 300      
             ;THROW 51000, 'Saldo En Revision Insuficiente', 1;      
    END       
      
--Ojo aca verificar como se deben actualizar estos disponibles.      
UPDATE  Cuenta_Virtual      
SET     disponible = disponible + ISNULL(@monto_disponible, 0) ,      
        saldo_en_cuenta = saldo_en_cuenta + ISNULL(@monto_saldo_en_cuenta,0) ,      
        saldo_en_revision = saldo_en_revision + ISNULL(@monto_saldo_en_revision, 0),  
  fecha_modificacion = GETDATE()  
WHERE id_cuenta = @id_cuenta;      
      
--Debo loguear en la tabla esta actualizacion.      
INSERT INTO [dbo].[Log_Movimiento_Cuenta_Virtual]      
           ([id_tipo_movimiento]      
           ,[id_tipo_origen_movimiento]      
           ,[id_log_proceso]      
           ,[id_cuenta]      
           ,[monto_disponible]      
           ,[disponible_anterior]      
           ,[disponible_actual]      
           ,[saldo_cuenta_anterior]      
           ,[saldo_cuenta_actual]      
           ,[saldo_revision_anterior]      
           ,[saldo_revision_actual]      
           ,[fecha_alta]      
           ,[usuario_alta]      
           ,[fecha_modificacion]      
           ,[usuario_modificacion]      
           ,[fecha_baja]      
           ,[usuario_baja]      
           ,[version]      
           ,[monto_saldo_cuenta]      
           ,[monto_revision])      
     VALUES      
           (@id_tipo_movimiento      
           ,@id_tipo_origen_movimiento      
           ,@id_log_proceso      
           ,@id_cuenta      
           ,@monto_disponible      
           ,@recupero_disponible      
           ,@nuevo_disponible      
           ,@recupero_saldo_cuenta      
           ,@nuevo_saldo_en_cuenta      
           ,@recupero_saldo_revison      
           ,@nuevo_saldo_en_revision      
           ,GETDATE()      
           ,@usuario_alta      
           ,NULL      
           ,NULL      
           ,NULL      
           ,NULL      
           ,0      
           ,@monto_saldo_en_cuenta      
           ,@monto_saldo_en_revision);      
      
END TRY      
BEGIN CATCH      
       ROLLBACK TRANSACTION       
       SELECT @Msg  = ERROR_MESSAGE()      
       ;THROW  51000, @Msg , 1;             
           
END CATCH      
      
COMMIT TRANSACTION       
      
SET TRANSACTION ISOLATION LEVEL READ COMMITTED      
      
RETURN 1
