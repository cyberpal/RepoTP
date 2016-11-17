
CREATE PROCEDURE dbo.Batch_Alerta_documentacion_pendiente
AS

DECLARE @id_proceso INT = 27;
DECLARE @id_log_proceso INT = NULL;
DECLARE @id_nivel_detalle_global INT = NULL;
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @primer_aviso INT;
DECLARE @segundo_aviso INT;
DECLARE @aviso_mensual INT;
DECLARE @url_notificacion VARCHAR(200);
DECLARE @url_portal VARCHAR(200);
DECLARE @cant_registros INT = 0;
DECLARE @msg VARCHAR(MAX);

SET NOCOUNT ON;

 
      EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso 
           @id_proceso,
           NULL,
           NULL,
           @Usuario,
           @id_log_proceso = @id_log_proceso OUTPUT,
           @id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;
		 
	
	SELECT @primer_aviso = CAST(valor AS INT)
      FROM Configurations.dbo.Parametro
     WHERE codigo = 'DOC_PRIMER_AVISO';
	 
	 
	SELECT @segundo_aviso = CAST(valor AS INT)
      FROM Configurations.dbo.Parametro
     WHERE codigo = 'DOC_SEGUNDO_AVISO';
	 
	 
	SELECT @aviso_mensual = CAST(valor AS INT)
      FROM Configurations.dbo.Parametro
     WHERE codigo = 'DOC_AVISO_MENSUAL';
	

    SELECT @url_portal = valor
      FROM Configurations.dbo.Parametro
     WHERE codigo = 'mailUrl';	
	 
	SELECT @url_notificacion = valor 
	  FROM Configurations.dbo.Parametro 
	 WHERE codigo = 'URL_WS_NOTIFICACION';	

	 
	TRUNCATE TABLE Configurations.dbo.cuenta_documentacion_faltante_tmp;

	
BEGIN TRY
    BEGIN TRANSACTION;	
	
	
   INSERT INTO Configurations.dbo.cuenta_documentacion_faltante_tmp
	    SELECT 
		       @url_notificacion,
			   '{"idNotificacion":"116",
		         "idCuenta":"'+CAST(cta.id_cuenta AS VARCHAR(10))+
				'","values":{"vinculo":"'+@url_portal+
				            '","mailForm":"notificaciones@todopago.com.ar","nombreVendedor":"'+cta.denominacion2+
				            '","mailVendedor":"'+uc.Email+
				'"},
				"attachments":null}'
          FROM Configurations.dbo.Cuenta cta
    INNER JOIN Configurations.dbo.Tipo t
            ON t.id_tipo = cta.id_tipo_cuenta
    INNER JOIN Configurations.dbo.Estado e
            ON e.id_estado= cta.id_estado_cuenta
    INNER JOIN Configurations.dbo.Situacion_Fiscal_Cuenta sfc
            ON sfc.id_cuenta = cta.id_cuenta
	INNER JOIN Configurations.dbo.Usuario_Cuenta uc
	        ON uc.id_cuenta = cta.id_cuenta
         WHERE t.codigo = 'CTA_EMPRESA'
    	   AND e.codigo = 'CTA_PENDIENTE'
    	   AND sfc.flag_validacion_excepcion IS NULL
    	   AND sfc.id_estado_documentacion = 21
    	   AND (DATEDIFF(DAY,cta.fecha_alta ,GETDATE()) = @primer_aviso
		        OR
				DATEDIFF(DAY,cta.fecha_alta ,GETDATE()) = @segundo_aviso
		        OR
                DATEDIFF(DAY,cta.fecha_alta ,GETDATE()) % @aviso_mensual = 0
               )
		   AND cta.fecha_alta > GETDATE();				

    COMMIT TRANSACTION;
	
	SELECT @cant_registros = COUNT(1) FROM Configurations.dbo.cuenta_documentacion_faltante_tmp
	
	EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso
         @id_log_proceso,
         @cant_registros,
         @usuario;
		 
	 RETURN 1;

END TRY

BEGIN CATCH

    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;	

