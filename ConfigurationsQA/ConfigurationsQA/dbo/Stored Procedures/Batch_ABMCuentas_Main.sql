
CREATE PROCEDURE [dbo].[Batch_ABMCuentas_Main]
AS
DECLARE @id_proceso INT = 26;
DECLARE @id_log_proceso INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @cant_archivo_alta INT;


                                     
SET NOCOUNT ON;


    EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
         @id_proceso,
         NULL,
         NULL,
         @Usuario,
         @id_log_proceso = @id_log_proceso OUTPUT,
         @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;
		
		
    SELECT
	    @cant_archivo_alta = COUNT(1)
    FROM Configurations.dbo.Archivo_ABM_Cuenta
	WHERE flag_procesado = 0
	  AND CAST(fecha_alta AS DATE) = CAST(GETDATE() AS DATE);
	
	
	WHILE(@cant_archivo_alta > 0)
      BEGIN
	    EXEC Configurations.dbo.Batch_ABMCuentas_Parse;
	    SET @cant_archivo_alta = @cant_archivo_alta - 1;
	  END
	  
	 
	EXEC Configurations.dbo.Batch_ABMJsons;

	
	EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
         @id_log_proceso,
         0,
         @usuario;

RETURN 1

