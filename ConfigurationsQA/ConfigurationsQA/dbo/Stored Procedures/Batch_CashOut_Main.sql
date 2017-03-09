CREATE PROCEDURE [dbo].[Batch_CashOut_Main]
AS
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @id_proceso INT = 8; 
DECLARE @id_log_proceso INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @registros_procesados INT = 0;
DECLARE @rc INT;

SET NOCOUNT ON;

    -- Iniciar Log        
    EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
         @id_proceso,
	     NULL,
	     NULL,
	     @Usuario,
	     @id_log_proceso = @id_log_proceso OUTPUT,
	     @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;
	   
	BEGIN TRY

		EXEC @rc = Configurations.dbo.Batch_CashOut_Obtener_Cuentas
			 @registros_procesados = @registros_procesados OUTPUT;
		IF @rc = 0
			THROW 50001, 'Error en Batch_CashOut_Obtener_Cuentas', 1;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;
		THROW;
		RETURN 0;
	END CATCH; 
	
    -- Completar Log de Proceso      
    EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
 	     @id_log_proceso,
	     @registros_procesados,
	     @usuario;

	RETURN 1;