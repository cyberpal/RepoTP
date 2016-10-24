
CREATE PROCEDURE [dbo].[sp_ProcesarCuentas_VueltaFacturacion](
			@p_usuario VARCHAR(20) = NULL,
			@p_flaggeA INT = NULL,
			@p_idLogProceso INT,
			@p_idLogPasoProceso INT,
			@p_estado_cod INT = NULL,
			@p_estado_desc VARCHAR(50) = NULL,
			@p_idCuenta INT,
			@p_sumaCargos DECIMAL(18,2) = NULL,
			@p_sumaImpuestos DECIMAL(18,2) = NULL,
			@p_importeNeto DECIMAL(18,2) = NULL,
			@p_importeIVA DECIMAL(18,2) = NULL,
			@p_importeNetoPesos DECIMAL(18,2) = NULL,
			@p_importeIVAPesos DECIMAL(18,2) = NULL,
			@p_idVueltaFacturacion INT = NULL,
			@p_tipoComprobante VARCHAR(1) = NULL,
			@p_fechaComprobante VARCHAR(30) = NULL,--DATETIME = NULL,
			@p_nroComprobante INT = NULL
)
AS

SET NOCOUNT ON;

-- comportamiento del sp con carga y concurrencia.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- 0. Variables para gestion de...

	-- Errores
		DECLARE @v_spErrorCod INT;
		DECLARE @v_spErrorMsg VARCHAR(255);
	
	-- Estados de cuentas
		DECLARE @v_fechaActualEstado DATETIME;
		DECLARE @v_estadoActual VARCHAR(20) = 'Pendiente';
		DECLARE @v_estadoNuevo VARCHAR(20) = NULL;
		DECLARE @v_impuestosReales DECIMAL(18,2) = NULL;
		DECLARE @v_sumaA DECIMAL(18,2);
		DECLARE @v_sumaB DECIMAL(18,2);
		DECLARE @v_restaAB DECIMAL(18,2);
		DECLARE @v_codigoOperacion INT;
		DECLARE @v_idTipoMovimiento INT;
		DECLARE @v_idTipoOrigenMovimiento INT;
		DECLARE @v_decimalNulo DECIMAL(18,2);

	-- Ajustes de cuentas
		DECLARE @v_idAjuste INT;
		DECLARE @v_idMotivoAjuste INT;
		DECLARE @v_estadoAjuste VARCHAR(20) = 'Aprobado';
		DECLARE @v_version INT = 0;

BEGIN TRANSACTION

	BEGIN TRY
	
		-- valor por defecto (ejecucion optima de este sp)
		SET @p_flaggeA = 0

-- 1. Manejo de errores: Validacion parametros ingresados ------------------------------

		IF (@p_usuario IS NULL)
			BEGIN
				SELECT  @v_spErrorCod = 10;
				THROW 51000, 'ERROR - Parametro nulo: p_usuario', 1;
				SET @p_flaggeA = 210;
			END

		IF (@p_flaggeA IS NULL)
			BEGIN
				SELECT  @v_spErrorCod = 20;
				THROW 51000, 'ERROR - Parametro nulo: p_flaggeA', 1;
				SET @p_flaggeA = 210;
			END

		IF (@p_idLogProceso IS NULL) OR (@p_idLogPasoProceso IS NULL) OR (@p_idCuenta IS NULL)
		--OR (@p_idVueltaFacturacion IS NULL) -> es nullable, para casos de registros con estado 'No Facturado' (ver ERS).
			BEGIN
				SELECT  @v_spErrorCod = 30;
				THROW 51000, 'ERROR - Parametro nulo: al menos un dato de id es nulo.', 1;
				SET @p_flaggeA = 210;
			END

-- 2. Estados en cuentas ----------------------------------------------------------------

		-- resuelve valor para campo fecha_alta, tabla Item_Facturacion
		SELECT @v_fechaActualEstado=GETDATE();
		
		-- procesamiento de cuentas aptas para estado 'PROCESADO' (camino 'feliz')
		IF @p_estado_cod = 1
			BEGIN
				-- resuelve estado
				SET @v_estadoNuevo = 'Procesado';
				
				-- resuelve campo impuestos_reales
				SET @v_impuestosReales = @p_importeNetoPesos + @p_importeIVAPesos;
				
				-- resuelve diferencia en cargos
				SET @v_sumaA = @p_sumaCargos + @p_sumaImpuestos;
				SET @v_sumaB = @p_sumaCargos + @v_impuestosReales;
				SET @v_restaAB = @v_sumaA - @v_sumaB;
				--SET @v_restaAB = (@p_sumaCargos + @p_sumaImpuestos) + (@p_sumaCargos + @p_impuestosReales)

				-- resuelve y verifica id de tipo de origen de movimiento
				SET @v_idTipoOrigenMovimiento = (SELECT tpo.id_tipo
												  FROM configurations.dbo.Tipo tpo WITH(NOLOCK)
												  WHERE tpo.codigo = 'ORIG_PROCESO'
												  AND tpo.id_grupo_tipo = 17);

				IF @v_idTipoOrigenMovimiento IS NULL
					SET @p_flaggeA = 215;

				-- actualiza y verifica datos de la cuenta
				UPDATE [dbo].[Item_Facturacion]
				SET vuelta_facturacion = @v_estadoNuevo,
					id_log_vuelta_facturacion = @p_idLogPasoProceso,
					identificador_carga_dwh = @p_idVueltaFacturacion,
					usuario_modificacion = @p_usuario,
					fecha_modificacion = @v_fechaActualEstado,
					impuestos_reales = @p_importeNetoPesos + @p_importeIVAPesos,
					tipo_comprobante = @p_tipoComprobante,
					nro_comprobante = @p_nroComprobante,
					fecha_comprobante = CAST(@p_fechaComprobante AS DATE)
				WHERE id_cuenta = @p_idCuenta
				AND vuelta_facturacion = @v_estadoActual;
				
				SET @p_flaggeA = (SELECT MIN(p.flagge) FROM (SELECT 000 flagge
															FROM [Configurations].[dbo].[Item_Facturacion] WITH(NOLOCK)
															WHERE id_cuenta = @p_idCuenta -- IN(1,2,14,262,339,301,433) 
															AND vuelta_facturacion = @v_estadoActual -- 'Procesado'
															UNION
															SELECT 220 flagge) p);
				

-- 3. Ajustes en cuentas ----------------------------------------------------------------
				
				IF CAST(@v_restaAB AS decimal) != CAST(0 AS decimal) --<> 0
					BEGIN

						-- resuelve y verifica id de codigo de operacion de ajuste que corresponde			
						SET @v_codigoOperacion = (SELECT id_codigo_operacion AS q_codigoOperacion 
													FROM Configurations.dbo.Codigo_Operacion
													WHERE codigo_operacion = (SELECT 'AJP' AS cod_operacion_txt FROM [dbo].[Item_Facturacion] 
																				WHERE @v_restaAB > 0
																				UNION 
																				SELECT 'AJN' AS cod_operacion_txt FROM [dbo].[Item_Facturacion]
																				WHERE @v_restaAB < 0));

						IF @v_codigoOperacion IS NULL
							SET @p_flaggeA = 225;
					
						-- resuelve y verifica id de tipo de movimiento que corresponde
						SET @v_idTipoMovimiento = (SELECT tpo.id_tipo
													FROM configurations.dbo.Tipo tpo WITH(NOLOCK)
													WHERE tpo.codigo = 'MOV_CRED'
													AND tpo.id_grupo_tipo = 16
													AND @v_restaAB > 0
												   UNION ALL
												   SELECT tpo.id_tipo
													FROM configurations.dbo.Tipo tpo WITH(NOLOCK)
													WHERE tpo.codigo = 'MOV_DEB'
													AND tpo.id_grupo_tipo = 16
													AND @v_restaAB < 0);

						IF @v_idTipoMovimiento IS NULL
							SET @p_flaggeA = 230;			
						
						-- resuelve y verifica id de nuevo registro de ajuste a ingresar
						SET @v_idAjuste = (SELECT ISNULL(MAX(id_ajuste),0) + 1
											FROM Configurations.dbo.Ajuste);

						IF @v_idAjuste IS NULL
							SET @p_flaggeA = 235;

						-- resuelve y verifica id de motivo del ajuste
						SET @v_idMotivoAjuste = (SELECT id_motivo_ajuste
												  FROM Configurations.dbo.Motivo_Ajuste 
												  WHERE codigo = 'DIF_FACT');

						IF @v_idMotivoAjuste IS NULL
							SET @p_flaggeA = 240;

						-- ingresa y verifica el ajuste
						INSERT INTO [dbo].[Ajuste](
								[id_ajuste],
								[id_codigo_operacion],
								[id_cuenta],
								[id_motivo_ajuste],
								[monto],
								[estado_ajuste],
								[fecha_alta],
								[usuario_alta],
								[version])
						VALUES(@v_idAjuste, 
								@v_codigoOperacion,
								@p_idCuenta,
								@v_idMotivoAjuste, 
								@v_restaAB,
								@v_estadoAjuste,
								GETDATE(),
								@p_usuario,
								@v_version);
						
						SET @p_flaggeA = (SELECT MIN(t.flagge) FROM (SELECT 000 flagge
																	FROM [Configurations].[dbo].[Ajuste]
																	WHERE id_ajuste = @v_idAjuste
																	UNION
																	SELECT 245 flagge) t);

						-- impacta el ajuste ingresado en montos de acumulados de la cuenta en t.Cuenta_Virtual (los actualiza)
						-- y loguea esta accion en t.Log_Movimiento_Cuenta_Virtual

						EXECUTE [Configurations].[dbo].[Actualizar_Cuenta_Virtual] @v_restaAB, @v_decimalNulo, @v_restaAB, @v_decimalNulo, @v_decimalNulo, @v_decimalNulo, @p_idCuenta, @p_usuario, @v_idTipoMovimiento, @v_idTipoOrigenMovimiento, @p_idLogProceso;
						
					END
			END

		-- procesamiento de cuentas aptas para estado 'NO FACTURADO' (camino alternativo)
		IF @p_estado_cod = 0
			BEGIN
				-- resuelve estado
				SET @v_estadoNuevo = 'No Facturado';
				
				-- actualiza tabla y verifica actualizacion
				UPDATE [dbo].[Item_Facturacion]
				SET vuelta_facturacion = @v_estadoNuevo,
					id_log_vuelta_facturacion = @p_idLogPasoProceso,
					identificador_carga_dwh = @p_idVueltaFacturacion,
					usuario_modificacion = @p_usuario,
					fecha_modificacion = @v_fechaActualEstado
				WHERE id_cuenta = @p_idCuenta
				AND vuelta_facturacion = @v_estadoActual;
				
				SET @p_flaggeA = (SELECT MIN(t.flagge) FROM (SELECT 000 flagge
															 FROM [Configurations].[dbo].[Item_Facturacion]
															 WHERE id_cuenta = @p_idCuenta
															 UNION
															 SELECT 250 flagge) t);
				
			END

	END TRY

-- 4. Manejo de errores: Informa mensajes -----------------------------------------------

	BEGIN CATCH

		ROLLBACK TRANSACTION;
		SELECT @v_spErrorMsg = ERROR_MESSAGE(), @v_idAjuste = NULL;
		THROW  51000, @v_spErrorMsg, 1;

	END CATCH
	
-- 5. Fin del sp (commit final, retorno de valores, etc.) -------------------------------
	
COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

RETURN @p_flaggeA;
