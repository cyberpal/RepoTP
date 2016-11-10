
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_ObtenerRegistros] (
@id_log_vuelta_facturacion INT,
@items_pendientes INT OUTPUT
)

AS

SET NOCOUNT ON;

BEGIN
		
		-- Obtener Items Pendientes y presuponer que no están facturados.
		INSERT INTO dbo.Item_Facturacion_tmp (
			id_item_facturacion,
			id_ciclo_facturacion,
			id_cuenta,
			anio,
			mes,
			suma_impuestos,
			vuelta_facturacion,
			id_log_vuelta_facturacion,
			tipo_comprobante,
			cuenta_aurus,
			suma_cargos_aurus
			)
		SELECT ifn.id_item_facturacion,
			ifn.id_ciclo_facturacion,
			ifn.id_cuenta,
			ifn.anio,
			ifn.mes,
			ifn.suma_impuestos,
			'No Facturado',
			@id_log_vuelta_facturacion,
			ifn.tipo_comprobante,
			ifn.cuenta_aurus,
			ifn.suma_cargos_aurus
		FROM Configurations.dbo.Item_Facturacion ifn
		WHERE ifn.vuelta_facturacion = 'Pendiente'
			AND ifn.id_log_vuelta_facturacion IS NULL
			AND ifn.identificador_carga_dwh IS NULL;

		SET @items_pendientes = @@ROWCOUNT;
		
RETURN 1;

END

