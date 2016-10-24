

CREATE PROCEDURE [dbo].[Actualizar_FlagFacturacion_Cuenta] (
	@vid_cuenta INT = NULL
)            
AS

DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

	UPDATE [dbo].[Cuenta]
	SET
		[flag_informado_a_facturacion] = 1
	WHERE [id_cuenta] = @vid_cuenta;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE();
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;
