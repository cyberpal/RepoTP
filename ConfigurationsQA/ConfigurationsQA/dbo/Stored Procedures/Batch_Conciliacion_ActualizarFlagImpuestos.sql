
CREATE PROCEDURE [dbo].[Batch_Conciliacion_ActualizarFlagImpuestos] (
   @usuario VARCHAR(20),
   @registros_procesados INT = NULL OUTPUT,
   @importe_procesados DECIMAL(12,2) = NULL OUTPUT,
   @resultado_proceso INT = 0 OUTPUT
	)
AS

DECLARE @movimientos TABLE (id_movimiento INT, importe_mov DECIMAL(12,2));

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener Movimientos --
		INSERT INTO @movimientos (
		id_movimiento,
		importe_mov
		)
		SELECT mpp.id_movimiento_mp,
		       ISNULL(CASE WHEN mad.signo_importe = '-' 
			               THEN (mad.importe * -1)
						   ELSE mad.importe 
					  END, 0) 
        FROM Configurations.dbo.Movimientos_a_distribuir mad 
        INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp 
		        ON mpp.id_movimiento_mp = mad.id_movimiento_mp
               AND CAST(GETDATE() AS DATE) = CAST(mad.fecha_alta AS DATE)
			   AND mad.flag_esperando_impuestos_generales_de_marca = 0;
        
		
		-- Obtener Resultados Para Log--
		SELECT
	        @registros_procesados = COUNT(1),
	        @importe_procesados = ISNULL(SUM(importe_mov), 0)
        FROM @movimientos; 

		
		-- Actualizar Flag Impuestos --
        UPDATE mad
           SET mad.flag_esperando_impuestos_generales_de_marca = 1
          FROM Configurations.dbo.Movimientos_a_distribuir mad
    INNER JOIN @movimientos m
            ON mad.id_movimiento_mp = m.id_movimiento;
		  
		  
        SET @resultado_proceso = 1;

		COMMIT TRANSACTION;

		RETURN 1;
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE();

		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		RETURN 0;
	END CATCH
END

