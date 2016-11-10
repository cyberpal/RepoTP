
CREATE PROCEDURE [dbo].[Batch_Concil_Movimientos_Conciliacion_Manual] (
	@flag_aceptada_marca BIT,
	@id_conciliacion_manual INT,
	@id_movimiento_mp INT,
	@usuario VARCHAR(20),
	@id_log_paso INT,
	@id_transaccion VARCHAR(36)
	)
AS

DECLARE @codigo_tipo VARCHAR(20);


BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		-- Obtener Codigo --
        SELECT
	      @codigo_tipo = tmp.codigo
        FROM
	      Configurations.dbo.Movimiento_Presentado_MP mpp 
	      INNER JOIN Configurations.dbo.Medio_De_Pago mdp 
		             ON mpp.id_medio_pago = mdp.id_medio_pago
	      INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp 
		             ON tmp.id_tipo_medio_pago = mdp.id_tipo_medio_pago
          WHERE mpp.id_movimiento_mp = @id_movimiento_mp


        -- Es aceptada o rechazada --
		IF(@flag_aceptada_marca = 1)
		   EXEC Configurations.dbo.Batch_Concil_Actualizar_Cupones
		        @id_transaccion,
				@id_log_paso,
				@usuario,
				@id_movimiento_mp,
				@codigo_tipo;
        ELSE
		   EXEC Configurations.dbo.Batch_Concil_Movimiento_Rechazado 
		        @id_movimiento_mp,
				@id_transaccion,
		        @id_log_paso,
				@usuario;

        -- Actualizar Conciliacion Manual--
		UPDATE
		   Configurations.dbo.Conciliacion_Manual
        SET flag_procesado = 1
        WHERE id_conciliacion_manual = @id_conciliacion_manual;
		
		-- Actualizar Conciliacion --
		UPDATE
		   Configurations.dbo.Conciliacion
        SET id_conciliacion_manual = @id_conciliacion_manual
        WHERE id_movimiento_mp = @id_movimiento_mp;
		

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
