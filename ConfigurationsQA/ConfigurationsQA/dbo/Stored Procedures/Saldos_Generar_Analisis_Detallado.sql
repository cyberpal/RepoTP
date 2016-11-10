
CREATE PROCEDURE [dbo].[Saldos_Generar_Analisis_Detallado]
AS
DECLARE @i INT = 1;
DECLARE @count INT;
DECLARE @id_resumen INT;
DECLARE @id_cuenta INT;
DECLARE @ret_code INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		CREATE TABLE #Cuentas_A_Detallar (
			i INT PRIMARY KEY identity(1, 1),
			id_resumen INT,
			id_cuenta INT
			);

		INSERT INTO #Cuentas_A_Detallar (
			id_resumen,
			id_cuenta
			)
		SELECT id_resumen,
			id_cuenta
		FROM Configurations.dbo.Resumen_Analisis_De_Saldo
		WHERE flag_generar_detalle = 1
			AND (
				detalle_generado_ok <> 1
				OR detalle_generado_ok IS NULL
				);

		SELECT @count = count(1)
		FROM #Cuentas_A_Detallar;

		WHILE (@i <= @count)
		BEGIN
			SELECT @id_resumen = id_resumen,
				@id_cuenta = id_cuenta
			FROM #Cuentas_A_Detallar
			WHERE i = @i;

			EXEC @ret_code = Configurations.dbo.Saldos_Detallar_Cuenta @id_cuenta;

			UPDATE Configurations.dbo.Resumen_Analisis_De_Saldo
			SET detalle_generado_ok = (
					CASE 
						WHEN @ret_code = 1
							THEN 1
						ELSE 0
						END
					)
			WHERE id_resumen = @id_resumen;

			SET @i += 1;
		END;

		DROP TABLE #Cuentas_A_Detallar;
	END TRY

	BEGIN CATCH
		throw;
	END CATCH;

	RETURN 1;
END

