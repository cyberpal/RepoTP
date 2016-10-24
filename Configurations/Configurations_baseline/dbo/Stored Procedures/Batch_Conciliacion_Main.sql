
CREATE PROCEDURE dbo.Batch_Conciliacion_Main 
AS
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @id_proceso INT = 2; 
DECLARE @id_log_proceso INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @cant_tx_visa INT;
DECLARE @cant_tx_cabal INT;
DECLARE @cant_tx_firstData INT;
DECLARE @cant_tx_amex INT;
DECLARE @cant_tx_rapipago INT;

SET NOCOUNT ON;

    -- Iniciar Log        
    EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
         @id_proceso,
	     NULL,
	     NULL,
	     @Usuario,
	     @id_log_proceso = @id_log_proceso OUTPUT,
	     @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;
	   
    SELECT
	    @cant_tx_visa = SUM(CASE WHEN  descripcion = 'VISA' THEN 1 ELSE 0 END),
	    @cant_tx_cabal = SUM(CASE WHEN  descripcion = 'CABAL' THEN 1 ELSE 0 END),
	    @cant_tx_firstData = SUM(CASE WHEN  descripcion = 'FIRST DATA' THEN 1 ELSE 0 END),	 
	    @cant_tx_amex = SUM(CASE WHEN  descripcion = 'AMEX' THEN 1 ELSE 0 END),	
	    @cant_tx_rapipago = SUM(CASE WHEN  descripcion = 'RAPIPAGO' THEN 1 ELSE 0 END)
    FROM Configurations.dbo.Archivo_Conciliacion
	WHERE flag_procesado = 0;
  
  
    WHILE(@cant_tx_visa > 0)
      BEGIN
	    EXEC Configurations.dbo.Batch_Conciliacion_ValidarVisa
	         @id_log_proceso;
	    SET @cant_tx_visa = @cant_tx_visa - 1;
	  END
    WHILE(@cant_tx_cabal > 0)
      BEGIN
	    EXEC Configurations.dbo.Batch_Conciliacion_ValidarCabal 
	         @id_log_proceso;
		   
	    SET @cant_tx_cabal = @cant_tx_cabal - 1;
	  END
    WHILE(@cant_tx_firstData > 0)
       BEGIN
	   	 EXEC Configurations.dbo.Batch_Conciliacion_ValidarFirstData
	          @id_log_proceso;

	     SET @cant_tx_firstData = @cant_tx_firstData - 1;
	   END
    WHILE(@cant_tx_amex > 0)
       BEGIN
	    EXEC Configurations.dbo.Batch_Conciliacion_ValidarAmex 
	         @id_log_proceso;

	     SET @cant_tx_amex = @cant_tx_amex - 1;
	   END
    WHILE(@cant_tx_rapipago > 0)
       BEGIN
	     EXEC Configurations.dbo.Batch_Conciliacion_ValidarRapipago 
	          @id_log_proceso;
		   
	     SET @cant_tx_rapipago = @cant_tx_rapipago - 1;
	   END
	

	EXEC Configurations.dbo.Batch_Conciliacion_RF2
	     @id_log_proceso;
	
	
	EXEC Configurations.dbo.Batch_Conciliacion_RF3
	     @id_log_proceso;
 

    EXEC Configurations.dbo.Batch_Conciliacion_RF4
	     @id_log_proceso;


    EXEC Configurations.dbo.Batch_Conciliacion_RF5
	     @id_log_proceso;


    EXEC Configurations.dbo.Batch_Conciliacion_RF9
	     @id_log_proceso;

		 
    EXEC Configurations.dbo.Batch_Conciliacion_RF10
	     @id_log_proceso;
		 
		 
    -- Completar Log de Proceso      
    EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
 	     @id_log_proceso,
	     0,
	     @usuario;
