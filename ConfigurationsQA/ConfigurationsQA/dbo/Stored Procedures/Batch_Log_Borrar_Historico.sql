CREATE PROCEDURE [dbo].[Batch_Log_Borrar_Historico]
AS
DECLARE @eliminar TABLE (id_log_proceso INT);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener históricos a eliminar por fecha.
		INSERT INTO @eliminar
		SELECT l.id_log_proceso
		FROM (
			SELECT lpo.id_log_proceso,
				(
					CASE 
						WHEN DATEDIFF(day, lpo.fecha_alta, GETDATE()) > clp.valor_historico_log
							THEN 1
						ELSE 0
						END
					) AS flag_eliminar
			FROM Configurations.dbo.Detalle_Log_Proceso dlp
			INNER JOIN Configurations.dbo.Log_Proceso lpo
				ON dlp.id_log_proceso = lpo.id_log_proceso
			INNER JOIN Configurations.dbo.Configuracion_Log_Proceso clp
				ON lpo.id_proceso = clp.id_proceso
			INNER JOIN Configurations.dbo.Tipo tpo
				ON clp.id_tipo_historico_log = tpo.id_tipo
			WHERE tpo.codigo = 'ANT_DIAS'
			
			UNION
			
			SELECT lpo.id_log_proceso,
				(
					CASE 
						WHEN DATEDIFF(month, lpo.fecha_alta, GETDATE()) > clp.valor_historico_log
							THEN 1
						ELSE 0
						END
					) AS flag_eliminar
			FROM Configurations.dbo.Detalle_Log_Proceso dlp
			INNER JOIN Configurations.dbo.Log_Proceso lpo
				ON dlp.id_log_proceso = lpo.id_log_proceso
			INNER JOIN Configurations.dbo.Configuracion_Log_Proceso clp
				ON lpo.id_proceso = clp.id_proceso
			INNER JOIN Configurations.dbo.Tipo tpo
				ON clp.id_tipo_historico_log = tpo.id_tipo
			WHERE tpo.codigo = 'ANT_MESES'
			) l
		WHERE l.flag_eliminar = 1;

		-- Obtener históricos a eliminar por ejecución.
		INSERT INTO @eliminar
		SELECT l.id_log_proceso
		FROM (
			SELECT lpo.id_proceso,
				lpo.id_log_proceso,
				ROW_NUMBER() OVER (
					PARTITION BY lpo.id_proceso ORDER BY lpo.id_proceso ASC,
						lpo.id_log_proceso DESC
					) AS ejecucion,
				clp.valor_historico_log
			FROM /*Configurations.dbo.Detalle_Log_Proceso dlp
			INNER JOIN*/ Configurations.dbo.Log_Proceso lpo
				--ON dlp.id_log_proceso = lpo.id_log_proceso
			INNER JOIN Configurations.dbo.Configuracion_Log_Proceso clp
				ON lpo.id_proceso = clp.id_proceso
			INNER JOIN Configurations.dbo.Tipo tpo
				ON clp.id_tipo_historico_log = tpo.id_tipo
			WHERE tpo.codigo = 'ANT_EJEC'
			AND EXISTS (SELECT 1 from Configurations.dbo.Detalle_Log_Proceso dlp WHERE dlp.id_log_proceso = lpo.id_log_proceso)
			) l
		WHERE l.ejecucion > l.valor_historico_log;

		-- Eliminar históricos
		DELETE Configurations.dbo.Detalle_Log_Proceso
		WHERE id_log_proceso IN (
				SELECT id_log_proceso
				FROM @eliminar
				);

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;

		RETURN 0;
	END CATCH;

	RETURN 1;
END;


