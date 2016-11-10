
CREATE PROCEDURE [dbo].[Batch_Liq_PC_Actualizar_Correos] (
@id_cuenta INT,
@usuario VARCHAR(20)

)

AS

DECLARE @ret_code INT;

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
				
		UPDATE configurations.dbo.Promocion_Bonificacion_tmp 
		SET
		fecha_envio_mail=GETDATE(),
		flag_envio_mail=1,
		fecha_modificacion=GETDATE(),
		usuario_modificacion=@usuario
		WHERE id_cuenta=@id_cuenta
		AND fecha_envio_mail IS NULL
		AND flag_envio_mail=0 OR flag_envio_mail IS NULL
				
	
  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  PRINT ERROR_MESSAGE();

  SET @ret_code = 0;
 END CATCH

 RETURN @ret_code;
END

