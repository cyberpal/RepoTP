
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ValidarVisaMovimientos] (
   @id_log_paso INT,
   @id INT,
   @archivo_entrada VARCHAR(100),
   @registros_procesados INT OUTPUT,
   @importe_procesados DECIMAL(12,2) OUTPUT,
   @resultado_proceso BIT OUTPUT,
   @motivo_rechazo VARCHAR(100) OUTPUT
)
AS
DECLARE @flak_ok BIT = 1;
DECLARE @fecha_pago DATETIME;
DECLARE @flag_fecha INT;
DECLARE @flag_existe INT;
DECLARE @cantidad_detalles INT = 0;
DECLARE @importe_detalles DECIMAL(12,2) = 0;
DECLARE @cantidad_totalizadores INT = 0;
DECLARE @importe_totalizadores DECIMAL(12,2) = 0;
DECLARE @msg VARCHAR(MAX);
CREATE TABLE #info_visa(TIPOREG CHAR(1), 
					    MCAPEX CHAR(1),
						CODOP VARCHAR(4),
                        importe DECIMAL(12,2),
					    signo_importe CHAR(1),
					    id_moneda INT,
					    cantidad_cuotas INT,
                        nro_tarjeta VARCHAR(16),
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
					    hash_nro_trajeta VARCHAR(80),
					    campo_mp_1 VARCHAR(10), 
		                valor_1 VARCHAR(15),
			            campo_mp_2 VARCHAR(10), 
		                valor_2 VARCHAR(15),
			            campo_mp_3 VARCHAR(10), 
		                valor_3 VARCHAR(15) 
					    );

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

   INSERT INTO #info_visa
   SELECT SUBSTRING(detalles,13,1),
	      SUBSTRING(detalles,127,1),
		  SUBSTRING(detalles,34,4), 
	      (CASE WHEN SUBSTRING(detalles,13,1) = 1 
	           THEN CAST(SUBSTRING(detalles,91,9) AS DECIMAL(12,2))
			   ELSE CAST(SUBSTRING(detalles,91,10) AS DECIMAL(12,2))
		  END)/100,
          co.signo,
	      mmp.id_moneda,
	      CASE WHEN SUBSTRING(detalles,108,2) = 0 
	           THEN 1
			   ELSE CAST(SUBSTRING(detalles,108,2) AS INT)
		  END,
	      SUBSTRING(detalles,55,16),
	      CAST((SUBSTRING(detalles,75,2)+SUBSTRING(detalles,73,2)+SUBSTRING(detalles,71,2)) AS DATETIME),
	      '0'+SUBSTRING(detalles,101,5),
	      CAST(SUBSTRING(detalles,83,8) AS INT),
	      CAST(CAST(SUBSTRING(detalles,24,10) AS INT) AS VARCHAR(50)),
	      ABS(CASE WHEN SUBSTRING(detalles,13,1) = 1
                   THEN CAST(SUBSTRING(detalles,155,1)+SUBSTRING(detalles,148,7) AS DECIMAL(12,2))+
		                CAST(SUBSTRING(detalles,220,1)+SUBSTRING(detalles,213,7) AS DECIMAL(12,2))+
				        CAST(SUBSTRING(detalles,233,1)+SUBSTRING(detalles,226,7) AS DECIMAL(12,2))
		           ELSE 0
		      END
	         )/100,
	      co.signo,
	      mdp.id_medio_pago,
	      CASE WHEN SUBSTRING(detalles,34,4) = 1507 AND SUBSTRING(detalles,137,2) = 98
		       THEN 3
			   ELSE comp.id_codigo_operacion
		  END,
	      CAST((SUBSTRING(detalles,81,2)+SUBSTRING(detalles,79,2)+SUBSTRING(detalles,77,2)) AS DATETIME),
	      SUBSTRING(detalles,39,4),
	      UPPER(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5',SUBSTRING(detalles,55,16))),3,32) + SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1',SUBSTRING(detalles,55,16))),3,40)),
	      'CODOP',
		  SUBSTRING(detalles,34,4),
		  0,
		  0,
		  0,
		  0
    FROM Configurations.dbo.Detalle_Archivo
	LEFT JOIN Configurations.dbo.Medio_de_Pago mdp
	       ON mdp.codigo = (CASE WHEN SUBSTRING(detalles,110,1) = 0 THEN 'VISA' ELSE 'VISADEBITO' END)
    LEFT JOIN Configurations.dbo.Codigo_Operacion_Medio_Pago comp
           ON comp.id_medio_pago = mdp.id_medio_pago AND comp.valor_1 = SUBSTRING(detalles,34,4) 
	LEFT JOIN Configurations.dbo.Codigo_Operacion co
	       ON co.id_codigo_operacion = comp.id_codigo_operacion
    LEFT JOIN Configurations.dbo.Moneda_Medio_Pago mmp
	       ON mmp.id_medio_pago = mdp.id_medio_pago
		  AND mmp.moneda_mp_conciliacion = SUBSTRING(detalles,139,1) 
	WHERE id_archivo = @id;
   
   
    SELECT @cantidad_detalles = COUNT(1),
           @importe_detalles = SUM(CASE WHEN signo_importe = '-'
	                                    THEN importe * -1
		                                ELSE importe
		                           END)
    FROM #info_visa
    WHERE TIPOREG = 1;
	
	
	SELECT @fecha_pago = i.fecha_pago,
	       @cantidad_totalizadores = i.cant_trailer,
           @importe_totalizadores = SUM(CASE WHEN i.signo_importe = '-'
	                                         THEN i.importe * -1
		                                     ELSE i.importe
		                                END)
    FROM (SELECT COUNT(1) AS cant_trailer,
                             importe,
	                         signo_importe,
							 fecha_pago
          FROM #info_visa
          WHERE TIPOREG = 5
          GROUP BY nro_agrupador_boton,
                   CODOP, 
                   fecha_pago,
	               importe,
		           signo_importe) i
    GROUP BY fecha_pago, 
	         cant_trailer;
	
	
   SELECT @flag_fecha = DATEDIFF (D,CAST(@fecha_pago AS DATE),CAST(GETDATE() AS DATE));
   
   SELECT @flag_existe = COUNT(1) 
   FROM Configurations.dbo.Log_Paso_Proceso
   WHERE archivo_entrada = REPLACE(@archivo_entrada,'M','P')  
     AND resultado_proceso = 1; 
  

   IF(@flag_fecha < 0)
	  BEGIN
	    SET @motivo_rechazo = 'Fecha de Pago mayor a la fecha de ejecucion del proceso.';
	  END 
	ELSE IF (@flag_existe = 0)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo de movimientos no tiene su correspondiente archivo de pagos.';
	  END
	ELSE IF(@cantidad_totalizadores > 1)
      BEGIN 
        SET @motivo_rechazo = 'Debe existir un único registro de totales de transacciones.';
      END 
    ELSE IF(@cantidad_detalles < 1)
      BEGIN
        SET @motivo_rechazo = 'La cantidad de registros de detalle de transacciones debe ser mayor o igual a 1.';
      END
    ELSE IF(@importe_totalizadores <> @importe_detalles)
      BEGIN
        SET @motivo_rechazo = 'La suma de los importes del detalle no coincide con lo reportado en el trailer.';
      END
	ELSE
	  BEGIN
	  
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
               ,hash_nro_tarjeta
			   ,campo_mp_1  
		       ,valor_1 
			   ,campo_mp_2
		       ,valor_2
			   ,campo_mp_3
		       ,valor_3)
		SELECT importe,
			   signo_importe,
			   id_moneda,
			   cantidad_cuotas ,
               nro_tarjeta,
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
			   hash_nro_trajeta,
			   campo_mp_1,  
		       valor_1, 
			   campo_mp_2,
		       valor_2,
			   campo_mp_3,
		       valor_3
		FROM #info_visa
		WHERE TIPOREG = 1; 
		
		
		UPDATE Configurations.dbo.Impuesto_General_MP
        SET solo_impuestos = 1,
            fecha_modificacion = GETDATE(),
	        usuario_modificacion = 'bpbatch'
        WHERE fecha_pago_desde = @fecha_pago
        AND fecha_pago_hasta = @fecha_pago;  
		
		SET @registros_procesados = @cantidad_detalles;
		
		SET @importe_procesados = @importe_detalles;
		
		SET @resultado_proceso = 1;
		
    END 
		
END TRY

BEGIN CATCH
	ROLLBACK TRANSACTION;

	SELECT @msg = ERROR_MESSAGE();

	THROW 51000,
		@msg,
		1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;





