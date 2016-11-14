
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ValidarVisa] (@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id INT;
DECLARE @id_log_paso INT;
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @descripcion VARCHAR(9) = 'VISA';
DECLARE @id_medio_pago INT = 6;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @msg VARCHAR(MAX);

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	    SELECT TOP 1 @id = (ac.id),
	           @archivo_entrada = ac.nombre_archivo 
	      FROM Configurations.dbo.Archivo_Conciliacion ac
	INNER JOIN Configurations.dbo.Detalle_Archivo da
	        ON ac.id = da.id_archivo
	     WHERE ac.flag_procesado = 0
	       AND ac.descripcion = @descripcion;


	SELECT TOP 1
       @fecha_ejecucion = fecha_inicio_ejecucion
    FROM Configurations.dbo.Log_Paso_Proceso
    WHERE archivo_entrada = @archivo_entrada 
    AND resultado_proceso = 1
	
	  
    EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 1,
		 @descripcion,
		 @archivo_entrada,
		 'bpbatch',
		 @id_log_paso = @id_log_paso OUTPUT; 

    
    IF(@fecha_ejecucion IS NOT NULL)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END
	ELSE IF(CHARINDEX('P',@archivo_entrada) <> 0)
      BEGIN
        EXEC Configurations.dbo.Batch_Conciliacion_ValidarVisaImpuestos
		     @id_log_paso,
			 @id,
			 @resultado_proceso = @resultado_proceso OUTPUT,
			 @motivo_rechazo = @motivo_rechazo OUTPUT;
      END
    ELSE 
      BEGIN
        EXEC Configurations.dbo.Batch_Conciliacion_ValidarVisaMovimientos
		     @id_log_paso,
			 @id,
			 @archivo_entrada,
			 @registros_procesados = @registros_procesados OUTPUT,
             @importe_procesados = @importe_procesados OUTPUT,
			 @resultado_proceso = @resultado_proceso OUTPUT,
			 @motivo_rechazo = @motivo_rechazo OUTPUT;
      END  
	
	UPDATE Configurations.dbo.Archivo_Conciliacion
	SET flag_procesado = 1
	WHERE id = @id;
	
	EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
	     @id_log_paso,
		 @archivo_entrada,
		 NULL,
		 @resultado_proceso,
		 @motivo_rechazo,
		 @registros_procesados,
		 @importe_procesados,
		 0,
		 0,
		 0,
		 0,
		 0,
		 0,
		 'bpbatch'; 

	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;

