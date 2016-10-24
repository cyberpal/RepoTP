
CREATE PROCEDURE [dbo].[Insertar_Conciliacion_Manual] (
	@id_movimiento_mp INT = NULL,
	@usuario_alta VARCHAR(20) = NULL,
	@id_log_paso INT = NULL
)            
AS

SET NOCOUNT ON;

DECLARE @msg VARCHAR(255) = NULL;
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
DECLARE @flag_contracargo BIT = NULL;
DECLARE	@fecha_pago DATETIME = NULL;
DECLARE	@cargos_marca_por_movimiento DECIMAL(12, 2) = NULL;
DECLARE	@signo_cargos_marca_por_movimiento VARCHAR(1) = NULL


BEGIN TRANSACTION;

BEGIN TRY

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
       @flag_contracargo = c.flag_contracargo
    FROM Movimiento_presentado_mp mp
    INNER JOIN Conciliacion c ON c.id_movimiento_mp = mp.id_movimiento_mp
    WHERE mp.id_movimiento_mp = @id_movimiento_mp


	IF(NOT EXISTS(SELECT 1 FROM Conciliacion_Manual WHERE id_transaccion = @id_transaccion))
	BEGIN
	
		SELECT @id_conciliacion_manual = ISNULL(MAX(id_conciliacion_manual), 0) + 1
		FROM [dbo].[Conciliacion_Manual];

		INSERT INTO [dbo].[Conciliacion_Manual]
			   ([id_conciliacion_manual]
			   ,[id_transaccion]
			   ,[importe]
			   ,[moneda]
			   ,[cantidad_cuotas]
			   ,[nro_tarjeta]
			   ,[fecha_movimiento]
			   ,[nro_autorizacion]
			   ,[nro_cupon]
			   ,[nro_agrupador_boton]
			   ,[flag_aceptada_marca]
			   ,[flag_contracargo]
			   ,[flag_conciliado_manual]
			   ,[flag_procesado]
			   ,[fecha_alta]
			   ,[usuario_alta]
			   ,[version]
			   ,[cargos_boton_por_movimiento]
			   ,[impuestos_boton_por_movimiento]
			   ,[cargos_marca_por_movimiento]
			   ,[fecha_pago]
			   ,[id_log_paso]
			   ,[signo_cargos_marca_por_movimiento]
			   ,[id_movimiento_mp])
		 VALUES
			   (@id_conciliacion_manual
			   ,@id_transaccion
			   ,@importe
			   ,@moneda
			   ,@cantidad_cuotas
			   ,@nro_tarjeta
			   ,@fecha_movimiento
			   ,@nro_autorizacion
			   ,@nro_cupon
			   ,@nro_agrupador_boton
			   ,@flag_aceptada_marca
			   ,@flag_contracargo
			   ,0
			   ,1
			   ,GETDATE()
			   ,@usuario_alta
			   ,0
			   ,0
			   ,0
			   ,@cargos_marca_por_movimiento
			   ,@fecha_pago
			   ,@id_log_paso
			   ,@signo_cargos_marca_por_movimiento
			   ,@id_movimiento_mp
			   );	  
	END
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	SELECT @msg  = ERROR_MESSAGE(), @id_log_paso = NULL;
	THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN 1;
