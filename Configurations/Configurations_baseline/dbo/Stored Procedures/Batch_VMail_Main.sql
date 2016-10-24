
CREATE PROCEDURE [dbo].[Batch_VMail_Main] (@Usuario VARCHAR(20))
AS
/*Variables*/
DECLARE @v_valor INT;
DECLARE @estado_mail_pendiente INT;
DECLARE @estado_mail_vencido INT;
DECLARE @id_log_proceso INT;
DECLARE @id_proceso INT;
DECLARE @log_proceso_ok INT;
DECLARE @fecha_resultado DATETIME;
DECLARE @registros_afectados INT;
DECLARE @id_nivel_detalle_global INT;
DECLARE @nombre_sp varchar(50);
DECLARE @msg varchar(50);
DECLARE @detalle varchar(200);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION

	BEGIN TRY
		BEGIN
			PRINT 'Comienzo del Proceso Actualizacion de mails...'
			SET @nombre_sp = 'Batch_VMail_Main';
			
			SELECT @id_proceso = lpo.id_proceso
			FROM Configurations.dbo.Proceso lpo
			WHERE lpo.nombre LIKE 'vencimiento de mail'

			
			-- Iniciar Log     
			EXEC  Configurations.dbo.Batch_Log_Iniciar_Proceso 
				@id_proceso   
				,NULL   
				,NULL
				,@Usuario
				,@id_log_proceso = @id_log_proceso OUTPUT
				,@id_nivel_detalle_global = @id_nivel_detalle_global OUTPUT;    

			
			 -- Iniciar detalle	
			EXEC configurations.dbo.Batch_Log_Detalle 
                 @id_nivel_detalle_global,
  				 @id_log_proceso,
				 @nombre_sp,
			     2,
				 'Se recuperan los IDs de los estados requeridos';
 
 
			-- Se recuperan los IDs de los estados requeridos
			SELECT @estado_mail_vencido = ROUND(SUM(trn.estado_vencido), 2),
				@estado_mail_pendiente = ROUND(SUM(trn.estado_pendiente), 2)
			FROM (
				SELECT id_estado AS estado_pendiente,
					0 AS estado_vencido
				FROM Configurations.dbo.Estado tmp
				WHERE tmp.codigo = 'mail_pendiente'
				
				UNION
				
				SELECT 0 AS estado_pendiente,
					id_estado AS estado_vencido
				FROM Configurations.dbo.Estado tmp
				WHERE tmp.codigo = 'mail_vencido'
				) trn


			--Se obtiene el valor del parametro
			SELECT @v_valor = cast(prm.valor AS INT)
			FROM Configurations.dbo.Parametro prm
			WHERE prm.codigo = 'MAIL_HORAS_CADUC' -- ok recuperacion del campo valor (tipo dato varchar 256)

			--Se calcula la fecha menos el parametro
			SELECT @fecha_resultado = DATEADD(HOUR, (@v_valor) * - 1, getdate());

			UPDATE Configurations.dbo.Historico_Mail_Cuenta
			SET id_estado_mail = @estado_mail_vencido,
				fecha_modificacion = GETDATE(),
				usuario_modificacion = @Usuario
			WHERE id_estado_mail = @estado_mail_pendiente
				AND fecha_alta < @fecha_resultado;

			SET @registros_afectados = @@ROWCOUNT;

			-- parametros de logueo
			SET @detalle = 'fecha_resultado = ' + convert(char(10),isnull(cast(@fecha_resultado AS date), 'NULL')) + ' estado_mail_vencido = ' + isnull(cast(@estado_mail_vencido AS varchar), 'NULL') + ' estado_mail_pendiente = ' + isnull(cast(@estado_mail_pendiente AS varchar), 'NULL') + ' valor parametro = ' + isnull(cast(@v_valor AS varchar), 'NULL');
               
			-- detalle	
			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@detalle;

	        -- Completar Log de Proceso   
            EXEC configurations.[dbo].[Batch_Log_Finalizar_Proceso] 
 			@id_log_proceso,
			@registros_afectados,
			@usuario;
 
		END
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;
            
			SELECT @msg = ERROR_MESSAGE();   
    
			 EXEC configurations.dbo.Batch_Log_Detalle 
			@id_nivel_detalle_global,
 			@id_log_proceso,
			@nombre_sp,
			1,
			@msg;
 
		RETURN 0;
	END CATCH

	COMMIT TRANSACTION

	RETURN 1;
END
