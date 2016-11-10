
CREATE PROCEDURE [dbo].[Batch_Log_Actualizar_Paso] (
	@id_log_paso INT = NULL,
	@archivo_entrada VARCHAR(256) = NULL,
	@archivo_salida VARCHAR(256) = NULL,
	@resultado_proceso BIT = NULL,
	@motivo_rechazo VARCHAR(100) = NULL,
	@registros_procesados INT = NULL,
	@importe_procesados DECIMAL(12, 2) = NULL,
	@registros_aceptados INT = NULL,
	@importe_aceptados DECIMAL(12, 2) = NULL,
	@registros_rechazados INT = NULL,
	@importe_rechazados DECIMAL(12, 2) = NULL,
	@registros_salida INT = NULL,
	@importe_salida DECIMAL(12, 2) = NULL,
	@usuario VARCHAR(20) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	IF (@id_log_paso IS NULL)
	BEGIN
		THROW 51000,
			'Id Log Paso Nulo',
			1;
	END;

	IF (
			NOT EXISTS (
				SELECT 1
				FROM dbo.Log_Paso_Proceso
				WHERE id_log_paso = @id_log_paso
				)
			)
	BEGIN
		THROW 51000,
			'No existe Log Paso Proceso con el Id indicado',
			1;
	END;

	IF (@resultado_proceso IS NULL)
	BEGIN
		THROW 51000,
			'Resultado Proceso Nulo',
			1;
	END;

	IF (@usuario IS NULL)
	BEGIN
		THROW 51000,
			'Usuario Nulo',
			1;
	END;

	UPDATE dbo.Log_Paso_Proceso
	SET archivo_entrada = (
			CASE 
				WHEN @archivo_entrada IS NULL
					THEN archivo_entrada
				ELSE @archivo_entrada
				END
			),
		archivo_salida = (
			CASE 
				WHEN @archivo_salida IS NULL
					THEN archivo_salida
				ELSE @archivo_salida
				END
			),
		resultado_proceso = (
			CASE 
				WHEN @resultado_proceso IS NULL
					THEN resultado_proceso
				ELSE @resultado_proceso
				END
			),
		motivo_rechazo = (
			CASE 
				WHEN @motivo_rechazo IS NULL
					THEN motivo_rechazo
				ELSE @motivo_rechazo
				END
			),
		registros_procesados = (
			CASE 
				WHEN @registros_procesados IS NULL
					THEN registros_procesados
				ELSE @registros_procesados
				END
			),
		importe_procesados = (
			CASE 
				WHEN @importe_procesados IS NULL
					THEN importe_procesados
				ELSE @importe_procesados
				END
			),
		registros_aceptados = (
			CASE 
				WHEN @registros_aceptados IS NULL
					THEN registros_aceptados
				ELSE @registros_aceptados
				END
			),
		importe_aceptados = (
			CASE 
				WHEN @importe_aceptados IS NULL
					THEN importe_aceptados
				ELSE @importe_aceptados
				END
			),
		registros_rechazados = (
			CASE 
				WHEN @registros_rechazados IS NULL
					THEN registros_rechazados
				ELSE @registros_rechazados
				END
			),
		importe_rechazados = (
			CASE 
				WHEN @importe_rechazados IS NULL
					THEN importe_rechazados
				ELSE @importe_rechazados
				END
			),
		registros_salida = (
			CASE 
				WHEN @registros_salida IS NULL
					THEN registros_salida
				ELSE @registros_salida
				END
			),
		importe_salida = (
			CASE 
				WHEN @importe_salida IS NULL
					THEN importe_salida
				ELSE @importe_salida
				END
			),
		fecha_modificacion = GETDATE(),
		usuario_modificacion = @usuario
	WHERE id_log_paso = @id_log_paso;

	COMMIT TRANSACTION;

	RETURN 1;
END;

