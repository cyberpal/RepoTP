
CREATE PROCEDURE [dbo].[Batch_Fact_Generar_Items_IIBB] (@fecha_hasta DATETIME)
AS
DECLARE @max_id_retencion INT;
DECLARE @items TABLE (
	id_retencion_iib INT,
	id_acumulador_impuesto INT,
	codigo_provincia INT,
	numero_retencion VARCHAR(20)
	);
DECLARE @provincias TABLE (
	idx INT identity(1, 1),
	codigo VARCHAR(20),
	codigo_contable INT,
	ultimo_certificado_iibb INT
	);
DECLARE @idx INT = 1;
DECLARE @count INT;
DECLARE @codigo VARCHAR(20);
DECLARE @codigo_contable INT;
DECLARE @ultimo_certificado_iibb INT;

BEGIN
	-- Obtener datos del Acumulador de Impuestos
	INSERT INTO Configurations.dbo.Item_Facturacion_IIBB (
		codigo_provincia,
		codigo_cliente_externo,
		cuit,
		razon_social,
		direccion,
		localidad,
		numero_iibb,
		regimen,
		fecha_pago,
		base_imponible,
		alicuota,
		importe_retenido,
		id_tipo_condicion_iibb,
		id_impuesto,
		jurisdiccion,
		id_acumulador_impuesto
		)
	OUTPUT inserted.id_retencion_iibb,
		inserted.id_acumulador_impuesto,
		inserted.codigo_provincia,
		NULL
	INTO @items
	SELECT pro.codigo_contable,
		(1000000 + aio.id_cuenta),
		isnull((
				CASE 
					WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_EMPRESA'
						THEN left(sfc.numero_CUIT, 2) + '-' + substring(sfc.numero_CUIT, 3, 8) + '-' + right(sfc.numero_CUIT, 1)
					WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_PROFESIONAL'
						AND ltrim(rtrim(t_iva.codigo)) <> 'IVA_CONS_FINAL'
						THEN left(cta.numero_CUIT, 2) + '-' + substring(cta.numero_CUIT, 3, 8) + '-' + right(cta.numero_CUIT, 1)
					ELSE NULL
					END
				), cta.numero_identificacion),
		(
			CASE 
				WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_EMPRESA'
					THEN left(ltrim(rtrim(cta.denominacion2)), 50)
				ELSE left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)), 50)
				END
			),
		(ltrim(rtrim(isnull(dct.calle, ''))) + ' ' + ltrim(rtrim(isnull(dct.numero, ''))) + ' ' + ltrim(rtrim(isnull(dct.piso, ''))) + ' ' + ltrim(rtrim(isnull(dct.departamento, '')))),
		(left(ltrim(rtrim(loc.nombre)), 20)),
		isnull((left(sfc.nro_inscripcion_iibb, 3) + '-' + substring(sfc.nro_inscripcion_iibb, 4, 6) + '-' + right(sfc.nro_inscripcion_iibb, 1)), ''),
		isnull(t_reg.descripcion, 'No Inscripto IIBB'),
		@fecha_hasta,
		aio.importe_total_tx,
		aio.alicuota,
		aio.importe_retencion,
		sfc.id_tipo_condicion_iibb,
		aio.id_impuesto,
		left(sfc.nro_inscripcion_iibb, 3),
		aio.id_acumulador_impuesto
	FROM Configurations.dbo.Acumulador_Impuesto aio
	INNER JOIN Configurations.dbo.Impuesto ipo
		ON aio.id_impuesto = ipo.id_impuesto
	INNER JOIN Configurations.dbo.Provincia pro
		ON ipo.id_provincia = pro.id_provincia
	INNER JOIN Configurations.dbo.Cuenta cta
		ON aio.id_cuenta = cta.id_cuenta
	INNER JOIN Configurations.dbo.Tipo t_cta
		ON cta.id_tipo_cuenta = t_cta.id_tipo
	INNER JOIN Configurations.dbo.Situacion_Fiscal_Cuenta sfc
		ON sfc.id_cuenta = aio.id_cuenta
			AND sfc.fecha_inicio_vigencia <= aio.fecha_hasta
			AND (
				sfc.fecha_fin_vigencia >= aio.fecha_hasta
				OR sfc.fecha_fin_vigencia IS NULL
				)
	INNER JOIN Configurations.dbo.Domicilio_Cuenta dct
		ON sfc.id_domicilio_facturacion = dct.id_domicilio
	INNER JOIN Configurations.dbo.Localidad loc
		ON dct.id_localidad = loc.id_localidad
	LEFT JOIN Configurations.dbo.Tipo t_reg
		ON sfc.id_tipo_condicion_iibb = t_reg.id_tipo
	INNER JOIN Configurations.dbo.Tipo t_iva
		ON sfc.id_tipo_condicion_IVA = t_iva.id_tipo
	WHERE aio.flag_supera_tope = 1
		AND aio.fecha_hasta <= @fecha_hasta
		AND aio.fecha_facturacion IS NULL;

	IF (@@ROWCOUNT > 0)
	BEGIN
		-- Obtener códigos de provincias
		INSERT INTO @provincias (
			codigo,
			codigo_contable,
			ultimo_certificado_iibb
			)
		SELECT codigo,
			codigo_contable,
			ultimo_certificado_iibb
		FROM Configurations.dbo.Provincia;

		BEGIN TRY
			BEGIN TRANSACTION

			-- Calcular número de retención por Provincia
			UPDATE Configurations.dbo.Item_Facturacion_IIBB
			SET numero_retencion = (
					CASE 
						WHEN its.codigo = 'CORDOBA'
							THEN ('0' + cast(1160000000000 + its.ultimo_certificado_iibb + its.fila AS VARCHAR))
						WHEN its.codigo = 'SANTA_FE'
							THEN (right(replicate('0', 14) + cast(its.ultimo_certificado_iibb + its.fila AS VARCHAR), 14))
						END
					)
			FROM Configurations.dbo.Item_Facturacion_IIBB ifi
			INNER JOIN (
				SELECT itm.id_retencion_iib,
					prv.codigo,
					prv.ultimo_certificado_iibb,
					row_number() OVER (
						PARTITION BY itm.codigo_provincia ORDER BY itm.id_retencion_iib
						) AS fila
				FROM @items itm
				INNER JOIN @provincias prv
					ON itm.codigo_provincia = prv.codigo_contable
				) its
				ON ifi.id_retencion_iibb = its.id_retencion_iib;

			-- Actualiar último número de retención por provincia
			UPDATE prov
			SET ultimo_certificado_iibb = (
					CASE 
						WHEN prov.codigo = 'CORDOBA'
							THEN CAST(RIGHT(t.ultimo_certificado_iibb, 10) AS INT)
						WHEN prov.codigo = 'SANTA_FE'
							THEN CAST(t.ultimo_certificado_iibb AS INT)
						END
					)
			FROM (
				SELECT pro.id_provincia,
					max(ifi.numero_retencion) AS ultimo_certificado_iibb
				FROM Provincia pro
				INNER JOIN Item_Facturacion_iibb ifi
					ON pro.codigo_contable = ifi.codigo_provincia
				GROUP BY pro.id_provincia
				) t
			INNER JOIN Configurations.dbo.Provincia prov
				ON t.id_provincia = prov.id_provincia;

			COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			IF (@@TRANCOUNT > 0)
				ROLLBACK TRANSACTION;

			throw;
		END CATCH;

		-- Actualizar fecha de facturación
		UPDATE Configurations.dbo.Acumulador_Impuesto
		SET fecha_facturacion = getdate()
		FROM Configurations.dbo.Acumulador_Impuesto aci
		INNER JOIN @items its
			ON aci.id_acumulador_impuesto = its.id_acumulador_impuesto;
	END;

	RETURN 1;
END

