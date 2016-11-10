
CREATE PROCEDURE [dbo].[Batch_Conciliacion_GenerarDatosDistribucion](@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id_log_paso INT;
DECLARE @registros_procesados INT;
DECLARE @importe_procesados DECIMAL(12,2);
DECLARE @registros_aceptados INT;
DECLARE @importe_aceptados DECIMAL(12,2);
DECLARE @registros_rechazados INT;
DECLARE @importe_rechazados DECIMAL(12,2);
DECLARE @total_impuestos DECIMAL(12,2);
DECLARE @total_cargos_marca DECIMAL(12,2);
DECLARE @total_cargos_boton DECIMAL(12,2);
DECLARE @total_impuesto_boton DECIMAL(12,2);
DECLARE @fecha_alta DATETIME = GETDATE();
DECLARE @fecha_altaToVarchar VARCHAR(8);
DECLARE @idx INT = 1;
DECLARE @cant INT;
DECLARE @id_medio_pago INT;
DECLARE @codigo VARCHAR(20);
DECLARE @archivo_salida VARCHAR(16);


SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	SELECT @cant = COUNT(1) FROM Configurations.dbo.medios_de_pago_a_distribuir;
	
	WHILE (@idx <= @cant)
	  BEGIN
		 SET @registros_aceptados = 0;
	     SET @registros_rechazados = 0;
		 SET @importe_aceptados = 0;
		 SET @importe_rechazados = 0;
		 SET @total_impuestos = 0;
		 SET @total_cargos_marca = 0;
		 SET @total_cargos_boton = 0;
		 SET @total_impuesto_boton = 0;
		 SET @importe_procesados = 0;
		
	    TRUNCATE TABLE Configurations.dbo.TransaccionesMedioPago_tmp;
		
	    SELECT @id_medio_pago = id_medio_pago,
			   @codigo = codigo
		  FROM Configurations.dbo.medios_de_pago_a_distribuir
		 WHERE id_mpd = @idx;
		
		
		EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	         @id_log_proceso,
		     5,
		     @codigo,
		     NULL,
		     'bpbatch',
		     @id_log_paso = @id_log_paso OUTPUT;
		 
			 
		SET @fecha_altaToVarchar = CONVERT(VARCHAR(8), @fecha_alta, 112);
		
		
		SET @archivo_salida = 'L_'+CAST(@id_medio_pago AS VARCHAR(4))+'_'+@fecha_altaToVarchar;
		
		
		INSERT INTO archivo_distribucion_medio_pago_tmp 
        VALUES(@archivo_salida,
		       ('H'+
		        @fecha_altaToVarchar+
				RIGHT('00000000000'+CAST(@id_medio_pago AS VARCHAR(4)),12)+
				RIGHT('00000000000'+CAST(@id_log_paso AS VARCHAR(8)),12)+
				REPLICATE(' ', 107)
				), 
			   @codigo
			  );


		INSERT INTO Configurations.dbo.TransaccionesMedioPago_tmp 
		SELECT 
			  id_transaccion,
			  tipo,
			  ISNULL(id_cuenta,0),
			  BCRA_cuenta,
			  BCRA_emisor_tarjeta,
			  signo_importe,
			  importe,
			  cargo_marca,
			  cargo_boton,
			  impuesto_boton,
			  fecha_liberacion_cashout,
			  flag_esperando_impuestos_generales_de_marca,
			  id_impuesto_general,
			  total_id_ig
		 FROM Configurations.dbo.Distribucion_tmp
		WHERE id_medio_pago = @id_medio_pago;

		
		SELECT @registros_procesados = COUNT(1) FROM Configurations.dbo.TransaccionesMedioPago_tmp;
		

		IF(@registros_procesados > 0)
		 BEGIN 
		  
		      INSERT INTO archivo_distribucion_medio_pago_tmp 
                   SELECT @archivo_salida,
				           ('D'+
		                   (CASE WHEN id_transaccion IS NULL THEN REPLICATE(' ', 36) ELSE id_transaccion END)+
				           RIGHT('000000000000'+CAST(id_cuenta AS VARCHAR(12)),12)+
				           RIGHT('00000'+CAST(BCRA_cuenta AS VARCHAR(5)),5)+
				           RIGHT('00000'+CAST(BCRA_emisor_tarjeta AS VARCHAR(5)),5)+
				           signo_importe+
				           RIGHT('00000000000000000'+REPLACE(CAST(importe AS VARCHAR(17)),'.',''),17)+
				           '+'+
				           RIGHT('000000000000000'+REPLACE(CAST(cargo_marca AS VARCHAR(15)),'.',''),15)+
						   '+'+
				           RIGHT('000000000000000'+REPLACE(CAST(cargo_boton AS VARCHAR(15)),'.',''),15)+
						   '+'+
				           RIGHT('000000000000000'+REPLACE(CAST(impuesto_boton AS VARCHAR(15)),'.',''),15)+
						   (CASE WHEN fecha_liberacion_cashout IS NULL THEN REPLICATE(' ', 8) ELSE CONVERT(VARCHAR(8), fecha_liberacion_cashout, 112) END)+
				           REPLICATE(' ', 7)
			              ), 
			              @codigo
			         FROM Configurations.dbo.TransaccionesMedioPago_tmp; 
			  
	          
			  SELECT @registros_aceptados = SUM(CASE WHEN tipo = 'C' THEN 1 ELSE 0 END),
	                 @registros_rechazados = SUM(CASE WHEN tipo = 'N' THEN 1 ELSE 0 END),
		             @importe_aceptados = ABS(SUM(CASE WHEN tipo = 'C' THEN importe ELSE 0 END)),
		             @importe_rechazados = ABS(SUM(CASE WHEN tipo = 'N' THEN importe ELSE 0 END)),
					 @total_cargos_marca = SUM(ISNULL(cargo_marca,0)),
					 @total_cargos_boton = SUM(ISNULL(cargo_boton,0)),
					 @total_impuesto_boton = SUM(ISNULL(impuesto_boton,0))
	            FROM Configurations.dbo.TransaccionesMedioPago_tmp;
				
			
			  SELECT @total_impuestos = SUM(cargos+percepciones+retenciones+otros_impuestos) 
                FROM Configurations.dbo.Impuesto_General_MP
			   WHERE CAST(fecha_alta AS DATE) = CAST(GETDATE() AS DATE)
           		 AND solo_impuestos = 1
            GROUP BY id_medio_pago
			  HAVING id_medio_pago = @id_medio_pago;
				
				
			     SET @importe_procesados = @importe_aceptados + @importe_rechazados;
			

			  UPDATE d
		         SET d.id_log_paso = @id_log_paso, 
		             d.usuario_modificacion = 'bpbatch', 
			         d.fecha_modificacion = @fecha_alta
		        FROM Configurations.dbo.Distribucion d
	      INNER JOIN Configurations.dbo.TransaccionesMedioPago_tmp tmp
                  ON d.id_transaccion = tmp.id_transaccion;
				  

	          UPDATE ig
		         SET ig.solo_impuestos = -1
		        FROM Configurations.dbo.Impuesto_General_MP ig
			   WHERE CAST(ig.fecha_alta AS DATE) = CAST(GETDATE() AS DATE);
				  
	     END 
	    
		INSERT INTO archivo_distribucion_medio_pago_tmp 
        VALUES(@archivo_salida,
		       ('T'+
		        RIGHT('0000000000'+CAST(@registros_procesados AS VARCHAR(10)),10)+
				'+'+
				RIGHT('00000000000000000000'+REPLACE(CAST(@importe_procesados AS VARCHAR(15)),'.',''),20)+
				'+'+
				RIGHT('000000000000000'+REPLACE(CAST(@total_impuestos AS VARCHAR(15)),'.',''),15)+
				'+'+
				RIGHT('00000000000000000000'+REPLACE(CAST(@total_cargos_marca AS VARCHAR(15)),'.',''),20)+
				'+'+
				RIGHT('00000000000000000000'+REPLACE(CAST(@total_cargos_boton AS VARCHAR(15)),'.',''),20)+
				'+'+
				RIGHT('00000000000000000000'+REPLACE(CAST(@total_impuesto_boton AS VARCHAR(15)),'.',''),20)+
				REPLICATE(' ', 14)
			   ), 
			  @codigo
			 );
		
		SET @resultado_proceso = 1;

        EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
	         @id_log_paso,
		     NULL,
		     @archivo_salida,
		     @resultado_proceso,
		     NULL,
		     @registros_procesados,
		     @importe_procesados,
		     @registros_aceptados,
		     @importe_aceptados,
		     @registros_rechazados,
		     @importe_rechazados,
		     0,
		     0,
		     'bpbatch';  
			 
		SET @idx = @idx + 1;
	  END 

	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;
