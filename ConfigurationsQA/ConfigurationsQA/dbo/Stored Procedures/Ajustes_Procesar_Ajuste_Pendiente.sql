
CREATE PROCEDURE [dbo].[Ajustes_Procesar_Ajuste_Pendiente] (
	@id_ajuste INT,
	@usuario VARCHAR(20)
	)
AS
-- Variables de error
DECLARE @err_code INT;
DECLARE @err_msg VARCHAR(200);
DECLARE @flag_ok INT;
-- Variables de Ajuste
DECLARE @id_cuenta INT;
DECLARE @estado_ajuste INT;
DECLARE @monto_neto DECIMAL(12, 2);
DECLARE @monto_impuesto DECIMAL(12, 2);
DECLARE @fecha_alta DATETIME;
DECLARE @signo CHAR(1);
DECLARE @facturable BIT;
DECLARE @afecta_saldo_total BIT;
DECLARE @afecta_saldo_disponible BIT;
DECLARE @afecta_saldo_revision BIT;
-- Variables de Cuenta Virtual
DECLARE @monto_disponible DECIMAL(12, 2) = NULL;
DECLARE @monto_saldo_en_cuenta DECIMAL(12, 2) = NULL;
DECLARE @monto_saldo_en_revision DECIMAL(12, 2) = NULL;
DECLARE @id_tipo_movimiento INT;
DECLARE @id_tipo_origen_movimiento INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Obtener Ajuste Pendiente.
		SET @err_code = 51500;
		SET @err_msg = 'El Ajuste ID = ' + cast(@id_ajuste AS VARCHAR) + ' no existe o no está pendiente.';

		SELECT @id_cuenta = aju.id_cuenta,
			@monto_neto = aju.monto_neto,
			@monto_impuesto = aju.monto_impuesto,
			@fecha_alta = aju.fecha_alta,
			@signo = maj.signo,
			@facturable = maj.facturable,
			@afecta_saldo_total = maj.afecta_saldo_total,
			@afecta_saldo_disponible = maj.afecta_saldo_disponible,
			@afecta_saldo_revision = maj.afecta_saldo_revision
		FROM Configurations.dbo.Ajuste aju
		INNER JOIN Configurations.dbo.Estado est
			ON aju.estado_ajuste = est.id_estado
		INNER JOIN Configurations.dbo.Motivo_Ajuste maj
			ON aju.id_motivo_ajuste = maj.id_motivo_ajuste
		WHERE aju.id_ajuste = @id_ajuste
			AND est.Codigo = 'AJUSTE_PENDIENTE';

		-- Incluir signo
		IF (@signo = '-')
		BEGIN
			SET @monto_neto = @monto_neto * - 1;

			SET @monto_impuesto = @monto_impuesto * - 1;
		END;

		-- Afectar Saldos
		IF @afecta_saldo_disponible = 1
			SET @monto_disponible = @monto_neto + @monto_impuesto;

		IF @afecta_saldo_total = 1
			SET @monto_saldo_en_cuenta = @monto_neto + @monto_impuesto;

		IF @afecta_saldo_revision = 1
			SET @monto_saldo_en_revision = @monto_neto + @monto_impuesto;
		-- Obtener Tipo y Origen de movimiento para Cuenta Virtual.
		SET @err_code = 51600;
		SET @err_msg = 'No se pudo obtener Origen o Tipo para le movimiento de la Cuenta Virtual.';

		SELECT @id_tipo_movimiento = tpo.id_tipo
		FROM Configurations.dbo.Tipo tpo
		WHERE tpo.codigo = (
				CASE 
					WHEN @signo = '+'
						THEN 'MOV_CRED'
					ELSE 'MOV_DEB'
					END
				);

		SELECT @id_tipo_origen_movimiento = tpo.id_tipo
		FROM dbo.Tipo tpo
		WHERE tpo.codigo = 'ORIG_AJUSTE';

		BEGIN TRANSACTION;

		-- Actualizar la Cuenta Virtual
		SET @err_code = 51700;
		SET @err_msg = 'No se pudo Actualizar la Cuenta Virtual.';

		EXEC @flag_ok = Configurations.dbo.Actualizar_Cuenta_Virtual @monto_disponible,
			NULL,
			@monto_saldo_en_cuenta,
			NULL,
			@monto_saldo_en_revision,
			NULL,
			@id_cuenta,
			@usuario,
			@id_tipo_movimiento,
			@id_tipo_origen_movimiento,
			NULL;

		IF (@flag_ok = 0)
		BEGIN
			throw @err_code,
				@err_msg,
				1;
		END;

		-- Si es un ajuste facturable, acumularlo para el control con facturación
		IF (@facturable = 1)
		BEGIN
			SET @err_code = 51800;
			SET @err_msg = 'No se pudo Actualizar el Control de Facturación.';

			MERGE Configurations.dbo.Control_Ajuste_Facturacion AS destino
			USING (
				SELECT @id_cuenta,
					CASE 
						WHEN day(@fecha_alta) BETWEEN 1
								AND 15
							THEN 1
						ELSE 2
						END,
					year(@fecha_alta),
					month(@fecha_alta),
					CASE 
						WHEN @signo = '+'
							THEN 'F'
						ELSE 'C'
						END,
					abs(@monto_neto)
				) AS origen(id_cuenta, id_ciclo_facturacion, anio, mes, tipo_comprobante, total_ajuste)
				ON destino.id_cuenta = origen.id_cuenta
					AND destino.id_ciclo_facturacion = origen.id_ciclo_facturacion
					AND destino.anio = origen.anio
					AND destino.mes = origen.mes
					AND destino.tipo_comprobante = origen.tipo_comprobante
			WHEN MATCHED
				THEN
					UPDATE
					SET total_ajuste += origen.total_ajuste
			WHEN NOT MATCHED
				THEN
					INSERT (
						id_cuenta,
						id_ciclo_facturacion,
						anio,
						mes,
						tipo_comprobante,
						total_ajuste
						)
					VALUES (
						origen.id_cuenta,
						origen.id_ciclo_facturacion,
						origen.anio,
						origen.mes,
						origen.tipo_comprobante,
						origen.total_ajuste
						);
		END;

		SET @err_code = 51900;
		SET @err_msg = 'No se pudo Actualizar el Ajuste.';

		-- Obtener estado procesado
		SELECT @estado_ajuste = est.id_estado
		FROM Configurations.dbo.Estado est
		WHERE est.Codigo = 'AJUSTE_PROCESADO';

		-- Actualizar el Ajuste
		UPDATE Configurations.dbo.Ajuste
		SET estado_ajuste = @estado_ajuste,
			fecha_modificacion = GETDATE(),
			usuario_modificacion = @usuario
		WHERE id_ajuste = @id_ajuste;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		IF (@err_code < 51000)
		BEGIN
			throw 51000,
				'Error no controlado.',
				1;
		END
		ELSE
		BEGIN
			SET @err_msg += ' - ' + ERROR_MESSAGE();

			throw @err_code,
				@err_msg,
				1;
		END;
	END CATCH;

	RETURN 1;
END

