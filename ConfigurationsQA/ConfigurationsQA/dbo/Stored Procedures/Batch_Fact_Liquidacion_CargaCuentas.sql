
CREATE PROCEDURE [dbo].[Batch_Fact_Liquidacion_CargaCuentas] (
	@fecha_desde DATETIME = NULL,
	@fecha_hasta DATETIME = NULL,
	@usuario VARCHAR(20)
	)
AS
DECLARE @id_ciclo_facturacion INT;
DECLARE @anio INT = year(@fecha_desde);
DECLARE @mes INT = month(@fecha_desde);

BEGIN
	SET @id_ciclo_facturacion = CASE 
			WHEN day(@fecha_desde) = 1
				THEN 1
			ELSE 2
			END;

	INSERT INTO Configurations.dbo.Control_Liquidacion_Facturacion (
		id_cuenta,
		total_liquidado,
		tipo_comprobante_liqui,
		fecha_alta,
		usuario_alta		
		)
	SELECT f.id_cuenta,
		sum(f.total_liquidado),
		f.tipo_comprobante_liqui,
		getdate(),
		@usuario
	FROM (
		SELECT trn.LocationIdentification AS id_cuenta,
			isnull(cpt.monto_calculado, 0) AS total_liquidado,
			(
				CASE 
					WHEN ltrim(rtrim(trn.OperationName)) IN (
							'Compra_online',
							'Compra_offline'
							)
						THEN 'F'
					WHEN ltrim(rtrim(trn.OperationName)) = 'Devolucion'
						THEN 'C'
					END
				) AS tipo_comprobante_liqui
		FROM Configurations.dbo.Cargos_Por_Transaccion cpt
		INNER JOIN Transactions.dbo.transactions trn
			ON cpt.id_transaccion = trn.Id
				AND trn.CreateTimestamp BETWEEN @fecha_desde
					AND @fecha_hasta
		) f
	GROUP BY f.id_cuenta,
		f.tipo_comprobante_liqui;

	MERGE Configurations.dbo.Control_Liquidacion_Facturacion AS Destino
	USING (
		SELECT id_cuenta,
			tipo_comprobante,
			total_ajuste
		FROM Configurations.dbo.Control_Ajuste_Facturacion
		WHERE id_ciclo_facturacion = @id_ciclo_facturacion
			AND anio = @anio
			AND mes = @mes
		) AS Origen
		ON (
				Origen.id_cuenta = Destino.id_cuenta
				AND Origen.tipo_comprobante = Destino.tipo_comprobante_liqui
				)
	WHEN MATCHED
		THEN
			UPDATE
			SET Destino.total_liquidado += Origen.total_ajuste
	WHEN NOT MATCHED
		THEN
			INSERT (
				id_cuenta,
				total_liquidado,
				tipo_comprobante_liqui,
				fecha_alta,
				usuario_alta
				)
			VALUES (
				Origen.id_cuenta,
				Origen.total_ajuste,
				Origen.tipo_comprobante,
				getdate(),
				@usuario
				);

	RETURN 1;
END

