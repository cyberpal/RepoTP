 
 
CREATE PROCEDURE [dbo].[Batch_Actividad_TX_Cuenta_Compradora] (   
  @fecha_desde_proceso CHAR(8) = NULL --aaaammdd   
 ,@fecha_hasta_proceso CHAR(8) = NULL --aaaammdd   
 ,@usuario VARCHAR(20) = NULL   
 )   
AS   
DECLARE @msg VARCHAR(300);   
DECLARE @version INT = 1;   
DECLARE @id_log_proceso INT;   
DECLARE @flag_ok INT;   
DECLARE @registros_afectados INT;   
DECLARE @fecha_desde DATETIME = NULL;   
DECLARE @fecha_hasta DATETIME = NULL;   
DECLARE @MergeRowCount TABLE (MergeAction VARCHAR(20));   
DECLARE @nombre_sp varchar(50);
DECLARE @id_proceso INT;
DECLARE @id_nivel_detalle_global INT ;    
DECLARE @detalle VARCHAR(200);

SET NOCOUNT ON;   
    
BEGIN TRY   
 BEGIN TRANSACTION;   
    
		SET @nombre_sp = 'Batch_Actividad_TX_Cuenta_Compradora';

		select @id_proceso = id_proceso 
    	from configurations.dbo.proceso
	    where nombre = 'Actividad Transaccional Comprador'

 IF (@id_proceso IS NULL) THROW 51000   
  ,'El parametro Id Proceso tiene valor Nulo'   
  ,1;   

       -- Iniciar Log     
 EXEC  Configurations.dbo.Batch_Log_Iniciar_Proceso 
       @id_proceso   
      ,@fecha_desde   
      ,@fecha_hasta
      ,@Usuario
	  ,@id_log_proceso = @id_log_proceso OUTPUT
	  ,@id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;    

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
 
 	--- incluir fechas
SET @detalle = 'Rango de fechas: @fecha_desde = ' + isnull(cast(@fecha_desde AS VARCHAR), 'NULL') +
                                '@fecha_hasta = ' + isnull(cast(@fecha_hasta AS VARCHAR), 'NULL');

	-- Actualizar Log     
	EXEC  Configurations.[dbo].[Batch_Log_Actualizar_Proceso]  
		@id_log_proceso 
		,@fecha_desde   
		,@fecha_hasta
		,@registros_afectados
		,@Usuario;    

	-- Iniciar detalle	
	EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
		@id_log_proceso,
		@nombre_sp,
		3,
		@detalle;

	--  detalle	
	EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
		@id_log_proceso,
		@nombre_sp,
		2,
		'Actualizando tabla Actividad_MP_Cuenta';

 --Obtener actividad x cta./Actualizar   
 MERGE Configurations.dbo.Actividad_MP_Cuenta AS destino   
 USING (   
  SELECT tx.id_medio_pago_cuenta AS id_medio_pago_cuenta   
   ,COUNT(1) AS cantidad   
   ,SUM(ISNULL(tx.importe,0)) AS importe   
   ,tx.fecha_procesada AS fecha_procesada   
   ,@id_log_proceso AS id_log_proceso   
   ,GETDATE() AS fecha_actual   
   ,@usuario AS usuario   
   ,NULL AS fecha_modificacion   
   ,NULL AS usuario_modificacion   
   ,NULL AS fecha_baja   
   ,NULL AS usuario_baja   
   ,@version AS version   
  FROM (   
   -- TARJETAS   
   SELECT    
    trn.id_medio_pago_cuenta AS id_medio_pago_cuenta   
 ,trn.BuyerAccountIdentification AS id_cta_compradora   
    ,CAST(CAST(trn.CreateTimestamp AS DATE) AS DATETIME) AS fecha_procesada   
    ,LTRIM(RTRIM(tmp.codigo)) AS tipo_tx   
    ,trn.Amount AS importe   
   FROM Transactions.dbo.transactions trn   
    ,Configurations.dbo.Medio_De_Pago mdp   
    ,Configurations.dbo.Tipo_Medio_Pago tmp   
    ,Configurations.dbo.Medio_Pago_Cuenta mpc   
   WHERE trn.ProductIdentification = mdp.id_medio_pago
    AND mpc.fecha_baja IS NULL  
    AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago   
    AND LTRIM(RTRIM(tmp.codigo)) IN (   
     'CREDITO'   
     ,'DEBITO'   
     )   
    AND LTRIM(RTRIM(trn.OperationName)) IN (   
     'Compra_offline'   
     ,'Compra_online'   
     )   
    AND trn.ResultCode = - 1   
    AND trn.ReverseStatus IS NULL   
    AND (   
     trn.ButtonId IS NULL   
     OR EXISTS (   
      SELECT 1   
      FROM Configurations.dbo.Boton btn   
       ,Configurations.dbo.Tipo tpo  
      WHERE trn.ButtonId = btn.id_boton   
       AND btn.id_tipo_concepto_boton = tpo.id_tipo   
       AND tpo.id_grupo_tipo = 12   
       AND LTRIM(RTRIM(tpo.codigo)) = 'CPTO_BTN_VTA'   
      )   
     )   
    AND trn.CreateTimestamp BETWEEN @fecha_desde AND @fecha_hasta    
    AND trn.BuyerAccountIdentification IS NOT NULL   
    AND trn.BuyerAccountIdentification = mpc.id_cuenta   
    AND trn.id_medio_pago_cuenta = mpc.id_medio_pago_cuenta   
   ) tx   
  GROUP BY tx.id_medio_pago_cuenta   
   ,tx.id_cta_compradora      ,tx.fecha_procesada   
   ,tx.tipo_tx   
  ) AS origen(id_medio_pago_cuenta, cantidad, importe, fecha_procesada, id_log_proceso, fecha_actual, usuario, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version)   
  ON (   
    destino.id_mp_cuenta = origen.id_medio_pago_cuenta   
    AND destino.fecha_compra = origen.fecha_procesada   
    )   
 WHEN MATCHED   
  THEN   
   UPDATE   
   SET destino.cant_tx_dia = origen.cantidad   
    ,destino.monto_tx_dia = origen.importe   
 WHEN NOT MATCHED   
  THEN   
   INSERT (   
    id_mp_cuenta   
    ,cant_tx_dia   
    ,monto_tx_dia   
    ,fecha_compra   
    ,id_log_proceso   
    ,fecha_alta   
    ,usuario_alta   
    ,fecha_modificacion   
    ,usuario_modificacion   
    ,fecha_baja   
    ,usuario_baja   
    ,version   
    )   
   VALUES (   
    origen.id_medio_pago_cuenta   
    ,origen.cantidad   
    ,origen.importe   
    ,origen.fecha_procesada   
    ,origen.id_log_proceso   
    ,origen.fecha_actual   
    ,origen.usuario   
    ,origen.fecha_modificacion   
    ,origen.usuario_modificacion   
    ,origen.fecha_baja   
    ,origen.usuario_baja   
    ,origen.version   
    )   
    
 OUTPUT $action INTO @MergeRowCount;   

--  detalle	
EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
	@id_log_proceso,
	@nombre_sp,
	2,
	'Actualización finalizada';


 SET @registros_afectados = (SELECT COUNT(*) FROM @MergeRowCount);   
    
 -- Completar Log de Proceso   
 EXEC configurations.[dbo].[Batch_Log_Finalizar_Proceso] 
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
 


