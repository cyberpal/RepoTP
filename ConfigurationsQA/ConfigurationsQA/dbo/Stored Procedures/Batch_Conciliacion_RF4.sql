
CREATE PROCEDURE [dbo].[Batch_Conciliacion_RF4]( @id_log_proceso INT )
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @usuario VARCHAR(8) = 'bpbatch';

SET NOCOUNT ON;

    
	TRUNCATE TABLE Configurations.dbo.Distribucion_tmp;
	

	--------------------------------NUEVO LOG PASO----------------------------------
    EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 4,
		 NULL,
		 NULL,
		 @usuario,
		 @id_log_paso = @id_log_paso OUTPUT; 

	
    --------------------------------OBTENER MOVIMIENTOS A DISTRIBUIR----------------	
    EXEC Configurations.dbo.Batch_Conciliacion_ObtenerMovimientosAdistribuir
    	 @id_log_paso,
    	 @usuario;
    
    --------------------------------OBTENER MOVIMIENTOS A DISTRIBUIR----------------	
    EXEC Configurations.dbo.Batch_Conciliacion_ActualizarDistribucion;
	
	
    ------------------------------ACTUALIZAR FLAG IMPUESTOS-------------------------
    EXEC Configurations.dbo.Batch_Conciliacion_ActualizarFlagImpuestos
    	 @usuario,
    	 @registros_procesados = @registros_procesados OUTPUT,
    	 @importe_procesados = @importe_procesados OUTPUT,
    	 @resultado_proceso = @resultado_proceso OUTPUT;
    
    
    ---------------------------------FINALIZAR LOG PASO----------------------------

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


