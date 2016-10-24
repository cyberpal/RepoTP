
CREATE PROCEDURE dbo.Batch_Conciliacion_ValidarCabal (@id_log_proceso INT)
AS

DECLARE @resultado_proceso BIT = 0;
DECLARE @id INT;
DECLARE @id_log_paso INT;
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @descripcion VARCHAR(6) = 'CABAL';
DECLARE @id_medio_pago INT = 6;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @fecha_pago DATETIME;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @otros_impuestos DECIMAL(12,2);
DECLARE @cargos DECIMAL(12,2);
DECLARE @percepciones_R3 DECIMAL(12,2);
DECLARE @retenciones DECIMAL(12,2);
DECLARE @percepciones DECIMAL(12,2);
DECLARE @importe_brutoR1 DECIMAL(12,2);
DECLARE @importe_brutoR2 DECIMAL(12,2);
DECLARE @costo_financieroR1 DECIMAL(12,2);
DECLARE @costo_financieroR3 DECIMAL(12,2);
DECLARE @importe_arancelR1 DECIMAL(12,2);
DECLARE @importe_arancelR2 DECIMAL(12,2);
DECLARE @contR1 INT;
DECLARE @contR2 INT;
DECLARE @msg VARCHAR(MAX);
CREATE TABLE #info_cabal(COSTO_FINANCIERO DECIMAL(12,2),
					     IMPORTE_ARANCEl DECIMAL(12,2),
					     CODOP VARCHAR(2),
                         importe DECIMAL(12,2),
					     signo CHAR(1),
					     id_moneda INT,
					     cantidad_cuotas INT,
					     fecha_movimiento DATETIME,
					     nro_autorizacion VARCHAR(8),
					     nro_cupon INT,
					     nro_agrupador_boton VARCHAR(50),
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
					     mask_nro_tarjeta VARCHAR(20),
					     version INT
					    );

					   
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;
    
	SELECT TOP 1 @id = (id),
	             @archivo_entrada = nombre_archivo 
	FROM Configurations.dbo.Archivo_Conciliacion 
	WHERE flag_procesado = 0
	  AND descripcion = @descripcion;

	  
	SELECT TOP 1
       @fecha_ejecucion = fecha_inicio_ejecucion
    FROM Configurations.dbo.Log_Paso_Proceso
    WHERE archivo_entrada = @archivo_entrada 
    AND resultado_proceso = 1  
	

    EXEC Configurations.dbo.Batch_Log_Iniciar_Paso
	     @id_log_proceso,
		 1,
		 @descripcion,
		 @archivo_entrada,
		 'bpbatch',
		 @id_log_paso = @id_log_paso OUTPUT; 


    INSERT INTO #info_cabal
    SELECT CAST(SUBSTRING(detalles,115,9) AS DECIMAL(12,2))/100,
	       CAST((CASE WHEN SUBSTRING(detalles,13,2) = 96 OR SUBSTRING(detalles,13,2) = 97 THEN SUBSTRING(detalles,66,9) ELSE SUBSTRING(detalles,106,9) END) AS DECIMAL(12,2))/100,
		   SUBSTRING(detalles,13,2),
	       CAST((CASE WHEN SUBSTRING(detalles,13,2) = 96 OR SUBSTRING(detalles,13,2) = 97 THEN 0 ELSE SUBSTRING(detalles,66,9) END) AS DECIMAL(12,2))/100,
    	   co.signo,
    	   mmp.id_moneda,
    	   CASE WHEN SUBSTRING(detalles,103,2) = 0
		        THEN 1
				ELSE CAST(SUBSTRING(detalles,103,2) AS INT)
				END,	
    	   CAST((SUBSTRING(detalles,35,2)+SUBSTRING(detalles,33,2)+SUBSTRING(detalles,31,2)) AS DATETIME),
		   SUBSTRING(detalles,43,5),
    	   CAST(SUBSTRING(detalles,79,4) AS INT),
		   SUBSTRING(detalles,2,11),
		   @id_medio_pago,
    	   comp.id_codigo_operacion,  
    	   CAST((SUBSTRING(detalles,87,2)+SUBSTRING(detalles,85,2)+SUBSTRING(detalles,83,2)) AS DATETIME),
		   SUBSTRING(detalles,48,3),
		   'CCAR',
		   SUBSTRING(detalles,90,1),
		   'CODOP',
		   SUBSTRING(detalles,13,2),
		   0,
		   0,
		   SUBSTRING(detalles,15,16),
		   0
    FROM Configurations.dbo.Detalle_Archivo
    INNER JOIN Configurations.dbo.Codigo_Operacion_Medio_Pago comp
            ON comp.id_medio_pago = @id_medio_pago AND comp.valor_1 = SUBSTRING(detalles,13,2) 
           AND comp.valor_2 = SUBSTRING(detalles,101,2)
	INNER JOIN Configurations.dbo.Codigo_Operacion co
	        ON co.id_codigo_operacion = comp.id_codigo_operacion
    INNER JOIN Configurations.dbo.Moneda_Medio_Pago mmp
	        ON mmp.id_medio_pago = @id_medio_pago 
		   AND mmp.moneda_mp_conciliacion = SUBSTRING(detalles,105,1)
	WHERE SUBSTRING(detalles,1,1) = 1
	  AND id_archivo = @id;
    
    
    SELECT 
	  @costo_financieroR3 = SUM(CAST(SUBSTRING(detalles,51,1)+SUBSTRING(detalles,39,12) AS DECIMAL(12,2)))/100,
	  @otros_impuestos = SUM(CAST(SUBSTRING(detalles,38,1)+SUBSTRING(detalles,26,12) AS DECIMAL(12,2)) + CAST(SUBSTRING(detalles,111,1)+SUBSTRING(detalles,104,7) AS DECIMAL(12,2)))/100,
	  @cargos = SUM(CAST(SUBSTRING(detalles,51,1)+SUBSTRING(detalles,39,12) AS DECIMAL(12,2)) + CAST(SUBSTRING(detalles,64,1)+SUBSTRING(detalles,52,12) AS DECIMAL(12,2)))/100,
	  @percepciones_R3 = SUM(CAST(SUBSTRING(detalles,90,1)+SUBSTRING(detalles,78,12) AS DECIMAL(12,2)) + CAST(SUBSTRING(detalles,25,1)+SUBSTRING(detalles,13,12) AS DECIMAL(12,2)))
	FROM Configurations.dbo.Detalle_Archivo
	WHERE SUBSTRING(detalles,1,1) = 3
	  AND id_archivo = @id;

	  
    SELECT 
	  @contR2 = COUNT(DISTINCT SUBSTRING(detalles,2,11)),
	  @importe_brutoR2 = SUM(CAST(SUBSTRING(detalles,25,1)+SUBSTRING(detalles,13,12) AS DECIMAL(12,2)))/100,
	  @importe_arancelR2 = SUM(CAST(SUBSTRING(detalles,38,1)+SUBSTRING(detalles,26,12) AS DECIMAL(12,2)))/100,
	  @retenciones = SUM(CAST(SUBSTRING(detalles,77,1)+SUBSTRING(detalles,65,12) AS DECIMAL(12,2)) + CAST(SUBSTRING(detalles,90,1)+SUBSTRING(detalles,78,12) AS DECIMAL(12,2)) + CAST(SUBSTRING(detalles,103,1)+SUBSTRING(detalles,91,12) AS DECIMAL(12,2)))/100,
	  @percepciones = SUM(CAST(SUBSTRING(detalles,116,1)+SUBSTRING(detalles,104,12) AS DECIMAL(12,2)) + @percepciones_R3)/100
	FROM Configurations.dbo.Detalle_Archivo
	WHERE SUBSTRING(detalles,1,1) = 2
	  AND id_archivo = @id;
	  

	SELECT
      @contR1 = COUNT(DISTINCT nro_agrupador_boton),	
	  @importe_brutoR1 = SUM(CASE WHEN signo= '-' THEN importe * -1 ELSE importe END),
	  @importe_arancelR1 = SUM(CASE WHEN signo= '-' THEN IMPORTE_ARANCEl * -1 ELSE IMPORTE_ARANCEl END),
	  @costo_financieroR1 = SUM(CASE WHEN signo= '-' THEN COSTO_FINANCIERO * -1 ELSE COSTO_FINANCIERO END)
    FROM #info_cabal;
	  
    
    IF(@fecha_ejecucion IS NOT NULL)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END
    ELSE IF(@contR2 <> @contR1)
      BEGIN
    	SET @motivo_rechazo = 'No existen Totales (Registro Tipo 2) para al menos un Comercio';
      END  
	ELSE IF(@importe_brutoR2 <> @importe_brutoR1)
      BEGIN 
    	SET @motivo_rechazo = 'La suma de Importes no coincide con el Importe Bruto para al menos un Comercio';
      END 
    ELSE IF(@importe_arancelR2 <> @importe_arancelR1)
      BEGIN
    	SET @motivo_rechazo = 'La suma de Aranceles no coincide con el Total de Aranceles para al menos un Comercio.';
      END
    ELSE IF(@costo_financieroR3 <> @costo_financieroR1)
      BEGIN
    	SET @motivo_rechazo = 'La suma de Costos no coincide con el Total de Costos para al menos un Comercio.';
      END
	ELSE 
	  BEGIN
        SET @resultado_proceso = 1; 
		
	    SELECT
	       @fecha_pago = fecha_pago,
	       @importe_procesados = SUM(CASE WHEN signo = '-' THEN importe * -1 ELSE importe END),
	       @registros_procesados = COUNT(1)
	    FROM #info_cabal
	    WHERE CODOP <> 96
	    GROUP BY fecha_pago;
	  

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
			   (IMPORTE_ARANCEl + COSTO_FINANCIERO),
			   '+',
			   @id_log_paso,
			   @id_medio_pago,
			   id_codigo_operacion,
			   fecha_pago,
			   nro_lote,
			   GETDATE(),
			   'bpbatch',
			   version,
			   mask_nro_tarjeta,
			   campo_mp_1, 
		       valor_1, 
			   campo_mp_2,
		       valor_2,
			   campo_mp_3,
		       valor_3
		FROM #info_cabal
		WHERE CODOP <> 96; 
		
		
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
        VALUES
           (@fecha_pago 
           ,@fecha_pago
           ,@percepciones
           ,@retenciones
           ,@cargos
           ,@otros_impuestos
           ,@id_medio_pago
           ,@id_log_paso
           ,GETDATE()
           ,'bpbatch'
           ,0
           ,1);
		   
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





