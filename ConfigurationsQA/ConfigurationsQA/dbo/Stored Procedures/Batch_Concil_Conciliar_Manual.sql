
CREATE PROCEDURE [dbo].[Batch_Concil_Conciliar_Manual] (
    @estado_movimiento VARCHAR(1),
	@id_log_paso INT,
	@usuario VARCHAR(20),
    @id_movimiento_mp INT,
    @codigo_tipo_mp VARCHAR(20),
	@CantId INT,
	@idTransaccion CHAR(36)
	)
AS

DECLARE @flag_aceptada_marca BIT = 0;
DECLARE @flag_contracargo BIT = 0;
DECLARE @fecha_pago DATETIME;
DECLARE @importe DECIMAL(12, 2);
DECLARE @signo_importe VARCHAR(1);
DECLARE @moneda INT;
DECLARE @cantidad_cuotas INT;
DECLARE @nro_tarjeta VARCHAR(50);
DECLARE @codigo_barra VARCHAR(128);
DECLARE @fecha_movimiento DATETIME;
DECLARE @nro_autorizacion VARCHAR(50);
DECLARE @nro_cupon VARCHAR(50);
DECLARE @cargos_marca_por_movimiento DECIMAL(12, 2);
DECLARE @signo_cargos_marca_por_movimiento VARCHAR(1);
DECLARE @nro_agrupador_boton VARCHAR(50);
DECLARE @id_conciliacion_manual INT;
DECLARE @codigo_operacion VARCHAR(5);
DECLARE @codigo_motivo VARCHAR(8);
DECLARE @id_motivo INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;


		-- Obtener Datos --
		SELECT 
		    @importe = mpm.importe,
			@signo_importe = mpm.signo_importe,
			@moneda = mpm.moneda,
			@cantidad_cuotas = mpm.cantidad_cuotas,
			@nro_tarjeta = mpm.nro_tarjeta,
			@codigo_barra = mpm.codigo_barra,
			@fecha_movimiento = mpm.fecha_movimiento,
			@nro_autorizacion = mpm.nro_autorizacion,
			@nro_cupon = mpm.nro_cupon,
			@cargos_marca_por_movimiento = mpm.cargos_marca_por_movimiento,
			@signo_cargos_marca_por_movimiento = mpm.signo_cargos_marca_por_movimiento,
			@nro_agrupador_boton = mpm.nro_agrupador_boton,
			@fecha_pago = mpm.fecha_pago, 
	        @codigo_operacion = co.codigo_operacion
	    FROM Configurations.dbo.Movimiento_Presentado_MP mpm
	    INNER JOIN Configurations.dbo.Codigo_operacion co 
		    ON mpm.id_codigo_operacion = co.id_codigo_operacion
	    WHERE mpm.id_movimiento_mp = @id_movimiento_mp; 


		IF (@codigo_operacion = 'CON')
		   SET @flag_contracargo = 1;


        IF(@estado_movimiento = 'A')
		  SET @flag_aceptada_marca = 1;
		ELSE 
		  SET @codigo_motivo = 'CM_00003';


		IF(@idTransaccion IS NULL AND @CantId<=1)
		  SET @codigo_motivo = 'CM_00001';
		ELSE IF(@CantId>1)
		  SET @codigo_motivo = 'CM_00002';


        SELECT @id_motivo = id_motivo_conciliacion_manual
		FROM Configurations.dbo.Motivo_Conciliacion_Manual
		WHERE codigo_motivo_conciliacion_manual = @codigo_motivo;


        SELECT @id_conciliacion_manual = ISNULL(MAX([id_conciliacion_manual]), 0) + 1
		FROM Configurations.dbo.Conciliacion_manual;

		INSERT INTO Configurations.dbo.Conciliacion_manual(
            id_conciliacion_manual,
            importe,
            moneda,
            cantidad_cuotas,
            nro_tarjeta,
            codigo_barra,
            fecha_movimiento,
            nro_autorizacion,
            nro_cupon,
			cargos_boton_por_movimiento,
			impuestos_boton_por_movimiento,
			cargos_marca_por_movimiento,
			signo_cargos_marca_por_movimiento,
			nro_agrupador_boton,
			fecha_pago,
			flag_aceptada_marca,
			flag_conciliado_manual,
			flag_contracargo,
			flag_procesado,
			id_log_paso,
			fecha_alta,
			usuario_alta,
			id_movimiento_mp,
			version,
			id_motivo_conciliacion_manual
			)
		VALUES(
			@id_conciliacion_manual,
            @importe,
			@moneda,
			@cantidad_cuotas,
			@nro_tarjeta,
			@codigo_barra,
			@fecha_movimiento,
			@nro_autorizacion,
			@nro_cupon,
			0,
			0,
			@cargos_marca_por_movimiento,
			@signo_cargos_marca_por_movimiento,
			@nro_agrupador_boton,
			@fecha_pago,
			@flag_aceptada_marca,
			0,
			@flag_contracargo,
			0,
			@id_log_paso,
			GETDATE(),
			@usuario,
			@id_movimiento_mp,
			0,
			@id_motivo
			);

        -- Es aceptada o rechazada --
		IF(@codigo_tipo_mp = 'EFECTIVO' OR @estado_movimiento = 'A')
		  INSERT INTO Configurations.dbo.movimientos_a_distribuir(
				 tipo,
				 BCRA_cuenta,
				 BCRA_emisor_tarjeta,
				 signo_importe,
				 signo_cargo_marca,
				 cargo_marca,
                 signo_cargo_boton,
				 cargo_boton,
				 signo_impuesto_boton,
				 impuesto_boton,
				 id_log_paso,
				 flag_esperando_impuestos_generales_de_marca,
                 importe,
				 id_movimiento_mp,
				 fecha_alta,
				 usuario_alta,
				 version
				 )
          VALUES(
		        'N',
				0,
				0,
				@signo_importe,
				@signo_cargos_marca_por_movimiento,
				@cargos_marca_por_movimiento,
				' ',
				0,
				' ',
				0,
				@id_log_paso,
				0,
				@importe,
				@id_movimiento_mp,
				GETDATE(),
				@usuario,
				0
				);


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
