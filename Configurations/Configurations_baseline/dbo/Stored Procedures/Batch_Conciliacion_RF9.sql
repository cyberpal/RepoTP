
CREATE PROCEDURE dbo.Batch_Conciliacion_RF9(@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @url_servicio VARCHAR(200);
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT = 0;
DECLARE @fecha_pago VARCHAR(10);
DECLARE @id_log_procesoFormat VARCHAR(8);


SET NOCOUNT ON;

	TRUNCATE TABLE Configurations.dbo.contracargos_tmp;
	
	
	EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 9,
		 'Generar Contracargos',
		 NULL,
		 'bpbatch',
		 @id_log_paso = @id_log_paso OUTPUT;
	
	
    SELECT @url_servicio = valor FROM Configurations.dbo.Parametro WHERE codigo = 'URL_WS_CONTRACARGO';
	
	SET @id_log_procesoFormat = CAST(@id_log_proceso AS VARCHAR(8));
	
	INSERT INTO 
	           Contracargos_tmp
	    SELECT 
	           c.id_transaccion,
			   CONVERT(VARCHAR(10), mpp.fecha_pago, 126),
			   @id_log_procesoFormat,
		       mpp.id_movimiento_mp,
		       @id_log_paso,
               c.id_conciliacion, 
               '{"idTransaccion":"'+c.id_transaccion+'","idProceso":"'+@id_log_procesoFormat+'","fechaContracargo":"'+CONVERT(VARCHAR(10), mpp.fecha_pago, 126)+'"}', 
		       @url_servicio
          FROM Configurations.dbo.Conciliacion c 
    INNER JOIN Configurations.dbo.Movimiento_presentado_mp mpp 
	        ON c.id_movimiento_mp = mpp.id_movimiento_mp 
         WHERE c.flag_contracargo = 1 
           AND c.id_disputa = 0
           AND EXISTS (SELECT 1
	                     FROM Configurations.dbo.Conciliacion_manual cm 
	                    WHERE cm.id_movimiento_mp = mpp.id_movimiento_mp
	                      AND cm.flag_procesado = 1
                      )
     UNION ALL
        SELECT 
	           c.id_transaccion,
			   CONVERT(VARCHAR(10), mpp.fecha_pago, 126),
			   @id_log_procesoFormat,
		       mpp.id_movimiento_mp,
		       @id_log_paso,
               c.id_conciliacion, 
               '{"idTransaccion":"'+c.id_transaccion+'","idProceso":"'+@id_log_procesoFormat+'","fechaContracargo":"'+CONVERT(VARCHAR(10), mpp.fecha_pago, 126)+'"}', 
		       @url_servicio
          FROM Configurations.dbo.Conciliacion c 
    INNER JOIN Configurations.dbo.Movimiento_presentado_mp mpp 
	        ON c.id_movimiento_mp = mpp.id_movimiento_mp 
         WHERE c.flag_contracargo = 1 
           AND c.id_disputa = 0;
   

    SELECT @registros_procesados = COUNT(1) FROM Configurations.dbo.contracargos_tmp;
	
	SET @resultado_proceso = 1;

    EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
	     @id_log_paso,
		 NULL,
		 NULL,
		 @resultado_proceso,
		 NULL,
		 @registros_procesados,
		 0,
		 0,
		 0,
		 0,
		 0,
		 0,
		 0,
		 'bpbatch';       
    

