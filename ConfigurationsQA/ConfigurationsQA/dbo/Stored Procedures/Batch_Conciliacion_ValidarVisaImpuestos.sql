
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ValidarVisaImpuestos] (
   @id_log_paso INT,
   @id INT,
   @resultado_proceso BIT OUTPUT,
   @motivo_rechazo VARCHAR(100) OUTPUT
)
AS
DECLARE @flak_ok BIT = 1;
DECLARE @id_medio_pago INT = 42;
DECLARE @fecha_pago DATETIME;
DECLARE @flag_fecha INT;
DECLARE @msg VARCHAR(MAX);

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY

   SELECT TOP 1 @fecha_pago = CAST((SUBSTRING(detalles,49,2)+SUBSTRING(detalles,47,2)+SUBSTRING(detalles,45,2)) AS DATETIME)
   FROM Configurations.dbo.Detalle_Archivo
   WHERE id_archivo = @id;
   
   
   SELECT @flag_fecha = DATEDIFF (D,CAST(@fecha_pago AS DATE),CAST(GETDATE() AS DATE))

   IF(@flag_fecha < 0)
	  BEGIN
	    SET @motivo_rechazo = 'Fecha de Pago mayor a la fecha de ejecucion del proceso.';
	  END 
	ELSE
	  BEGIN
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
          SELECT 
                @fecha_pago 
               ,@fecha_pago
               ,SUM(CASE WHEN SUBSTRING(detalles,13,1) = 2
                    THEN CAST(SUBSTRING(detalles,101,1)+SUBSTRING(detalles,92,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,111,1)+SUBSTRING(detalles,102,9) AS DECIMAL(12,2))
		            ELSE CAST(SUBSTRING(detalles,91,1)+SUBSTRING(detalles,82,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,220,1)+SUBSTRING(detalles,211,9) AS DECIMAL(12,2))
		            END
	               )/100
               ,SUM(CASE WHEN SUBSTRING(detalles,13,1) = 2
                    THEN CAST(SUBSTRING(detalles,91,1)+SUBSTRING(detalles,84,7) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,351,1)+SUBSTRING(detalles,342,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,361,1)+SUBSTRING(detalles,352,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,371,1)+SUBSTRING(detalles,362,9) AS DECIMAL(12,2))
		            ELSE CAST(SUBSTRING(detalles,126,1)+SUBSTRING(detalles,117,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,236,1)+SUBSTRING(detalles,221,15) AS DECIMAL(12,2))
		            END
	               )/100
               ,SUM(CASE WHEN SUBSTRING(detalles,13,1) = 2
                    THEN CAST(SUBSTRING(detalles,141,1)+SUBSTRING(detalles,132,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,201,1)+SUBSTRING(detalles,192,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,231,1)+SUBSTRING(detalles,222,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,261,1)+SUBSTRING(detalles,252,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,291,1)+SUBSTRING(detalles,282,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,321,1)+SUBSTRING(detalles,312,9) AS DECIMAL(12,2))
		            ELSE CAST(SUBSTRING(detalles,170,1)+SUBSTRING(detalles,155,15) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,259,1)+SUBSTRING(detalles,252,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,275,1)+SUBSTRING(detalles,268,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,291,1)+SUBSTRING(detalles,284,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,307,1)+SUBSTRING(detalles,300,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,323,1)+SUBSTRING(detalles,316,7) AS DECIMAL(12,2))
		             END
	                )/100
               ,SUM(CASE WHEN SUBSTRING(detalles,13,1) = 2
                    THEN CAST(SUBSTRING(detalles,121,1)+SUBSTRING(detalles,112,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,131,1)+SUBSTRING(detalles,122,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,151,1)+SUBSTRING(detalles,142,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,161,1)+SUBSTRING(detalles,152,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,181,1)+SUBSTRING(detalles,172,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,191,1)+SUBSTRING(detalles,182,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,211,1)+SUBSTRING(detalles,202,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,221,1)+SUBSTRING(detalles,212,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,241,1)+SUBSTRING(detalles,232,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,251,1)+SUBSTRING(detalles,242,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,271,1)+SUBSTRING(detalles,262,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,281,1)+SUBSTRING(detalles,272,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,301,1)+SUBSTRING(detalles,292,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,311,1)+SUBSTRING(detalles,302,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,331,1)+SUBSTRING(detalles,322,9) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,341,1)+SUBSTRING(detalles,332,9) AS DECIMAL(12,2))
		            ELSE CAST(SUBSTRING(detalles,116,1)+SUBSTRING(detalles,107,9) AS DECIMAL(12,2))+
		                 CAST(SUBSTRING(detalles,178,1)+SUBSTRING(detalles,171,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,200,1)+SUBSTRING(detalles,189,11) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,267,1)+SUBSTRING(detalles,260,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,283,1)+SUBSTRING(detalles,276,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,299,1)+SUBSTRING(detalles,292,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,315,1)+SUBSTRING(detalles,308,7) AS DECIMAL(12,2))+
				         CAST(SUBSTRING(detalles,331,1)+SUBSTRING(detalles,324,7) AS DECIMAL(12,2))
		             END
	                )/100
               ,@id_medio_pago
               ,@id_log_paso
               ,GETDATE()
               ,'bpbatch'
               ,0
               ,0
		  FROM Configurations.dbo.Detalle_Archivo
		  WHERE id_archivo = @id;

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





