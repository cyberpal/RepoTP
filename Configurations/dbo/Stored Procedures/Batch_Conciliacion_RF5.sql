
CREATE PROCEDURE dbo.Batch_Conciliacion_RF5(@id_log_proceso INT)
AS

SET NOCOUNT ON;


	TRUNCATE TABLE Configurations.dbo.Distribucion_tmp;

	TRUNCATE TABLE Configurations.dbo.archivo_distribucion_medio_pago_tmp;


    --------------------------------OBTENER MOVIMIENTOS A DISTRIBUIR----------------	
    EXEC Configurations.dbo.Batch_Conciliacion_ActualizarDistribucion;

  
    ------------------------------ACTUALIZAR FLAG IMPUESTOS-------------------------
    EXEC Configurations.dbo.Batch_Conciliacion_GenerarDatosDistribucion
    	 @id_log_proceso;


