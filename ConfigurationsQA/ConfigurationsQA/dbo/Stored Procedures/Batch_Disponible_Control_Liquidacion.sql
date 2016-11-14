
CREATE PROCEDURE [dbo].[Batch_Disponible_Control_Liquidacion] (@id_cuenta INT)
AS
DECLARE @importe_liquidado DECIMAL(12, 2);
DECLARE @importe_cashout_actual DECIMAL(12, 2);
DECLARE @importe_cashout_pendiente DECIMAL(12, 2);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Sumarizar registros de la Cuenta con fecha de Cashout actual por Código de Operación:
		-- 1 - Compra
		-- 3 - Devolución
		-- 8 - Bonificación
		SELECT @importe_liquidado = sum(isnull(cld.importe, 0))
		FROM Configurations.dbo.Control_Liquidacion_Disponible cld
		WHERE cld.id_cuenta = @id_cuenta
			AND cld.fecha_de_cashout = cast(getdate() AS DATE)
			AND cld.id_codigo_operacion IN (
				1,
				3,
				8
				);

		-- Obtener importe de cashout correspondiente a la fecha actual y a las anteriores
		SELECT @importe_cashout_actual = sum(iif(tmp.fecha_cashout = cast(getdate() AS DATE), tmp.importe, 0)),
			@importe_cashout_pendiente = sum(iif(tmp.fecha_cashout = cast(getdate() AS DATE), 0, tmp.importe))
		FROM Configurations.dbo.Disponible_Detalle_Tmp tmp
		WHERE tmp.id_cuenta = @id_cuenta;

		-- Actualizar estado de procesamiento de la Cuenta
		UPDATE Configurations.dbo.Disponible_Por_Cuenta_Tmp
		SET importe_liquidado = @importe_liquidado,
			importe_cashout_actual = @importe_cashout_actual,
			importe_cashout_pendiente = @importe_cashout_pendiente,
			flag_liquidacion_ok = (
				CASE 
					WHEN @importe_liquidado = importe
						THEN 1
					ELSE 0
					END
				)
		WHERE id_cuenta = @id_cuenta;
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		throw;

		RETURN 0;
	END CATCH;

	RETURN 1;
END;

