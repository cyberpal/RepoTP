
CREATE PROCEDURE [dbo].[Batch_Liq_Actualizar_Ajuste_Negativo] (
 @idCuenta INT
 ,@idMotivoAjuste INT
 ,@Monto DECIMAL(18, 2)
 ,@Usuario VARCHAR(20)
 )
AS
DECLARE @Msg VARCHAR(20);
DECLARE @v_idAjuste INT;
DECLARE @v_idMotivoAjuste INT;
DECLARE @v_codigoOperacion INT;
DECLARE @RetCode INT

BEGIN
 SET NOCOUNT ON;

 BEGIN TRANSACTION

 BEGIN TRY
  --Obtener el ID para tabla ajuste
  SET @v_idAjuste = (
    SELECT ISNULL(MAX(id_ajuste), 0) + 1
    FROM Configurations.dbo.Ajuste
    );
  --Obtener el codigo de operacion
  SET @v_codigoOperacion = (
    SELECT id_codigo_operacion AS q_codigoOperacion
    FROM Configurations.dbo.Codigo_Operacion
    WHERE codigo_operacion = 'AJN'
    );

  --Insertar el registro en la tabla
  INSERT INTO [dbo].[Ajuste] (
   [id_ajuste]
   ,[id_codigo_operacion]
   ,[id_cuenta]
   ,[id_motivo_ajuste]
   ,[monto]
   ,[estado_ajuste]
   ,[fecha_alta]
   ,[usuario_alta]
   ,[version]
   )
  VALUES (
   @v_idAjuste
   ,@v_codigoOperacion
   ,@idCuenta
   ,@idMotivoAjuste
   ,@Monto
   ,'Aprobado'
   ,GETDATE()
   ,@Usuario
   ,0
   );

  SET @RetCode = 1;
 END TRY

 BEGIN CATCH
  IF (@@TRANCOUNT > 0)
   ROLLBACK TRANSACTION;

  SET @RetCode = 0;

  RETURN @RetCode;
 END CATCH

 COMMIT TRANSACTION;

 RETURN @RetCode;
END
