
CREATE PROCEDURE [dbo].[Batch_Liq_PC_Actualizar_Bonificaciones] (
@usuario VARCHAR(20)

)

AS
DECLARE @ret_code INT;

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
				
		UPDATE configurations.dbo.Bonificacion
		SET 
		fecha_envio_mail=GETDATE(),
		flag_envio_mail=1,
		fecha_modificacion=GETDATE(),
		usuario_modificacion=@usuario
		WHERE id_bonificacion in
		(
		SELECT id_bonificacion from Configurations.dbo.Promocion_Bonificacion_tmp tmp
		WHERE tmp.fecha_envio_mail is not null
		AND tmp.flag_envio_mail=1
		)

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  PRINT ERROR_MESSAGE();

  SET @ret_code = 0;
 END CATCH

 RETURN @ret_code;
END
