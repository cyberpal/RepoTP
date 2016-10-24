

CREATE PROCEDURE [dbo].[Finalizar_Log_Proceso] (
	@id_log_proceso INT = NULL,
	@registros_afectados INT = NULL,
	@usuario VARCHAR(20) = NULL
)            
AS

DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

	IF (@id_log_proceso IS NULL)
		THROW 51000, 'Id Log Proceso Nulo', 1;

	IF (NOT EXISTS (SELECT 1 FROM [dbo].[Log_Proceso] WHERE [id_log_proceso] = @id_log_proceso))
		THROW 51000, 'No existe Log Proceso con el Id indicado', 1;

	IF (@usuario IS NULL)
		THROW 51000, 'Usuario Nulo', 1;

	UPDATE [dbo].[Log_Proceso]
	SET
		[fecha_fin_ejecucion] = GETDATE(),
		[registros_afectados] = @registros_afectados,
		[fecha_modificacion] = GETDATE(),
		[usuario_modificacion] = @usuario
	WHERE [id_log_proceso] = @id_log_proceso;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE();
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;
