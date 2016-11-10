
CREATE VIEW [dbo].[TransactionsView] AS
select 
       t.Id as id, 
       t.CreateTimestamp as fecha,
       t.CredentialEmailAddress as cliente, 
       t.saleConcept as concepto,
       t.amount as amount,
       t.TransactionStatus as estado,
       t.CredentialMask as CredentialMask,
       t.CredentialHolderName as CredentialHolderName,
       t.CreateTimeStamp as CreateTimeStSaleConceptamp,
       t.CredentialEmailAddress as CredencialEmailAddress,
       t.AvailableTimestamp as AvailableTimestamp,
       t.ProductIdentification as ProductIdentification,
       t.ProviderTransactionID as ProviderTransactionID,
       t.LiquidationTimestamp as LiquidationTimestamp,
       t.CouponExpirationDate as CouponExpirationDate,
       t.TaxAmount as TaxAmount,
       t.FeeAmount as FeeAmount,
       t.CouponStatus as CouponStatus,
       t.ResultCode as ResultCode,
       t.LiquidationStatus as LiquidationStatus,
       t.OperationName as OperationName,
       t.LocationIdentification as locationIdentification,
       t.PaymentTimestamp as PaymentTimestamp,
       'tx' as origin,
       t.CashoutTimestamp as CashoutTimestamp,
       t.ChargebackStatus as ChargebackStatus,
       t.BuyerAccountIdentification as BuyerAccountIdentification,
       t.BankIdentification as BankIdentification,
	   t.CurrencyCode as CurrencyCode,
	   t.facilitiesPayments as FacilitiesPayments,
	   t.OriginalOperationId as OriginalOperationId,
	   t.taxAmountBuyer as taxAmountBuyer,
	   t.amountBuyer as amountBuyer,
       bco.denominacion as BancoDenominacion,
	   cta.denominacion1 as CuentaDenominacion1,
	   cta.denominacion2 as CuentaDenominacion2,
	   usu_cta.eMail as VendedorEmailAddress,
	   t.productType as ProductType,
	   t.resultMessage as ResultMessage,
	   e.nombre as EstadoTransaccion,
	   t.channel as Channel
from Transactions.dbo.transactions t
left join dbo.Banco bco
on bco.id_banco = t.bankIdentification
left join dbo.Cuenta cta
on cta.id_cuenta = t.LocationIdentification
left join dbo.Usuario_Cuenta usu_cta
on usu_cta.id_cuenta = t.LocationIdentification
left join dbo.Estado e
on e.codigo = t.TransactionStatus

union all
select (cast (r.id_retiro_dinero as varchar)) 
       as id, 
       r.fecha_alta as fecha,
       NULL as cliente, 
       concat('Transferencia a cuenta ',b.nombre_banco) as concepto,
       r.monto as amount,
       r.estado_transaccion as estado,
       NULL as CredentialMask,
       NULL as CredentialHolderName,
       NULL as CreateTimeStamp,
       NULL as CredencialEmailAddress,
       NULL as AvailableTimestamp,
       NULL as ProductIdentification,
       (cast (r.id_retiro_dinero as varchar)) as ProviderTransactionID,
       NULL as LiquidationTimestamp,
       NULL as CouponExpirationDate,
       NULL as TaxAmount,
       NULL as FeeAmount,
       NULL as CouponStatus,
       r.cod_respuesta_interno as ResultCode,
       NULL as LiquidationStatus,
       'Retiro_de_Dinero' as OperationName,
       r.id_cuenta as locationIdentification,
       null as PaymentTimestamp,
       'rd' as origin,
       null as CashoutTimestamp,
       null as ChargebackStatus,
       null as BuyerAccountIdentification,
       null as BankIdentification,
	   null as CurrencyCode,
	   null as FacilitiesPayments,
	   null as OriginalOperationId,
	   null as taxAmountBuyer,
	   null as amountBuyer,
       null as BancoDenominacion,
	   null as CuentaDenominacion1,
	   null as CuentaDenominacion2,
	   null as VendedorEmailAddress,
	   null as ProductType,
	   null as ResultMessage,
	   e.nombre as EstadoTransaccion,
	   null as channel
from dbo.Retiro_Dinero r
right join dbo.Informacion_Bancaria_Cuenta b
on r.id_informacion_bancaria_destino = b.id_informacion_bancaria
left join dbo.Estado e
on e.codigo = r.estado_transaccion

union all
select (cast (a.id_ajuste as varchar)) 
       as id, 
       a.fecha_alta as fecha,
       NULL as cliente, 
       ma.descripcion as concepto,
       a.monto_neto as amount,
       e.nombre as estado,
       NULL as CredentialMask,
       (CAST (a.id_ajuste AS VARCHAR)) as CredentialHolderName,
       a.fecha_alta as CreateTimeStamp,
       NULL as CredencialEmailAddress,
       NULL as AvailableTimestamp,
       NULL as ProductIdentification,
       (cast (a.id_ajuste as varchar)) as ProviderTransactionID,
       NULL as LiquidationTimestamp,
       NULL as CouponExpirationDate,
       NULL as TaxAmount,
       NULL as FeeAmount,
       NULL as CouponStatus,
       -1 as ResultCode,
       NULL as LiquidationStatus,
       'Ajuste' as OperationName,
       a.id_cuenta as locationIdentification,
       null as PaymentTimestamp,
       'rd' as origin,
       null as CashoutTimestamp,
       null as ChargebackStatus,
       null as BuyerAccountIdentification,
       null as BankIdentification,
	   null as CurrencyCode,
	   null as FacilitiesPayments,
	   null as OriginalOperationId,
	   null as taxAmountBuyer,
	   null as amountBuyer,
       null as BancoDenominacion,
	   null as CuentaDenominacion1,
	   null as CuentaDenominacion2,
	   null as VendedorEmailAddress,
	   null as ProductType,
	   null as ResultMessage,
	   e.nombre as EstadoTransaccion,
	   null as channel
from dbo.Ajuste a
left join dbo.Estado e
on e.id_estado = a.estado_ajuste
left join dbo.Motivo_Ajuste ma
on a.id_motivo_ajuste = ma.id_motivo_ajuste
WHERE e.codigo = 'AJUSTE_PROCESADO'

