
CREATE PROCEDURE [dbo].[Batch_Concil_Macheo_Transacciones](
@id_movimiento_mp INT,
@codigo_tipo_mp VARCHAR(20),
@id_medio_pago INT,
@Id VARCHAR(36) = NULL OUTPUT,
@validacion_resultado_mov VARCHAR(250) = NULL OUTPUT,
@CantId INT = NULL OUTPUT
)

AS
SET NOCOUNT ON;

DECLARE @msg VARCHAR(MAX);
DECLARE @QUERY nvarchar(MAX);
DECLARE @formato_parametro VARCHAR(10);
DECLARE @id_codigo_operacion INT;
DECLARE @id_mp VARCHAR(50);
DECLARE @idSalida VARCHAR(36) = NULL;
DECLARE @resultadoSalida VARCHAR(250) = NULL;
DECLARE @ParmDefinition NVARCHAR(MAX);

BEGIN TRY 

BEGIN TRANSACTION

SET @id_mp = @id_movimiento_mp;

SET @QUERY = ' SELECT
	             @idOUT = trn.Id,
	             @resultado_movOUT = mpm.validacion_resultado_mov
              FROM Configurations.dbo.Movimiento_Presentado_MP mpm 
	          LEFT JOIN Transactions.dbo.transactions trn ';

IF (@codigo_tipo_mp = 'EFECTIVO')
   BEGIN
     SET @QUERY = @QUERY + 'ON  SUBSTRING (mpm.codigo_barra,16,8) = trn.ProviderTransactionID ';
   END	  		
ELSE 
   BEGIN

     SET @QUERY = @QUERY + 'ON mpm.importe = trn.Amount 
	                        AND mpm.id_medio_pago = trn.ProductIdentification
	                        AND mpm.moneda = (SELECT top 1 mmp.id_moneda_mp FROM dbo.Moneda_Medio_Pago mmp WHERE mmp.moneda_mp_autorizacion = trn.CurrencyCode) ';


     SELECT 
	    @formato_parametro = ccn.formato_parametro,
	    @id_codigo_operacion = mpm.id_codigo_operacion
	 FROM Configurations.dbo.Movimiento_Presentado_MP mpm
	 INNER JOIN Configurations.dbo.Configuracion_Conciliacion ccn 
	         ON ccn.id_medio_pago = mpm.id_medio_pago
	 WHERE mpm.id_movimiento_mp = @id_movimiento_mp;


	 IF(@formato_parametro = 'hash')
	    SET @QUERY = @QUERY + 'AND mpm.hash_nro_tarjeta = trn.CredentialCardHash ';
	 ELSE
	    SET @QUERY = @QUERY + 'AND (LEFT(mpm.mask_nro_tarjeta,6)+RIGHT(RTRIM(LTRIM(mpm.mask_nro_tarjeta)),4)= LEFT(trn.CredentialMask,6)+RIGHT(trn.CredentialMask,4)) ';
     
	 IF(@id_medio_pago = 14 OR @id_medio_pago = 2 OR @id_medio_pago = 4 OR @id_medio_pago = 907 OR @id_medio_pago = 13 OR @id_medio_pago = 30)
	   BEGIN
	     SET @QUERY = @QUERY + 'AND (RTRIM(LTRIM(mpm.nro_autorizacion))) = (RTRIM(LTRIM(trn.ProviderAuthorizationCode)))
		                        AND CAST(mpm.fecha_movimiento AS DATE) = CAST(trn.CreateTimestamp AS DATE)
								AND mpm.cantidad_cuotas = trn.FacilitiesPayments
								AND mpm.nro_cupon = trn.TicketNumber ';
	   END
     ELSE 
	   BEGIN
	    IF(@id_medio_pago = 42)
		   BEGIN
		     SET @QUERY = @QUERY + 'AND (RTRIM(LTRIM(mpm.nro_autorizacion)) = ''0''+SUBSTRING(trn.ProviderAuthorizationCode, 2, 5)) 
		                            AND CAST(mpm.fecha_movimiento AS DATE) = CAST(trn.CreateTimestamp AS DATE)
								    AND mpm.cantidad_cuotas = trn.FacilitiesPayments
								    AND mpm.nro_cupon = trn.TicketNumber ';
		   END
		 ELSE
		   BEGIN
		     IF(@id_medio_pago = 6)
			   BEGIN
			    SET @QUERY = @QUERY + 'AND (RTRIM(LTRIM(mpm.nro_autorizacion)) = SUBSTRING(trn.ProviderAuthorizationCode, 2, 5)) 
		                               AND CAST(mpm.fecha_movimiento AS DATE) = CAST(trn.CreateTimestamp AS DATE)
								       AND mpm.cantidad_cuotas = trn.FacilitiesPayments ';
               END
             ELSE IF(@id_medio_pago = 1 AND @id_codigo_operacion <> 2)
			    BEGIN
				  SET @QUERY = @QUERY + 'AND CAST(mpm.fecha_movimiento AS DATE) = CAST(trn.CreateTimestamp AS DATE)
								         AND mpm.cantidad_cuotas = trn.FacilitiesPayments 
										 AND mpm.nro_cupon = trn.TicketNumber ';
				END
		   END 	 
       END
   END

SET @QUERY = @QUERY + 'WHERE mpm.id_movimiento_mp = ' + @id_mp;

SET @ParmDefinition = '@idOUT VARCHAR(36) = NULL OUTPUT,
                       @resultado_movOUT VARCHAR(100) = NULL OUTPUT';


EXEC sp_executesql @QUERY, 
                   @ParmDefinition,
				   @idOUT = @idSalida OUTPUT, 
				   @resultado_movOUT = @resultadoSalida OUTPUT;

SET @CantId = @@ROWCOUNT;				   
				   
SELECT @Id = @idSalida,
       @validacion_resultado_mov = @resultadoSalida;


COMMIT TRANSACTION

END TRY

BEGIN CATCH
    IF @@TRANCOUNT > 0
	ROLLBACK TRANSACTION;

	SELECT @msg = ERROR_MESSAGE();

	THROW 51000,
		@msg,
		1;
END CATCH;


