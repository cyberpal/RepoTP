
CREATE PROCEDURE dbo.Batch_Conciliacion_RF3(@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @cant_mov INT;
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;
    
	TRUNCATE TABLE Configurations.dbo.Movimientos_conciliados_manual_tmp;
	
	
	EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	    @id_log_proceso,
		3,
		NULL,
		NULL,
		'bpbatch',
		@id_log_paso = @id_log_paso OUTPUT;
	

   EXEC @cant_mov = Configurations.dbo.Batch_Conciliacion_ObtenerMovimientosCM;
   
   
   IF(@cant_mov > 0)
    BEGIN
		
	   EXEC Configurations.dbo.Batch_Conciliacion_ConciliacionManual
	        @id_log_paso,
			@registros_procesados = @registros_procesados OUTPUT,
		    @importe_procesados = @importe_procesados OUTPUT;
			
	   
	END 
	
   SET @resultado_proceso = 1;
	
   EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
	    @id_log_paso,
		NULL,
		NULL,
		@resultado_proceso,
		NULL,
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