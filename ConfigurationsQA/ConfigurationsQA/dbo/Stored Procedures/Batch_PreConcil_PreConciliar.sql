 
CREATE PROCEDURE [dbo].[Batch_PreConcil_PreConciliar] (   
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
DECLARE @importe_procesado DECIMAL(12,2) = 0;
DECLARE @registros_aceptados INT = 0;
DECLARE @importe_aceptados DECIMAL(12,2) = 0;
DECLARE @registros_rechazados INT = 0;
DECLARE @importe_rechazados DECIMAL(12,2) = 0;
DECLARE @ProviderTransactionID VARCHAR(64);
DECLARE @TransactionStatus VARCHAR(20);
DECLARE @id_transaccion VARCHAR(36);
DECLARE @importe DECIMAL(12,2);
DECLARE @nro_tarjeta VARCHAR(50);
DECLARE @nro_autorizacion VARCHAR(8);
DECLARE @nro_cupon INT;
DECLARE @fecha_presentacion DATETIME;
DECLARE @id_codigo_operacion INT;
DECLARE @msg VARCHAR(MAX);
DECLARE @movimientos_decidir TABLE (i INT IDENTITY(1,1) ,
                                    id_movimiento_decidir INT,
									id_transaccion VARCHAR(36),
									importe DECIMAL(12,2),
									nro_tarjeta VARCHAR(50),
									nro_autorizacion VARCHAR(8),
									nro_cupon INT,
									fecha_presentacion DATETIME,
									id_codigo_operacion INT,
									id_medio_pago INT
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
	WHERE nombre = 'Preconciliar Movimientos'
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
	'Obtener movimientos a preconciliar';
	
	
	INSERT @movimientos_decidir					 
    SELECT 
	   mpd.id_movimiento_decidir,
	   mpd.id_transaccion,
	   mpd.importe,
	   mpd.nro_tarjeta,
	   mpd.nro_autorizacion,
	   mpd.nro_cupon,
	   mpd.fecha_presentacion,
	   mpd.id_codigo_operacion,
	   mpd.id_medio_pago
    FROM Configurations.dbo.Movimiento_Presentado_Decidir mpd 
    WHERE NOT EXISTS(SELECT 1 FROM Configurations.dbo.PreConciliacion pc
                     WHERE pc.id_movimiento_decidir = mpd.id_movimiento_decidir)
      AND NOT EXISTS(SELECT 1 FROM Configurations.dbo.PreConciliacion_Manual pcm
	                 WHERE pcm.id_movimiento_decidir = mpd.id_movimiento_decidir);
	
	
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
		        @ProviderTransactionID = trn.ProviderTransactionID,
                @TransactionStatus = trn.TransactionStatus,
				@id_movimiento_decidir = md.id_movimiento_decidir,
				@id_transaccion = md.id_transaccion,
                @importe = md.importe,
                @nro_tarjeta = md.nro_tarjeta,
                @nro_autorizacion = md.nro_autorizacion,
                @nro_cupon = md.nro_cupon,
                @fecha_presentacion = md.fecha_presentacion,
                @id_codigo_operacion = md.id_codigo_operacion
             FROM @movimientos_decidir md
             LEFT JOIN Transactions.dbo.transactions trn
             ON md.id_transaccion = trn. ProviderTransactionID
             AND md.id_medio_pago = trn.ProductIdentification
             WHERE md.i = @mov_i;
			 
			 IF(
			    (@id_codigo_operacion IN (1,3) AND @TransactionStatus = 'TX_APROBADA' AND @ProviderTransactionID IS NOT NULL) 
				OR
				(@id_codigo_operacion = 6 AND @TransactionStatus = 'TX_RECHAZADA' AND @ProviderTransactionID IS NOT NULL)
			   )
			   BEGIN
			    EXEC Configurations.dbo.Batch_PreConcil_Preconciliar_Movimiento
				     @usuario,
					 @id_log_paso,
					 @id_movimiento_decidir,
					 @ProviderTransactionID,
					 @fecha_presentacion,
					 @id_nivel_detalle_global,
					 @id_log_proceso;
			   
			   END
			 ELSE
			   BEGIN
			     INSERT Configurations.dbo.PreConciliacion_Manual(
                        id_log_paso,
                        id_movimiento_decidir,
                        importe,
                        nro_tarjeta,
                        nro_autorizacion,
                        nro_cupon,
                        fecha_presentacion,
                        fecha_alta,
                        usuario_alta,
                        id_transaccion,
                        flag_preconciliado_manual,
                        flag_procesado,
                        version)
				 VALUES(
				        @id_log_paso,
						@id_movimiento_decidir,
						@importe,
						@nro_tarjeta,
						@nro_autorizacion,
						@nro_cupon,
						@fecha_presentacion,
						GETDATE(),
						@usuario,
						@id_transaccion,
						0,
						0,
						0
				       );
			   END

             SET @mov_i += 1;

           END
		   
		SELECT @registros_aceptados = COUNT(pc.id_preconciliacion),
	           @importe_aceptados = ISNULL(SUM(mpd.importe),0)
        FROM dbo.PreConciliacion pc 
        INNER JOIN dbo.Movimiento_Presentado_Decidir mpd
        ON mpd.id_movimiento_decidir = pc.id_movimiento_decidir
        WHERE pc.flag_preconciliada = 1
        AND pc.id_log_paso = @id_log_paso;
		
		SELECT @registros_rechazados = COUNT(pcm.id_preconciliacion_manual),
	           @importe_rechazados = ISNULL(SUM(mpd.importe),0)
        FROM dbo.PreConciliacion_Manual pcm 
        INNER JOIN dbo.Movimiento_Presentado_Decidir mpd 
        ON mpd.id_movimiento_decidir = pcm.id_movimiento_decidir
        WHERE pcm.flag_preconciliado_manual = 0
        AND pcm.id_log_paso = @id_log_paso;
		
		SET @importe_procesado = @importe_aceptados + @importe_rechazados;
		
	  END
	ELSE
	  BEGIN
	     EXEC configurations.dbo.Batch_Log_Detalle 
	         @id_nivel_detalle_global,
 	         @id_log_proceso,
	         @nombre_sp,
	         2,
	         'No se encontraron registros a preconciliar';
	  END
	  
	  EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
		   @id_log_paso,
	       NULL,
		   NULL,
	       1,
	       NULL,
	       @registros_procesados,
	       @importe_procesado,
	       @registros_aceptados,
	       @importe_aceptados,
	       @registros_rechazados,
	       @importe_rechazados,
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


