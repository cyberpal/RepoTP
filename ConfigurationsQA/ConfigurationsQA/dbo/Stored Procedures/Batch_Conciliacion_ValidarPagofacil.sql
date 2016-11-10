
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ValidarPagofacil](@id_log_proceso INT)
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id INT;
DECLARE @id_log_paso INT;
DECLARE @fecha_archivo VARCHAR(6)
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @descripcion VARCHAR(9) = 'PAGOFACIL';
DECLARE @cantidad_reg_1 INT;
DECLARE @cantidad_reg_3 INT;
DECLARE @cantidad_reg_5 INT;
DECLARE @cantidad_reg_6 INT;
DECLARE @cantidad_reg_7 INT;
DECLARE @cantidad_reg_8 INT;
DECLARE @cantidad_reg_9 INT;
DECLARE @importe_reg_5 DECIMAL(12,2) = NULL;
DECLARE @importe_reg_8 DECIMAL(12,2) = NULL;
DECLARE @cantidad_tx INT;
DECLARE @cantidad_tx_trailer INT;
DECLARE @registros_procesados INT;
DECLARE @importe_procesados DECIMAL(12,2);
DECLARE @msg VARCHAR(MAX);

SET NOCOUNT ON;


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
	           @cantidad_reg_1 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 1 THEN 1 ELSE 0 END),
	           @cantidad_reg_3 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 3 THEN 1 ELSE 0 END),
               @cantidad_reg_5 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 5 THEN 1 ELSE 0 END),
	           @cantidad_reg_6 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 6 THEN 1 ELSE 0 END),
	           @cantidad_reg_7 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 7 THEN 1 ELSE 0 END),
	           @cantidad_reg_8 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN 1 ELSE 0 END),
			   @cantidad_reg_9 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 9 THEN 1 ELSE 0 END),
			   @importe_reg_5 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 5 THEN CAST(SUBSTRING(detalles,49,10) AS DECIMAL(12,2)) ELSE 0 END),
			   @importe_reg_8 = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN CAST(SUBSTRING(detalles,24,10) AS DECIMAL(12,2))  ELSE 0 END),
	           @cantidad_tx = COUNT(1),
			   @cantidad_tx_trailer = SUM(CASE WHEN SUBSTRING(detalles,1,1) = 8 THEN CAST(SUBSTRING(detalles,16,7) AS INT)  ELSE 0 END)
          FROM Configurations.dbo.Detalle_Archivo
         WHERE id_archivo = @id;
	
    
        SELECT TOP 1
               @fecha_archivo = SUBSTRING(detalles,8,2)+SUBSTRING(detalles,6,2)+SUBSTRING(detalles,4,2)	
          FROM Configurations.dbo.Detalle_Archivo
         WHERE SUBSTRING(detalles,1,1) = 1
	       AND id_archivo = @id;
	
BEGIN TRY
	BEGIN TRANSACTION;
	
    IF(@fecha_ejecucion IS NOT NULL)
	  BEGIN
	    SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END
	ELSE IF(@cantidad_reg_5 <> @cantidad_reg_6 AND @cantidad_reg_6 <> @cantidad_reg_7)
      BEGIN 
    	SET @motivo_rechazo = 'La cantidad de registros del tipo 5, 6 y 7 son distintos.';
      END 
    ELSE IF(@cantidad_reg_1 <> @cantidad_reg_9)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de registros del tipo 1 son distintos al del tipo 9.';
      END
    ELSE IF(@cantidad_reg_3 <> @cantidad_reg_8)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de registros del tipo 3 son distintos al del tipo 8.';
      END
	ELSE IF(@cantidad_tx > 500)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de transacciones informadas por lote debe ser menor o igual a 500.';
      END
	ELSE IF(@importe_reg_5 <> @importe_reg_8)
      BEGIN
    	SET @motivo_rechazo = 'La sumatoria de importes del detalle no concide con el valor informado en el trailer.';
      END
	ELSE IF(CHARINDEX(@fecha_archivo,@archivo_entrada) = 0)
      BEGIN
    	SET @motivo_rechazo = 'La fecha de proceso informada en el header no concuerda con la definida en el nombre del mismo.';
      END
	ELSE IF(@cantidad_reg_5 <> @cantidad_reg_6 AND @cantidad_reg_6 <> @cantidad_reg_7 AND @cantidad_reg_7 <> @cantidad_tx_trailer)
      BEGIN
    	SET @motivo_rechazo = 'La cantidad de transacciones informadas en cada lote debe coincidir con el valor  en el trailer.';
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
              T1.importe, 
        	  T1.signo, 
        	  T1.id_moneda,
        	  1,
              T2.codigo_barra, 
        	  T1.nro_comercio, 
        	  0,
              '+',
        	  @id_log_paso,
        	  T1.id_medio_pago,
              T1.id_codigo_operacion,  
              T1.fecha_pago,
        	  GETDATE(),
        	  'bpbatch',
        	  0
        FROM
             (SELECT 
                     ROW_NUMBER() OVER(ORDER BY d.id_archivo DESC) AS row_1,
        		     CAST(SUBSTRING(d.detalles,49,10) AS DECIMAL(12,2))/100 AS importe,
        			 co.signo,
            	     mmp.id_moneda,
        			 mdp.nro_comercio,
        			 mp.id_medio_pago,
            	     comp.id_codigo_operacion,  
            	     CAST(SUBSTRING(detalles,65,8) AS DATETIME) AS fecha_pago
                FROM Configurations.dbo.Detalle_Archivo d
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
        	   WHERE SUBSTRING(detalles,1,1) = 5
        		 AND id_archivo = @id
                   ) T1
          INNER JOIN
             (SELECT 
        	         ROW_NUMBER() OVER(ORDER BY id_archivo DESC) AS row_2,
        			 SUBSTRING(detalles,2,50) AS codigo_barra
                FROM Configurations.dbo.Detalle_Archivo
               WHERE SUBSTRING(detalles,1,1) = 6
        		 AND id_archivo = @id
                   ) T2 
        		  ON T1.row_1 = T2.row_2;
		
		
		SET @registros_procesados = @cantidad_reg_5;
		
		SET @importe_procesados = @importe_reg_5;
		 
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

