
CREATE PROCEDURE [dbo].[Batch_Concil_Resultado_WScontracargo] (
    @usuario VARCHAR(20),
	@id_log_paso INT,
	@id_disputa VARCHAR(20),
	@codigo VARCHAR(20),
	@id_movimiento_mp INT,
	@id_conciliacion INT
	)
AS
 
DECLARE @CodigoAux VARCHAR(6);
DECLARE @id_conciliacion_manual INT = NULL;
DECLARE @importe DECIMAL(12, 2) = NULL;
DECLARE	@moneda INT = NULL;
DECLARE @cantidad_cuotas INT = NULL;
DECLARE	@nro_tarjeta VARCHAR(50) = NULL;
DECLARE	@fecha_movimiento DATETIME = NULL;
DECLARE	@nro_autorizacion VARCHAR(50) = NULL;
DECLARE	@nro_cupon VARCHAR(50) = NULL;
DECLARE	@nro_agrupador_boton VARCHAR(50) = NULL;
DECLARE @id_transaccion VARCHAR(40) = NULL;
DECLARE	@flag_aceptada_marca BIT = NULL;
DECLARE	@fecha_pago DATETIME = NULL;
DECLARE	@cargos_marca_por_movimiento DECIMAL(12, 2) = NULL;
DECLARE	@signo_cargos_marca_por_movimiento VARCHAR(1) = NULL
DECLARE @cargos_boton_por_movimiento DECIMAL(12, 2) = NULL;
DECLARE @impuestos_boton_por_movimiento DECIMAL(12, 2) = NULL;
DECLARE @id_motivo INT;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		SET @CodigoAux = RIGHT(@codigo, 5);

		IF(@CodigoAux = '00000')
		   BEGIN
		     UPDATE configurations.dbo.conciliacion 
             SET id_disputa = @id_disputa
             WHERE id_conciliacion = @id_conciliacion;
		   END;
		ELSE IF(@CodigoAux <> '10001' AND
		        @CodigoAux <> '10002' AND
				@CodigoAux <> '10003' AND
				@CodigoAux <> '10004' AND
				@CodigoAux <> '10005' AND
				@CodigoAux <> '10202' AND
				@CodigoAux <> '10206' AND
				NOT EXISTS(SELECT 1 
				           FROM Configurations.dbo.Conciliacion_Manual 
						   WHERE id_transaccion = @id_transaccion
						   )
				)
           BEGIN
		     
			 SELECT @id_motivo = id_motivo_conciliacion_manual
		     FROM Configurations.dbo.Motivo_Conciliacion_Manual
		     WHERE codigo_motivo_conciliacion_manual = @codigo;

		     SELECT 
			    @id_conciliacion_manual = ISNULL(MAX([id_conciliacion_manual]), 0) + 1
		     FROM Configurations.dbo.Conciliacion_manual;

			 SELECT 
	            @importe = mp.importe, 
                @moneda = mp.moneda, 
                @cantidad_cuotas = mp.cantidad_cuotas, 
                @nro_tarjeta = mp.nro_tarjeta, 
                @fecha_movimiento = mp.fecha_movimiento, 
                @nro_autorizacion = mp.nro_autorizacion, 
                @nro_cupon = mp.nro_cupon, 
                @nro_agrupador_boton = mp.nro_agrupador_boton,
                @fecha_pago = mp.fecha_pago,
                @cargos_marca_por_movimiento = mp.cargos_marca_por_movimiento,
                @signo_cargos_marca_por_movimiento = mp.signo_cargos_marca_por_movimiento,
                @id_transaccion = c.id_transaccion, 
                @flag_aceptada_marca = c.flag_aceptada_marca,
				@cargos_boton_por_movimiento = t.FeeAmount,
				@impuestos_boton_por_movimiento = t.TaxAmount
            FROM Configurations.dbo.Movimiento_presentado_mp mp
            INNER JOIN Configurations.dbo.Conciliacion c ON c.id_movimiento_mp = mp.id_movimiento_mp
			INNER JOIN Transactions.dbo.transactions t ON t.Id = c.id_transaccion
            WHERE mp.id_movimiento_mp = @id_movimiento_mp;

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
			  0,
			  0,
			  0,
			  @impuestos_boton_por_movimiento,
			  @cargos_boton_por_movimiento,
			  @id_movimiento_mp,
			  0,
			  @id_motivo
			  );

		   END


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
