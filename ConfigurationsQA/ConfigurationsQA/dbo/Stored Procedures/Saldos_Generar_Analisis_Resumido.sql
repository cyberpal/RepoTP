
CREATE PROCEDURE [dbo].[Saldos_Generar_Analisis_Resumido] (@p_solo_cuentas_activas BIT = 0)
AS
DECLARE @i INT = 1;
DECLARE @count INT;
DECLARE @id_cuenta INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		CREATE TABLE #Cuentas_A_Resumir (
			i INT PRIMARY KEY identity(1, 1),
			id_cuenta INT
			);

		-- CORREGIR PARA RECUPERAR SOLO CUENTAS ACTIVAS --
		INSERT INTO #Cuentas_A_Resumir (id_cuenta)
		SELECT id_cuenta
		FROM Configurations.dbo.Cuenta cta
		INNER JOIN Configurations.dbo.Estado est
			ON cta.id_estado_cuenta = est.id_estado
		WHERE est.Codigo NOT IN (
				'CTA_CREADA',
				'CTA_CERRADA',
				'CTA_RECHAZADA',
				'CTA_VENCIDA'
				);

		SELECT @count = count(1)
		FROM #Cuentas_A_Resumir;

		WHILE (@i <= @count)
		BEGIN
			SELECT @id_cuenta = id_cuenta
			FROM #Cuentas_A_Resumir
			WHERE i = @i;

			EXEC Configurations.dbo.Saldos_Resumir_Cuenta @id_cuenta;

			SET @i += 1;
		END;

		DROP TABLE #Cuentas_A_Resumir;
	END TRY

	BEGIN CATCH
		throw;
	END CATCH;

	RETURN 1;
END

