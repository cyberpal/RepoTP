
CREATE PROCEDURE [dbo].[Iniciar_Log_Paso_Proceso] (
	@id_log_proceso INT = NULL,
	@id_paso_proceso INT = NULL,
	@descripcion VARCHAR(25) = NULL,
	@archivo_entrada VARCHAR(256) = NULL,
	@usuario VARCHAR(20) = NULL
)            
AS

DECLARE @id_log_paso INT = NULL;
DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

	IF (@id_log_proceso IS NULL)
		THROW 51000, 'Id Log Proceso Nulo', 1;

	IF (NOT EXISTS (SELECT 1 FROM [dbo].[Log_Proceso] WHERE [id_log_proceso] = @id_log_proceso))
		THROW 51000, 'No existe Log Proceso con el Id indicado', 1;

	IF (@id_paso_proceso IS NULL)
		THROW 51000, 'Id Paso Proceso Nulo', 1;

	IF (NOT EXISTS (SELECT 1 FROM [dbo].[Paso_Proceso] WHERE [id_paso_proceso] = @id_paso_proceso))
		THROW 51000, 'No existe Paso Proceso con el Id indicado', 1;

	IF (NOT EXISTS (
		SELECT 1
		FROM [dbo].[Paso_Proceso]
		WHERE [paso] = @id_paso_proceso
		  AND [id_proceso] = (
			SELECT [id_proceso]
			FROM [dbo].[Log_Proceso]
			WHERE [id_log_proceso] = @id_log_proceso)
	))
		THROW 51000, 'El Id Proceso no corresponde al Id Paso', 1;

	IF (@usuario IS NULL)
		THROW 51000, 'Usuario Nulo', 1;


	INSERT INTO [dbo].[Log_Paso_Proceso] (
		[id_log_proceso],
		[id_paso_proceso],
		[fecha_inicio_ejecucion],
		[descripcion],
		[archivo_entrada],
		[fecha_alta],
		[usuario_alta],
		[version]
	) VALUES (
		@id_log_proceso,
		@id_paso_proceso,
		GETDATE(),
		@descripcion,
		@archivo_entrada,
		GETDATE(),
		@usuario,
		0
	);

	SET @id_log_paso = SCOPE_IDENTITY();

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE(), @id_log_paso = NULL;
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN @id_log_paso;





