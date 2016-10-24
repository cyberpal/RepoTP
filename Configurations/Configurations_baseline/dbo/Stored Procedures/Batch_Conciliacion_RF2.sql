
CREATE PROCEDURE dbo.Batch_Conciliacion_RF2(@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @cant_mov INT;
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @registros_aceptados INT = 0;
DECLARE @importe_aceptados DECIMAL(12,2) = 0;
DECLARE @registros_rechazados INT = 0;
DECLARE @importe_rechazados DECIMAL(12,2) = 0;
	
SET NOCOUNT ON;

	TRUNCATE TABLE Configurations.dbo.movimientos_conciliados_tmp;
	
	TRUNCATE TABLE Configurations.dbo.Transacciones_Conciliacion_tmp;
	
	TRUNCATE TABLE Configurations.dbo.Movimientos_a_Conciliar_tmp;
	
	
	EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	    @id_log_proceso,
		2,
		NULL,
		NULL,
		'bpbatch',
		@id_log_paso = @id_log_paso OUTPUT;
	

   EXEC @cant_mov = Configurations.dbo.Batch_Conciliacion_ObtenerMovimientos;
   
   
   IF(@cant_mov > 0)
    BEGIN
	   EXEC Configurations.dbo.Batch_Conciliacion_MacheoMovimientos;
	   
	
	   EXEC Configurations.dbo.Batch_Conciliacion_InsertarMovimientos
	        @id_log_paso,
			@registros_procesados = @registros_procesados OUTPUT,
		    @importe_procesados = @importe_procesados OUTPUT,
		    @registros_aceptados = @registros_aceptados OUTPUT,
		    @importe_aceptados = @importe_aceptados OUTPUT,
		    @registros_rechazados = @registros_rechazados OUTPUT,
		    @importe_rechazados = @importe_rechazados OUTPUT;
	   
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
		@registros_aceptados,
		@importe_aceptados,
		@registros_rechazados,
		@importe_rechazados,
		0,
		0,
		'bpbatch';       
    
