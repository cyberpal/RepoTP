
CREATE PROCEDURE [dbo].[Batch_Log_Finalizar_Proceso] (
	@id_log_proceso INT = NULL,
	@registros_afectados INT = NULL,
	@usuario VARCHAR(20) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	UPDATE Configurations.dbo.Log_Proceso
	SET fecha_fin_ejecucion = getdate(),
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
