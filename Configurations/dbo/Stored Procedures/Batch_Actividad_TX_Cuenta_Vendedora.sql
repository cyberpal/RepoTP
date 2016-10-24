 
CREATE PROCEDURE [dbo].[Batch_Actividad_TX_Cuenta_Vendedora] (   
  @fecha_desde_proceso CHAR(8) = NULL, --aaaammdd   
  @fecha_hasta_proceso CHAR(8) = NULL, --aaaammdd   
  @usuario VARCHAR(20) = NULL   
 )   
AS   

CREATE TABLE #info (id_cuenta INT ,
			        fecha_procesada DATETIME,  
			        cant_tx_dia_TC INT,
			        cant_tx_dia_TD INT, 
			        cant_tx_dia_cupon INT,
			        cant_tx_dia_cupon_vencido INT,
			        cant_tx_dia_cashOut INT,
			        cant_tx_dia_TC_mPos INT,
			        cant_tx_dia_TD_mPos INT,
			        monto_tx_dia_TC DECIMAL (12,2),
			        monto_tx_dia_TD DECIMAL (12,2),
			        monto_tx_dia_cupon DECIMAL (12,2),
			        monto_tx_dia_cupon_vencido DECIMAL (12,2),
			        monto_tx_dia_cashOut DECIMAL (12,2),
			        monto_tx_dia_TC_mPos DECIMAL (12,2),
			        monto_tx_dia_TD_mPos DECIMAL (12,2)
			        );
DECLARE @registros_afectados INT;
DECLARE @fecha_desde DATETIME;
DECLARE @fecha_hasta DATETIME; 
DECLARE @msg VARCHAR(MAX);   
DECLARE @id_log_proceso INT;
DECLARE @version INT = 1;
DECLARE @id_proceso INT = NULL;
DECLARE @id_nivel_detalle_lp INT;
DECLARE @nombre_sp varchar(200);
DECLARE @id_nivel_detalle_global INT; 
DECLARE @detalle VARCHAR(200);

SET NOCOUNT ON;   
    
BEGIN TRY   
 BEGIN TRANSACTION;   
    

	SET @nombre_sp = OBJECT_NAME(@@PROCID);

    SELECT @id_proceso = id_proceso 
	FROM Configurations.dbo.Proceso
	WHERE nombre = 'Actividad Transaccional Cuenta'

    IF (@id_proceso IS NULL) THROW 51000   
       ,'El parametro Id Proceso tiene valor Nulo'   
       ,1;   
    
 
    -- Iniciar Log     
    EXEC  Configurations.dbo.Batch_Log_Iniciar_Proceso 
          @id_proceso,
		  @fecha_desde,
		  @fecha_hasta,
		  @Usuario,
		  @id_log_proceso = @id_log_proceso OUTPUT,
		  @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;    
    
	
    IF (@usuario IS NULL) THROW 51000   
       ,'El parametro Usuario tiene valor Nulo'   
       ,1;      

	   
    -- Iniciar detalle	
    EXEC configurations.dbo.Batch_Log_Detalle 
		 @id_nivel_detalle_global,
 		 @id_log_proceso,
		 @nombre_sp,
		 2,
		 'Obteniendo rango de fechas';
 

  --Si no hay parametros establecer x default el día anterior   
    IF (@fecha_desde_proceso IS NULL)       
    BEGIN     
     SET @fecha_desde = CAST(CAST(GETDATE() -1 AS DATE) AS DATETIME);     
     SET @fecha_hasta = @fecha_desde;   
    END     
    --Si se indica una sola fecha filtrar solo por ese dia     
    ELSE IF (@fecha_hasta_proceso IS NULL)     
    BEGIN       
     SET @fecha_desde = CAST(@fecha_desde_proceso AS DATETIME);    
     SET @fecha_hasta = @fecha_desde;    
    END     
    ELSE     
    BEGIN     
     SET @fecha_desde = CAST(@fecha_desde_proceso AS DATETIME);    
     SET @fecha_hasta = CAST(@fecha_hasta_proceso AS DATETIME);    
    END;     
     
	 
    SET @fecha_hasta = DATEADD(s, -1, @fecha_hasta)+1;    

    -- parametros para log
    SET @detalle = 'Rango de fechas: @fecha_desde = ' + CONVERT(CHAR(10),CAST(@fecha_desde AS VARCHAR))+
                                   ' @fecha_hasta = ' + CONVERT(CHAR(10),CAST(@fecha_hasta AS VARCHAR));
								

    -- Actualizar Log     
    EXEC  Configurations.dbo.Batch_Log_Actualizar_Proceso
	      @id_log_proceso, 
          @fecha_desde, 
          @fecha_hasta,
	      @registros_afectados,
          @Usuario;    

	-- Iniciar detalle	
	EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
		 @id_log_proceso,
		 @nombre_sp,
		 3,
		 @detalle;


    -- Inserto registros en tabla temporal
    INSERT INTO #info(id_cuenta,
					  fecha_procesada,
					  cant_tx_dia_TC,
					  cant_tx_dia_TD,
					  cant_tx_dia_cupon,
                      cant_tx_dia_cupon_vencido, 
					  cant_tx_dia_cashOut,
					  cant_tx_dia_TC_mPos,
					  cant_tx_dia_TD_mPos,
					  monto_tx_dia_TC,
                      monto_tx_dia_TD,
					  monto_tx_dia_cupon,
					  monto_tx_dia_cupon_vencido, 
					  monto_tx_dia_cashOut,
					  monto_tx_dia_TC_mPos,
					  monto_tx_dia_TD_mPos
					  )
    SELECT 
	  tx.id_cuenta AS id_cuenta,
	  tx.fecha_procesada AS fecha_procesada,
      --cantidades
	  SUM(CASE WHEN  tx.tipo_tx = 'CREDITO' THEN 1 ELSE 0 END) AS cant_tx_dia_TC,
	  SUM(CASE WHEN  tx.tipo_tx = 'DEBITO' THEN 1 ELSE 0 END) AS cant_tx_dia_TD,
	  SUM(CASE WHEN  tx.tipo_tx = 'CUPON' THEN 1 ELSE 0 END) AS cant_tx_dia_cupon,
	  SUM(CASE WHEN  tx.tipo_tx = 'CUPON VENCIDO' THEN 1 ELSE 0 END) AS cant_tx_dia_cupon_vencido,		 
	  SUM(CASE WHEN  tx.tipo_tx = 'CASHOUT' THEN 1 ELSE 0 END) AS cant_tx_dia_cashOut,	
	  SUM(CASE WHEN  tx.tipo_tx = 'CREDITO' AND tx.canal = 'mPOS' THEN 1 ELSE 0 END) AS cant_tx_dia_TC_mPos,
	  SUM(CASE WHEN  tx.tipo_tx = 'DEBITO' AND tx.canal = 'mPOS' THEN 1 ELSE 0 END) AS cant_tx_dia_TD_mPos,
      -- montos
	  SUM(CASE WHEN  tx.tipo_tx = 'CREDITO' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_TC,
	  SUM(CASE WHEN  tx.tipo_tx = 'DEBITO' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_TD,
	  SUM(CASE WHEN  tx.tipo_tx = 'CUPON' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_cupon,
	  SUM(CASE WHEN  tx.tipo_tx = 'CUPON VENCIDO' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_cupon_vencido,		 
	  SUM(CASE WHEN  tx.tipo_tx = 'CASHOUT' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_cashOut,		 
	  SUM(CASE WHEN  tx.tipo_tx = 'CREDITO' AND tx.canal = 'mPOS' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_TC_mPos,
	  SUM(CASE WHEN  tx.tipo_tx = 'DEBITO' AND tx.canal = 'mPOS' THEN ISNULL(tx.importe, 0) ELSE 0 END) AS monto_tx_dia_TD_mPos
    -- Se incluyen TX con Transactions.ButtonId = NULL (por API - op.sin boton)
    FROM (
	     -- TARJETA y EFECTIVO
	     SELECT
		   trn.LocationIdentification AS id_cuenta,
		   trn.channel AS canal,
		   CAST(CAST(trn.CreateTimestamp AS DATE) AS DATETIME) AS fecha_procesada,
	      (CASE WHEN LTRIM(RTRIM(tmp.codigo)) = 'EFECTIVO' 
	            THEN (CASE WHEN (LTRIM(RTRIM(trn.CouponStatus)) = 'VENCIDO' OR LTRIM(RTRIM(trn.TransactionStatus)) = 'TX_VENCIDA')
		                   THEN 'CUPON VENCIDO'
			               ELSE 'CUPON'
		              END)
                ELSE LTRIM(RTRIM(tmp.codigo))
           END) AS tipo_tx,	
		   trn.Amount AS importe
	     FROM
		   Transactions.dbo.transactions trn,
		   Configurations.dbo.Medio_De_Pago mdp,
		   Configurations.dbo.Tipo_Medio_Pago tmp
	     WHERE trn.ProductIdentification = mdp.id_medio_pago
		   AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
		   AND LTRIM(RTRIM(tmp.codigo)) IN ('CREDITO', 'DEBITO','EFECTIVO')
		   AND LTRIM(RTRIM(trn.OperationName)) IN ('Compra_offline','Compra_online')
		   AND trn.ResultCode = -1
		   AND trn.ReverseStatus IS NULL
		   AND trn.locationidentification IS NOT NULL
		   AND (trn.ButtonId IS NULL
		        OR 
				EXISTS (SELECT 1
		                FROM
			              Configurations.dbo.Boton btn,
			              Configurations.dbo.Tipo tpo
		                WHERE trn.ButtonId = btn.id_boton
		                  AND btn.id_tipo_concepto_boton = tpo.id_tipo
		                  AND tpo.id_grupo_tipo = 12
		                  AND LTRIM(RTRIM(tpo.codigo)) = 'CPTO_BTN_VTA'
	                    )
                )		
	       AND trn.CreateTimestamp BETWEEN @fecha_desde AND @fecha_hasta
	
	     UNION ALL
	     -- CASHOUT
	     SELECT
		   rdo.id_cuenta,
		   trn.channel AS canal,
		   CAST(CAST(rdo.fecha_alta AS DATE) AS DATETIME) AS fecha_procesada,
		   'CASHOUT' AS tipo_tx,
		   rdo.monto AS importe
	     FROM 
		   Configurations.dbo.Retiro_Dinero rdo,
	       Transactions.dbo.transactions trn
	     WHERE trn.locationidentification = rdo.id_cuenta 
	       AND rdo.cod_respuesta_interno = -1
	       AND rdo.fecha_alta BETWEEN @fecha_desde AND @fecha_hasta
        ) tx
    GROUP BY
	    tx.id_cuenta,
	    tx.fecha_procesada
					
					
    SELECT @registros_afectados = COUNT(*) FROM #info;    
  
  	--  detalle	
	EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
		@id_log_proceso,
		@nombre_sp,
		2,
		'Actualizando tabla Actividad_Transaccional_Cuenta';

    --Obtener actividad x cta./Actualizar   
    IF (@registros_afectados > 0)
	    BEGIN
          MERGE Configurations.dbo.Actividad_Transaccional_Cuenta AS trg  
          USING #INFO AS src 
          ON (trg.id_cuenta = src.id_cuenta AND trg.fecha_procesada = src.fecha_procesada)   
          WHEN MATCHED
          THEN   
            UPDATE   
              SET trg.cant_tx_dia_TC = src.cant_tx_dia_TC,
		          trg.cant_tx_dia_TD = src.cant_tx_dia_TD,
		          trg.cant_tx_dia_cupon = src.cant_tx_dia_cupon,
		          trg.cant_tx_dia_cupon_vencido = src.cant_tx_dia_cupon_vencido,		 
		          trg.cant_tx_dia_cashOut = src.cant_tx_dia_cashOut,	
		          trg.cant_tx_dia_TC_mPos = src.cant_tx_dia_TC_mPos,
		          trg.cant_tx_dia_TD_mPos = src.cant_tx_dia_TD_mPos,
		          trg.monto_tx_dia_TC = src.monto_tx_dia_TC,
		          trg.monto_tx_dia_TD = src.monto_tx_dia_TD,
		          trg.monto_tx_dia_cupon = src.monto_tx_dia_cupon,
		          trg.monto_tx_dia_cupon_vencido = src.monto_tx_dia_cupon_vencido,		 
		          trg.monto_tx_dia_cashOut = src.monto_tx_dia_cashOut,	
		          trg.monto_tx_dia_TC_mPos = src.monto_tx_dia_TC_mPos,
		          trg.monto_tx_dia_TD_mPos = src.monto_tx_dia_TD_mPos,
		          trg.id_log_proceso = @id_log_proceso,	 
		          trg.fecha_modificacion = GETDATE(),   
		          trg.usuario_modificacion = @usuario

          WHEN NOT MATCHED BY TARGET
          THEN
            INSERT(   
		          id_cuenta,  
		          cant_tx_dia_TC,
		          cant_tx_dia_TD,
		          cant_tx_dia_cupon,
		          cant_tx_dia_cupon_vencido,		 
		          cant_tx_dia_cashOut,
		          cant_tx_dia_TC_mPos,
		          cant_tx_dia_TD_mPos,		 	
		          monto_tx_dia_TC,
		          monto_tx_dia_TD,
		          monto_tx_dia_cupon,
		          monto_tx_dia_cupon_vencido,		 
		          monto_tx_dia_cashOut,
				  monto_tx_dia_TC_mPos,
				  monto_tx_dia_TD_mPos,
		          fecha_procesada,
		          id_log_proceso,
		          fecha_alta, 
		          usuario_alta,
		          version	   
                  )
            VALUES(   
		          src.id_cuenta,
                  src.cant_tx_dia_TC,
		          src.cant_tx_dia_TD,
		          src.cant_tx_dia_cupon,
		          src.cant_tx_dia_cupon_vencido,		 
		          src.cant_tx_dia_cashOut,	
		          src.cant_tx_dia_TC_mPos,
		          src.cant_tx_dia_TD_mPos,
		          src.monto_tx_dia_TC,
		          src.monto_tx_dia_TD,
		          src.monto_tx_dia_cupon,
		          src.monto_tx_dia_cupon_vencido,		 
		          src.monto_tx_dia_cashOut,	
                  src.monto_tx_dia_TC_mPos,
                  src.monto_tx_dia_TD_mPos,				  
                  src.fecha_procesada,
		          @id_log_proceso,
		          GETDATE(), 
		          @usuario,
		          1
                  );  
	    END

		
    --detalle	
    EXEC configurations.dbo.Batch_Log_Detalle 
	     @id_nivel_detalle_global,
	     @id_log_proceso,
	     @nombre_sp,
	     2,
	     'Actualización finalizada';

		 
    DROP TABLE #info;


    -- Completar Log de Proceso   
    EXEC configurations.dbo.Batch_Log_Finalizar_Proceso
 		 @id_log_proceso,
		 @registros_afectados,
		 @usuario;
 
    
  COMMIT TRANSACTION;   
RETURN 1;

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
  RETURN 0;
END CATCH;   
 