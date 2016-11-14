
CREATE PROCEDURE [dbo].[Batch_Log_Iniciar_Paso] (
	@id_log_proceso INT = NULL,
	@id_paso_proceso INT = NULL,
	@descripcion VARCHAR(25) = NULL,
	@archivo_entrada VARCHAR(256) = NULL,
	@usuario VARCHAR(20) = NULL,
	@id_log_paso INT OUTPUT
	)
AS
BEGIN
	BEGIN TRANSACTION;

	IF (@id_log_proceso IS NULL)
	BEGIN
		THROW 51000,
			'Id Log Proceso Nulo',
			1;
	END;

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.Log_Proceso
				WHERE id_log_proceso = @id_log_proceso
				)
			)
	BEGIN
		THROW 51000,
			'No existe Log Proceso con el Id indicado',
			1;
	END;

	IF (@id_paso_proceso IS NULL)
	BEGIN
		THROW 51000,
			'Id Paso Proceso Nulo',
			1;
	END;

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.Paso_Proceso
				WHERE id_paso_proceso = @id_paso_proceso
				)
			)
	BEGIN
		THROW 51000,
			'No existe Paso Proceso con el Id indicado',
			1;
	END;

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.Paso_Proceso
				WHERE paso = @id_paso_proceso
					AND id_proceso = (
						SELECT id_proceso
						FROM dbo.Log_Proceso
						WHERE id_log_proceso = @id_log_proceso
						)
				)
			)
	BEGIN
		THROW 51000,
			'El Id Proceso no corresponde al Id Paso',
			1;
	END;

	IF (@usuario IS NULL)
	BEGIN
		THROW 51000,
			'Usuario Nulo',
			1;
	END;


	INSERT INTO dbo.Log_Paso_Proceso (
		id_log_proceso,
		id_paso_proceso,
		fecha_inicio_ejecucion,
		descripcion,
		archivo_entrada,
		fecha_alta,
		usuario_alta,
		version
		)
	VALUES (
		@id_log_proceso,
		@id_paso_proceso,
		GETDATE(),
		@descripcion,
		@archivo_entrada,
		GETDATE(),
		@usuario,
		0
		);

	COMMIT TRANSACTION;
	
	SET @id_log_paso = SCOPE_IDENTITY();

	RETURN 1;
END;

