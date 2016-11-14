
CREATE PROCEDURE [dbo].[Iniciar_Log_Proceso] (
	@id_proceso INT = NULL,
	@fecha_desde_proceso DATETIME = NULL,
	@fecha_hasta_proceso DATETIME = NULL,
	@usuario VARCHAR(20) = NULL
)            
AS

DECLARE @id_log_proceso INT = NULL;
DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

	IF (@id_proceso IS NULL)
		THROW 51000, 'Id Proceso Nulo', 1;

	IF (NOT EXISTS (SELECT 1 FROM [dbo].[Proceso] WHERE [id_proceso] = @id_proceso))
		THROW 51000, 'No existe Proceso con el Id indicado', 1;

	IF (@usuario IS NULL)
		THROW 51000, 'Usuario Nulo', 1;


	INSERT INTO [dbo].[Log_Proceso] (
		[id_proceso],
		[fecha_inicio_ejecucion],
		[fecha_desde_proceso],
		[fecha_hasta_proceso],
		[fecha_alta],
		[usuario_alta],
		[version]
	) VALUES (
		@id_proceso,
		GETDATE(),
		@fecha_desde_proceso,
		@fecha_hasta_proceso,
		GETDATE(),
		@usuario,
		0
	);

	SET @id_log_proceso = SCOPE_IDENTITY();

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE(), @id_log_proceso = NULL;
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN @id_log_proceso;




