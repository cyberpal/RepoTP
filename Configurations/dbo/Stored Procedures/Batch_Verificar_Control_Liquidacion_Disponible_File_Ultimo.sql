

CREATE PROCEDURE [dbo].[Batch_Verificar_Control_Liquidacion_Disponible_File_Ultimo] 
	@id_cuenta INT = NULL,
	@fecha_de_cashout DATE = NULL,
	@importe_disponible DECIMAL(12, 2) = NULL,
	@importe_liquidacion DECIMAL(12, 2) OUTPUT
AS
	DECLARE @ret INT;
	DECLARE @msg VARCHAR(MAX);
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT @importe_liquidacion = SUM(cld.importe)
		FROM Configurations.dbo.Control_Liquidacion_Disponible cld
		WHERE cld.fecha_de_cashout = @fecha_de_cashout
		  AND cld.id_cuenta = @id_cuenta;

		IF (@importe_liquidacion = @importe_disponible)
			SET @ret = 1;
		ELSE
			SET @ret = 0;
	END TRY

	BEGIN CATCH
		SELECT @msg  = ERROR_MESSAGE();
		THROW  51000, @msg , 1;
	END CATCH;

	RETURN @ret;
END;

