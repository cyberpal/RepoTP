
CREATE PROCEDURE dbo.Batch_Conciliacion_ConciliacionManual(
   @id_log_paso INT,
   @registros_procesados INT OUTPUT,
   @importe_procesados DECIMAL(12,2) OUTPUT
)
AS
DECLARE @max_id_conciliacion INT;
	
SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;
	
	SELECT @max_id_conciliacion = ISNULL(MAX(id_conciliacion),0) 
	                              FROM Configurations.dbo.Conciliacion;

								  
	INSERT INTO Configurations.dbo.Conciliacion
               (id_conciliacion
               ,id_transaccion
			   ,id_conciliacion_manual
               ,id_log_paso
               ,flag_aceptada_marca
               ,flag_conciliada
               ,flag_contracargo
               ,id_disputa
               ,fecha_alta
               ,usuario_alta
               ,version
               ,flag_distribuida
               ,id_movimiento_mp
               ,flag_notificado)
	    SELECT 
               ROW_NUMBER() OVER(ORDER BY id_conciliacion_manual) + @max_id_conciliacion AS id_conciliacion,
			   id_transaccion,
			   id_conciliacion_manual,
			   @id_log_paso,
			   flag_aceptada_marca,
			   1,
			   flag_contracargo,
			   CASE WHEN mcm.codigo <> 'EFECTIVO'
	                THEN 0
               END,
			   GETDATE(),
			   'bpbatch',
			   0,
			   1,
			   mcm.id_movimiento_mp,
			   CASE WHEN co.codigo_operacion = 'COM' AND mcm.codigo = 'EFECTIVO'
	                THEN 0
	    	        ELSE 1
               END
		  FROM Configurations.dbo.Movimientos_conciliados_manual_tmp mcm
    INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp
	        ON mpp.id_movimiento_mp = mcm.id_movimiento_mp
    INNER JOIN Configurations.dbo.Codigo_operacion co 
            ON mpp.id_codigo_operacion = co.id_codigo_operacion;
		   
		   
	    UPDATE cm
           SET cm.cargos_boton_por_movimiento = ISNULL(tc.FeeAmount,0),
               cm.impuestos_boton_por_movimiento = ISNULL(tc.TaxAmount,0),
		       cm.usuario_modificacion = 'bpbatch',
			   cm.fecha_modificacion = GETDATE(),
			   cm.flag_procesado = 1
          FROM Configurations.dbo.Conciliacion_Manual cm
    INNER JOIN Transacciones_Conciliacion_tmp tc
            ON cm.id_transaccion = tc.Id;
		 
		 
	    UPDATE t
           SET t.PaymentTimestamp = mpp.fecha_pago,
			   t.ReconciliationStatus = 1,
			   t.ReconciliationTimestamp = GETDATE(),
			   t.SyncStatus = 0,
			   t.CouponStatus = CASE WHEN mcm.codigo = 'EFECTIVO' AND t.CouponStatus = 'PENDIENTE'
                        			 THEN 'ACREDITADO'
			                         ELSE t.CouponStatus
							    END,
			   t.TransactionStatus = CASE WHEN mcm.codigo = 'EFECTIVO' 
			                              THEN 'TX_PROCESADA'
			                              ELSE t.TransactionStatus
							         END
          FROM Transactions.dbo.transactions t
    INNER JOIN Configurations.dbo.Movimientos_conciliados_manual_tmp mcm
	        ON mcm.id_transaccion = t.Id
    INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp
	        ON mpp.id_movimiento_mp = mcm.id_movimiento_mp;
			
		   
	SELECT
        @registros_procesados = COUNT(1),
        @importe_procesados = SUM(CASE WHEN mpp.signo_importe = '-' THEN (mpp.importe * -1) ELSE mpp.importe END)
          FROM Configurations.dbo.Movimientos_conciliados_manual_tmp mcm
    INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp
	        ON mpp.id_movimiento_mp = mcm.id_movimiento_mp;


	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;