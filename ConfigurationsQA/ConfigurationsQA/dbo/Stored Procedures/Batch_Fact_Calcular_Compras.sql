
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Compras] (
	@id_log_facturacion INT = NULL,
	@v_id_ciclo_facturacion INT = NULL,
	@v_tipo CHAR(3) = NULL,
	@v_concepto CHAR(3) = NULL,
	@v_subconcepto CHAR(3) = NULL,
	@v_id_cuenta INT = NULL,
	@v_anio INT = NULL,
	@v_mes INT = NULL,
	@v_vuelta_facturacion VARCHAR(15) = NULL,
	@v_usuario_alta VARCHAR(20) = NULL,
	@v_version INT = NULL,
	@v_cuenta_aurus INT = NULL,
	@fecha_finProceso DATETIME = NULL
	)
AS
SET NOCOUNT ON;

DECLARE @v_id_item_facturacion INT;
DECLARE @v_fecha_actual DATETIME;
DECLARE @flag_cargos BIT = 0;
DECLARE @suma_tax_amount DECIMAL(12, 2);

BEGIN
	SET @v_fecha_actual = GETDATE()

	IF (
			EXISTS (
				SELECT 1
				FROM Configurations.dbo.Procesar_Facturacion_tmp pf
				WHERE LTRIM(RTRIM(pf.OperationName)) IN (
						'Compra_offline',
						'Compra_online'
						)
					AND pf.LocationIdentification = @v_id_cuenta
				HAVING SUM(ISNULL(pf.FeeAmount, 0)) > 0
				)
			)
	BEGIN
		INSERT INTO [dbo].[Item_Facturacion] (
			[id_log_facturacion],
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
			[tipo_comprobante],
			[fecha_alta],
			[usuario_alta],
			[version],
			[cuenta_aurus],
			[suma_cargos_aurus],
			[fecha_desde_proceso],
			[fecha_hasta_proceso]
			)
		SELECT @id_log_facturacion,
			@v_id_ciclo_facturacion,
			@v_tipo,
			@v_concepto,
			@v_subconcepto,
			@v_id_cuenta,
			@v_anio,
			@v_mes,
			SUM(pf.FeeAmount),
			SUM(pf.TaxAmount),
			@v_vuelta_facturacion,
			'F',
			@v_fecha_actual,
			@v_usuario_alta,
			@v_version,
			@v_cuenta_aurus,
			SUM(pf.FeeAmount),
			MIN(CreateTimestamp),
			@fecha_finProceso
		FROM Configurations.dbo.Procesar_Facturacion_tmp pf
		WHERE LTRIM(RTRIM(pf.OperationName)) IN (
				'Compra_offline',
				'Compra_online'
				)
			AND pf.LocationIdentification = @v_id_cuenta;

		SELECT @v_id_item_facturacion = SCOPE_IDENTITY()

		--Detalle del Item                
		INSERT INTO [dbo].[Detalle_Facturacion] (
			[id_item_facturacion],
			[id_transaccion],
			[fecha_alta],
			[usuario_alta],
			[version],

			[providerTransactionID],
			[createTimestamp],
			[saleConcept],
			[CredentialEmailAddress],
			[amount],
			[feeAmount]

			)
		SELECT @v_id_item_facturacion,
			txs.Id,
			@v_fecha_actual,
			@v_usuario_alta,
			@v_version,

			txs.providerTransactionID,
			txs.CreateTimeStamp,
			txs.saleConcept ,
			txs.CredentialEmailAddress,
			txs.Amount,
			txs.FeeAmount


		FROM Configurations.dbo.Procesar_Facturacion_tmp txs
		WHERE LTRIM(RTRIM(txs.OperationName)) IN (
				'Compra_offline',
				'Compra_online'
				)
			AND txs.LocationIdentification = @v_id_cuenta;
	END;

	RETURN 1;
END

