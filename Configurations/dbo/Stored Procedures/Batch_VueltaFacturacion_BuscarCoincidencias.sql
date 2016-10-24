
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_BuscarCoincidencias] (
	@items_pendientes INT
	)
AS
DECLARE @i INT = 1;
DECLARE @cuenta_aurus INT;
DECLARE @tipo_comprobante CHAR(1);
DECLARE @suma_cargos_aurus DECIMAL(18, 2);
DECLARE @id_ciclo_facturacion INT;
DECLARE @anio INT;
DECLARE @mes INT;
DECLARE @fecha_base DATETIME;
DECLARE @fecha_vuelta_desde DATETIME;
DECLARE @fecha_vuelta_hasta DATETIME;
DECLARE @id_vuelta_facturacion INT=0;
DECLARE @importe_pesos_iva DECIMAL(18, 2);
DECLARE @nro_comporbante NUMERIC(9, 0);
DECLARE @fecha_comporbante DATE;
DECLARE @mascara CHAR(4);
DECLARE @letra_comporbante CHAR(1);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		WHILE (@i <= @items_pendientes)
		
		BEGIN
			
			BEGIN TRANSACTION;

			-- Obtener el item a machear
			SELECT @cuenta_aurus = ift.cuenta_aurus,
				   @tipo_comprobante = ift.tipo_comprobante,
				   @suma_cargos_aurus = ift.suma_cargos_aurus,
				   @id_ciclo_facturacion = ift.id_ciclo_facturacion,
				   @anio = ift.anio,
				   @mes = ift.mes
			FROM Configurations.dbo.Item_Facturacion_tmp ift
			WHERE ift.i = @i;

			-- Si es una Nota de Crédito, el importe debe ser negativo
			IF (@tipo_comprobante = 'C')
			BEGIN
				SET @suma_cargos_aurus = @suma_cargos_aurus * - 1;
			END;

			-- Establecer rango de fechas:
			-- Si es facturación del 1er ciclo, tiene que haberse facturado con fecha dentro del 2do ciclo.
			-- Si es facturación del 2do ciclo:
			--		Probablemente se haya facturado con fecha dentro del 2do ciclo.
			--		Si no fué así, tiene que haberse facturado con fecha del siguiente ciclo.
			--
			--
			-- Buscar primero por 2do ciclo.
			SET @fecha_base = DATEFROMPARTS(@anio, @mes, 16);

			EXEC Configurations.dbo.Calcular_Ciclo_Facturacion @fecha_base,
				@fecha_vuelta_desde OUTPUT,
				@fecha_vuelta_hasta OUTPUT;

			SET @id_vuelta_facturacion=NULL
			SET @importe_pesos_iva=NULL
			SET @nro_comporbante=NULL
			SET @fecha_comporbante=NULL
			SET @mascara=NULL
			SET @letra_comporbante=NULL

			SELECT @id_vuelta_facturacion = vfn.id_vuelta_facturacion,
				   @importe_pesos_iva = vfn.Importe_pesos_iva,
				   @nro_comporbante = vfn.Nro_comprobante,
				   @fecha_comporbante = vfn.Fecha_comprobante,
				   @mascara = vfn.Mascara,
				   @letra_comporbante = vfn.Letra_comprobante
			FROM Configurations.dbo.vuelta_facturacion vfn
			WHERE vfn.Nro_cliente_ext = @cuenta_aurus
				AND vfn.Tipo_comprobante = @tipo_comprobante
				AND vfn.Importe_pesos = @suma_cargos_aurus
				AND LTRIM(RTRIM(vfn.Nro_item))='0100010000' 
				AND vfn.Fecha_comprobante
				BETWEEN @fecha_vuelta_desde AND @fecha_vuelta_hasta;

			-- Si es 2do ciclo y no se encuentra coincidencia
			IF (
					@id_ciclo_facturacion = 2
					AND @id_vuelta_facturacion IS NULL
					)
			BEGIN
				-- Buscar en el ciclo siguiente
				SET @fecha_base = DATEADD(DD, 16, @fecha_base);

				EXEC Configurations.dbo.Calcular_Ciclo_Facturacion @fecha_base,
					@fecha_vuelta_desde OUTPUT,
					@fecha_vuelta_hasta OUTPUT;
				
				SET @id_vuelta_facturacion=NULL
			    SET @importe_pesos_iva=NULL
			    SET @nro_comporbante=NULL
			    SET @fecha_comporbante=NULL
			    SET @mascara=NULL
			    SET @letra_comporbante=NULL

				SELECT @id_vuelta_facturacion = vfn.id_vuelta_facturacion,
					   @importe_pesos_iva = vfn.Importe_pesos_iva,
					   @nro_comporbante = vfn.Nro_comprobante,
					   @fecha_comporbante = vfn.Fecha_comprobante,
					   @mascara = vfn.Mascara,
					   @letra_comporbante = vfn.Letra_comprobante
				FROM Configurations.dbo.vuelta_facturacion vfn
				WHERE vfn.Nro_cliente_ext = @cuenta_aurus
					AND vfn.Tipo_comprobante = @tipo_comprobante
					AND vfn.Importe_pesos = @suma_cargos_aurus
					AND LTRIM(RTRIM(vfn.Nro_item))='0100010000'
					AND vfn.Fecha_comprobante 
					BETWEEN @fecha_vuelta_desde AND @fecha_vuelta_hasta;
			END;

			
			-- Si se encontró coincidencia actualizar la tabla temporal
			IF (@id_vuelta_facturacion IS NOT NULL)
				UPDATE Configurations.dbo.Item_Facturacion_tmp
				SET vuelta_facturacion = 'Procesado',
					identificador_carga_dwh = @id_vuelta_facturacion,
					impuestos_reales = @importe_pesos_iva,
					nro_comprobante = @nro_comporbante,
					fecha_comprobante = @fecha_comporbante,
					punto_venta = @mascara,
					letra_comprobante = @letra_comporbante,
					dif_ajuste=(isnull(suma_impuestos,0)-isnull(@importe_pesos_iva,0))
				WHERE i = @i;

			COMMIT TRANSACTION;

			SET @i += 1;
		END;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		THROW;
	END CATCH

	RETURN 1;
END
