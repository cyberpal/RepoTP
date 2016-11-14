
CREATE PROCEDURE [dbo].[Batch_Conciliacion_RF10](@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @url VARCHAR(200);
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT = 0;

SET NOCOUNT ON;
    
	TRUNCATE TABLE Configurations.dbo.Notificaciones_tmp;
	
	
	EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 10,
		 'Enviar Notificaciones',
		 NULL,
		 'bpbatch',
		 @id_log_paso = @id_log_paso OUTPUT;
	
	
    SELECT @url = valor FROM Configurations.dbo.Parametro WHERE codigo = 'URL_WS_NOTIF_PUSH';
	
	
	INSERT INTO Configurations.dbo.Notificaciones_tmp (
	        id_conciliacion,
			body_json,
			url_servicio
			)
		SELECT 
		    cln.id_conciliacion,
		    '{"idNotificacion":5,"idCuenta":"'+CAST(tc.LocationIdentification AS VARCHAR(10))+'","values":{"codigoBanco":null,"nombreVendedor":"'+(CASE WHEN cta.id_tipo_cuenta = 29 THEN  cta.denominacion1 ELSE cta.denominacion2+' '+cta.denominacion1 END)+'","concepto":"'+tc.SaleConcept+'","montoBruto":"'+CAST(tc.Amount AS VARCHAR(12))+'","cliente":"'+tc.credentialholdername+'","mailCliente":"'+tc.CredentialEmailAddress+'","motivoRechazo":null,"TransactionId":"'+cln.id_transaccion+'"}}',
			@url
	   FROM Configurations.dbo.Conciliacion cln
 INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mmp
	     ON mmp.id_movimiento_mp = cln.id_movimiento_mp
 INNER JOIN Configurations.dbo.Medio_de_Pago mdp
		 ON mmp.id_medio_pago = mdp.id_medio_pago
 INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
		 ON cln.id_transaccion = tc.Id
 INNER JOIN Configurations.dbo.Cuenta cta
		 ON cta.id_cuenta = tc.LocationIdentification
	  WHERE cln.flag_notificado = 0
		AND mdp.id_tipo_medio_pago = 3;
   

    SELECT @registros_procesados = COUNT(1) FROM Configurations.dbo.Cupones_tmp;
	
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
    


