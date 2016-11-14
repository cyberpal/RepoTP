
CREATE PROCEDURE [dbo].[Medios_Vencidos] 
(
	@id_log_proceso INT = NULL,
	@usuario VARCHAR(20) = NULL,
	@contador INT OUTPUT
)        
    
AS

DECLARE @id_paso_proceso INT = NULL;
DECLARE @msg VARCHAR(255) = NULL;
DECLARE @id_log_paso INT = NULL



SET NOCOUNT ON;

BEGIN TRANSACTION;
BEGIN TRY

SET @id_paso_proceso = 1;

-- Inicio Log paso proceso 

	EXEC  @id_log_paso = Configurations.dbo.Iniciar_Log_Paso_Proceso 
	  
	   @id_log_proceso
	  ,@id_paso_proceso
      ,NULL
      ,NULL
      ,@usuario;
	  

-- Inicio proceso 

BEGIN
        SELECT @contador = COUNT(*) FROM Configurations.dbo.medio_pago_cuenta MPC
	    INNER JOIN tipo_medio_pago tpo ON MPC.id_tipo_medio_pago = tpo.id_tipo_medio_pago
		WHERE  (
		LEFT (fecha_vencimiento, 2) < DATEPART (MM, GETDATE())
		AND RIGHT (fecha_vencimiento, 4) = DATEPART (YYYY, GETDATE())
		AND id_estado_medio_pago <> 41
		)
		OR
		(
		RIGHT (fecha_vencimiento, 4) < DATEPART (YYYY, GETDATE())
		AND id_estado_medio_pago <> 41
		AND tpo.id_tipo_medio_pago = 1              --SOLO MEDIOS CREDITO
		)

		
		UPDATE Configurations.dbo.medio_pago_cuenta 
		SET id_estado_medio_pago = (
		CASE WHEN (
		LEFT (fecha_vencimiento, 2) < DATEPART (MM, GETDATE())
		AND RIGHT (fecha_vencimiento, 4) = DATEPART (YYYY, GETDATE())
		)
		OR
		(
		RIGHT (fecha_vencimiento, 4) < DATEPART (YYYY, GETDATE())
		)
		THEN 41
		ELSE id_estado_medio_pago 
		END),

		fecha_modificacion = (
		CASE WHEN (
		LEFT (fecha_vencimiento, 2) < DATEPART (MM, GETDATE())
		AND RIGHT (fecha_vencimiento, 4) = DATEPART (YYYY, GETDATE())
		)
		OR
		(
		RIGHT (fecha_vencimiento, 4) < DATEPART (YYYY, GETDATE())
		)
		THEN getdate()
		ELSE fecha_modificacion 
		END),

		usuario_modificacion = (
		CASE WHEN (
		LEFT (fecha_vencimiento, 2) < DATEPART (MM, GETDATE())
		AND RIGHT (fecha_vencimiento, 4) = DATEPART (YYYY, GETDATE())
		)
		OR
		(
		RIGHT (fecha_vencimiento, 4) < DATEPART (YYYY, GETDATE())
		)
		THEN 'Script' 
		ELSE usuario_modificacion 
		END)	
	
		WHERE id_estado_medio_pago <> 41
		AND id_tipo_medio_pago = 1              --SOLO MEDIOS CREDITO
		
END


END TRY

BEGIN CATCH
    IF(@@TRANCOUNT > 0)
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE(), @id_log_paso = NULL;
	THROW  51000, @msg, 1;
	
END CATCH;

COMMIT TRANSACTION;

RETURN @id_log_paso;
