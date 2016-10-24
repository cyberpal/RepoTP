
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Ajuste_Merge] @id_cuenta INT,
	@fecha_comienzo_proceso DATETIME,
	@usuario VARCHAR(20),
	@item_facturacion INT OUTPUT
AS
DECLARE @actualizado TABLE (
	accion NVARCHAR(10),
	id_item_update INT,
	id_item_insert INT
	);

BEGIN
	MERGE Configurations.dbo.Item_Facturacion AS Destino
	USING (
		SELECT tmp.id_cuenta,
			tmp.suma_monto_neto,
			tmp.suma_monto_impuesto,
			tmp.id_ciclo_facturacion,
			tmp.tipo,
			tmp.concepto,
			tmp.subconcepto,
			tmp.anio,
			tmp.mes,
			tmp.vuelta_facturacion,
			tmp.tipo_comprobante,
			tmp.version,
			tmp.fecha_desde_proceso,
			tmp.fecha_hasta_proceso
		FROM Configurations.dbo.Facturacion_Sumas_Ajuste_tmp tmp
		WHERE tmp.id_cuenta = @Id_cuenta
		) AS Origen
		ON (
				Origen.id_cuenta = Destino.id_cuenta
				AND Origen.tipo_comprobante = Destino.tipo_comprobante
				AND Destino.vuelta_facturacion = 'Pendiente'
				AND Destino.fecha_alta >= @fecha_comienzo_proceso
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET Destino.suma_cargos += Origen.suma_monto_neto,
				Destino.suma_impuestos += Origen.suma_monto_impuesto,
				Destino.suma_cargos_aurus += Origen.suma_monto_neto,
				Destino.fecha_modificacion = getdate(),
				Destino.usuario_modificacion = @Usuario
	WHEN NOT MATCHED
		THEN
			INSERT (
				id_ciclo_facturacion,
				tipo,
				concepto,
				subconcepto,
				id_cuenta,
				anio,
				mes,
				suma_cargos,
				suma_impuestos,
				vuelta_facturacion,
				tipo_comprobante,
				fecha_alta,
				usuario_alta,
				version,
				cuenta_aurus,
				suma_cargos_aurus,
				fecha_desde_proceso,
				fecha_hasta_proceso
				)
			VALUES (
				Origen.id_ciclo_facturacion,
				Origen.tipo,
				Origen.concepto,
				Origen.subconcepto,
				Origen.id_cuenta,
				Origen.anio,
				Origen.mes,
				Origen.suma_monto_neto,
				Origen.suma_monto_impuesto,
				Origen.vuelta_facturacion,
				Origen.tipo_comprobante,
				getdate(),
				@Usuario,
				Origen.version,
				Origen.id_cuenta + 1000000,
				Origen.suma_monto_neto,
				Origen.fecha_desde_proceso,
				Origen.fecha_hasta_proceso
				)
	OUTPUT $ACTION,
		Deleted.id_item_facturacion,
		Inserted.id_item_facturacion
	INTO @actualizado;

	SELECT @item_facturacion = (
			CASE 
				WHEN accion = 'INSERT'
					THEN id_item_insert
				ELSE id_item_update
				END
			)
	FROM @actualizado;

	RETURN 1;
END
