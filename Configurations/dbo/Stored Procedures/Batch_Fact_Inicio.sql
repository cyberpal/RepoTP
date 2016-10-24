
CREATE PROCEDURE [dbo].[Batch_Fact_Inicio] (@usuario VARCHAR(20))
AS
/*Variables de retorno*/
DECLARE @ret_validaciones INT = 0;
DECLARE @ret_obtenertxs INT = 0;
DECLARE @ret_ciclo_fact INT = 0;
DECLARE @ret_log_proceso INT = 0;
DECLARE @ret_log_paso_mov INT = 0;
DECLARE @ret_log_paso_tablas INT = 0;
DECLARE @ret_log_finalizar_proceso INT = 0;
DECLARE @cantidad_control_cuentas INT = 0;
DECLARE @TotalAltas INT = 0;
DECLARE @TotalActualizaciones INT = 0;
DECLARE @Total_ajustes_procesados INT = 0;
DECLARE @cant_modificacionesCtas INT = 0;
DECLARE @cant_items_ajuste INT = 0;
DECLARE @cant_ctasSumarizadas_ajuste INT = 0;
DECLARE @cantidad_ajustes_x_cuenta INT = 0;
DECLARE @RegistrosLiquidadosHoy INT = 0;
DECLARE @cantidad_registrosIIBB INT = 0;
DECLARE @total_diferencias_control_liquidacion_facturacion INT = 0;
DECLARE @flag_Control_liquidacion_facturacion_carga_saldos INT = 0;
DECLARE @flag_Control_liquidacion_facturacion_carga_items INT = 0;
DECLARE @flag_Control_liquidacion_facturacion INT = 0;
DECLARE @flag_IngresosBrutos INT = 0;
DECLARE @flag_comprobar_ajustes INT = 0;
DECLARE @flag_actualizar_detalles_ajustes INT = 0;
DECLARE @flag_merge_ajustes INT = 0;
DECLARE @flag_cargaItems_ajustes INT = 0;
DECLARE @flag_cargaCuentas_ajustes INT = 0;
DECLARE @flag_novedadesCtas INT = 0;
DECLARE @flag_calcular_compras INT = 0;
DECLARE @flag_calcular_dev INT = 0;
DECLARE @flag_actualizar INT = 0;
DECLARE @flag_ajuste INT = 0;
DECLARE @flag_log_paso_items INT = 0;
DECLARE @flag_log_paso_control INT = 0;
DECLARE @flag_ctrol_Liqui_Facturacion INT = 0;
DECLARE @flag_completa_saldos INT = 0;
/*Fechas de proceso*/
DECLARE @fecha_desde DATETIME;
DECLARE @fecha_hasta DATETIME;
DECLARE @fecha_comienzo_proceso DATETIME;
DECLARE @id_Facturacion INT = 0;
DECLARE @id_log_paso_control_liquidacion INT = 0;
DECLARE @IdCicloFacturacion INT = 0;
DECLARE @cantidad_txs INT = 0;
DECLARE @cantidad_ctas INT = 0;
DECLARE @i_ctas INT = 0;
DECLARE @v_I INT = 0;
DECLARE @v_id_cuenta INT = 0;
/*Variables de items facturacion*/
DECLARE @v_tipo CHAR(3) = 'COM';
DECLARE @v_concepto CHAR(3) = '010';
DECLARE @v_subconcepto CHAR(3) = '01';
DECLARE @v_vuelta_facturacion VARCHAR(15) = 'Pendiente';
DECLARE @v_version INT = 0;
/*Variables de ajustes*/
DECLARE @v_I_ajuste INT = 0;
DECLARE @v_cuenta_ajuste INT = 0;
DECLARE @v_tipocomprobante_ajuste CHAR(1)
DECLARE @i_ajustes INT = 0;
DECLARE @item_facturacion INT = 0;
DECLARE @id_log_proceso INT = 0;
DECLARE @id_log_paso_mov INT = 0;
DECLARE @id_log_paso_tablas INT = 0;
DECLARE @ComprasFacturadas INT = 0;
DECLARE @CargosComprasFacturadas INT = 0;
DECLARE @DevolucionesFacturadas INT = 0;
DECLARE @CargosDevolucionesFacturadas INT = 0;
DECLARE @ResultadoProceso INT = 0;
DECLARE @TotalRegistos INT = 0;
DECLARE @TotalCargos INT = 0;
DECLARE @id_nivel_detalle_global INT = 0;
DECLARE @nombre_sp VARCHAR(50);
DECLARE @msg VARCHAR(50);
DECLARE @detalle VARCHAR(200);
DECLARE @informe_facturacion VARCHAR(180)
DECLARE @cuenta_procesada VARCHAR(180)
DECLARE @I_control INT = 0;
DECLARE @cuenta_control INT = 0;
DECLARE @suma_cargos_aurus_control DECIMAL(18, 2) = 0;
DECLARE @total_liquidado_control DECIMAL(18, 2) = 0;
DECLARE @cta_control INT = 0;
DECLARE @total_tabla_items INT = 0;

CREATE TABLE #cta_x_transacciones (
	I INT PRIMARY KEY IDENTITY(1, 1),
	id_cuenta INT
	);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		PRINT 'Comienzo del Proceso Facturacion'

		SET @nombre_sp = 'Batch_Fact_Inicio';
		SET @fecha_comienzo_proceso = getdate();

		PRINT 'Captura del id de proceso'

		SELECT @Id_Facturacion = lpo.id_proceso
		FROM configurations.dbo.Proceso lpo
		WHERE lpo.nombre = 'Facturación'

		PRINT 'Verificando dia de ejecucion'

		EXEC @ret_ciclo_fact = Configurations.dbo.Batch_Fact_Calcular_Ciclo_Facturacion @fecha_desde OUTPUT,
			@fecha_hasta OUTPUT,
			@IdCicloFacturacion OUTPUT;

		PRINT 'Retorno de variables de calculo ciclo facturacion'
		PRINT 'Id de factuacion: ' + isnull(cast(@Id_Facturacion AS VARCHAR(50)), 0)
		PRINT 'Fecha desde: ' + isnull(cast(@fecha_desde AS VARCHAR(50)), 0)
		PRINT 'Fecha hasta: ' + isnull(cast(@fecha_hasta AS VARCHAR(50)), 0)
		PRINT 'Ciclo de facturacion: ' + isnull(cast(@IdCicloFacturacion AS VARCHAR(50)), 0)
		PRINT 'Usuario :' + isnull(cast(@Usuario AS VARCHAR(50)), 0)

		IF (
				@ret_ciclo_fact = 1
				AND @fecha_desde IS NULL
				AND @fecha_hasta IS NULL
				AND @IdCicloFacturacion IS NULL
				) THROW 51000,
			'No es dia de ejecucion de proceso',
			1;
			/*
			SELECT @RegistrosLiquidadosHoy=COUNT(tx.id)
			FROM Transactions.dbo.transactions tx
			WHERE datediff(dd,cast(tx.LiquidationTimestamp as date),cast(getdate() as date))=0
			AND tx.liquidationstatus=-1
			AND tx.billingtimestamp is null
			AND tx.billingstatus<>-1
			*/
			SELECT @RegistrosLiquidadosHoy = 1
			WHERE EXISTS (
					SELECT 1
					FROM Transactions.dbo.transactions
					WHERE LiquidationTimestamp > cast(getdate() AS DATE)
					);

		IF (@RegistrosLiquidadosHoy = 0) THROW 51000,
			'No hay registros liquidados en la fecha',
			1;
			EXEC @ret_log_proceso = Configurations.dbo.Batch_Log_Iniciar_Proceso @Id_Facturacion,
				@fecha_desde,
				@fecha_hasta,
				@Usuario,
				@id_log_proceso OUTPUT,
				@id_nivel_detalle_global OUTPUT;

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
			1,
			'Carga tablas novedades',
			NULL,
			@Usuario,
			@id_log_paso_tablas OUTPUT;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Log proceso y Log paso registrado';

		DECLARE @v_anio INT = DATEPART(YY, DATEADD(YY, 0, @fecha_hasta))
		DECLARE @v_mes INT = DATEPART(MM, DATEADD(MM, 0, @fecha_hasta))

		TRUNCATE TABLE Configurations.dbo.Facturacion_NovedadesCtas_tmp;

		TRUNCATE TABLE Configurations.dbo.Facturacion_Items_Ajuste_tmp;

		TRUNCATE TABLE Configurations.dbo.Facturacion_Sumas_Ajuste_tmp;

		TRUNCATE TABLE Configurations.dbo.Control_Liquidacion_Facturacion;

		TRUNCATE TABLE Configurations.dbo.Procesar_Facturacion_tmp;

		EXEC @flag_novedadesCtas = Configurations.dbo.Batch_Fact_NovedadesCtas @fecha_desde,
			@fecha_hasta;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de tablas altas y modificaciones...';

		EXEC @flag_IngresosBrutos = configurations.dbo.Batch_Fact_Generar_Items_IIBB @fecha_hasta;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de IIBB facturacion...';

		EXEC @flag_Control_liquidacion_facturacion = Configurations.dbo.Batch_Fact_Liquidacion_CargaCuentas @fecha_desde,
			@fecha_hasta,
			@Usuario;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de registros control...';

		EXEC @flag_cargaItems_ajustes = Configurations.dbo.Batch_Fact_Calcular_Ajuste_ObtenerRegistros @fecha_hasta,
			@Usuario,
			@cant_items_ajuste OUTPUT;

		EXEC @flag_cargaCuentas_ajustes = Configurations.dbo.Batch_Fact_Calcular_Ajuste_Sumarizacion @IdCicloFacturacion,
			@v_tipo,
			@v_concepto,
			@v_subconcepto,
			@v_anio,
			@v_mes,
			@Usuario,
			@fecha_hasta,
			@cant_ctasSumarizadas_ajuste OUTPUT;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de ajustes...';

		EXEC @ret_obtenertxs = Configurations.dbo.Batch_Fact_Obtener_Transacciones @usuario,
			@fecha_hasta,
			@cantidad_txs OUTPUT;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de transacciones...';

		IF (@cantidad_txs <> 0)
		BEGIN
			INSERT INTO #cta_x_transacciones (id_cuenta)
			SELECT DISTINCT f.IDCuenta
			FROM (
				SELECT tmp.LocationIdentification AS IDCuenta
				FROM Configurations.dbo.Procesar_Facturacion_tmp tmp
				
				UNION ALL
				
				SELECT sumasAj.id_cuenta AS IDCuenta
				FROM Configurations.dbo.Facturacion_Sumas_Ajuste_tmp sumasAj
				) f

			SET @cantidad_ctas = @@ROWCOUNT
		END

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso_tablas,
			NULL,
			NULL,
			1,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			@Usuario;

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Carga de cuentas';

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Fin: Paso proceso - carga de tablas';

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

IF (@cantidad_ctas <> 0)
BEGIN
	
	EXEC @ret_log_paso_mov = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
		2,
		'Procesar Movimientos',
		NULL,
		@Usuario,
		@id_log_paso_mov OUTPUT;

	EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
		@id_log_proceso,
		@nombre_sp,
		2,
		'Procesando cuentas...';

	SET @i_ctas = 1;

	WHILE (@i_ctas <= @cantidad_ctas)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			SELECT @v_I = tmp.I,
				@v_id_cuenta = tmp.id_cuenta
			FROM #cta_x_transacciones tmp
			WHERE tmp.i = @i_ctas;

			DECLARE @v_cuenta_aurus INT = (@v_id_cuenta + 1000000)

			/*Loggea la cuenta que se esta procesando*/
			SET @cuenta_procesada = CONCAT (
					'Cuenta Procesada:  ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			EXEC @flag_calcular_compras = Configurations.dbo.Batch_Fact_Calcular_Compras @id_log_paso_mov,
				@IdCicloFacturacion,
				@v_tipo,
				@v_concepto,
				@v_subconcepto,
				@v_id_cuenta,
				@v_anio,
				@v_mes,
				@v_vuelta_facturacion,
				@usuario,
				@v_version,
				@v_cuenta_aurus,
				@fecha_hasta;

			SET @cuenta_procesada = CONCAT (
					'Compra:  ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			EXEC @flag_calcular_dev = Configurations.dbo.Batch_Fact_Calcular_Dev @id_log_paso_mov,
				@IdCicloFacturacion,
				@v_tipo,
				@v_concepto,
				@v_subconcepto,
				@v_id_cuenta,
				@v_anio,
				@v_mes,
				@v_vuelta_facturacion,
				@usuario,
				@v_version,
				@v_cuenta_aurus,
				@fecha_hasta;

			SET @cuenta_procesada = CONCAT (
					'Devolucion:  ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			EXEC @flag_merge_ajustes = Configurations.dbo.Batch_Fact_Calcular_Ajuste_Merge @v_id_cuenta,
				@fecha_comienzo_proceso,
				@Usuario,
				@item_facturacion OUTPUT;

			EXEC @flag_actualizar_detalles_ajustes = Configurations.dbo.Batch_Fact_Calcular_Ajuste_Detalle @fecha_comienzo_proceso,
				@v_id_cuenta,
				@Usuario;

			SET @cuenta_procesada = CONCAT (
					'Ajustes:  ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			EXEC @flag_Control_liquidacion_facturacion_carga_items = Configurations.dbo.Batch_Fact_Liquidacion_CargaItems @v_id_cuenta,
				@fecha_comienzo_proceso,
				@Usuario;

			SET @cuenta_procesada = CONCAT (
					'Control-Carga Items:  ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			EXEC @flag_actualizar = Configurations.dbo.Batch_Fact_Actualizar_Procesados @fecha_hasta,
				@v_id_cuenta;

			SET @cuenta_procesada = CONCAT (
					'Actualizar Txs: ',
					isnull(@v_id_cuenta, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;

			COMMIT TRANSACTION;
		
		END TRY

		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
			BEGIN
				ROLLBACK TRANSACTION;

				THROW;
			END
		END CATCH

		SET @i_ctas += 1;
	
	END

	EXEC @ret_log_paso_mov = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso_mov,
		NULL,
		NULL,
		1,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		@Usuario;
--END

--BEGIN

	/*SET @cta_control = 1;

	SELECT @cantidad_ctas = COUNT(clf.I_control)
	FROM configurations.dbo.Control_Liquidacion_Facturacion clf

	WHILE (@cta_control <= @cantidad_ctas)
	
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			SELECT @I_control = tmp.I_control,
				@cuenta_control = tmp.id_cuenta,
				@suma_cargos_aurus_control = tmp.suma_cargos_aurus,
				@total_liquidado_control = tmp.total_liquidado
			FROM Configurations.dbo.Control_Liquidacion_Facturacion tmp
			WHERE tmp.I_control = @cta_control

			SET @cuenta_procesada = CONCAT (
					'Completar control liquidacion facturacion:  ',
					isnull(@cuenta_control, 0)
					)

			EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
				@id_log_proceso,
				@nombre_sp,
				3,
				@cuenta_procesada;
			
		*/

BEGIN
		
	BEGIN TRY
			BEGIN TRANSACTION;

		EXEC    @flag_completa_saldos = Configurations.dbo.Batch_Fact_Liquidacion_CargaSaldos
			    @fecha_desde,
				@fecha_hasta,
				@suma_cargos_aurus_control,
				@total_liquidado_control,
				@Usuario,
				@v_mes,
				@v_anio,
				@IdCicloFacturacion;

			COMMIT TRANSACTION;
		
		END TRY

		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
			BEGIN
				ROLLBACK TRANSACTION;

				THROW;
			END
		END CATCH

		--SET @cta_control += 1;
	END
END

BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		/*Resultados del procesamiento de items facturacion*/
		SELECT @ComprasFacturadas = ROUND(SUM(trn.Total), 2),
			@CargosComprasFacturadas = ROUND(SUM(trn.Cargos), 2),
			@DevolucionesFacturadas = ROUND(SUM(trn.TotalDev), 2),
			@CargosDevolucionesFacturadas = ROUND(SUM(trn.CargosDev), 2),
			@ResultadoProceso = 1
		FROM (
			SELECT count(itf.id_item_facturacion) AS Total,
				isnull(sum(itf.suma_cargos), 0) AS Cargos,
				0 AS TotalDev,
				0 AS CargosDev
			FROM Configurations.dbo.item_facturacion itf
			WHERE itf.id_log_vuelta_facturacion IS NULL
				AND itf.vuelta_facturacion = 'Pendiente'
				AND itf.fecha_alta >= @fecha_comienzo_proceso
				AND itf.tipo_comprobante = 'F'
			
			UNION
			
			SELECT 0 AS Total,
				0 AS Cargos,
				count(itf.id_item_facturacion) AS TotalDev,
				isnull(sum(itf.suma_cargos), 0) AS CargosDev
			FROM Configurations.dbo.item_facturacion itf
			WHERE itf.id_log_vuelta_facturacion IS NULL
				AND itf.vuelta_facturacion = 'Pendiente'
				AND itf.fecha_alta >= @fecha_comienzo_proceso
				AND itf.tipo_comprobante = 'C'
			) trn

		SET @TotalRegistos = @ComprasFacturadas + @DevolucionesFacturadas
		SET @TotalCargos = @CargosComprasFacturadas + @CargosDevolucionesFacturadas

		SELECT @TotalAltas = ROUND(SUM(trn.TotalAltas), 2),
			@TotalActualizaciones = ROUND(SUM(trn.TotalActualizaciones), 2)
		FROM (
			SELECT COUNT(tmp.i) AS TotalAltas,
				0 AS TotalActualizaciones
			FROM Facturacion_NovedadesCtas_tmp tmp
			WHERE tmp.Tipo_Novedad = 'Alta'
			
			UNION
			
			SELECT 0 AS TotalAltas,
				COUNT(tmp.i) AS TotalActualizaciones
			FROM Facturacion_NovedadesCtas_tmp tmp
			WHERE tmp.Tipo_Novedad = 'Modificacion'
			) trn

		SELECT @Total_ajustes_procesados = COUNT(aj.id_ajuste)
		FROM Configurations.dbo.ajuste aj
		WHERE aj.facturacion_estado = - 1
			AND aj.facturacion_fecha >= @fecha_comienzo_proceso
			AND aj.fecha_modificacion >= @fecha_comienzo_proceso

		/*Diferencias de saldos que muestra el control*/
		SELECT @total_diferencias_control_liquidacion_facturacion = count(clf.id_cuenta)
		FROM configurations.dbo.Control_Liquidacion_Facturacion clf
		WHERE clf.posee_diferencia = 1

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			'Informe de Facturacion'

		SET @informe_facturacion = CONCAT (
				'Codigo del proceso de Facturacion:  ',
				isnull(@Id_Facturacion, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Fecha de comienzo:',
				isnull(convert(DATETIME, @fecha_comienzo_proceso), 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Ciclo:',
				isnull(@IdCicloFacturacion, 0),
				' ',
				isnull(cast(@fecha_desde AS DATETIME), 0),
				' - ',
				isnull(cast(@fecha_hasta AS DATETIME), 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Registros generados por IIBB:',
				isnull(@cantidad_registrosIIBB, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total ajustes procesados:',
				isnull(@Total_ajustes_procesados, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de Altas generadas:  ',
				isnull(@TotalAltas, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de Modificaciones generadas:  ',
				isnull(@TotalActualizaciones, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de Compras Facturadas:  ',
				isnull(@ComprasFacturadas, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de cargos Facturados por compras:  ',
				isnull(@CargosComprasFacturadas, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de Devoluciones Facturadas:  ',
				isnull(@ComprasFacturadas, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de cargos Facturados por Devoluciones:  ',
				isnull(@CargosComprasFacturadas, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		SET @informe_facturacion = CONCAT (
				'Total de registros con diferencias en el control:  ',
				isnull(@total_diferencias_control_liquidacion_facturacion, 0)
				)

		EXEC configurations.dbo.Batch_Log_Detalle @id_nivel_detalle_global,
			@id_log_proceso,
			@nombre_sp,
			2,
			@informe_facturacion;

		EXEC @ret_log_finalizar_proceso = Configurations.dbo.Batch_Log_Finalizar_Proceso @id_log_proceso,
			0,
			@Usuario;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH

	RETURN 1;
END
