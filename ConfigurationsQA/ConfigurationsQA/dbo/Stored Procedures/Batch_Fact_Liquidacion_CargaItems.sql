
CREATE PROCEDURE [dbo].[Batch_Fact_Liquidacion_CargaItems] (
	@id_cuenta INT,
	@fecha_comienzo_proceso DATETIME = NULL,
	@Usuario VARCHAR(20)
	)
AS


BEGIN
		
		MERGE Configurations.dbo.Control_Liquidacion_Facturacion AS Destino
		
		USING (
			SELECT itf.id_cuenta,
				itf.tipo_comprobante,
				itf.suma_cargos_aurus
			FROM Configurations.dbo.Item_Facturacion itf
			WHERE itf.vuelta_facturacion = 'Pendiente'
			AND itf.fecha_alta>=@fecha_comienzo_proceso
			AND itf.id_cuenta=@id_cuenta
			) AS Origen
			ON (
					Origen.id_cuenta = Destino.id_cuenta
					AND Origen.tipo_comprobante = Destino.tipo_comprobante_liqui
					)
		WHEN MATCHED AND ISNULL(Origen.suma_cargos_aurus,0)<>ISNULL(Destino.total_liquidado,0)
			    THEN
				UPDATE
				SET Destino.suma_cargos_aurus = Origen.suma_cargos_aurus,
					Destino.tipo_comprobante_fact = Origen.tipo_comprobante,
					Destino.fecha_modificacion = getdate(),
					Destino.usuario_modificacion=@Usuario,
					Destino.posee_diferencia=1
		WHEN NOT MATCHED
			THEN
				INSERT (
					id_cuenta,
					suma_cargos_aurus,
					tipo_comprobante_fact,
					posee_diferencia,
					fecha_alta,
					usuario_alta
					)
				VALUES (
					Origen.id_cuenta,
					Origen.suma_cargos_aurus,
					Origen.tipo_comprobante,
					1,
					getdate(),
					@Usuario										
					)
		WHEN MATCHED AND ISNULL(Origen.suma_cargos_aurus,0)=ISNULL(Destino.total_liquidado,0)
		    THEN
			     DELETE;
		

RETURN 1;

END


