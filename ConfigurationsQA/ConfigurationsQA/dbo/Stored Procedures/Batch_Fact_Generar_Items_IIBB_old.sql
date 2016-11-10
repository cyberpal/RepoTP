
CREATE PROCEDURE [dbo].[Batch_Fact_Generar_Items_IIBB_old] (@fecha_hasta DATETIME)
AS
DECLARE @items TABLE (
	Idret INT,
	id_acumulador_impuesto INT
	);

BEGIN
	-- Obtener datos del Acumulador de Impuestos
	INSERT INTO Configurations.dbo.Item_Facturacion_IIBB (
		Codprov,
		Codcliext,
		Cuit,
		Razsoc,
		Direc,
		Localidad,
		Nroiibb,
		Regimen,
		Fecpag,
		Baseimp,
		Alicuota,
		Impret,
		id_tipo_condicion_IIBB,
		id_impuesto,
		jurisdiccion,
		id_acumulador_impuesto
		)
	OUTPUT inserted.Idret,
		inserted.id_acumulador_impuesto
	INTO @items
	SELECT pro.codigo_contable AS Codprov,
		(1000000 + aio.id_cuenta) AS Codcliext,
		isnull((
				CASE 
					WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_EMPRESA'
						THEN left(sfc.numero_CUIT, 2) + '-' + substring(sfc.numero_CUIT, 3, 8) + '-' + right(sfc.numero_CUIT, 1)
					WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_PROFESIONAL'
						AND ltrim(rtrim(t_iva.codigo)) <> 'IVA_CONS_FINAL'
						THEN left(cta.numero_CUIT, 2) + '-' + substring(cta.numero_CUIT, 3, 8) + '-' + right(cta.numero_CUIT, 1)
					ELSE NULL
					END
				), cta.numero_identificacion) AS Cuit,
		(
			CASE 
				WHEN ltrim(rtrim(t_cta.codigo)) = 'CTA_EMPRESA'
					THEN left(ltrim(rtrim(cta.denominacion2)), 50)
				ELSE left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)), 50)
				END
			) AS Razsoc,
		(ltrim(rtrim(isnull(dct.calle, ''))) + ' ' + ltrim(rtrim(isnull(dct.numero, ''))) + ' ' + ltrim(rtrim(isnull(dct.piso, ''))) + ' ' + ltrim(rtrim(isnull(dct.departamento, '')))) AS Direc,
		(left(ltrim(rtrim(loc.nombre)), 20)) AS Localidad,
		isnull((left(sfc.nro_inscripcion_iibb, 3) + '-' + substring(sfc.nro_inscripcion_iibb, 4, 6) + '-' + right(sfc.nro_inscripcion_iibb, 1)), '') AS Nroib,
		isnull(t_reg.descripcion, 'No Inscripto IIBB') AS Regimen,
		convert(CHAR(10), @fecha_hasta, 103) AS Fecpag,
		aio.importe_total_tx AS Baseimp,
		NULL AS Alicuota,
		aio.importe_retencion AS Impret,
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

	-- Actualizar Numero de Retencion
	UPDATE Configurations.dbo.Item_Facturacion_IIBB
	SET Numret = ('0' + cast(1160000000000 + ifi.Idret AS VARCHAR))
	FROM Configurations.dbo.Item_Facturacion_IIBB ifi
	INNER JOIN @items its
		ON ifi.Idret = its.Idret;

	-- Obtener Alicuota para las Cuentas registradas en IIBB
	UPDATE Configurations.dbo.Item_Facturacion_IIBB
	SET Alicuota = ipt.alicuota
	FROM Configurations.dbo.Item_Facturacion_IIBB ifi
	INNER JOIN @items its
		ON ifi.Idret = its.Idret
	INNER JOIN Configurations.dbo.Impuesto_Por_Tipo ipt
		ON ipt.id_impuesto = ifi.id_impuesto
			AND ipt.id_tipo = ifi.id_tipo_condicion_IIBB
	INNER JOIN Configurations.dbo.Impuesto_Por_Jurisdiccion_IIBB ipj
		ON ipt.id_impuesto_tipo = ipj.id_impuesto_tipo
	INNER JOIN Configurations.dbo.Jurisdiccion_IIBB jib
		ON ipj.id_jurisdiccion_iibb = jib.id_jurisdiccion_iibb
			AND jib.codigo = ifi.jurisdiccion
	WHERE ifi.Alicuota IS NULL
		AND ifi.jurisdiccion IS NOT NULL;

	-- Obtener Alicuota para las Cuentas sin Jurisdiccion con Tipo de Condicion de IIBB
	UPDATE Configurations.dbo.Item_Facturacion_IIBB
	SET Alicuota = ipt.alicuota
	FROM Configurations.dbo.Item_Facturacion_IIBB ifi
	INNER JOIN @items its
		ON ifi.Idret = its.Idret
	INNER JOIN Configurations.dbo.Impuesto_Por_Tipo ipt
		ON ipt.id_impuesto = ifi.id_impuesto
			AND ipt.id_tipo = ifi.id_tipo_condicion_IIBB
	WHERE ifi.Alicuota IS NULL
		AND ifi.jurisdiccion IS NULL;

	-- Obtener Alicuota para las Cuentas sin Jurisdiccion ni Tipo de Condicion de IIBB
	UPDATE Configurations.dbo.Item_Facturacion_IIBB
	SET Alicuota = ipt.alicuota
	FROM Configurations.dbo.Item_Facturacion_IIBB ifi
	INNER JOIN @items its
		ON ifi.Idret = its.Idret
	INNER JOIN Configurations.dbo.Impuesto_Por_Tipo ipt
		ON ipt.id_impuesto = ifi.id_impuesto
	WHERE ifi.Alicuota IS NULL
		AND ipt.id_tipo IS NULL;

	-- Actualizar Acumulador de Impuestos con la fecha de facturación
	UPDATE Configurations.dbo.Acumulador_Impuesto
	SET fecha_facturacion = getdate()
	FROM Configurations.dbo.Acumulador_Impuesto aio
	INNER JOIN @items its
		ON aio.id_acumulador_impuesto = its.id_acumulador_impuesto;

	RETURN 1;
END

