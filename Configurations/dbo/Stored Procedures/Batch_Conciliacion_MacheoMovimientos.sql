
CREATE PROCEDURE dbo.Batch_Conciliacion_MacheoMovimientos
AS
	
SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	INSERT INTO Configurations.dbo.movimientos_conciliados_tmp	  
    SELECT tc.Id,
	       mac.id_movimiento_mp
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON mac.id_medio_pago = tc.ProductIdentification
           AND mac.importe = tc.Amount
	       AND mac.nro_autorizacion = tc.ProviderAuthorizationCode
	       AND mac.fecha_movimiento = tc.CreateTimestamp
	       AND mac.cantidad_cuotas = tc.FacilitiesPayments 
	       AND (LEFT(mac.mask_nro_tarjeta,6)+RIGHT(mac.mask_nro_tarjeta,4)) = tc.CredentialMask
    WHERE mac.id_medio_pago = 6;
	
	
	INSERT INTO Configurations.dbo.movimientos_conciliados_tmp	  
    SELECT tc.Id,
	       mac.id_movimiento_mp
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON mac.id_medio_pago = tc.ProductIdentification
           AND mac.importe = tc.Amount
	       AND mac.nro_autorizacion = tc.ProviderAuthorizationCode
	       AND mac.fecha_movimiento = tc.CreateTimestamp
	       AND mac.cantidad_cuotas = tc.FacilitiesPayments 
	       AND mac.hash_nro_tarjeta = tc.CredentialCardHash 
		   AND mac.nro_cupon = tc.TicketNumber
    WHERE mac.id_medio_pago = 42;
	
	
	INSERT INTO Configurations.dbo.movimientos_conciliados_tmp	  
    SELECT tc.Id,
	       mac.id_movimiento_mp
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON mac.id_medio_pago = tc.ProductIdentification
           AND mac.importe = tc.Amount
	       AND mac.nro_autorizacion = tc.ProviderAuthorizationCode
	       AND mac.fecha_movimiento = tc.CreateTimestamp
	       AND mac.cantidad_cuotas = tc.FacilitiesPayments
		   AND mac.nro_cupon = tc.TicketNumber
	       AND (LEFT(mac.mask_nro_tarjeta,6)+RIGHT(mac.mask_nro_tarjeta,4)) = tc.CredentialMask
    WHERE mac.id_medio_pago IN (14,2,4,907,13,30);
    
	
	INSERT INTO Configurations.dbo.movimientos_conciliados_tmp	  
    SELECT tc.Id,
	       mac.id_movimiento_mp
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON mac.id_medio_pago = tc.ProductIdentification
           AND mac.codigo_barra = tc.InvoiceBarCode
    WHERE mac.id_medio_pago IN (500,501);
	
	
	INSERT INTO Configurations.dbo.movimientos_conciliados_tmp	  
    SELECT tc.Id,
	       mac.id_movimiento_mp
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON mac.id_medio_pago = tc.ProductIdentification
		   AND mac.importe = tc.Amount
		   AND (LEFT(mac.mask_nro_tarjeta,6)+RIGHT(mac.mask_nro_tarjeta,4)) = tc.CredentialMask
		   AND (mac.fecha_movimiento = tc.CreateTimestamp OR mac.fecha_movimiento IS NULL)
		   AND (mac.cantidad_cuotas = tc.FacilitiesPayments OR mac.cantidad_cuotas IS NULL)
		   AND (mac.nro_cupon = tc.TicketNumber OR mac.nro_cupon IS NULL)
    WHERE mac.id_medio_pago = 1;
	
	
	UPDATE mac
    SET mac.cant_tx = tx.cant
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN (SELECT id_movimiento_mp,
                COUNT(1) AS cant
                FROM Configurations.dbo.movimientos_conciliados_tmp
                GROUP BY id_movimiento_mp
               )tx
            ON tx.id_movimiento_mp = mac.id_movimiento_mp;

			
    UPDATE mac    
    SET mac.id_transaccion = mc.Id,
        mac.impuestos_boton_por_movimiento = ISNULL(tc.TaxAmount,0),
    	mac.cargos_boton_por_movimiento = ISNULL(tc.FeeAmount,0),
		mac.estado_cupon = tc.CouponStatus,
		mac.estado_tx = tc.TransactionStatus
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
    INNER JOIN Configurations.dbo.movimientos_conciliados_tmp mc
            ON mc.id_movimiento_mp = mac.id_movimiento_mp
    INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc
            ON tc.Id = mc.Id
    WHERE mac.cant_tx = 1

	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;