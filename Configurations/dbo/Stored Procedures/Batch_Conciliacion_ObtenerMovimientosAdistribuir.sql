
CREATE PROCEDURE dbo.Batch_Conciliacion_ObtenerMovimientosAdistribuir(
	@id_log_paso INT,
	@usuario VARCHAR(20)
	)
AS
DECLARE @distribuidas TABLE (id_transaccion VARCHAR(36));

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener Conciliaciones no Distribuidas
		INSERT INTO Configurations.dbo.Movimientos_a_distribuir (
			id_transaccion,
			id_medio_pago,
			id_cuenta,
			BCRA_cuenta,
			BCRA_emisor_tarjeta,
			signo_importe,
			importe,
			signo_cargo_marca,
			cargo_marca,
			signo_cargo_boton,
			cargo_boton,
			signo_impuesto_boton,
			impuesto_boton,
			fecha_liberacion_cashout,
			id_log_paso,
			tipo,
			flag_esperando_impuestos_generales_de_marca,
			usuario_alta,
			id_movimiento_mp,
			fecha_alta,
			version
			)
		OUTPUT inserted.id_transaccion
		INTO @distribuidas
		SELECT trn.Id,
			trn.ProductIdentification,
			trn.LocationIdentification,
			CAST(ISNULL(LEFT(ibc.cbu_cuenta_banco, 4), '0') AS INT),
			0,
			mpm.signo_importe,
			mpm.importe,
			'+',
			mpm.cargos_marca_por_movimiento,
			'+',
			ISNULL(trn.FeeAmount, 0),
			'+',
			ISNULL(trn.TaxAmount, 0),
			trn.CashoutTimestamp,
			@id_log_paso,
			'C',
			0,
			@usuario,
			mpm.id_movimiento_mp,
			GETDATE(),
			0
		FROM Configurations.dbo.Conciliacion con
		INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpm
			ON con.id_movimiento_mp = mpm.id_movimiento_mp
		INNER JOIN Transactions.dbo.transactions trn
			ON con.id_transaccion = trn.Id
		LEFT JOIN Configurations.dbo.Informacion_Bancaria_Cuenta ibc
			ON trn.LocationIdentification = ibc.id_cuenta
			AND (
				ibc.flag_vigente = 1
				OR (
					ibc.flag_vigente = 0
					AND ibc.fecha_baja IS NULL
					AND ibc.fecha_alta = (
						SELECT MAX(ibc1.fecha_alta)
						FROM Configurations.dbo.Informacion_Bancaria_Cuenta ibc1
						WHERE ibc1.id_cuenta = trn.LocationIdentification
							AND ibc1.flag_vigente = 0
						)
					)
				)
		WHERE con.flag_distribuida = 0
			AND con.flag_conciliada = 1
			AND con.flag_aceptada_marca = 1;
			

		-- Actualizar las distribuidas
        UPDATE c
        SET c.flag_distribuida = 1
        FROM Configurations.dbo.Conciliacion c
  INNER JOIN @distribuidas d
          ON c.id_transaccion = d.id_transaccion;
  
		COMMIT TRANSACTION;

		RETURN 1;
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE();

		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		RETURN 0;
	END CATCH
END
