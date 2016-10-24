
CREATE PROCEDURE dbo.Batch_ABMCuentas_Main
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id_proceso INT = 26;
DECLARE @id_log_proceso INT;
DECLARE @cant INT;
DECLARE @archivo_entrada VARCHAR(100) = NULL;
DECLARE @id_nivel_detalle_global INT;
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @cant_tx INT;


                                     
SET NOCOUNT ON;

    TRUNCATE TABLE Configurations.dbo.Info_archivo_abm_cuenta_Tmp;
	
    EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
         @id_proceso,
         NULL,
         NULL,
         @Usuario,
         @id_log_proceso = @id_log_proceso OUTPUT,
         @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;
		 
		 
	SELECT
	       @cant_tx = COUNT(1)
      FROM Configurations.dbo.Archivo_abm_cuenta
	 WHERE CAST(fecha AS DATE)=CAST(GETDATE() AS DATE);
	

    WHILE(@cant_tx > 0)
      BEGIN
	    EXEC Configurations.dbo.Batch_ABMCuentas_Parse;
	    SET @cant_tx = @cant_tx - 1;
	  END

	
	EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
         @id_log_proceso,
         0,
         @usuario;

RETURN 1
