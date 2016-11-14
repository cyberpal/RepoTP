
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ValidarRapipago] (@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id INT;
DECLARE @id_log_paso INT;
DECLARE @fecha_archivo VARCHAR(6)
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @descripcion VARCHAR(9) = 'RAPIPAGO';
DECLARE @cantidad_total INT;
DECLARE @importe_total DECIMAL(12,2);
DECLARE @cant_trailer INT;
DECLARE @cant_header INT;
DECLARE @cant_detalles INT;
DECLARE @importe_detalles DECIMAL(12,2);
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12,2) = 0;
DECLARE @msg VARCHAR(MAX);

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

		SELECT TOP 1 @id = (ac.id),
	           @archivo_entrada = ac.nombre_archivo 
	      FROM Configurations.dbo.Archivo_Conciliacion ac
	INNER JOIN Configurations.dbo.Detalle_Archivo da
	        ON ac.id = da.id_archivo
	     WHERE ac.flag_procesado = 0
	       AND ac.descripcion = @descripcion;



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


    SELECT
       @cantidad_total = SUM(CASE WHEN SUBSTRING(detalles,1,8) = 99999999 THEN CAST(SUBSTRING(detalles,9,8) AS INT) ELSE 0 END),
	   @importe_total = SUM(CASE WHEN SUBSTRING(detalles,1,8) = 99999999 THEN CAST(SUBSTRING(detalles,17,18) AS DECIMAL(12,2))/100 ELSE 0 END),
	   @cant_trailer = SUM(CASE WHEN SUBSTRING(detalles,1,8) = 99999999 THEN 1 ELSE 0 END),
	   @cant_header = SUM(CASE WHEN SUBSTRING(detalles,1,8) = 00000000 THEN 1 ELSE 0 END),
	   @cant_detalles = SUM(CASE WHEN SUBSTRING(detalles,1,8) <> 99999999 AND SUBSTRING(detalles,1,8) <> 00000000  THEN 1 ELSE 0 END),
	   @importe_detalles = SUM(CASE WHEN SUBSTRING(detalles,1,8) <> 99999999 AND SUBSTRING(detalles,1,8) <> 00000000  THEN CAST(SUBSTRING(detalles,9,15) AS DECIMAL(12,2))/100 ELSE 0 END)
    FROM Configurations.dbo.Detalle_Archivo
    WHERE id_archivo = @id
	
    
    SELECT TOP 1
       @fecha_archivo = SUBSTRING(detalles,35,2)+SUBSTRING(detalles,33,2)+SUBSTRING(detalles,31,2)	
    FROM Configurations.dbo.Detalle_Archivo
    WHERE SUBSTRING(detalles,1,8) = 00000000
	  AND id_archivo = @id;
	
	
    IF(@fecha_ejecucion IS NOT NULL)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END
	ELSE IF(@importe_total <> @importe_detalles)
      BEGIN 
    	SET @motivo_rechazo = 'Los importes informados en el archivo son inconsistentes.';
      END 
    ELSE IF(@cantidad_total <> @cant_detalles)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de registros de detalle no concuerdan con la cantidad definida en el trailer.';
      END
    ELSE IF(@cant_header <> 1)
      BEGIN
    	SET @motivo_rechazo = 'Hay mas de 1 header definido en el archivo.';
      END
	ELSE IF(@cant_trailer <> 1)
      BEGIN
    	SET @motivo_rechazo = 'Hay mas de 1 trailer definido en el archivo.';
      END
	ELSE IF(CHARINDEX(@fecha_archivo,@archivo_entrada) = 0)
      BEGIN
    	SET @motivo_rechazo = 'La fecha de proceso informada en el header no concuerda con la definida en el nombre del mismo.';
      END
	ELSE
	  BEGIN
        SET @resultado_proceso = 1; 
		
	   
	    INSERT INTO Configurations.dbo.Movimiento_Presentado_MP
               (importe
               ,signo_importe
               ,moneda
               ,cantidad_cuotas
			   ,codigo_barra
               ,nro_agrupador_boton
               ,cargos_marca_por_movimiento
               ,signo_cargos_marca_por_movimiento
               ,id_log_paso
               ,id_medio_pago
               ,id_codigo_operacion
               ,fecha_pago
               ,fecha_alta
               ,usuario_alta
               ,version)
		SELECT 
		   CAST(SUBSTRING(detalles,9,15) AS DECIMAL(12,2))/100,
	       co.signo,
    	   mmp.id_moneda,
    	   1,
           SUBSTRING(detalles,24,50),		   
    	   mdp.nro_comercio,
		   0,
    	   '+',
		   @id_log_paso,
		   mp.id_medio_pago,
    	   comp.id_codigo_operacion,  
    	   CAST(SUBSTRING(detalles,1,8) AS DATETIME),
		   GETDATE(),
		   'bpbatch',
		   0
        FROM Configurations.dbo.Detalle_Archivo
		INNER JOIN Configurations.dbo.Medio_De_Pago mp 
		        ON mp.codigo = @descripcion
        INNER JOIN Configurations.dbo.Codigo_Operacion_Medio_Pago comp
                ON comp.id_medio_pago = mp.id_medio_pago 
	    INNER JOIN Configurations.dbo.Codigo_Operacion co
	            ON co.id_codigo_operacion = comp.id_codigo_operacion
        INNER JOIN Configurations.dbo.Moneda_Medio_Pago mmp
	            ON mmp.id_medio_pago = mp.id_medio_pago 
		INNER JOIN Configurations.dbo.Medio_De_Pago mdp
		        ON mdp.id_medio_pago = mp.id_medio_pago
	    WHERE SUBSTRING(detalles,1,8) <> 99999999 
		  AND SUBSTRING(detalles,1,8) <> 00000000
	      AND id_archivo = @id;
		
		SET @registros_procesados = @cant_detalles;
		
		SET @importe_procesados = @importe_detalles;
		 
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

	RETURN 0;
END CATCH;

