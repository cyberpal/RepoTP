
CREATE PROCEDURE [dbo].[Batch_Log_Iniciar_Proceso] (
	@id_proceso INT = NULL,
	@fecha_desde_proceso DATETIME = NULL,
	@fecha_hasta_proceso DATETIME = NULL,
	@usuario VARCHAR(20) = NULL,
	@id_log_proceso INT OUTPUT,
	@id_nivel_detalle_global INT OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@id_proceso IS NULL)
	BEGIN
		THROW 51000,
			'Id Proceso Nulo',
			1;
	END;

	IF (
			NOT EXISTS (
				SELECT 1
				FROM Configurations.dbo.Proceso
				WHERE id_proceso = @id_proceso
				)
			)
	BEGIN
		THROW 51000,
			'No existe Proceso con el Id indicado',
			1;
	END;

	IF (@usuario IS NULL)
	BEGIN
		THROW 51000,
			'Usuario Nulo',
			1;
	END;

	BEGIN TRANSACTION;

	SELECT @id_nivel_detalle_global = id_nivel_detalle_lp
	FROM Configurations.dbo.Configuracion_Log_Proceso
	WHERE id_proceso = @id_proceso;

	INSERT INTO Configurations.dbo.Log_Proceso (
		id_proceso,
		fecha_inicio_ejecucion,
		fecha_desde_proceso,
		fecha_hasta_proceso,
		fecha_alta,
		usuario_alta,
		version
		)
	VALUES (
		@id_proceso,
		GETDATE(),
		@fecha_desde_proceso,
		@fecha_hasta_proceso,
		GETDATE(),
		@usuario,
		0
		);
		
	SET @id_log_proceso = SCOPE_IDENTITY();

	COMMIT TRANSACTION;

	RETURN 1;
END;

