
CREATE PROCEDURE [dbo].[Ajustes_Nuevo_Ajuste_Pendiente] (
	@id_cuenta INT,
	@id_motivo_ajuste INT,
	@importe_neto DECIMAL(12, 2),
	@observaciones VARCHAR(140),
	@usuario VARCHAR(20),
	@id_ajuste INT OUTPUT
	)
AS
DECLARE @err_code INT;
DECLARE @err_msg VARCHAR(200);
DECLARE @facturable BIT;
DECLARE @alicuota DECIMAL(12, 2);
DECLARE @monto_impuesto DECIMAL(12, 2) = 0;
DECLARE @estado_ajuste INT;
DECLARE @ajuste TABLE (id_ajuste INT);


BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Eliminar signo del importe neto
		set @importe_neto = abs(@importe_neto);
		-- Verificar si el ajuste es Facturable
		SELECT @facturable = maj.facturable
		FROM Configurations.dbo.Motivo_Ajuste maj
		WHERE maj.id_motivo_ajuste = @id_motivo_ajuste;

		IF (@facturable = 1)
		BEGIN
			-- Obtener alicuota del IVA vigente para la Cuenta.
			SET @err_code = 51300;
			SET @err_msg = 'No se pudo obtener la Condición de IVA de la Cuenta.';

			SELECT @alicuota = ipt.alicuota
			FROM Configurations.dbo.Situacion_Fiscal_Cuenta sfc
			INNER JOIN Configurations.dbo.Domicilio_Cuenta dca
				ON sfc.id_cuenta = dca.id_cuenta
					AND sfc.id_domicilio_facturacion = dca.id_domicilio
			INNER JOIN Configurations.dbo.Impuesto ipo
				ON ipo.id_provincia = dca.id_provincia
					OR ipo.flag_todas_provincias = 1
			INNER JOIN Configurations.dbo.Impuesto_Por_Tipo ipt
				ON ipo.id_impuesto = ipt.id_impuesto
					AND ipt.id_tipo = sfc.id_tipo_condicion_IVA
			WHERE sfc.id_cuenta = @id_cuenta
				AND sfc.flag_vigente = 1
				AND ipo.codigo = 'IVA';

			IF (@alicuota IS NULL)
			BEGIN
				throw @err_code,
					@err_msg,
					1;
			END;

			-- Calcular IVA
			SET @monto_impuesto = @importe_neto * @alicuota / 100;
		END;

		-- Obtener estado PENDIENTE
		SET @err_code = 51400;
		SET @err_msg = 'No se pudo obtener el Id de estado para el ajuste pendiente.';

		SELECT @estado_ajuste = est.id_estado
		FROM Configurations.dbo.Estado est
		WHERE est.Codigo = 'AJUSTE_PENDIENTE';

		IF (@estado_ajuste IS NULL)
		BEGIN
			throw @err_code,
				@err_msg,
				1;
		END;

		-- Insertar en la tabla Ajuste
		SET @err_code = 51100;
		SET @err_msg = 'No se pudo insertar el ajuste en la tabla Ajuste.';

		BEGIN TRANSACTION;

		INSERT INTO Configurations.dbo.Ajuste (
			id_cuenta,
			id_motivo_ajuste,
			estado_ajuste,
			monto_neto,
			monto_impuesto,
			observaciones,
			fecha_alta,
			usuario_alta,
			version
			)
		OUTPUT inserted.id_ajuste
		INTO @ajuste
		VALUES (
			@id_cuenta,
			@id_motivo_ajuste,
			@estado_ajuste,
			@importe_neto,
			@monto_impuesto,
			@observaciones,
			GETDATE(),
			@usuario,
			0
			);

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
		
		RETURN 0;
	END CATCH;
	
	-- Retornar el Ajuste
	SELECT @id_ajuste = id_ajuste
	FROM @ajuste;

	RETURN 1;
END
