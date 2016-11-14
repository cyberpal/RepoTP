  
CREATE PROCEDURE [dbo].[Actualizar_Cupones]     (  
  
@idTransaccion char (36),  
@id_log_paso_padre int,  
@usuario varchar(20),  
@id_movimiento_presentado int,  
@productidentification int,  
@codigo_operacion varchar (5),
@codigo_tipo varchar (15)
  
)        
AS  
  
DECLARE @id_paso int = 0 ;   
DECLARE @esRF2oRF3 bit ;  
DECLARE @ESTADO varchar(20) ;  
DECLARE @importe decimal(12,2);  
DECLARE @moneda int;  
DECLARE @cantidad_cuotas int;  
DECLARE @nro_tarjeta varchar(50);  
DECLARE @fecha_movimiento datetime;  
DECLARE @nro_autorizacion varchar(50);  
DECLARE @nro_cupon varchar (50);  
DECLARE @cargos_marca_por_movimiento  decimal (12,2);  
DECLARE @signo_cargos_marca_por_movimiento varchar (1);  
DECLARE @nro_agrupador_boton varchar(50);   
DECLARE @fecha_pago datetime;  
DECLARE @ID_PASO_PROCESO int;  
DECLARE @id_conciliacion int;
DECLARE @id_disputa bit = null;
DECLARE @id_conciliacion_manual int;


SET NOCOUNT ON;  
  
  
DECLARE @msg VARCHAR(255) = NULL;  
  
  
BEGIN TRANSACTION;  
  
BEGIN TRY  
   
 SELECT @id_paso = ID_PASO_PROCESO FROM dbo.LOG_PASO_PROCESO WHERE ID_LOG_PASO = @id_log_paso_padre;  
  
 IF(@id_paso=2)  
 
  SET @esRF2oRF3 = 0;  
    
 ELSE  
 
  SET @esRF2oRF3 = 1;  

    
 SET @ESTADO = (SELECT COUPONSTATUS from Transactions.dbo.transactions WHERE Id = @idTransaccion);  
    
  
 IF(@codigo_tipo = 'EFECTIVO')  

BEGIN    
 UPDATE Transactions.dbo.transactions   
 SET PaymentTimestamp = (SELECT mpm.fecha_pago FROM Configurations.dbo.Movimiento_Presentado_MP mpm WHERE id_movimiento_mp = @id_movimiento_presentado),  
  ReconciliationStatus = 1,  
  ReconciliationTimestamp = GETDATE(),  
  SyncStatus = 0,  
  CouponStatus = 'ACREDITADO',  
  TransactionStatus = 'TX_PROCESADA'  
 WHERE Id = @idTransaccion  
END  
 ELSE  
BEGIN   
 UPDATE Transactions.dbo.transactions   
 SET PaymentTimestamp = (SELECT mpm.fecha_pago FROM Configurations.dbo.Movimiento_Presentado_MP mpm WHERE id_movimiento_mp = @id_movimiento_presentado),  
  ReconciliationStatus = 1,  
  ReconciliationTimestamp = GETDATE(),  
  SyncStatus = 0
 WHERE Id = @idTransaccion  

 BEGIN
   SET @id_disputa = 0;
 END

END   
  
  
BEGIN  
  
IF (@codigo_operacion = 'COM' and @codigo_tipo = 'EFECTIVO' )  
BEGIN

SELECT
@id_conciliacion = ISNULL(MAX([id_conciliacion]), 0) + 1
FROM dbo.Conciliacion;
  
INSERT INTO dbo.Conciliacion  
  (id_conciliacion,  
   id_transaccion,  
   id_log_paso,   
   flag_aceptada_marca,   
   flag_conciliada,   
   flag_distribuida,   
   flag_contracargo,  
   id_movimiento_mp,  
   flag_notificado,  
   fecha_alta,  
   usuario_alta,  
   id_disputa,  
   version)  
VALUES(
    @id_conciliacion,
	@idTransaccion,   
    @id_log_paso_padre,  
    1,   
    1,  
    @esRF2oRF3,  
    0,  
    @id_movimiento_presentado,  
    0,  
    GETDATE(),  
    @usuario,  
    @id_disputa,  
    0)  
END
ELSE IF (@codigo_operacion = 'CON') 
BEGIN

SELECT
@id_conciliacion = ISNULL(MAX([id_conciliacion]), 0) + 1
FROM dbo.Conciliacion;

INSERT INTO dbo.Conciliacion  
  (id_conciliacion,  
   id_transaccion,  
   id_log_paso,   
   flag_aceptada_marca,   
   flag_conciliada,   
   flag_distribuida,   
   flag_contracargo,  
   id_movimiento_mp,  
   flag_notificado,  
   fecha_alta,  
   usuario_alta,  
   id_disputa,  
   version)  
VALUES(
	@id_conciliacion,	
	@idTransaccion,   
    @id_log_paso_padre,  
    1,   
    1,  
    @esRF2oRF3,  
    1,  
    @id_movimiento_presentado,  
    1,  
    GETDATE(),  
    @usuario,  
    @id_disputa,  
    0)         
END
ELSE  

BEGIN
SELECT
@id_conciliacion = ISNULL(MAX([id_conciliacion]), 0) + 1
FROM dbo.Conciliacion;
  
INSERT INTO dbo.Conciliacion  
  (id_conciliacion,  
   id_transaccion,  
   id_log_paso,   
   flag_aceptada_marca,   
   flag_conciliada,   
   flag_distribuida,   
   flag_contracargo,  
   id_movimiento_mp,  
   flag_notificado,  
   fecha_alta,  
   usuario_alta,  
   id_disputa,  
   version)  
VALUES(
	@id_conciliacion,
	@idTransaccion,   
    @id_log_paso_padre,  
    1,   
    1,  
    @esRF2oRF3,  
    0,  
    @id_movimiento_presentado,  
    1,  
    GETDATE(),  
    @usuario,  
    @id_disputa,  
    0) 
	  
END  
    
  
 IF ( @ESTADO <> 'PENDIENTE' and @codigo_tipo = 'EFECTIVO')  
   
 BEGIN  
 SELECT   
@importe =  mpm.importe,  
@moneda  =  mpm.moneda,  
@cantidad_cuotas =  mpm.cantidad_cuotas,  
@nro_tarjeta =   mpm.nro_tarjeta,  
@fecha_movimiento =  mpm.fecha_movimiento,  
@nro_autorizacion =   mpm.nro_autorizacion,  
@nro_cupon =   mpm.nro_cupon,  
@cargos_marca_por_movimiento =  mpm.cargos_marca_por_movimiento,  
@signo_cargos_marca_por_movimiento = mpm.signo_cargos_marca_por_movimiento,  
@nro_agrupador_boton =  mpm.nro_agrupador_boton,   
@fecha_pago =  mpm.fecha_pago,  
@ID_PASO_PROCESO = lpp.ID_PASO_PROCESO  
FROM dbo.Movimiento_Presentado_MP AS mpm , dbo.LOG_PASO_PROCESO AS lpp   
WHERE mpm.id_movimiento_mp = @id_movimiento_presentado AND lpp.ID_LOG_PASO = @id_log_paso_padre  
   
SELECT
@id_conciliacion_manual = ISNULL(MAX([id_conciliacion_manual]), 0) + 1
FROM dbo.Conciliacion_manual;
   
INSERT INTO dbo.Conciliacion_Manual  
  (id_conciliacion_manual,  
   id_transaccion,   
   importe,  
   moneda,   
   cantidad_cuotas,   
   nro_tarjeta,   
   fecha_movimiento,   
   nro_autorizacion,   
   nro_cupon,  
   nro_agrupador_boton,  
   cargos_marca_por_movimiento,  
   signo_cargos_marca_por_movimiento,  
   fecha_pago,  
   id_log_paso,  
   fecha_alta,  
   usuario_alta,  
   flag_aceptada_marca,  
   flag_contracargo,  
   flag_conciliado_manual,  
   flag_procesado,  
   impuestos_boton_por_movimiento,  
   cargos_boton_por_movimiento,  
   id_movimiento_mp,  
   version)  
VALUES(
		@id_conciliacion_manual,
		@idTransaccion,  
        @importe,  
        @moneda,  
        @cantidad_cuotas,  
        @nro_tarjeta,  
        @fecha_movimiento,  
        @nro_autorizacion,  
        @nro_cupon,  
        @nro_agrupador_boton,  
        @cargos_marca_por_movimiento,  
        @signo_cargos_marca_por_movimiento,  
        @fecha_pago ,  
        (SELECT TOP 1 id_log_paso FROM dbo.Conciliacion order by id_conciliacion desc),  
         GETDATE(),  
        @usuario,  
        (SELECT TOP 1 flag_aceptada_marca FROM dbo.Conciliacion order by id_conciliacion desc),  
        (SELECT TOP 1 flag_contracargo FROM dbo.Conciliacion order by id_conciliacion desc),  
        0,  
        0,  
        (SELECT TaxAmount FROM Transactions.dbo.transactions AS t WHERE t.ID = @idTransaccion),  
        (SELECT FeeAmount FROM Transactions.dbo.transactions AS t WHERE t.ID = @idTransaccion),  
        @id_movimiento_presentado,  
        0)  
END         
END         
         
END TRY  
BEGIN CATCH  
 ROLLBACK TRANSACTION;  
 SELECT @msg  = ERROR_MESSAGE();  
 THROW  51000, @msg, 1;  
END CATCH;  
  
COMMIT TRANSACTION;  
  
RETURN 1;  

