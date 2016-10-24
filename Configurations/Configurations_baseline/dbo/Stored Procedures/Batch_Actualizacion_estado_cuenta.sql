 
CREATE PROCEDURE [dbo].[Batch_Actualizacion_estado_cuenta] (   
  @usuario VARCHAR(20) = NULL   
 )   
AS   

DECLARE @registros_afectados INT;
DECLARE @msg VARCHAR(50);  
DECLARE @id_log_proceso INT;
DECLARE @id_proceso INT = NULL;
DECLARE @id_nivel_detalle_global INT; 
DECLARE @nombre_sp VARCHAR(50);
DECLARE @MergeRowCount TABLE (MergeAction VARCHAR(20)); 
DECLARE @horas_de_espera INT;
DECLARE @id_estado_cuenta_vencida INT;
DECLARE @cuentas TABLE (id_cuenta INT);

SET NOCOUNT ON;   
    
BEGIN TRY   
 BEGIN TRANSACTION;   
    

	SET @nombre_sp = OBJECT_NAME(@@PROCID);

	
    SELECT @id_proceso = id_proceso 
	FROM configurations.dbo.proceso
	WHERE nombre = 'Actualización estado cuenta'
    
	
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

   

    -- Obtener Cuentas Vencidos	
    EXEC configurations.dbo.Batch_Log_Detalle 
		 @id_nivel_detalle_global,
 		 @id_log_proceso,
		 @nombre_sp,
		 2,
		 'Obtener cuentas vencidas.';
		
		
	SET @horas_de_espera = (SELECT CAST(valor AS INT)
	                        FROM Configurations.dbo.Parametro
	                        WHERE codigo = 'PZO_VEND_CONF');

	INSERT
       @cuentas	
    SELECT
       ctas.id_cuenta
    FROM (SELECT
		    cta.id_cuenta,
		    MAX(nea.fecha_envio) AS max_fecha_envio
	      FROM
		    Configurations.dbo.Cuenta cta,
		    Configurations.dbo.Usuario_Cuenta uca,
		    Configurations.dbo.Estado edo,
		    Configurations.dbo.Notificacion_Enviada nea
	      WHERE cta.id_cuenta = uca.id_cuenta
	        AND cta.id_estado_cuenta = edo.id_estado
	        AND cta.id_cuenta = nea.id_cuenta 
	        AND edo.Codigo = 'CTA_CREADA'
	        AND uca.mail_confirmado = 0
	        AND nea.id_notificacion = 1
	        AND nea.flag_enviado = 1
	      GROUP BY cta.id_cuenta
        ) ctas
    WHERE DATEADD(HH, @horas_de_espera, ctas.max_fecha_envio) < GETDATE();
	
	  
	SET @registros_afectados = @@ROWCOUNT;
	
	-- Actualizar Cuentas  
	IF (@registros_afectados <> 0)
	  BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'Actualizar el estado de las cuentas.';
		 
		 
		SET @id_estado_cuenta_vencida = (SELECT id_estado
	                                     FROM Configurations.dbo.Estado 
	                                     WHERE Codigo = 'CTA_VENCIDA');
		 
		 
	    UPDATE Configurations.dbo.Cuenta 
	    SET id_estado_cuenta = @id_estado_cuenta_vencida,
	        fecha_modificacion = GETDATE(),
	    	usuario_modificacion = @usuario
	    WHERE EXISTS (SELECT * FROM @cuentas);
	  END
	ELSE
      BEGIN
	    EXEC configurations.dbo.Batch_Log_Detalle 
		@id_nivel_detalle_global,
 		@id_log_proceso,
		@nombre_sp,
		2,
		'No se encontraron cuentas a procesar.';
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