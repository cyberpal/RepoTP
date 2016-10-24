
CREATE PROCEDURE dbo.Batch_Conciliacion_ActualizarDistribucion
AS

SET NOCOUNT ON;


	INSERT INTO Configurations.dbo.Distribucion_tmp
	     SELECT m.id_transaccion, 
				1, 
				0, 
				m.tipo, 
				m.id_cuenta, 
				m.BCRA_cuenta, 
				m.BCRA_emisor_tarjeta, 
				m.signo_importe,
				(CASE WHEN m.signo_importe = '-' THEN (m.importe * -1)ELSE m.importe END),
				(CASE WHEN m.signo_cargo_marca = '-' THEN (m.cargo_marca * -1)ELSE m.cargo_marca END), 
				m.cargo_boton, 
				m.impuesto_boton, 
				m.fecha_liberacion_cashout, 
				m.flag_esperando_impuestos_generales_de_marca,
				ig.id_impuesto_general,
				(ig.percepciones+ig.retenciones+ig.cargos+ig.otros_impuestos),
				mdp.id_medio_pago
   		   FROM Configurations.dbo.Distribucion d 
	 INNER JOIN Configurations.dbo.Movimientos_a_distribuir m ON d.id_transaccion = m.id_transaccion
	 INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = m.id_movimiento_mp
	 INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago 
	 INNER JOIN Configurations.dbo.Impuesto_General_MP ig  ON ig.id_medio_pago = mdp.id_medio_pago
	      WHERE d.flag_procesado = 0 
		    AND d.fecha_distribucion IS NULL 
			AND ig.solo_impuestos = 1
	        AND CAST(mpp.fecha_pago AS DATE) = CAST(ig.fecha_pago_desde AS DATE)
			AND (mpp.id_log_paso = ig.id_log_paso OR mdp.id_medio_pago = 42);

INSERT INTO Configurations.dbo.Distribucion_tmp
	     SELECT m.id_transaccion,
				1, 
				0, 
				m.tipo, 
				m.id_cuenta, 
				m.BCRA_cuenta, 
				m.BCRA_emisor_tarjeta, 
				m.signo_importe,
				(CASE WHEN m.signo_importe = '-' THEN (m.importe * -1)ELSE m.importe END),
				(CASE WHEN m.signo_cargo_marca = '-' THEN (m.cargo_marca * -1)ELSE m.cargo_marca END), 
				m.cargo_boton, 
				m.impuesto_boton, 
				m.fecha_liberacion_cashout, 
				m.flag_esperando_impuestos_generales_de_marca,
				NULL,
				NULL,
				mdp.id_medio_pago
   		   FROM Configurations.dbo.Distribucion d 
	 INNER JOIN Configurations.dbo.Movimientos_a_distribuir m ON d.id_transaccion = m.id_transaccion
	 INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = m.id_movimiento_mp
	 INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago 
	      WHERE d.flag_procesado = 0 
		    AND d.fecha_distribucion IS NULL 
			AND mdp.id_medio_pago = 500;


	INSERT INTO Configurations.dbo.Distribucion_tmp
	     SELECT md.id_transaccion, 
				1, 
				0, 
				md.tipo, 
				md.id_cuenta, 
				md.BCRA_cuenta, 
				md.BCRA_emisor_tarjeta, 
				md.signo_importe,
				(CASE WHEN md.signo_importe = '-' THEN (md.importe * -1)ELSE md.importe END),
				(CASE WHEN md.signo_cargo_marca = '-' THEN (md.cargo_marca * -1)ELSE md.cargo_marca END), 
				md.cargo_boton, 
				md.impuesto_boton, 
				md.fecha_liberacion_cashout, 
				md.flag_esperando_impuestos_generales_de_marca,
				ig.id_impuesto_general,
				(ig.percepciones+ig.retenciones+ig.cargos+ig.otros_impuestos),
				mdp.id_medio_pago
   		   FROM Configurations.dbo.Movimientos_a_distribuir md  
	 INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = md.id_movimiento_mp
	 INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago
	 INNER JOIN Configurations.dbo.Impuesto_General_MP ig  ON ig.id_medio_pago = mdp.id_medio_pago  
	      WHERE md.flag_esperando_impuestos_generales_de_marca = 1
	  		AND ig.solo_impuestos = 1
	        AND CAST(mpp.fecha_pago AS DATE) = CAST(ig.fecha_pago_desde AS DATE)	 
			AND (mpp.id_log_paso = ig.id_log_paso OR mdp.id_medio_pago = 42)
			AND NOT EXISTS (SELECT 1 FROM Configurations.dbo.Distribucion dis  
								    WHERE md.id_transaccion = dis.id_transaccion
									  AND CAST(md.fecha_alta AS DATE) = CAST(fecha_alta AS DATE));



	INSERT INTO Configurations.dbo.Distribucion_tmp
	     SELECT md.id_transaccion,
				1, 
				0, 
				md.tipo, 
				md.id_cuenta, 
				md.BCRA_cuenta, 
				md.BCRA_emisor_tarjeta, 
				md.signo_importe,
				(CASE WHEN md.signo_importe = '-' THEN (md.importe * -1)ELSE md.importe END),
				(CASE WHEN md.signo_cargo_marca = '-' THEN (md.cargo_marca * -1)ELSE md.cargo_marca END), 
				md.cargo_boton, 
				md.impuesto_boton, 
				md.fecha_liberacion_cashout, 
				md.flag_esperando_impuestos_generales_de_marca,
				NULL,
				NULL,
				mdp.id_medio_pago
   		   FROM Configurations.dbo.Movimientos_a_distribuir md  
	 INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = md.id_movimiento_mp
	 INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago
	      WHERE md.flag_esperando_impuestos_generales_de_marca = 1
		    AND mdp.id_medio_pago = 500	 
			AND NOT EXISTS (SELECT 1 FROM Configurations.dbo.Distribucion dis  
								    WHERE md.id_transaccion = dis.id_transaccion
									  AND CAST(md.fecha_alta AS DATE) = CAST(fecha_alta AS DATE));

									  
BEGIN TRY
	BEGIN TRANSACTION;	
	
									  
	INSERT INTO Configurations.dbo.Distribucion    
		        (id_transaccion
                ,fecha_alta
                ,usuario_alta   
                ,version
                ,flag_procesado
                ,fecha_distribucion
                )
		 SELECT id_transaccion, 
		        GETDATE(), 
				'bpbatch', 
				0, 
				1, 
				GETDATE()
		   FROM dbo.Distribucion_tmp 
		  WHERE id_transaccion IS NOT NULL;
		  
								  
COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;