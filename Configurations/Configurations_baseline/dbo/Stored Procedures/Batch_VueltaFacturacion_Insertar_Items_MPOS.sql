
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_Insertar_Items_MPOS] (
		@v_id_log_vuelta_facturacion INT = NULL,
		@fecha_vuelta_desde DATETIME,
		@fecha_vuelta_hasta DATETIME,
		@id_ciclo_facturacion INT,
		@mes INT,
		@anio INT,
		@usuario VARCHAR(20)
		
)

AS  
		DECLARE @ret INT;
		DECLARE @i INT = 1; 
		DECLARE @v_id_item_facturacion INT;
		DECLARE @v_identificador_carga INT;
		DECLARE @v_tipo CHAR(3)='COM';
		DECLARE @v_concepto CHAR(3)='010';
		DECLARE @v_subconcepto CHAR(3)='01';
		DECLARE @cuenta_aurus CHAR(10);
		DECLARE @id_cuenta INT;
		DECLARE @tipo_comprobante CHAR(1);
		DECLARE @suma_cargos_aurus DECIMAL(18,2);
					

BEGIN            
 
 SET NOCOUNT ON;      
      
	INSERT INTO [dbo].[Item_Facturacion] (
			[id_ciclo_facturacion],
			[tipo],
			[concepto],
			[subconcepto],
			[id_cuenta],
			[anio],
			[mes],
			[suma_cargos],
			[suma_impuestos],
			[vuelta_facturacion],
			[id_log_vuelta_facturacion],
			[identificador_carga_dwh],
			[tipo_comprobante],
			[impuestos_reales],
			[nro_comprobante],
			[fecha_comprobante],
			[fecha_alta],
			[usuario_alta],
			[version],
			[cuenta_aurus],
			[suma_cargos_aurus],
			[fecha_desde_proceso],
			[fecha_hasta_proceso],
			[letra_comprobante]			
			)
			SELECT 
			@id_ciclo_facturacion,
			@v_tipo as v_tipo,
			@v_concepto as v_concepto, 
			@v_subconcepto as v_subconcepto,
			convert(int,vfact.Nro_cliente_ext-1000000),
			@anio,
			@mes,
			vfact.Importe_pesos,
			vfact.Importe_pesos_iva,
			'Procesado' as vuelta_facturacion,
			@v_id_log_vuelta_facturacion,
			vfact.id_vuelta_facturacion,
			vfact.Tipo_comprobante,
			vfact.Importe_pesos_iva,
			vfact.nro_comprobante,
			vfact.fecha_comprobante,
			getdate() as fecha,
			@usuario as usuario,
			0 as versionfact,
			vfact.Nro_cliente_ext,
			vfact.Importe_pesos,
			@fecha_vuelta_desde,
			@fecha_vuelta_hasta,
			vfact.letra_comprobante
			FROM Configurations.dbo.vuelta_facturacion vfact
			WHERE LTRIM(RTRIM(vfact.Nro_item)) NOT IN ('0100010000')
				
RETURN  1;      

END