
CREATE PROCEDURE [dbo].[Batch_Log_Borrar_Antiguos](
 @id_proceso INT,
 @id_nivel_detalle INT
)
AS

DECLARE @log_borrar TABLE (id_log INT);
DECLARE @id_tipo_historico_log INT;
DECLARE @valor_historico_log INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @codigo_tipo VARCHAR(10);
DECLARE @fecha DATETIME;
DECLARE @flag BIT = 0;
DECLARE @Msg VARCHAR(80);

BEGIN          
	
	SET NOCOUNT ON;          
	              
    BEGIN TRANSACTION 
	
	BEGIN TRY
	   
	   SELECT @id_tipo_historico_log = clp.id_tipo_historico_log,
              @valor_historico_log = clp.valor_historico_log,
			  @id_nivel_detalle_global = clp.id_nivel_detalle_lp
       FROM Configurations.dbo.Configuracion_Log_Proceso clp
       WHERE id_proceso = @id_proceso;

      IF(@id_nivel_detalle <= @id_nivel_detalle_global)  
	  BEGIN
	   SELECT @codigo_tipo = t.codigo 
	   FROM Configurations.dbo.Tipo t
	   WHERE t.id_tipo = @id_tipo_historico_log;


	   IF(@codigo_tipo LIKE '%ANT%DIAS%')
	      BEGIN
		    SET @fecha = DATEADD(DD, @valor_historico_log*-1,GETDATE());
			SET @flag = 1;
		  END
	   ELSE IF(@codigo_tipo LIKE '%ANT%MESES%')
	      BEGIN
			SET @fecha = DATEADD(MM, @valor_historico_log*-1,GETDATE());
			SET @flag = 1;
		  END


       IF (@flag = 1)
	     BEGIN
		   INSERT @log_borrar
		   SELECT lp.id_log_proceso
		   FROM Configurations.dbo.Log_Proceso lp
		   WHERE lp.id_proceso = @id_proceso
		     AND CAST(lp.fecha_alta AS DATE) < CAST(@fecha AS DATE);

           DELETE Configurations.dbo.Detalle_Log_Proceso
		   WHERE id_log_proceso IN (SELECT id_log FROM @log_borrar);

		 END
	   ELSE
		 BEGIN
		   INSERT @log_borrar
		   SELECT TOP(@valor_historico_log) lp.id_log_proceso
		   FROM Configurations.dbo.Log_Proceso lp
		   WHERE lp.id_proceso = @id_proceso
		   ORDER BY lp.fecha_alta DESC

           DELETE dlp
		   FROM Configurations.dbo.Detalle_Log_Proceso dlp
		   INNER JOIN Configurations.dbo.Log_Proceso lp
		           ON dlp.id_log_proceso = lp.id_log_proceso
		   WHERE dlp.id_log_proceso NOT IN (SELECT id_log FROM @log_borrar)
		     AND lp.id_proceso = @id_proceso;
		 END	  
	   END  
	COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT @msg = ERROR_MESSAGE();

		THROW 51000,
			@Msg,
			1;
	END CATCH;

	RETURN 1;
END;
