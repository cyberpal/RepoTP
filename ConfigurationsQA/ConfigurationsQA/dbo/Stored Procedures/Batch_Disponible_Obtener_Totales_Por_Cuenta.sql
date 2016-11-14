
CREATE PROCEDURE [dbo].[Batch_Disponible_Obtener_Totales_Por_Cuenta] (@cuentas_count INT OUTPUT)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		TRUNCATE TABLE Configurations.dbo.Disponible_Por_Cuenta_Tmp;

		-- Sumar totales por Cuenta
		INSERT INTO Configurations.dbo.Disponible_Por_Cuenta_Tmp (
			id_cuenta,
			importe
			)
		SELECT tmp.id_cuenta,
			sum(tmp.importe)
		FROM Configurations.dbo.Disponible_Detalle_Tmp tmp
		GROUP BY tmp.id_cuenta;

		-- Obtener denominacion de cada Cuenta
		UPDATE Configurations.dbo.Disponible_Por_Cuenta_Tmp
		SET denominacion = left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)), 50)
		FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp tmp
		INNER JOIN Configurations.dbo.Cuenta cta
			ON tmp.id_cuenta = cta.id_cuenta;

		SELECT @cuentas_count = count(1)
		FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp;

		RETURN 1;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SET @cuentas_count = 0;

		RETURN 0;
	END CATCH
END

