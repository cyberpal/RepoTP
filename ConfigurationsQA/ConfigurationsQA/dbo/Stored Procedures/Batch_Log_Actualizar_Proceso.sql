
CREATE PROCEDURE [dbo].[Batch_Log_Actualizar_Proceso] (
	@id_log_proceso INT = NULL,
	@fecha_desde_proceso DATETIME = NULL,
	@fecha_hasta_proceso DATETIME = NULL,
	@registros_afectados INT = NULL,
	@usuario VARCHAR(20) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	UPDATE Configurations.dbo.Log_Proceso
	SET fecha_desde_proceso = (
			CASE 
				WHEN @fecha_desde_proceso IS NULL
					THEN fecha_desde_proceso
				ELSE @fecha_desde_proceso
				END
			),
		fecha_hasta_proceso = (
			CASE 
				WHEN @fecha_hasta_proceso IS NULL
					THEN fecha_hasta_proceso
				ELSE @fecha_hasta_proceso
				END
			),
		registros_afectados = (
			CASE 
				WHEN @registros_afectados IS NULL
					THEN registros_afectados
				ELSE @registros_afectados
				END
			),
		fecha_modificacion = getdate(),
		usuario_modificacion = @usuario
	WHERE id_log_proceso = @id_log_proceso;

	COMMIT TRANSACTION;

	RETURN 1;
END;

