
CREATE PROCEDURE [dbo].[Batch_Concil_Actualizar_Conciliacion_Manual]
AS
SET NOCOUNT ON;

DECLARE @msg VARCHAR(255) = NULL;

BEGIN TRANSACTION;

BEGIN TRY
	BEGIN
		UPDATE dbo.Conciliacion_Manual
		SET flag_procesado = 1
		WHERE id_transaccion IS NOT NULL
			AND flag_conciliado_manual = 1
	END
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION;

	SELECT @msg = ERROR_MESSAGE();

	THROW 51000,
		@msg,
		1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;
