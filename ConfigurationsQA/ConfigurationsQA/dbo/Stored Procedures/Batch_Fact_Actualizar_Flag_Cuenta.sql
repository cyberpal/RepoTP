
CREATE PROCEDURE [dbo].[Batch_Fact_Actualizar_Flag_Cuenta]           
AS

DECLARE @msg VARCHAR(MAX);
DECLARE @cuenta_tmp TABLE (id_cuenta_tmp INT);

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

    INSERT @cuenta_tmp
	SELECT (id_cuenta - 1000000)
    FROM Configurations.dbo.Facturacion_NovedadesCtas_tmp; 

	UPDATE cta
	SET cta.flag_informado_a_facturacion = 1
	FROM Configurations.dbo.Cuenta cta
	INNER JOIN @cuenta_tmp cta_tmp
		    ON cta.id_cuenta = cta_tmp.id_cuenta_tmp;

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE();
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;


