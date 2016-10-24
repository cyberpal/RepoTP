CREATE PROCEDURE dbo.Batch_Conciliacion_ResultadoWScontracargo(
	@id_log_paso INT,
	@idDisputa VARCHAR(20),
	@codigo VARCHAR(20),
	@id_movimiento_mp INT,
	@id_conciliacion INT,
	@id_transaccion VARCHAR(36)
)
AS
 
DECLARE @CodigoAux VARCHAR(6);
DECLARE @id_conciliacion_manual INT;

SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		SET @CodigoAux = RIGHT(@codigo, 5);

		IF(@CodigoAux = '00000')
		   BEGIN
		     UPDATE configurations.dbo.conciliacion 
             SET id_disputa = @idDisputa
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

		   SELECT @id_conciliacion_manual = ISNULL(MAX(id_conciliacion_manual), 0) + 1
		     FROM Configurations.dbo.Conciliacion_manual;


		   INSERT INTO Configurations.dbo.Conciliacion_Manual(
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
		        SELECT 
		               @id_conciliacion_manual,
					   @id_transaccion,
					   mp.importe,
					   mp.moneda,
					   mp.cantidad_cuotas,
					   mp.nro_tarjeta,
					   mp.fecha_movimiento,
					   mp.nro_autorizacion, 
                       mp.nro_cupon, 
                       mp.nro_agrupador_boton,
					   mp.cargos_marca_por_movimiento,
					   mp.signo_cargos_marca_por_movimiento,
                       mp.fecha_pago,
					   @id_log_paso,
					   GETDATE(),
					   'bpbatch',
                       c.flag_aceptada_marca,
					   1,
					   0,
					   0,
					   tc.TaxAmount,
					   tc.FeeAmount,
					   @id_movimiento_mp,
					   0,
					   mcm.id_motivo_conciliacion_manual
				  FROM Configurations.dbo.Movimiento_presentado_mp mp
            INNER JOIN Configurations.dbo.Conciliacion c 
			        ON c.id_movimiento_mp = mp.id_movimiento_mp
			INNER JOIN Configurations.dbo.Transacciones_Conciliacion_tmp tc 
			        ON tc.Id = c.id_transaccion
			INNER JOIN Configurations.dbo.Motivo_Conciliacion_Manual mcm
			        ON mcm.codigo_motivo_conciliacion_manual = @codigo
                 WHERE mp.id_movimiento_mp = @id_movimiento_mp;
	 
		 

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
