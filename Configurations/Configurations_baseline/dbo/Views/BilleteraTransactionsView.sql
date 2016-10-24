
CREATE VIEW [dbo].[BilleteraTransactionsView] AS
select 
t.CreateTimestamp as fecha,	
t.Id as identificadorMovimiento, 
	t.OperationName as tipoMovimiento,
	t.saleConcept as conceptoMovimiento,
	t.LocationIdentification as cuentaVendedor,
	'idCuentaComprador' as idCuentaComprador,
	t.ProductIdentification as idMedioDePago,
	t.CredentialMask as nroTarjeta,
	'denominacionTablaBanco' as banco,
	mt.codigo as tipoMedioPago,
	t.FacilitiesPayments as cantidadCuotas,
	t.TransactionStatus as estadoMovimiento,
	CAST(mj.mensaje AS VARCHAR(100)) AS motivoRechazoMovimiento,
	t.CurrencyCode as monedaMovimiento,
	t.Amount as importeMovimiento,
	t.CredentialEmailAddress as mailComprador,
	c.denominacion1 as nombreCuenta,
	c.denominacion2 as apellidoCuenta,
	c.denominacion2 as razonSocialCuenta,
	t.OriginalOperationId as compraAsociadaADevolucion,
	t.resultCode as resultCode

from Transactions.dbo.transactions t
left join medio_de_pago m on m.id_medio_pago = t.ProductIdentification
left join tipo_medio_pago mt on mt.id_tipo_medio_pago = m.id_tipo_medio_pago
left join Codigo_Respuesta_Resolutor cr on m.id_resolutor = cr.id_resolutor and t.ProcessorResultCode = cr.codigo_respuesta
left join Mensaje mj on cr.id_mensaje = mj.id_mensaje
left join cuenta c on c.id_cuenta = t.LocationIdentification
UNION ALL
select 
aj.fecha_alta as fecha,	
CAST(aj.id_ajuste AS VARCHAR(100)) as identificadorMovimiento, 
	'Ajuste' as tipoMovimiento,
	null as conceptoMovimiento,
	aj.id_cuenta as cuentaVendedor,
	null as idCuentaComprador,
	null as idMedioDePago,
	null as nroTarjeta,
	null as banco,
	null as tipoMedioPago,
	null as cantidadCuotas,
	 aj.estado_ajuste as estadoMovimiento,
	null AS motivoRechazoMovimiento,
	null as monedaMovimiento,
	 aj.monto as importeMovimiento,
	null as mailComprador,
	 c.denominacion1 as nombreCuenta,
	 c.denominacion2 as apellidoCuenta,
	 c.denominacion2 as razonSocialCuenta,
	null as compraAsociadaADevolucion,
	null as resultCode
from Ajuste aj
left join cuenta c on c.id_cuenta = aj.id_cuenta
