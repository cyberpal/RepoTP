
CREATE PROCEDURE dbo.Batch_Conciliacion_InsertarMovimientos(
   @id_log_paso INT,
   @registros_procesados INT OUTPUT,
   @importe_procesados DECIMAL(12,2) OUTPUT,
   @registros_aceptados INT OUTPUT,
   @importe_aceptados DECIMAL(12,2) OUTPUT,
   @registros_rechazados INT OUTPUT,
   @importe_rechazados DECIMAL(12,2) OUTPUT
)
AS
DECLARE @max_id_conciliacion INT;
DECLARE @max_id_conciliacion_manual INT;
	
SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;
	
	SELECT @max_id_conciliacion = ISNULL(MAX(id_conciliacion),0) 
	                              FROM Configurations.dbo.Conciliacion;

	INSERT INTO Configurations.dbo.Conciliacion
               (id_conciliacion
               ,id_transaccion
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
               ROW_NUMBER() OVER(ORDER BY id) + @max_id_conciliacion AS id_conciliacion,
			   id_transaccion,
			   @id_log_paso,
			   flag_aceptada_marca,
			   1,
			   flag_contracargo,
			   id_disputa,
			   GETDATE(),
			   'bpbatch',
			   0,
			   0,
			   id_movimiento_mp,
			   flag_notificado
		  FROM Configurations.dbo.Movimientos_a_Conciliar_tmp
         WHERE flag_aceptada_marca = 1
           AND id_transaccion IS NOT NULL;

		   
	SELECT @max_id_conciliacion_manual = ISNULL(MAX(id_conciliacion_manual),0) 
	                                     FROM Configurations.dbo.Conciliacion_Manual;
		  
	INSERT INTO Configurations.dbo.Conciliacion_Manual(
			    id_conciliacion_manual,
			    importe,
			    moneda,
			    cantidad_cuotas,
			    nro_tarjeta,
				codigo_barra,
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
			    version,
			    id_motivo_conciliacion_manual)
		 SELECT 
                ROW_NUMBER() OVER(ORDER BY mac.id) + @max_id_conciliacion_manual AS id_conciliacion_manual,
				mac.importe,
				mac.moneda,
				mac.cantidad_cuotas,
				mac.nro_tarjeta,
				mac.codigo_barra,
				mac.fecha_movimiento,
				mac.nro_autorizacion,
				mac.nro_cupon,
				mac.nro_agrupador_boton,
				mac.cargos_marca_por_movimiento,
				mac.signo_cargos_marca_por_movimiento,
				mac.fecha_pago,
				@id_log_paso,
			    GETDATE(),
			    'bpbatch',
				mac.flag_aceptada_marca,
				mac.flag_contracargo,
			    0,
			    0,
				ISNULL(mac.impuestos_boton_por_movimiento,0),
			    ISNULL(mac.cargos_boton_por_movimiento,0),
			    mac.id_movimiento_mp,
			    0,
				mcm.id_motivo_conciliacion_manual
		  FROM Configurations.dbo.Movimientos_a_Conciliar_tmp mac
	INNER JOIN Configurations.dbo.Motivo_Conciliacion_Manual mcm
            ON mcm.codigo_motivo_conciliacion_manual = (CASE WHEN (mac.id_transaccion IS NULL AND mac.cant_tx = 0) THEN 'CM_00001' 
                                                             WHEN (mac.id_transaccion IS NULL AND mac.cant_tx > 1) THEN 'CM_00002'
                                                             WHEN mac.flag_aceptada_marca = 0 THEN 'CM_00003'
				                                             WHEN (mac.estado_tx <> 'PENDIENTE' AND mac.codigo = 'EFECTIVO') THEN 'CM_00004'
                                                             ELSE 'CM_99999' 
			                                            END)
         WHERE mac.flag_aceptada_marca = 0
            OR mac.id_transaccion IS NULL
		    OR (mac.estado_tx <> 'PENDIENTE' AND mac.codigo = 'EFECTIVO')
			OR mac.flag_contracargo = 1;
		   
	 INSERT INTO Configurations.dbo.movimientos_a_distribuir(
				 tipo,
				 BCRA_cuenta,
				 BCRA_emisor_tarjeta,
				 signo_importe,
				 signo_cargo_marca,
				 cargo_marca,
                 signo_cargo_boton,
				 cargo_boton,
				 signo_impuesto_boton,
				 impuesto_boton,
				 id_log_paso,
				 flag_esperando_impuestos_generales_de_marca,
                 importe,
				 id_movimiento_mp,
				 fecha_alta,
				 usuario_alta,
				 version)
		  SELECT 
		        'N',
				0,
				0,
				signo_importe,
				signo_cargos_marca_por_movimiento,
				cargos_marca_por_movimiento,
				' ',
				0,
				' ',
				0,
				@id_log_paso,
				0,
				importe,
				id_movimiento_mp,
				GETDATE(),
				'bpbatch',
				0
		   FROM Configurations.dbo.Movimientos_a_Conciliar_tmp
          WHERE flag_aceptada_marca = 1
            AND id_transaccion IS NULL;	 
		   
		   
	    UPDATE c
           SET c.id_conciliacion_manual = cm.id_conciliacion_manual
          FROM Configurations.dbo.Conciliacion c
    INNER JOIN Configurations.dbo.Conciliacion_Manual cm
            ON cm.id_movimiento_mp = c.id_movimiento_mp
		 WHERE c.id_log_paso = @id_log_paso;
		 
		 
	    UPDATE t
           SET t.PaymentTimestamp = mac.fecha_pago,
			   t.ReconciliationStatus = 1,
			   t.ReconciliationTimestamp = GETDATE(),
			   t.SyncStatus = 0,
			   t.CouponStatus = CASE WHEN mac.codigo = 'EFECTIVO'
                        			 THEN 'ACREDITADO'
			                         ELSE mac.estado_cupon
							    END,
			   t.TransactionStatus = CASE WHEN mac.codigo = 'EFECTIVO' 
			                              THEN 'TX_PROCESADA'
			                              ELSE mac.estado_tx
							         END
          FROM Transactions.dbo.transactions t
    INNER JOIN Configurations.dbo.Movimientos_a_Conciliar_tmp mac
	        ON mac.id_transaccion = t.Id
         WHERE mac.flag_aceptada_marca = 1
           AND mac.id_transaccion IS NOT NULL;
		   
		   
	SELECT
        @registros_aceptados = SUM(CASE WHEN flag_aceptada_marca = 1 AND id_transaccion IS NOT NULL
                                        THEN 1
								        ELSE 0
							       END),
        @importe_aceptados = SUM(CASE WHEN flag_aceptada_marca = 1 AND id_transaccion IS NOT NULL 
                                      THEN (CASE WHEN signo_importe = '-' THEN (importe * -1) ELSE importe END)
								      ELSE 0
							     END),
        @registros_rechazados = SUM(CASE WHEN id_transaccion IS NULL
                                         THEN 1
								         ELSE 0
							        END),
        @importe_rechazados = SUM(CASE WHEN id_transaccion IS NULL 
                                       THEN (CASE WHEN signo_importe = '-' THEN (importe * -1) ELSE importe END)
								       ELSE 0
							      END)
    FROM Configurations.dbo.Movimientos_a_Conciliar_tmp;


    SET @registros_procesados =  @registros_rechazados + @registros_aceptados;
	
    SET @importe_procesados = @importe_rechazados + @importe_aceptados;
	
	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;