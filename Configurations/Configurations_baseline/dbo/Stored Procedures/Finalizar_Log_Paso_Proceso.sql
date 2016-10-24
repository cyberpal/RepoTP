


CREATE PROCEDURE [dbo].[Finalizar_Log_Paso_Proceso] (
	@id_log_paso INT = NULL,
	@archivo_salida VARCHAR(256) = NULL,
	@resultado_proceso BIT = NULL,
	@motivo_rechazo VARCHAR(100) = NULL,
	@registros_procesados INT = NULL,
	@importe_procesados DECIMAL(12,2) = NULL,
	@registros_aceptados INT = NULL,
	@importe_aceptados DECIMAL(12,2) = NULL,
	@registros_rechazados INT = NULL,
	@importe_rechazados DECIMAL(12,2) = NULL,
	@registros_salida INT = NULL,
	@importe_salida DECIMAL(12,2) = NULL,
	@usuario VARCHAR(20) = NULL
)            
AS

DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

	IF (@id_log_paso IS NULL)
		THROW 51000, 'Id Log Paso Nulo', 1;

	IF (NOT EXISTS (SELECT 1 FROM [dbo].[Log_Paso_Proceso] WHERE [id_log_paso] = @id_log_paso))
		THROW 51000, 'No existe Log Paso Proceso con el Id indicado', 1;

	IF (@resultado_proceso IS NULL)
		THROW 51000, 'Resultado Proceso Nulo', 1;

	IF (@usuario IS NULL)
		THROW 51000, 'Usuario Nulo', 1;

	UPDATE [dbo].[Log_Paso_Proceso]
	SET
		[fecha_fin_ejecucion] = GETDATE(),
		[archivo_salida] = @archivo_salida,
		[resultado_proceso] = @resultado_proceso,
		[motivo_rechazo] = @motivo_rechazo,
		[registros_procesados] = @registros_procesados,
		[importe_procesados] = @importe_procesados,
		[registros_aceptados] = @registros_aceptados,
		[importe_aceptados] = @importe_aceptados,
		[registros_rechazados] = @registros_rechazados,
		[importe_rechazados] = @importe_rechazados,
		[registros_salida] = @registros_salida,
		[importe_salida] = @importe_salida,
		[fecha_modificacion] = GETDATE(),
		[usuario_modificacion] = @usuario
	WHERE [id_log_paso] = @id_log_paso;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE();
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;

