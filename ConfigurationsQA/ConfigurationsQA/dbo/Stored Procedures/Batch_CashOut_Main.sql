
CREATE PROCEDURE dbo.Batch_CashOut_Main 
AS
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @id_proceso INT = 8; 
DECLARE @id_log_proceso INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @registros_procesados INT = 0;
DECLARE @ret_obtener_cuentas INT=0;
DECLARE @err varchar(max)=NULL;


SET NOCOUNT ON;
BEGIN TRY
		-- Iniciar Log        
		EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
			 @id_proceso,
			 NULL,
			 NULL,
			 @Usuario,
			 @id_log_proceso = @id_log_proceso OUTPUT,
			 @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;	   

	   --Validamos que la tabla feriados exista.

		IF OBJECT_ID('Configurations.dbo.Feriados','U') IS NULL
			THROW 51000, 'No existe la Tabla Feriados',1;
  
		EXEC @ret_obtener_cuentas = Configurations.dbo.Batch_CashOut_Obtener_Cuentas    @registros_procesados = @registros_procesados OUTPUT , @err = @err OUTPUT

		IF @ret_obtener_cuentas = 0 
		 THROW 51000,@err,1; 	 
	
		-- Completar Log de Proceso      
		EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
 			 @id_log_proceso,
			 @registros_procesados,
			 @usuario;

	RETURN 1;
END TRY

BEGIN CATCH 

		If @err IS  NULL
		set @err = ERROR_MESSAGE();			
		
		PRINT @err;
		Return 0;

END CATCH