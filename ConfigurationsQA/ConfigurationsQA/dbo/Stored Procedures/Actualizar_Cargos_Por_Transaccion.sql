

CREATE PROCEDURE [dbo].[Actualizar_Cargos_Por_Transaccion] (
	@fecha_alta DATETIME = NULL,
	@id_transaccion VARCHAR(36),
	@monto_calculado DECIMAL(12,2),
	@valor_aplicado DECIMAL(12,2),
	@id_cargo INT,
	@id_tipo_aplicacion INT,
	@usuario_alta VARCHAR(20) = NULL
	)            
AS

DECLARE @msg VARCHAR(255) = NULL;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
	IF(@id_transaccion IS NULL)
		THROW 51000, 'id_transaccion Nulo', 1;

	IF(@monto_calculado IS NULL)
		THROW 51000, 'monto_calculado Nulo', 1;

	IF(@valor_aplicado IS NULL)
		THROW 51000, 'valor_aplicado Nulo', 1;

	IF(@id_cargo IS NULL)
		THROW 51000, 'id_cargo Nulo', 1;



	INSERT INTO [dbo].[Cargos_Por_Transaccion] (
		[fecha_alta],
		[id_transaccion],
		[monto_calculado],
		[valor_aplicado],
		[id_cargo],
		[id_tipo_aplicacion],
		[usuario_alta]
	) VALUES (
		@fecha_alta,
		@id_transaccion,
		@monto_calculado,
		@valor_aplicado,
		@id_cargo,
		@id_tipo_aplicacion,
		@usuario_alta
	);
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE();
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;


