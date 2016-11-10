
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ObtenerMovimientos]
AS
DECLARE @cant INT;

BEGIN
 SET NOCOUNT ON;
 
    INSERT INTO Configurations.dbo.Movimientos_a_Conciliar_tmp
    SELECT
	    mpp.id_movimiento_mp,
	    NULL,
	    mdp.id_medio_pago,
	    mpp.importe,
        mpp.signo_importe,
        mpp.moneda,
        mpp.cantidad_cuotas,
        mpp.nro_tarjeta,
        mpp.codigo_barra,
        CAST(mpp.fecha_movimiento AS DATE),
        mpp.nro_autorizacion,
        mpp.nro_cupon,
        mpp.cargos_marca_por_movimiento,
        mpp.signo_cargos_marca_por_movimiento,
	    NULL,
	    NULL,
        mpp.nro_agrupador_boton,
        mpp.fecha_pago,
	    mpp.mask_nro_tarjeta,
	    mpp.hash_nro_tarjeta,
	    tmp.codigo,
	    CASE WHEN co.codigo_operacion = 'CON'
	         THEN 1
	    	 ELSE 0
        END,
	    CASE WHEN tmp.codigo = 'EFECTIVO'
	         THEN 1
	    	 ELSE (CASE WHEN em.estado_movimiento = 'A' 
	    	            THEN 1
	    			    ELSE 0
                   END)
        END ,
	    CASE WHEN tmp.codigo <> 'EFECTIVO'
	         THEN 0
        END,
	    CASE WHEN co.codigo_operacion = 'COM' AND tmp.codigo = 'EFECTIVO'
	         THEN 0
	    	 ELSE 1
        END,
	    0,
		NULL,
		NULL
    FROM Configurations.dbo.Movimiento_Presentado_MP mpp 
    INNER JOIN Configurations.dbo.Medio_De_Pago mdp 
    		ON mpp.id_medio_pago = mdp.id_medio_pago
    INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp 
    		ON tmp.id_tipo_medio_pago = mdp.id_tipo_medio_pago
    INNER JOIN Configurations.dbo.Codigo_operacion co 
            ON mpp.id_codigo_operacion = co.id_codigo_operacion
     LEFT JOIN Configurations.dbo.Estado_Movimiento_MP em
            ON mpp.id_medio_pago = em.id_medio_pago
    	   AND em.campo_mp_1 = mpp.campo_mp_1
    	   AND em.valor_1 = mpp.valor_1
    	   AND em.campo_mp_2 = mpp.campo_mp_2
    	   AND em.valor_2 = mpp.valor_2
    	   AND em.campo_mp_3 = mpp.campo_mp_3
    	   AND em.valor_3= mpp.valor_3
    WHERE NOT EXISTS (
    	SELECT 1
    	FROM Configurations.dbo.Conciliacion cnn 
    	WHERE cnn.id_movimiento_mp = mpp.id_movimiento_mp
      )
     AND NOT EXISTS (
    	SELECT 1
    	FROM Configurations.dbo.Conciliacion_Manual cnm 
    	WHERE cnm.id_movimiento_mp = mpp.id_movimiento_mp
      );

	  
    INSERT INTO Configurations.dbo.Transacciones_Conciliacion_tmp
    SELECT Id,
	       InvoiceBarCode,
	       Amount,
	       ProductIdentification,
	       CurrencyCode,
	       CredentialCardHash,
	       LEFT(CredentialMask,6)+RIGHT(CredentialMask,4),
	       CASE WHEN ProductIdentification = 42 THEN '0'+SUBSTRING(ProviderAuthorizationCode, 2, 5)
		        WHEN ProductIdentification = 6 THEN SUBSTRING(ProviderAuthorizationCode, 2, 5)
				ELSE ProviderAuthorizationCode
		   END,
	       CAST(CreateTimestamp AS DATE),
		   FacilitiesPayments,
	       TicketNumber,
	       CouponStatus,
		   TransactionStatus,
	       TaxAmount,
	       FeeAmount,
	       LocationIdentification,
	       SaleConcept,
	       CredentialEmailAddress,
	       credentialholdername
    FROM Transactions.dbo.transactions
    WHERE ResultCode = -1;


    SELECT @cant = COUNT(1) FROM Configurations.dbo.Movimientos_a_Conciliar_tmp; 			
 
 RETURN @cant;
END
