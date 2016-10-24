
CREATE PROCEDURE dbo.Batch_Conciliacion_ValidarFirstData (@id_log_proceso INT)
AS

DECLARE @resultado_proceso BIT = 0;
DECLARE @id INT;
DECLARE @id_log_paso INT;
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @id_medio_pago INT = 6;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @fecha_pago DATETIME;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @registros_procesados_aux INT = 0;
DECLARE @GralRegDetalleR9 INT;
DECLARE @importe_procesados_aux DECIMAL(12,2) = 0;
DECLARE @GralImporteTotalR9 DECIMAL(12,2) = 0;
DECLARE @GralImporteTotalR7 DECIMAL(12,2) = 0;
DECLARE @GralArancYCFinR9 DECIMAL(12,2) = 0;
DECLARE @GralArancYCFinR7 DECIMAL(12,2) = 0;
DECLARE @GralRetecFiscR9 DECIMAL(12,2) = 0;
DECLARE @GralRetecFiscR7 DECIMAL(12,2) = 0;
DECLARE @GralOtrosCreditosR9 DECIMAL(12,2) = 0;
DECLARE @GralOtrosCreditosR7 DECIMAL(12,2) = 0;
DECLARE @GralOtrosDebitosR9 DECIMAL(12,2) = 0;
DECLARE @GralOtrosDebitosR7 DECIMAL(12,2) = 0;
DECLARE @GralArancelCtoFinancieroR9 DECIMAL(12,2) = 0;
DECLARE @GralArancelCtoFinancieroR3 DECIMAL(12,2) = 0;
DECLARE @flag_fecha INT;
DECLARE @msg VARCHAR(MAX);
CREATE TABLE #info_movimientos(ARANCEL_COSTO DECIMAL(12,2),
                               importe DECIMAL(12,2),
					           signo CHAR(1),
					           id_moneda INT,
					           cantidad_cuotas INT,
					           fecha_movimiento DATETIME,
					           nro_autorizacion VARCHAR(8),
					           nro_cupon INT,
					           nro_agrupador_boton VARCHAR(50),
							   cargos_marca_por_movimiento DECIMAL(12,2),
							   signo_cargos_marca_por_movimiento CHAR(1),
					           id_medio_pago INT,
					           id_codigo_operacion INT,
					           fecha_pago DATETIME,
					           nro_lote  VARCHAR(15),
					           campo_mp_1 VARCHAR(10), 
		                       valor_1 VARCHAR(15),
			                   campo_mp_2 VARCHAR(10), 
		                       valor_2 VARCHAR(15),
			                   campo_mp_3 VARCHAR(10), 
		                       valor_3 VARCHAR(15),
					           mask_nro_tarjeta VARCHAR(20)
					          );
CREATE TABLE #info_impuestos(fecha_pago DATETIME,
                             percepciones DECIMAL(12,2),
                             retenciones DECIMAL(12,2),
                             cargos DECIMAL(12,2),
                             otros_impuestos DECIMAL(12,2),
                             id_medio_pago INT
					        );

					   
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;
    
	SELECT TOP 1 @id = (id),
	             @archivo_entrada = nombre_archivo 
	FROM Configurations.dbo.Archivo_Conciliacion 
	WHERE flag_procesado = 0
	  AND descripcion = 'FIRST DATA';

	  
	SELECT TOP 1
       @fecha_ejecucion = fecha_inicio_ejecucion
    FROM Configurations.dbo.Log_Paso_Proceso
    WHERE archivo_entrada = @archivo_entrada 
    AND resultado_proceso = 1  
	

    EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 1,
		 'FIRST DATA',
		 @archivo_entrada,
		 'bpbatch',
		 @id_log_paso = @id_log_paso OUTPUT; 


    INSERT INTO #info_movimientos
    SELECT (CAST((CASE WHEN SUBSTRING(detalles,212,1) = 2 THEN '-'+SUBSTRING(detalles,203,9) ELSE SUBSTRING(detalles,203,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,238,1) = 2 THEN '-'+SUBSTRING(detalles,229,9) ELSE SUBSTRING(detalles,229,9)END) AS DECIMAL(12,2))
		    )/100,
	       CAST(SUBSTRING(detalles,104,13) AS DECIMAL(12,2))/100,
    	   co.signo,
    	   mmp.id_moneda,
    	   CASE WHEN SUBSTRING(detalles,100,2) = 0
		        THEN 1
				ELSE CAST(SUBSTRING(detalles,100,2) AS INT)
				END,	
    	   CAST(SUBSTRING(detalles,62,8) AS DATETIME),
		   LTRIM(RTRIM(SUBSTRING(detalles,275,8))),
    	   CAST(SUBSTRING(detalles,95,5) AS INT),
		   SUBSTRING(detalles,41,8),
		   ABS(CAST((CASE WHEN SUBSTRING(detalles,212,1) = 2 THEN '-'+SUBSTRING(detalles,203,9) ELSE SUBSTRING(detalles,203,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,222,1) = 2 THEN '-'+SUBSTRING(detalles,213,9) ELSE SUBSTRING(detalles,213,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,238,1) = 2 THEN '-'+SUBSTRING(detalles,229,9) ELSE SUBSTRING(detalles,229,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,248,1) = 2 THEN '-'+SUBSTRING(detalles,239,9) ELSE SUBSTRING(detalles,239,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,263,1) = 2 THEN '-'+SUBSTRING(detalles,254,9) ELSE SUBSTRING(detalles,254,9)END) AS DECIMAL(12,2))+
		    CAST((CASE WHEN SUBSTRING(detalles,273,1) = 2 THEN '-'+SUBSTRING(detalles,264,9) ELSE SUBSTRING(detalles,264,9)END) AS DECIMAL(12,2))
		   )/100,
		   co.signo,
		   mp.id_medio_pago,
    	   comp.id_codigo_operacion,  
    	   CAST(SUBSTRING(detalles,25,8) AS DATETIME),
		   SUBSTRING(detalles,92,3),
		   'ME',
		   SUBSTRING(detalles,151,1),
		   0,
		   0,
		   0,
		   0,
		   RTRIM(SUBSTRING(detalles,153,19))
    FROM Configurations.dbo.Detalle_Archivo
	INNER JOIN Configurations.dbo.Codigo_Operacion_Medio_Pago comp
            ON comp.id_medio_pago = 14 
		   AND comp.valor_1 = SUBSTRING(detalles,70,3) 
	INNER JOIN Configurations.dbo.Codigo_Operacion co
	        ON co.id_codigo_operacion = comp.id_codigo_operacion
    INNER JOIN Configurations.dbo.Moneda_Medio_Pago mmp
	        ON mmp.id_medio_pago = 14
		   AND mmp.moneda_mp_conciliacion = SUBSTRING(detalles,17,3)
	INNER JOIN Configurations.dbo.Medio_De_Pago mp
            ON mp.codigo = (CASE WHEN SUBSTRING(detalles,16,1) = 'C' THEN 'MASTERCARD' 
                                 WHEN SUBSTRING(detalles,16,1) = 'G' THEN 'DINERS'
                                 WHEN SUBSTRING(detalles,16,1) = 'S' THEN 'ARGENCARD'
				                 WHEN SUBSTRING(detalles,16,1) = 'H' THEN 'MASTERDEBIT'
                                                                     ELSE 'MAESTRO' 
			                END)
	WHERE SUBSTRING(detalles,1,1) = 3
	  AND id_archivo = @id;
	  
	  
	INSERT INTO #info_impuestos
    SELECT CAST(SUBSTRING(detalles,25,8) AS DATETIME),
	       (CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN (CAST((CASE WHEN SUBSTRING(detalles,133,1) = 2 THEN '-'+SUBSTRING(detalles,120,13) ELSE SUBSTRING(detalles,120,13)END) AS DECIMAL(12,2))+
		                                                CAST((CASE WHEN SUBSTRING(detalles,175,1) = 2 THEN '-'+SUBSTRING(detalles,162,13) ELSE SUBSTRING(detalles,162,13)END) AS DECIMAL(12,2))
													   )
												 ELSE 0
           END)/100,
           (CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN (CAST((CASE WHEN SUBSTRING(detalles,119,1) = 2 THEN '-'+SUBSTRING(detalles,106,13) ELSE SUBSTRING(detalles,106,13)END) AS DECIMAL(12,2))+
		                                                CAST((CASE WHEN SUBSTRING(detalles,147,1) = 2 THEN '-'+SUBSTRING(detalles,134,13) ELSE SUBSTRING(detalles,134,13)END) AS DECIMAL(12,2))+
													    CAST((CASE WHEN SUBSTRING(detalles,160,1) = 2 THEN '-'+SUBSTRING(detalles,148,13) ELSE SUBSTRING(detalles,148,13)END) AS DECIMAL(12,2))+
													    CAST((CASE WHEN SUBSTRING(detalles,189,1) = 2 THEN '-'+SUBSTRING(detalles,176,13) ELSE SUBSTRING(detalles,176,13)END) AS DECIMAL(12,2))
													   )
												 ELSE (CAST((CASE WHEN SUBSTRING(detalles,131,1) = 2 THEN '-'+SUBSTRING(detalles,118,13) ELSE SUBSTRING(detalles,118,13)END) AS DECIMAL(12,2))
													   )
           END)/100,			   
		   0,
           (CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN (CAST((CASE WHEN SUBSTRING(detalles,200,1) = 2 THEN '-'+SUBSTRING(detalles,191,9) ELSE SUBSTRING(detalles,191,9)END) AS DECIMAL(12,2))+
		                                                CAST((CASE WHEN SUBSTRING(detalles,91,1) = 2 THEN '-'+SUBSTRING(detalles,78,13) ELSE SUBSTRING(detalles,78,13)END) AS DECIMAL(12,2))
													   )
												 ELSE (CAST((CASE WHEN SUBSTRING(detalles,145,1) = 2 THEN '-'+SUBSTRING(detalles,132,13) ELSE SUBSTRING(detalles,132,13)END) AS DECIMAL(12,2))+
		                                               CAST((CASE WHEN SUBSTRING(detalles,159,1) = 2 THEN '-'+SUBSTRING(detalles,146,13) ELSE SUBSTRING(detalles,146,13)END) AS DECIMAL(12,2))
													   )
           END)/100,													   
	       mp.id_medio_pago
	FROM Configurations.dbo.Detalle_Archivo
   	INNER JOIN Configurations.dbo.Medio_De_Pago mp
            ON mp.codigo = (CASE WHEN SUBSTRING(detalles,16,1) = 'C' THEN 'MASTERCARD' 
                                 WHEN SUBSTRING(detalles,16,1) = 'G' THEN 'DINERS'
                                 WHEN SUBSTRING(detalles,16,1) = 'S' THEN 'ARGENCARD'
				                 WHEN SUBSTRING(detalles,16,1) = 'H' THEN 'MASTERDEBIT'
                                                                     ELSE 'MAESTRO' 
			                END)
	WHERE SUBSTRING(detalles,1,1) = 7
	   OR SUBSTRING(detalles,1,1) = 8
	  AND id_archivo = @id;  
    
	
    SELECT @GralImporteTotalR9 = CAST((CASE WHEN SUBSTRING(detalles,54,1) = 2 THEN '-'+SUBSTRING(detalles,41,13) ELSE SUBSTRING(detalles,41,13)END) AS DECIMAL(12,2))/100,
	       @GralArancYCFinR9 = CAST((CASE WHEN SUBSTRING(detalles,96,1) = 2 THEN '-'+SUBSTRING(detalles,83,13) ELSE SUBSTRING(detalles,83,13)END) AS DECIMAL(12,2))/100,
		   @GralRetecFiscR9 = CAST((CASE WHEN SUBSTRING(detalles,110,1) = 2 THEN '-'+SUBSTRING(detalles,97,13) ELSE SUBSTRING(detalles,97,13)END) AS DECIMAL(12,2))/100,
		   @GralOtrosDebitosR9 = CAST((CASE WHEN SUBSTRING(detalles,124,1) = 2 THEN '-'+SUBSTRING(detalles,111,13) ELSE SUBSTRING(detalles,111,13)END) AS DECIMAL(12,2))/100,
		   @GralOtrosCreditosR9 = CAST((CASE WHEN SUBSTRING(detalles,138,1) = 2 THEN '-'+SUBSTRING(detalles,125,13) ELSE SUBSTRING(detalles,125,13)END) AS DECIMAL(12,2))/100,
		   @GralRegDetalleR9 = CAST(SUBSTRING(detalles,153,7) AS INT),
		   @GralArancelCtoFinancieroR9 = (CAST((CASE WHEN SUBSTRING(detalles,194,1) = 2 THEN '-'+SUBSTRING(detalles,181,13) ELSE SUBSTRING(detalles,181,13)END) AS DECIMAL(12,2))+
		                                  CAST((CASE WHEN SUBSTRING(detalles,208,1) = 2 THEN '-'+SUBSTRING(detalles,195,13) ELSE SUBSTRING(detalles,195,13)END) AS DECIMAL(12,2))
                                         )/100
	FROM Configurations.dbo.Detalle_Archivo
	WHERE SUBSTRING(detalles,1,1) = 9
	  AND id_archivo = @id;  
	
	
	SELECT @GralImporteTotalR7 = SUM(CAST((CASE WHEN SUBSTRING(detalles,75,1) = 2 THEN '-'+SUBSTRING(detalles,62,13) ELSE SUBSTRING(detalles,62,13)END) AS DECIMAL(12,2)))/100,
	       @GralArancYCFinR7 = SUM(CAST((CASE WHEN SUBSTRING(detalles,117,1) = 2 THEN '-'+SUBSTRING(detalles,104,13) ELSE SUBSTRING(detalles,104,13)END) AS DECIMAL(12,2)))/100,
		   @GralRetecFiscR7 = SUM(CAST((CASE WHEN SUBSTRING(detalles,131,1) = 2 THEN '-'+SUBSTRING(detalles,118,13) ELSE SUBSTRING(detalles,118,13)END) AS DECIMAL(12,2)))/100,
		   @GralOtrosDebitosR7 = SUM(CAST((CASE WHEN SUBSTRING(detalles,145,1) = 2 THEN '-'+SUBSTRING(detalles,132,13) ELSE SUBSTRING(detalles,132,13)END) AS DECIMAL(12,2)))/100,
		   @GralOtrosCreditosR7 = SUM(CAST((CASE WHEN SUBSTRING(detalles,159,1) = 2 THEN '-'+SUBSTRING(detalles,146,13) ELSE SUBSTRING(detalles,146,13)END) AS DECIMAL(12,2)))/100
	FROM Configurations.dbo.Detalle_Archivo
	WHERE SUBSTRING(detalles,1,1) = 7
	  AND id_archivo = @id;  
	  
	  
	SELECT @fecha_pago = fecha_pago, 
	       @registros_procesados_aux = COUNT(1),
		   @GralArancelCtoFinancieroR3 = SUM(ARANCEL_COSTO), 
		   @importe_procesados_aux = SUM(CASE WHEN signo = '-' 
			                              THEN importe * -1 
									      ELSE importe
								 END)
	FROM #info_movimientos
	GROUP BY fecha_pago
	 
	 
	SELECT @flag_fecha = DATEDIFF (D,CAST(@fecha_pago AS DATE),CAST(GETDATE() AS DATE));

	
    IF(@fecha_ejecucion IS NOT NULL)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END 
	ELSE IF(@flag_fecha < 0)
	  BEGIN
	    SET @motivo_rechazo = 'Fecha de Pago mayor a la fecha de ejecucion del proceso.';
	  END 
	ELSE IF(@GralImporteTotalR9 <> @GralImporteTotalR7)
      BEGIN 
    	SET @motivo_rechazo = 'La sumatoria de los campos TotalImporteTotal no coincide con el campo TotalGralImporteTotal.';
      END 
    ELSE IF(@GralArancYCFinR9 <> @GralArancYCFinR7)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de los campos ArancelesCtoFin no coincide con el campo TotalGralArancYCFin.';
      END
    ELSE IF(@GralRetecFiscR9 <> @GralRetecFiscR7)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de los campos RetencionesFiscales no coincide con el campo TotalGralRetecFisc.';
      END
	ELSE IF(@GralOtrosCreditosR9 <> @GralOtrosCreditosR7)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de los campos OtrosCreditos no coincide con el campo TotalGralOtrosCreditos.';
      END
	ELSE IF(@GralOtrosDebitosR9 <> @GralOtrosDebitosR7)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de los campos OtrosDebitos no coincide con el campo TotalGralOtrosDebitos.';
      END
	ELSE IF(@registros_procesados_aux <> @GralRegDetalleR9)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de registros del archivo no coinciden con el campo TotalGralRegDetalle.';
      END
	ELSE IF(@GralArancelCtoFinancieroR9 <> @GralArancelCtoFinancieroR3)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de Aranceles-CostoFinanciero no coincide con la suma GralArancel-GralCtoFinanciero';
      END
	ELSE
	  BEGIN
        SET @resultado_proceso = 1; 
		SET @registros_procesados = @registros_procesados_aux;
		SET @importe_procesados = @importe_procesados_aux;
		
		
	    INSERT INTO Configurations.dbo.Movimiento_Presentado_MP
               (importe
               ,signo_importe
               ,moneda
               ,cantidad_cuotas
               ,nro_tarjeta
               ,fecha_movimiento
               ,nro_autorizacion
               ,nro_cupon
               ,nro_agrupador_boton
               ,cargos_marca_por_movimiento
               ,signo_cargos_marca_por_movimiento
               ,id_log_paso
               ,id_medio_pago
               ,id_codigo_operacion
               ,fecha_pago
               ,nro_lote
               ,fecha_alta
               ,usuario_alta
               ,version
               ,mask_nro_tarjeta
			   ,campo_mp_1  
		       ,valor_1 
			   ,campo_mp_2
		       ,valor_2
			   ,campo_mp_3
		       ,valor_3)
		SELECT importe,
			   signo,
			   id_moneda,
			   cantidad_cuotas ,
               mask_nro_tarjeta,
			   fecha_movimiento,
			   nro_autorizacion,
			   nro_cupon,
			   nro_agrupador_boton,
			   cargos_marca_por_movimiento,
			   signo_cargos_marca_por_movimiento,
			   @id_log_paso,
			   id_medio_pago,
			   id_codigo_operacion,
			   fecha_pago,
			   nro_lote,
			   GETDATE(),
			   'bpbatch',
			   0,
			   mask_nro_tarjeta,
			   campo_mp_1,  
		       valor_1, 
			   campo_mp_2,
		       valor_2,
			   campo_mp_3,
		       valor_3
		FROM #info_movimientos; 
		
		
	    INSERT INTO Configurations.dbo.Impuesto_General_MP
           (fecha_pago_desde
           ,fecha_pago_hasta
           ,percepciones
           ,retenciones
           ,cargos
           ,otros_impuestos
           ,id_medio_pago
           ,id_log_paso
           ,fecha_alta
           ,usuario_alta
           ,version
           ,solo_impuestos)
        SELECT fecha_pago,
		       fecha_pago,
			   SUM(percepciones),
		       SUM(retenciones),
			   SUM(cargos),
			   SUM(otros_impuestos),
			   id_medio_pago,
			   @id_log_paso,
			   GETDATE(),
			   'bpbatch',
			   0,
			   1
		FROM #info_impuestos
		GROUP BY id_medio_pago,
		         fecha_pago;
			   
	  END
	
	
	UPDATE Configurations.dbo.Archivo_Conciliacion
	SET flag_procesado = 1
	WHERE id = @id;
	
	
	EXEC Configurations.dbo.Batch_Log_Finalizar_Paso
	     @id_log_paso,
		 @archivo_entrada,
		 NULL,
		 @resultado_proceso,
		 @motivo_rechazo,
		 @registros_procesados,
		 @importe_procesados,
		 0,
		 0,
		 0,
		 0,
		 0,
		 0,
		 'bpbatch'; 

    COMMIT TRANSACTION;

    RETURN 1;

END TRY

BEGIN CATCH

    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;