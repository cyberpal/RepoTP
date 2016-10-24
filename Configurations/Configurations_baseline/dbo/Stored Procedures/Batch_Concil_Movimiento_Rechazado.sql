
CREATE PROCEDURE [dbo].[Batch_Concil_Movimiento_Rechazado] (
    @id_movimiento_mp INT,
	@id_transaccion VARCHAR(36),
	@id_log_paso INT,
	@usuario VARCHAR(20)
	)
AS

DECLARE @importe DECIMAL(12,2);
DECLARE @moneda INT;
DECLARE @cantidad_cuotas INT;
DECLARE @nro_tarjeta VARCHAR(50);
DECLARE @fecha_movimiento DATETIME;
DECLARE @nro_autorizacion VARCHAR(50);
DECLARE @nro_cupon VARCHAR(50);
DECLARE @cargos_marca_por_movimiento DECIMAL(12,2);
DECLARE @signo_cargos_marca_por_movimiento VARCHAR(1);
DECLARE @nro_agrupador_boton VARCHAR(50);
DECLARE @fecha_pago DATETIME;
DECLARE @codigo_operacion VARCHAR(20);
DECLARE @flag_contracargo BIT;
DECLARE @TaxAmount DECIMAL(12,2);
DECLARE @FeeAmount DECIMAL(12,2);
DECLARE @id_conciliacion INT;
DECLARE @id_conciliacion_manual INT;
DECLARE @id_paso_proceso  INT;
DECLARE @id_motivo INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener Datos --
		SELECT
		   @importe = mpm.importe, 
		   @moneda = mpm.moneda,
		   @cantidad_cuotas = mpm.cantidad_cuotas,
		   @nro_tarjeta = mpm.nro_tarjeta,
		   @fecha_movimiento = mpm.fecha_movimiento,
		   @nro_autorizacion = mpm.nro_autorizacion,
	       @nro_cupon =mpm.nro_cupon,
	       @cargos_marca_por_movimiento = mpm.cargos_marca_por_movimiento,
	       @signo_cargos_marca_por_movimiento = mpm.signo_cargos_marca_por_movimiento,
	       @nro_agrupador_boton = mpm.nro_agrupador_boton,	
	       @fecha_pago = mpm.fecha_pago,
	       @codigo_operacion = co.codigo_operacion
	    FROM Configurations.dbo.Movimiento_Presentado_MP mpm
	    INNER JOIN Configurations.dbo.Codigo_operacion co ON mpm.id_codigo_operacion = co.id_codigo_operacion
	    WHERE mpm.id_movimiento_mp = @id_movimiento_mp;

		IF(@codigo_operacion = 'CON')
		   SET @flag_contracargo = 1;
        ELSE
		   SET @flag_contracargo = 0;

		SELECT 
		   @TaxAmount = t.TaxAmount,
		   @FeeAmount = t.FeeAmount 
		FROM Transactions.dbo.transactions t
		WHERE Id= @id_transaccion;

        -- Insertar en Conciliacion --
		SELECT @id_conciliacion = ISNULL(MAX(id_conciliacion), 0) + 1
	    FROM dbo.Conciliacion;
		
        INSERT INTO Configurations.dbo.Conciliacion(
		   id_conciliacion,
           id_movimiento_mp,      
           id_log_paso, 
           id_transaccion, 
           flag_aceptada_marca, 
           flag_conciliada, 
           flag_distribuida, 
           flag_contracargo,
           flag_notificado,
           fecha_alta,
           id_disputa,
           usuario_alta,
		   version
		   )
		VALUES(
		   @id_conciliacion,
		   @id_movimiento_mp,
		   @id_log_paso,
		   @id_transaccion,
		   0,
		   1,
		   0,
		   @flag_contracargo,
		   1,
		   GETDATE(),
		   0,
		   @usuario,
		   0
		   );


		IF(@id_paso_proceso = 2)
		BEGIN
		   SELECT @id_conciliacion_manual = ISNULL(MAX(id_conciliacion_manual), 0) + 1
		   FROM Configurations.dbo.Conciliacion_manual;

		   SELECT @id_motivo = id_motivo_conciliacion_manual
		   FROM Configurations.dbo.Motivo_Conciliacion_Manual
		   WHERE codigo_motivo_conciliacion_manual = 'CM_00003';

		   INSERT INTO Configurations.dbo.Conciliacion_Manual (
			id_conciliacion_manual,
			id_transaccion,
			importe,
			moneda,
			cantidad_cuotas,
			nro_tarjeta,
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
			id_motivo_conciliacion_manual
			)
		  VALUES (
			@id_conciliacion_manual,
			@id_transaccion,
			@importe,
			@moneda,
			@cantidad_cuotas,
			@nro_tarjeta,
			@fecha_movimiento,
			@nro_autorizacion,
			@nro_cupon,
			@nro_agrupador_boton,
			@cargos_marca_por_movimiento,
			@signo_cargos_marca_por_movimiento,
			@fecha_pago,
			@id_log_paso,
			GETDATE(),
			@usuario,
			0,
			@flag_contracargo,
			0,
			0,
			@TaxAmount,
			@FeeAmount,
			@id_movimiento_mp,
			0,
			@id_motivo
			);
        END
		ELSE
		BEGIN
		  SELECT @id_conciliacion_manual = id_conciliacion_manual
		  FROM Configurations.dbo.Conciliacion_manual
		  WHERE id_movimiento_mp = @id_movimiento_mp;

		  UPDATE Configurations.dbo.Conciliacion_Manual
		  SET impuestos_boton_por_movimiento = @TaxAmount,
		      cargos_boton_por_movimiento = @FeeAmount
		  WHERE id_conciliacion_manual = @id_conciliacion_manual;
		END 

        -- Actualizar Conciliacion --
		UPDATE Configurations.dbo.Conciliacion 
        SET id_conciliacion_manual = @id_conciliacion_manual
        WHERE id_conciliacion = @id_conciliacion;

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
