
CREATE PROCEDURE [dbo].[Batch_Concil_Obtener_Cupones]
AS
SET NOCOUNT ON;

DECLARE @msg VARCHAR(max);
DECLARE @i INT = 1;
DECLARE @count INT;
DECLARE @url VARCHAR(256);

BEGIN
	BEGIN TRY
		-- Limpiar tabla temporal
		TRUNCATE TABLE Configurations.dbo.Cupones_tmp;

		BEGIN TRANSACTION;

		-- Obtener URL del WebService
		SELECT @url = par.valor
		FROM Configurations.dbo.Parametro par
		WHERE par.codigo = 'URL_WS_NOTIF_PUSH';

		-- Obtener cupones a notificar.
		INSERT INTO Configurations.dbo.Cupones_tmp (
			id_conciliacion,
			id_transaccion,
			numero_cuenta,
			concepto,
			importe,
			e_mail,
			nombre_comprador,
			nombre_vendedor,
			url
			)
		SELECT id_conciliacion,
			id_transaccion,
			LocationIdentification,
			SaleConcept,
			Amount,
			CredentialEmailAddress,
			credentialholdername,
			CONCAT (
				cta.denominacion2,
				' ',
				cta.denominacion1
				),
			@url
		FROM Configurations.dbo.Conciliacion cln
		INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mmp
			ON mmp.id_movimiento_mp = cln.id_movimiento_mp
		INNER JOIN Configurations.dbo.Medio_de_Pago mdp
			ON mmp.id_medio_pago = mdp.id_medio_pago
		INNER JOIN Transactions.dbo.transactions trn
			ON cln.id_transaccion = trn.Id
		INNER JOIN Configurations.dbo.Cuenta cta
			ON cta.id_cuenta = trn.LocationIdentification
		WHERE cln.flag_notificado = 0
			AND mdp.id_tipo_medio_pago = 3;

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT @msg = ERROR_MESSAGE();

		THROW 51000,
			@Msg,
			1;
	END CATCH;

	RETURN 1;
END;
