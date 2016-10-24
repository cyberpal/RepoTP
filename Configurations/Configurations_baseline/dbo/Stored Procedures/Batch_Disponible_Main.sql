
CREATE PROCEDURE [dbo].[Batch_Disponible_Main] (@Usuario VARCHAR(20))
AS
-- Rango de fechas de proceso
DECLARE @fecha_desde_proceso DATETIME;
DECLARE @fecha_hasta_proceso DATETIME;
-- Log de proceso
DECLARE @id_proceso INT = 6;
DECLARE @id_log_proceso INT;
DECLARE @id_nivel_detalle_global INT;
-- flag de proceso OK
DECLARE @flag_ok INT;
-- Parámetros de tipo y origen de movimiento para Saldo Disponible
DECLARE @id_tipo_movimiento INT;
DECLARE @id_origen_movimiento INT;
-- Variables de iteracion
DECLARE @i INT = 1;
DECLARE @cuentas_count INT;
-- Valores por Cuenta
DECLARE @id_cuenta INT;
DECLARE @importe DECIMAL(12, 2);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Obtener rango de fechas del proceso
		SELECT @fecha_desde_proceso = ISNULL(MAX(cast(lpo.fecha_fin_ejecucion AS DATE)), '20140901 00:00:00.000'),
			@fecha_hasta_proceso = DATEADD(SS, - 1, DATEADD(DD, 1, cast(cast(getdate() AS DATE) AS DATETIME)))
		FROM Configurations.dbo.Log_Proceso lpo
		WHERE lpo.id_proceso = @id_proceso
			AND lpo.fecha_fin_ejecucion IS NOT NULL;

		-- Obtener tipo de movimiento Crédito
		SELECT @id_tipo_movimiento = id_tipo
		FROM configurations.dbo.Tipo tpo
		WHERE tpo.codigo = 'MOV_CRED';

		-- Obtener origen de movimiento Proceso
		SELECT @id_origen_movimiento = id_tipo
		FROM configurations.dbo.Tipo tpo
		WHERE tpo.codigo = 'ORIG_PROCESO';

		-- Iniciar Log
		EXEC Configurations.dbo.Batch_Log_Iniciar_Proceso @id_proceso,
			@fecha_desde_proceso,
			@fecha_hasta_proceso,
			@usuario,
			@id_log_proceso OUTPUT,
			@id_nivel_detalle_global OUTPUT;

		IF (@id_log_proceso IS NOT NULL)
			EXEC @flag_ok = Configurations.dbo.Batch_Disponible_Obtener_Movimientos @fecha_hasta_proceso;

		IF (@flag_ok = 1)
			EXEC @flag_ok = Configurations.dbo.Batch_Disponible_Obtener_Totales_Por_Cuenta @cuentas_count OUTPUT;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		throw;

		RETURN 0;
	END CATCH;

	-- Si no hubo error obteniendo los datos a procesar
	IF (@flag_ok = 1)
	BEGIN
		-- Para cada Cuenta
		WHILE (@i <= @cuentas_count)
		BEGIN
			BEGIN TRY
				-- Obtener Cuenta e Importe
				SELECT @id_cuenta = tmp.id_cuenta,
					@importe = tmp.importe
				FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp tmp
				WHERE tmp.i = @i;

				-- Actualizar Saldo Disponible
				EXEC @flag_ok = Configurations.dbo.Batch_Disponible_Actualizar_Saldo @id_cuenta,
					@importe,
					@id_tipo_movimiento,
					@id_origen_movimiento,
					@usuario,
					@id_log_proceso,
					@fecha_hasta_proceso;

				-- Controlar el Saldo con el Liquidador
				EXEC @flag_ok = Configurations.dbo.Batch_Disponible_Control_Liquidacion @id_cuenta;
			END TRY

			BEGIN CATCH
				IF (@@TRANCOUNT > 0)
					ROLLBACK TRANSACTION;
			END CATCH;

			-- Incrementar contador
			SET @i += 1;
		END;
	END;

	--Datos Archivo
	EXEC Configurations.dbo.Batch_Disponible_ArchivoError;


	EXEC Configurations.dbo.Batch_Disponible_ArchivoLiquidacion;


	-- Finalizar Log
	EXEC Configurations.dbo.Batch_Log_Finalizar_Proceso @id_log_proceso,
		@cuentas_count,
		@usuario;

	RETURN 1;
END;
