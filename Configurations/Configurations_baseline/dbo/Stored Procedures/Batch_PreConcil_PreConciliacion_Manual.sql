 
CREATE PROCEDURE [dbo].[Batch_PreConcil_PreConciliacion_Manual] (   
  @usuario VARCHAR(20),   
  @id_log_proceso INT,
  @id_nivel_detalle_global INT
 )   
AS   
DECLARE @id_log_paso INT;
DECLARE @id_paso_proceso INT;
DECLARE @id_proceso INT;
DECLARE @nombre_sp VARCHAR(MAX);
DECLARE @mov_i INT = 1;
DECLARE @id_movimiento_decidir INT;
DECLARE @registros_procesados INT = 0;
DECLARE @ProviderTransactionID VARCHAR(64);
DECLARE @fecha_presentacion DATETIME;
DECLARE @msg VARCHAR(MAX);
DECLARE @movimientos_decidir_manual TABLE (i INT IDENTITY(1,1) ,
                                    id_movimiento_decidir INT,
									id_transaccion VARCHAR(36),
									fecha_presentacion DATETIME
                                    );

SET NOCOUNT ON;   
    
BEGIN TRY   
 BEGIN TRANSACTION;   
 
    SET @nombre_sp = OBJECT_NAME(@@PROCID);
 
    SELECT @id_proceso = id_proceso 
	FROM Configurations.dbo.Proceso 
	WHERE nombre = 'Preconciliacion';
 
 
    SELECT @id_paso_proceso = paso
	FROM configurations.dbo.paso_proceso
	WHERE nombre = 'Preconciliar Movimientos de Preconciliacion manual'
	  AND id_proceso = @id_proceso;
						
	
    EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
         @id_log_proceso,
		 @id_paso_proceso,
         NULL,
		 NULL,
         @Usuario,
		 @id_log_paso = @id_log_paso OUTPUT;
						 
	
	EXEC configurations.dbo.Batch_Log_Detalle 
	@id_nivel_detalle_global,
 	@id_log_proceso,
	@nombre_sp,
	2,
	'Obtener movimientos de preconciliacion manual';
	
	
	INSERT @movimientos_decidir_manual					 
    SELECT 
	   pcm.id_movimiento_decidir,
	   pcm.id_transaccion,
	   pcm.fecha_presentacion
    FROM dbo.PreConciliacion_Manual pcm
    WHERE pcm.flag_preconciliado_manual = 1 
	  AND pcm.flag_procesado = 0 
      AND NOT EXISTS (SELECT 1 FROM PreConciliacion pc 
	                  WHERE pc.id_movimiento_decidir = pcm.id_movimiento_decidir);
	
	
	SET @registros_procesados = @@ROWCOUNT;
	
	
	IF(@registros_procesados <> 0)
	  BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
	         @id_nivel_detalle_global,
 	         @id_log_proceso,
	         @nombre_sp,
	         2,
	         'Preconciliar registros';
			 
	    WHILE (@mov_i <= @registros_procesados)  
           BEGIN  
		   
		     SELECT
				@id_movimiento_decidir = mdm.id_movimiento_decidir,
				@ProviderTransactionID= mdm.id_transaccion,
                @fecha_presentacion = mdm.fecha_presentacion
             FROM @movimientos_decidir_manual mdm
             WHERE mdm.i = @mov_i;
    

			 EXEC Configurations.dbo.Batch_PreConcil_Preconciliar_Movimiento
				  @usuario,
				  @id_log_paso,
				  @id_movimiento_decidir,
				  @ProviderTransactionID,
				  @fecha_presentacion,
				  @id_nivel_detalle_global,
	              @id_log_proceso;

             SET @mov_i += 1;

           END
		   
	  END
	  ELSE
	   BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
	         @id_nivel_detalle_global,
 	         @id_log_proceso,
	         @nombre_sp,
	         2,
	         'No se encontraron registros a preconciliar manualmente';
	   END
	  
	  EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
		   @id_log_paso,
	       NULL,
		   NULL,
	       1,
	       NULL,
	       @registros_procesados,
	       0,
	       0,
	       0,
	       0,
	       0,
	       0,
	       0,
	       @usuario;
			 
  COMMIT TRANSACTION;   
END TRY   
    
BEGIN CATCH   
     
 IF(@@TRANCOUNT > 0)   
  ROLLBACK TRANSACTION;   
    
 SELECT @msg = ERROR_MESSAGE();   
 
 EXEC configurations.dbo.Batch_Log_Detalle 
			@id_nivel_detalle_global,
 			@id_log_proceso,
			@nombre_sp,
			1,
			@msg;
 
   
 THROW 51000   
  ,@msg   
  ,1;   
 
END CATCH; 

RETURN 1;