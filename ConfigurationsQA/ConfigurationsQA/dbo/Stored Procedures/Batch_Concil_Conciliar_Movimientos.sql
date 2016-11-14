
CREATE PROCEDURE [dbo].[Batch_Concil_Conciliar_Movimientos] (
    @estado_movimiento VARCHAR(1),
	@id_transaccion VARCHAR(36),
	@id_log_paso INT,
	@usuario VARCHAR(20),
    @id_movimiento_mp INT,
    @codigo_tipo_mp VARCHAR(20)
	)
AS

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

        -- Es aceptada o rechazada --
		IF(@codigo_tipo_mp = 'EFECTIVO' OR @estado_movimiento = 'A')
		   EXEC Configurations.dbo.Batch_Concil_Actualizar_Cupones
		        @id_transaccion,
				@id_log_paso,
				@usuario,
				@id_movimiento_mp,
				@codigo_tipo_mp;
        ELSE
		   EXEC Configurations.dbo.Batch_Concil_Movimiento_Rechazado 
		        @id_movimiento_mp,
				@id_transaccion,
		        @id_log_paso,
				@usuario;

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
