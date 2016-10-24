 
CREATE PROCEDURE [dbo].[Batch_Actualizacion_estado_cupon] (   
  @usuario VARCHAR(20) = NULL   
 )   
AS   

DECLARE @registros_afectados INT = 0;
DECLARE @registros INT;
DECLARE @msg VARCHAR(50);  
DECLARE @id_log_proceso INT;
DECLARE @id_proceso INT = NULL;
DECLARE @id_nivel_detalle_global INT; 
DECLARE @nombre_sp VARCHAR(50);
DECLARE @MergeRowCount TABLE (MergeAction VARCHAR(20)); 
DECLARE @cupones_vencidos TABLE (Id VARCHAR(36),
                                 id_cuenta INT,
							     fecha_procesada DATETIME,
							     importe DECIMAL(12,2)
							    );

SET NOCOUNT ON;   
    
BEGIN TRY   
 BEGIN TRANSACTION;   
    

	SET @nombre_sp = OBJECT_NAME(@@PROCID);

	
    SELECT @id_proceso = id_proceso 
	FROM configurations.dbo.proceso
	WHERE nombre = 'Actualización estado cupón'
    
	
	IF (@id_proceso IS NULL) THROW 51000   
       ,'El parametro Id Proceso tiene valor Nulo'   
       ,1;   

	
    IF (@usuario IS NULL) THROW 51000   
       ,'El parametro Usuario tiene valor Nulo'   
       ,1;   
 
 
  -- Iniciar Log     
    EXEC  Configurations.dbo.Batch_Log_Iniciar_Proceso 
          @id_proceso   
          ,NULL 
          ,NULL
          ,@Usuario
	      ,@id_log_proceso = @id_log_proceso OUTPUT
	      ,@id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;    

   

    -- Obtener Cupones Vencidos	
	    EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'Obtener cupones pendientes.';
		
		
    INSERT 
	    @cupones_vencidos
	SELECT
	    trn.Id,
	    trn.LocationIdentification,
	    CAST(CAST(trn.CreateTimestamp AS DATE) AS DATETIME),
	    trn.Amount
    FROM
	   Transactions.dbo.transactions trn,
	   Configurations.dbo.Medio_De_Pago mdp,
	   Configurations.dbo.Tipo_Medio_Pago tmp
    WHERE trn.ProductIdentification = mdp.id_medio_pago
	  AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
	  AND LTRIM(RTRIM(tmp.codigo)) = 'EFECTIVO'
	  AND LTRIM(RTRIM(trn.OperationName)) IN ('Compra_offline','Compra_online')
	  AND LTRIM(RTRIM(trn.TransactionStatus)) = 'TX_PENDIENTE'
      AND LTRIM(RTRIM(trn.CouponStatus)) = 'PENDIENTE'
	  AND trn.ResultCode = -1
	  AND trn.ReverseStatus IS NULL
	  AND trn.LocationIdentification IS NOT NULL
	  AND DATEADD(d, mdp.plazo_pago_marca + mdp.margen_espera_pago_marca, CAST(trn.CouponExpirationDate AS DATE)) < CAST(GETDATE() AS DATE);

	  
	SET @registros = @@ROWCOUNT;
	
	-- Actualizar Transactions  
	IF (@registros <> 0)
	  BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'Actualizar transacciones encontradas.';
		 
		 
	    UPDATE Transactions.dbo.transactions 
	    SET TransactionStatus = 'TX_VENCIDA',
	        SyncStatus = 0,
	    	CouponStatus = 'VENCIDO'
	    WHERE EXISTS (SELECT * FROM @cupones_vencidos);
		
		
		EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'Actualizar Actividad_Transaccional_Cuenta.';
		
		
		MERGE Configurations.dbo.Actividad_Transaccional_Cuenta AS trg
		      USING(SELECT 
			          id_cuenta,
					  fecha_procesada,
					  SUM(importe) as total,
					  COUNT(Id) AS cant_tx
					FROM @cupones_vencidos
					GROUP BY id_cuenta,
					         fecha_procesada
			       ) AS src
		ON (trg.id_cuenta = src.id_cuenta AND trg.fecha_procesada = src.fecha_procesada)
		WHEN MATCHED THEN 
             UPDATE SET trg.cant_tx_dia_cupon_vencido = src.cant_tx,
				        trg.monto_tx_dia_cupon_vencido = src.total,
						trg.id_log_proceso = @id_log_proceso, 
						trg.fecha_modificacion = GETDATE(),
						trg.usuario_modificacion = @usuario
        WHEN NOT MATCHED BY TARGET THEN 
             INSERT (id_cuenta, 
			         cant_tx_dia_TC, 
			         cant_tx_dia_TD, 
					 cant_tx_dia_cupon, 
					 cant_tx_dia_cupon_vencido, 
					 cant_tx_dia_cashOut, 
					 monto_tx_dia_TC, 
					 monto_tx_dia_TD, 
					 monto_tx_dia_cupon, 
					 monto_tx_dia_cupon_vencido, 
					 monto_tx_dia_cashOut, 
					 fecha_procesada, 
					 id_log_proceso, 
					 fecha_alta, 
					 usuario_alta, 
					 version) 
	         VALUES (src.id_cuenta, 
			         0, 
					 0, 
					 0,
					 src.cant_tx,
					 0,
					 0,
					 0,
					 0,
					 src.total,
					 0,
					 src.fecha_procesada,
					 @id_log_proceso,
					 GETDATE(),
					 @usuario,
					 1)
		    
		OUTPUT $action INTO @MergeRowCount;   
        SET @registros_afectados = (SELECT COUNT(*) 
		                            FROM @MergeRowCount);  

	  END
	ELSE
      BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'No se encontraron transacciones a procesar.';
      END	  
	
	
 -- Completar Log de Proceso   
    EXEC configurations.dbo.Batch_Log_Finalizar_Proceso 
 			@id_log_proceso,
			@registros_afectados,
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