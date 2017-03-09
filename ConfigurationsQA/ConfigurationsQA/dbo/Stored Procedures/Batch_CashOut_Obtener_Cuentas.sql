CREATE PROCEDURE [dbo].[Batch_CashOut_Obtener_Cuentas]
(
      @registros_procesados INT OUTPUT
)              
AS                        
DECLARE @EsFeriado BIT = NULL;  
DECLARE @url_ws_cashout VARCHAR(256);  
DECLARE @url_ws_notificacion VARCHAR(256);  
DECLARE @url_ws_login_batch VARCHAR(256);  
                
SET NOCOUNT ON;          

BEGIN TRY
    TRUNCATE TABLE Configurations.dbo.Cuentas_CashOut_tmp;

    SELECT @Esferiado = fro.esFeriado
      FROM Configurations.dbo.Feriados fro 
     WHERE CAST(fro.fecha AS DATE) = CAST(GETDATE() AS DATE)
       AND fro.habilitado = 1;   

	IF (@Esferiado IS NULL) THROW 50001, 'No existe el registro en la tabla de Feriados.', 1;
			   
	SELECT @url_ws_notificacion = p.valor
	  FROM Configurations.dbo.Parametro p 
	 WHERE p.codigo = 'URL_WS_NOTIFICACION';

	IF (@url_ws_notificacion IS NULL) THROW 50001, 'No existe el parametro @url_ws_notificacion en la tabla', 1;
	
	
	SELECT @url_ws_cashout = p.valor
	  FROM Configurations.dbo.Parametro p 
	 WHERE p.codigo = 'URL_WS_CASHOUT';

	IF (@url_ws_cashout IS NULL) THROW 50001, 'No existe el parametro @url_ws_cashout en la tabla', 1;


	SELECT @url_ws_login_batch = p.valor 
      FROM Configurations.dbo.Parametro p 
     WHERE p.codigo = 'URL_WS_LOGIN_BATCH'

	IF (@url_ws_login_batch IS NULL) THROW 50001, 'No existe el parametro @url_ws_login_batch en la tabla', 1;

END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;
	THROW;
	RETURN 0;
END CATCH; 



	   
    
 BEGIN TRY              
  BEGIN TRANSACTION;      
    
    IF(@EsFeriado IS NULL)	
	  PRINT 'La Fecha actual no es Día Habil, el proceso no se ejecuta';
    ELSE
      BEGIN	
	  
	         INSERT INTO Configurations.dbo.Cuentas_CashOut_tmp
                  SELECT 
                         cta.id_cuenta,
                         CASE WHEN tpo.codigo = 'CTA_EMPRESA' THEN cta.denominacion1 ELSE cta.denominacion1+' '+cta.denominacion2 END,
                         CASE WHEN tpo.codigo = 'CTA_PARTICULAR' THEN ibc.cuit ELSE cta.numero_CUIT END,
                         uca.id_usuario_cuenta,
                         cvl.disponible,
                         ibc.cbu_cuenta_banco,
						 @url_ws_cashout,
						 @url_ws_notificacion,
						 @url_ws_login_batch
                    FROM Configurations.dbo.Cuenta cta
              INNER JOIN Configurations.dbo.Cuenta_Virtual cvl
                      ON cta.id_cuenta = cvl.id_cuenta 
              INNER JOIN Configurations.dbo.Estado est
                      ON cta.id_estado_cuenta = est.id_estado
              INNER JOIN Configurations.dbo.Tipo tpo
                      ON cta.id_tipo_cuenta = tpo.id_tipo
              INNER JOIN Configurations.dbo.Tipo tpo2
                      ON cvl.id_tipo_cashout = tpo2.id_tipo
              INNER JOIN Configurations.dbo.Usuario_Cuenta uca
                      ON cta.id_cuenta = uca.id_cuenta
         LEFT OUTER JOIN Configurations.dbo.Informacion_Bancaria_Cuenta ibc
                      ON (cta.id_cuenta = ibc.id_cuenta
                          AND 
						  ibc.flag_vigente = 1
                         )
                   WHERE est.codigo IN ('CTA_HABILITADA','CTA_INHAB_VENTA')
                     AND tpo2.codigo = 'CASHOUT_AUTO'
                     AND cvl.disponible > 0;


				  SELECT @registros_procesados = COUNT(1) FROM Configurations.dbo.Cuentas_CashOut_tmp;
					 
      END 
         
   COMMIT TRANSACTION;  
   
   RETURN 1;         
   
 END TRY                  
              
BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;
	RETURN 0;
END CATCH; 
  