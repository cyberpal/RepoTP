
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_ProcesarItems] (
	@items_pendientes INT,
	@usuario VARCHAR(20),
	@id_log_proceso INT
	)
AS
DECLARE @id_motivo_ajuste_positivo INT;
DECLARE @id_motivo_ajuste_negativo INT;
DECLARE @id_motivo_ajuste INT;
DECLARE @i INT = 1;
DECLARE @id_item_facturacion INT;
DECLARE @id_cuenta INT;
DECLARE @suma_impuestos DECIMAL(18, 2);
DECLARE @vuelta_facturacion VARCHAR(15);
DECLARE @id_log_vuelta_facturacion INT;
DECLARE @identificador_carga_dwh INT;
DECLARE @impuestos_reales DECIMAL(18, 2);
DECLARE @nro_comprobante INT;
DECLARE @fecha_comprobante DATE;
DECLARE @punto_venta CHAR(1);
DECLARE @letra_comprobante CHAR(1);
DECLARE @importe_ajuste DECIMAL(18, 2);
DECLARE @id_ajuste INT;
DECLARE @id_tipo_movimiento INT;
DECLARE @msg_error VARCHAR(max);
DECLARE @ret_code INT;

BEGIN
	SET NOCOUNT ON;

	SELECT @id_motivo_ajuste_positivo = id_motivo_ajuste
	FROM Configurations.dbo.Motivo_Ajuste
	WHERE codigo = 1;

	SELECT @id_motivo_ajuste_negativo = id_motivo_ajuste
	FROM Configurations.dbo.Motivo_Ajuste
	WHERE codigo = 2;

	WHILE (@i <= @items_pendientes)
	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;

			-- Obtener item desde la Temporal
			SET @msg_error = 'No se pudo obtener el Item desde la tabla Temporal.';

			SELECT @id_item_facturacion = ift.id_item_facturacion,
				@id_cuenta = ift.id_cuenta,
				@suma_impuestos = ift.suma_impuestos,
				@vuelta_facturacion = ift.vuelta_facturacion,
				@id_log_vuelta_facturacion = ift.id_log_vuelta_facturacion,
				@identificador_carga_dwh = ift.identificador_carga_dwh,
				@impuestos_reales = ift.impuestos_reales,
				@nro_comprobante = ift.nro_comprobante,
				@fecha_comprobante = ift.fecha_comprobante,
				@punto_venta = ift.punto_venta,
				@letra_comprobante = ift.letra_comprobante,
				@importe_ajuste=ift.dif_ajuste
			FROM Configurations.dbo.Item_Facturacion_tmp ift
			WHERE ift.i = @i;

			-- Actualizar Item_Facturacion
			SET @msg_error = 'No se pudo actualizar Item Facturación.';

			UPDATE Configurations.dbo.Item_Facturacion
			SET vuelta_facturacion = @vuelta_facturacion,
				id_log_vuelta_facturacion = @id_log_vuelta_facturacion,
				identificador_carga_dwh = @identificador_carga_dwh,
				impuestos_reales = @impuestos_reales,
				nro_comprobante = @nro_comprobante,
				fecha_comprobante = @fecha_comprobante,
				punto_venta = @punto_venta,
				letra_comprobante = @letra_comprobante
			WHERE id_item_facturacion = @id_item_facturacion;

			-- Generar Ajuste si corresponde
			--SET @importe_ajuste = @suma_impuestos - @impuestos_reales;

			print @importe_ajuste

			IF (@importe_ajuste<>0)
			BEGIN
				-- Crear nuevo Ajuste
				SET @msg_error = 'No se pudo crear el nuevo Ajuste.';
				-- Indicar el motivo
				SET @id_motivo_ajuste = iif(@importe_ajuste > 0, @id_motivo_ajuste_positivo, @id_motivo_ajuste_negativo);

				EXEC @ret_code = Configurations.dbo.Ajustes_Nuevo_Ajuste @id_cuenta,
					@id_motivo_ajuste,
					@importe_ajuste,
					'Ajuste generado por el proceso de Facturación.',
					@usuario;

				IF (@ret_code <> 1)
				BEGIN
					throw 51000,
						@msg_error,
						1;
				END;
			END;

			-- Desmarcar TX si no se encontraron coincidencias para su Item correspondiente
			SET @msg_error = 'No se pudo actualizar la Transacción.';

			IF (@vuelta_facturacion = 'No procesado')
			BEGIN
				UPDATE Transactions.dbo.transactions
				SET BillingTimestamp = NULL,
					BillingStatus = 0,
					SyncStatus = 0
				WHERE EXISTS (
						SELECT 1
						FROM Configurations.dbo.Detalle_Facturacion dfn
						WHERE dfn.id_item_facturacion = @id_item_facturacion
							AND dfn.id_transaccion = Id
						);
			END;

			COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
		END CATCH

		SET @i += 1;
	END;

	RETURN 1;
END
