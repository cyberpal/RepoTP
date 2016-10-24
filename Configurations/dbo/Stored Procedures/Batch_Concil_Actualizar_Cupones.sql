
CREATE PROCEDURE [dbo].[Batch_Concil_Actualizar_Cupones] (
	@idTransaccion CHAR(36),
	@id_log_paso_padre INT,
	@usuario VARCHAR(20),
	@id_movimiento_presentado INT,
	@codigo_tipo VARCHAR(15)
	)
AS
DECLARE @id_paso INT = 0;
DECLARE @flag_aceptada_marca BIT;
DECLARE @flag_conciliada BIT;
DECLARE @flag_distribuida BIT;
DECLARE @flag_contracargo BIT;
DECLARE @flag_notificado BIT;
DECLARE @Estado VARCHAR(20);
DECLARE @fecha_pago DATETIME;
DECLARE @importe DECIMAL(12, 2);
DECLARE @moneda INT;
DECLARE @cantidad_cuotas INT;
DECLARE @nro_tarjeta VARCHAR(50);
DECLARE @fecha_movimiento DATETIME;
DECLARE @nro_autorizacion VARCHAR(50);
DECLARE @nro_cupon VARCHAR(50);
DECLARE @cargos_marca_por_movimiento DECIMAL(12, 2);
DECLARE @signo_cargos_marca_por_movimiento VARCHAR(1);
DECLARE @nro_agrupador_boton VARCHAR(50);
DECLARE @ID_PASO_PROCESO INT;
DECLARE @id_conciliacion INT;
DECLARE @id_disputa BIT = NULL;
DECLARE @id_conciliacion_manual INT;
DECLARE @msg VARCHAR(255) = NULL;
DECLARE @FeeAmount DECIMAL(12, 2);
DECLARE @TaxAmount DECIMAL(12, 2);
DECLARE @productidentification INT;
DECLARE @codigo_operacion VARCHAR(5);
DECLARE @id_motivo INT;

SET NOCOUNT ON;

BEGIN TRANSACTION;

BEGIN TRY
	SELECT @Estado = CouponStatus,
		@FeeAmount = FeeAmount,
		@TaxAmount = TaxAmount,
		@productidentification = Productidentification 
	FROM Transactions.dbo.transactions
	WHERE Id = @idTransaccion;

	SELECT @fecha_pago = mpm.fecha_pago, 
	       @codigo_operacion = co.codigo_operacion
	FROM Configurations.dbo.Movimiento_Presentado_MP mpm
	INNER JOIN Configurations.dbo.Codigo_operacion co ON mpm.id_codigo_operacion = co.id_codigo_operacion
	WHERE mpm.id_movimiento_mp = @id_movimiento_presentado;

	IF (@codigo_tipo = 'EFECTIVO')
	BEGIN
		UPDATE Transactions.dbo.transactions
		SET PaymentTimestamp = @fecha_pago,
			ReconciliationStatus = 1,
			ReconciliationTimestamp = GETDATE(),
			SyncStatus = 0,
			CouponStatus = 'ACREDITADO',
			TransactionStatus = 'TX_PROCESADA'
		WHERE Id = @idTransaccion;
	END
	ELSE
	BEGIN
		UPDATE Transactions.dbo.transactions
		SET PaymentTimestamp = @fecha_pago,
			ReconciliationStatus = 1,
			ReconciliationTimestamp = GETDATE(),
			SyncStatus = 0
		WHERE Id = @idTransaccion;

		SET @id_disputa = 0;
	END

	SET @flag_aceptada_marca = 1;
	SET @flag_conciliada = 1;

	SELECT @id_paso = ID_PASO_PROCESO
	FROM Configurations.dbo.LOG_PASO_PROCESO
	WHERE ID_LOG_PASO = @id_log_paso_padre;

	IF (@id_paso = 2)
		SET @flag_distribuida = 0;
	ELSE
		SET @flag_distribuida = 1;

	IF (
			@codigo_operacion = 'COM'
			AND @codigo_tipo = 'EFECTIVO'
			)
	BEGIN
		SET @flag_contracargo = 0;
		SET @flag_notificado = 0;
	END
	ELSE IF (@codigo_operacion = 'CON')
	BEGIN
		SET @flag_contracargo = 1;
		SET @flag_notificado = 1;
	END
	ELSE
	BEGIN
		SET @flag_contracargo = 0;
		SET @flag_notificado = 1;
	END

	SELECT @id_conciliacion = ISNULL(MAX([id_conciliacion]), 0) + 1
	FROM dbo.Conciliacion;

	INSERT INTO Configurations.dbo.Conciliacion (
		id_conciliacion,
		id_transaccion,
		id_log_paso,
		flag_aceptada_marca,
		flag_conciliada,
		flag_distribuida,
		flag_contracargo,
		id_movimiento_mp,
		flag_notificado,
		fecha_alta,
		usuario_alta,
		id_disputa,
		version
		)
	VALUES (
		@id_conciliacion,
		@idTransaccion,
		@id_log_paso_padre,
		@flag_aceptada_marca,
		@flag_conciliada,
		@flag_distribuida,
		@flag_contracargo,
		@id_movimiento_presentado,
		@flag_notificado,
		GETDATE(),
		@usuario,
		@id_disputa,
		0
		);

	IF (@ESTADO <> 'PENDIENTE' AND @codigo_tipo = 'EFECTIVO')
	BEGIN
	    SELECT @id_motivo = id_motivo_conciliacion_manual
		FROM Configurations.dbo.Motivo_Conciliacion_Manual
		WHERE codigo_motivo_conciliacion_manual = 'CM_00004';

		SELECT @importe = mpm.importe,
			@moneda = mpm.moneda,
			@cantidad_cuotas = mpm.cantidad_cuotas,
			@nro_tarjeta = mpm.nro_tarjeta,
			@fecha_movimiento = mpm.fecha_movimiento,
			@nro_autorizacion = mpm.nro_autorizacion,
			@nro_cupon = mpm.nro_cupon,
			@cargos_marca_por_movimiento = mpm.cargos_marca_por_movimiento,
			@signo_cargos_marca_por_movimiento = mpm.signo_cargos_marca_por_movimiento,
			@nro_agrupador_boton = mpm.nro_agrupador_boton,
			@fecha_pago = mpm.fecha_pago,
			@ID_PASO_PROCESO = lpp.ID_PASO_PROCESO
		FROM Configurations.dbo.Movimiento_Presentado_MP AS mpm,
			Configurations.dbo.LOG_PASO_PROCESO AS lpp
		WHERE mpm.id_movimiento_mp = @id_movimiento_presentado
			AND lpp.ID_LOG_PASO = @id_log_paso_padre

		SELECT @id_conciliacion_manual = ISNULL(MAX([id_conciliacion_manual]), 0) + 1
		FROM Configurations.dbo.Conciliacion_manual;

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
			@idTransaccion,
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
			@id_log_paso_padre,
			GETDATE(),
			@usuario,
			@flag_aceptada_marca,
			@flag_contracargo,
			0,
			0,
			@TaxAmount,
			@FeeAmount,
			@id_movimiento_presentado,
			0,
			@id_motivo
			)
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
