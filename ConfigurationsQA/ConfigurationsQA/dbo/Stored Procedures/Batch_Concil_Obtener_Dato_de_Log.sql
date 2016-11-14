
CREATE PROCEDURE [dbo].[Batch_Concil_Obtener_Dato_de_Log]
(
   @id_log_paso INT,
   @usuario VARCHAR(20),
   @registros_aceptados INT = NULL OUTPUT,
   @importe_aceptados DECIMAL(12,2)= NULL OUTPUT,
   @registros_rechazados INT = NULL OUTPUT,
   @importe_rechazados DECIMAL(12,2) = NULL OUTPUT,
   @registros_salida INT = NULL OUTPUT,
   @importe_salida DECIMAL(12,2) = NULL OUTPUT,
   @resultado_proceso INT = 0 OUTPUT
)
AS 
DECLARE @msg VARCHAR(MAX)

BEGIN TRY 

SELECT
	@registros_aceptados = ISNULL(COUNT(*),0),
	@importe_aceptados = ISNULL(SUM(CASE WHEN RTRIM(LTRIM(mpm.signo_importe)) = '-' THEN (mpm.importe * -1)ELSE mpm.importe END),0)
FROM
	dbo.Conciliacion cln 
	INNER JOIN
	dbo.Movimiento_Presentado_MP mpm 
	ON cln.id_movimiento_mp = mpm.id_movimiento_mp
WHERE cln.flag_conciliada = 1
	AND cln.flag_aceptada_marca = 1
	AND cln.id_log_paso = @id_log_paso

SELECT
	@registros_rechazados = SUM(R.cantidad),
	@importe_rechazados = ISNULL(SUM(R.importe), 0)
FROM(
	SELECT
		COUNT(*) AS cantidad,
		SUM(CASE WHEN RTRIM(LTRIM(mpm.signo_importe)) = '-' THEN (mpm.importe * -1)ELSE mpm.importe END) as importe
	FROM
		dbo.Conciliacion cln 
		INNER JOIN
		dbo.Movimiento_Presentado_MP mpm 
		ON cln.id_movimiento_mp = mpm.id_movimiento_mp
	WHERE cln.flag_conciliada = 1
	  AND cln.flag_aceptada_marca = 0
	  AND cln.id_log_paso = @id_log_paso
	UNION ALL
	SELECT
		COUNT(*) AS cantidad,
		SUM(CASE WHEN RTRIM(LTRIM(mad.signo_importe)) = '-' THEN (mad.importe * -1)ELSE mad.importe END) as importe
	FROM dbo.Movimientos_a_distribuir mad
	WHERE mad.tipo = 'N'
	  AND mad.id_log_paso = @id_log_paso
) R


SET @registros_salida =  @registros_rechazados + @registros_aceptados;
SET @importe_salida = @importe_rechazados + @importe_aceptados;
SET @resultado_proceso = 1;

EXEC Configurations.dbo.Finalizar_Log_Paso_Proceso	
    @id_log_paso, 
	NULL, 
	@resultado_proceso,
	NULL,
	0,
	0,
	@registros_aceptados,
	@importe_aceptados,
	@registros_rechazados,
	@importe_rechazados,
	@registros_salida,
	@importe_salida,
	@usuario;

END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;

	SELECT @msg = ERROR_MESSAGE();

	THROW 51000,
		@msg,
		1;
END CATCH;



