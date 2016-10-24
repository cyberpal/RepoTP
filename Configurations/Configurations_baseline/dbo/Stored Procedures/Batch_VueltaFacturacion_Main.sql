
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_Main] (@Usuario VARCHAR(20))
AS
	
	DECLARE @ret_items_pendientes INT=0;
	DECLARE @ret_calculo_ciclo INT=0;
	DECLARE @ret_insert_MPOS INT=0;
	DECLARE @ret_log_proceso INT=0;
	DECLARE @ret_log_paso_carga INT=0;
	DECLARE @ret_log_paso_update INT=0;
	DECLARE @ret_log_finalizar_proceso INT=0;
	DECLARE @msg_error VARCHAR(max);
	DECLARE @id_proceso INT = 0;
	DECLARE @id_log_proceso INT = 0;
	DECLARE @id_log_paso INT = 0;
	DECLARE @items_pendientes INT = 0;
	DECLARE @flag_ok INT=0;
	DECLARE @flag_ok_MPOS INT=0;
	DECLARE @cantidad_registros_MPOS INT=0;
	DECLARE @registros_procesados INT=0;
	DECLARE @importe_procesados DECIMAL(12, 2);
	DECLARE @registros_aceptados INT=0;
	DECLARE @importe_aceptados DECIMAL(12, 2);
	DECLARE @registros_rechazados INT=0;
	DECLARE @importe_rechazados DECIMAL(12, 2);
	DECLARE @fecha_comienzo_proceso DATETIME;
	DECLARE @fecha_vuelta_desde DATETIME;
	DECLARE @fecha_vuelta_hasta DATETIME;
	DECLARE @id_ciclo_facturacion INT=0;
	DECLARE @id_nivel_detalle_global INT=0;
	DECLARE @nombre_sp VARCHAR(80);

BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
	
	BEGIN TRANSACTION;
		
		-- Obtener el ID de Proceso
		SET @msg_error = 'No se encontró el ID de Proceso de Vuelta de Facturación';

		SET @nombre_sp = 'Batch_VueltaFacturacion_Main';

		SELECT @id_proceso = lpo.id_proceso FROM Configurations.dbo.Proceso lpo
		WHERE lpo.nombre LIKE 'Vuelta de Facturaci%';

		SELECT @fecha_comienzo_proceso=getdate()

		EXEC @ret_calculo_ciclo=Configurations.dbo.Batch_VueltaFacturacion_Calcular_Ciclo_Facturacion
		     @fecha_comienzo_proceso,
			 @fecha_vuelta_desde OUTPUT,
			 @fecha_vuelta_hasta OUTPUT,
			 @id_ciclo_facturacion OUTPUT;
		
		print @fecha_vuelta_desde
		print @fecha_vuelta_hasta
		print @id_ciclo_facturacion

		DECLARE @anio INT = DATEPART(YY, DATEADD(YY, 0, @fecha_vuelta_hasta))
		DECLARE @mes INT = DATEPART(MM, DATEADD(MM, 0, @fecha_vuelta_hasta))

		IF (@id_proceso IS NULL)
		BEGIN
			THROW 51000,'El registro id de proceso no existe.',1;
		END;
		
		EXEC @ret_log_proceso = Configurations.dbo.Batch_Log_Iniciar_Proceso 
		     @id_proceso,
			 @fecha_vuelta_desde,
			 @fecha_vuelta_hasta,
			 @Usuario,
			 @id_log_proceso OUTPUT,
			 @id_nivel_detalle_global OUTPUT;

		IF (@id_log_proceso IS NULL)
		BEGIN
			THROW 51000,'id_log_proceso es NULO.',1;
		END;

		-- Iniciar Log de Paso
		SET @msg_error = 'No se pudo iniciar el Log de Paso de Proceso';


		EXEC @ret_log_paso_carga = Configurations.dbo.Batch_Log_Iniciar_Paso 
		     @id_log_proceso,
			 1,
			 'Procesar ANAFACTU',
			 NULL,
			 @Usuario,
			 @id_log_paso OUTPUT;

		IF (@id_log_paso IS NULL)
		
		BEGIN
			THROW 51000,'id_log_paso es NULO.',1;
		END;

		EXEC configurations.dbo.Batch_Log_Detalle 
		     @id_nivel_detalle_global,
			 @id_log_proceso,
			 @nombre_sp,
			 2,
			 'Fin: Log proceso y Log paso';

		COMMIT TRANSACTION;
		
		END TRY

		BEGIN CATCH
			
			IF (@@TRANCOUNT > 0)
			
			BEGIN
				
				ROLLBACK TRANSACTION;

				THROW;
			END
		
		END CATCH
END
		
IF (@id_log_proceso is not null AND @id_log_paso is not null)

BEGIN

	BEGIN TRY
	
	BEGIN TRANSACTION;
		
		print @id_ciclo_facturacion

		EXEC @ret_insert_MPOS = Configurations.dbo.Batch_VueltaFacturacion_Insertar_Items_MPOS
			 @id_log_paso,
			 @fecha_vuelta_desde,
			 @fecha_vuelta_hasta,
			 @id_ciclo_facturacion,
			 @mes,
			 @anio,
		     @Usuario;
		print 'sale de aca'

		EXEC configurations.dbo.Batch_Log_Detalle 
		     @id_nivel_detalle_global,
			 @id_log_proceso,
			 @nombre_sp,
			 2,
			 'Fin: Carga items MPOS';
		
		TRUNCATE TABLE Configurations.dbo.Item_Facturacion_tmp;

		EXEC @ret_items_pendientes = Configurations.dbo.Batch_VueltaFacturacion_ObtenerRegistros 
		     @id_log_paso,
			 @items_pendientes OUTPUT;

		EXEC configurations.dbo.Batch_Log_Detalle 
		     @id_nivel_detalle_global,
			 @id_log_proceso,
			 @nombre_sp,
			 3,
			 'Fin: Recuperacion registros facturados';

		-- Obtener Items de Facturación Pendientes
		SET @msg_error = 'No se pudo obtener los Items de Facturación pendientes';

		IF (@items_pendientes > 0)
		BEGIN
			-- Buscar registros coincidentes en Vuelta de Facturación
			SET @msg_error = 'No se pudo buscar coincidencias en Vuelta de Facturación';

			EXEC  @flag_ok = Configurations.dbo.Batch_VueltaFacturacion_BuscarCoincidencias 
			      @items_pendientes;

			EXEC configurations.dbo.Batch_Log_Detalle 
		     @id_nivel_detalle_global,
			 @id_log_proceso,
			 @nombre_sp,
			 3,
			 'Fin: Buscar coincidencias';

			IF @flag_ok = 1
			BEGIN
				-- Procesar los items
				SET @msg_error = 'No se pudieron procesar los Items de Facturación pendientes';

				EXEC @flag_ok = Configurations.dbo.Batch_VueltaFacturacion_ProcesarItems @items_pendientes,
					@Usuario,
					@id_log_proceso;

				EXEC configurations.dbo.Batch_Log_Detalle 
		              @id_nivel_detalle_global,
			          @id_log_proceso,
			          @nombre_sp,
			          3,
			          'Fin: Buscar coincidencias';

				IF @flag_ok <> 1
				BEGIN
					THROW 51000,
						'flag_ok distinto de 1',
						1;
				END;
			END;
			ELSE
			BEGIN
				THROW 51000,
					'flag_ok distinto de 1',
					1;
			END;
		END
		ELSE
		
		BEGIN
			SET @msg_error = 'No hay items pendientes';
		END;

		-- Actualizar Log Paso
		SELECT @registros_procesados = count(1),
			   @importe_procesados = sum(ift.suma_cargos_aurus),
			   @registros_aceptados = sum(CASE 
					WHEN ift.vuelta_facturacion = 'Procesado'
						THEN 1
					ELSE 0
					END),
			   @importe_aceptados = sum(CASE 
					WHEN ift.vuelta_facturacion = 'Procesado'
						THEN ift.suma_cargos_aurus
					ELSE 0
					END),
			  @registros_rechazados = sum(CASE 
					WHEN ift.vuelta_facturacion <> 'Procesado'
						THEN 1
					ELSE 0
					END),
			 @importe_rechazados = sum(CASE 
					WHEN ift.vuelta_facturacion <> 'Procesado'
						THEN ift.suma_cargos_aurus
					ELSE 0
					END)
	   FROM Configurations.dbo.Item_Facturacion_tmp ift;

	
	   EXEC @ret_log_paso_update = Configurations.dbo.Batch_Log_Finalizar_Paso 
				@id_log_paso,
				NULL,
				NULL,
				1,
				NULL,
				@registros_procesados,
				@importe_procesados,
				@registros_aceptados,
				@importe_aceptados,
				@registros_rechazados,
				@importe_rechazados,
				NULL,
				NULL,
				@Usuario;

		
		EXEC @ret_log_finalizar_proceso = Configurations.dbo.Batch_Log_Finalizar_Proceso 
		     @id_log_proceso,
			 @registros_procesados,
			 @Usuario;

		COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		PRINT @msg_error + ' - ' + ERROR_MESSAGE();

		RETURN 0;
	
	END CATCH;
	
	RETURN 1;

END;
