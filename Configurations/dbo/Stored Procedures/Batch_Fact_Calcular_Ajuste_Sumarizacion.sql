
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Ajuste_Sumarizacion] (
	@id_ciclo_facturacion INT = NULL,
	@tipo CHAR(3) = NULL,
	@concepto CHAR(3) = NULL,
	@subconcepto CHAR(3) = NULL,
	@anio INT = NULL,
	@mes INT = NULL,
	@Usuario VARCHAR(20),
	@fecha_fin_proceso AS DATETIME,
	@cant_ctasSumarizadas_ajuste INT OUTPUT
	)
AS
SET NOCOUNT ON;

DECLARE @I INT;

BEGIN
	INSERT INTO [dbo].[Facturacion_Sumas_Ajuste_tmp] (
		[I],
		[id_cuenta],
		[suma_monto_neto],
		[suma_monto_impuesto],
		[id_ciclo_facturacion],
		[tipo],
		[concepto],
		[subconcepto],
		[anio],
		[mes],
		[vuelta_facturacion],
		[tipo_comprobante],
		[version],
		[fecha_desde_proceso],
		[fecha_hasta_proceso],
		[fecha_alta],
		[usuario_alta]
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY id_cuenta
			) AS I,
		f.[id_cuenta],
		f.[suma_monto_neto],
		f.[suma_monto_impuesto],
		f.[id_ciclo_facturacion],
		f.[tipo],
		f.[concepto],
		f.[subconcepto],
		f.[anio],
		f.[mes],
		f.[vuelta_facturacion],
		f.[tipo_comprobante],
		f.[version],
		f.[fecha_desde_proceso],
		f.[fecha_hasta_proceso],
		f.[fecha_alta],
		f.[usuario_alta]
	FROM (
		SELECT tmp.id_cuenta,
			ISNULL(SUM(tmp.monto_neto), 0) AS suma_monto_neto,
			ISNULL(SUM(tmp.monto_impuesto), 0) AS suma_monto_impuesto,
			@id_ciclo_facturacion AS id_ciclo_facturacion,
			@tipo AS tipo,
			@concepto AS concepto,
			@subconcepto AS subconcepto,
			@anio AS anio,
			@mes AS mes,
			'Pendiente' AS vuelta_facturacion,
			tmp.signo AS tipo_comprobante,
			0 AS version,
			getdate() AS fecha_alta,
			MIN(tmp.fecha_alta) AS fecha_desde_proceso,
			@fecha_fin_proceso AS fecha_hasta_proceso,
			@Usuario AS usuario_alta
		FROM configurations.dbo.Facturacion_Items_Ajuste_tmp tmp
		GROUP BY tmp.id_cuenta,
			tmp.signo
		) f;

	SET @cant_ctasSumarizadas_ajuste = @@ROWCOUNT

	RETURN 1;
END
