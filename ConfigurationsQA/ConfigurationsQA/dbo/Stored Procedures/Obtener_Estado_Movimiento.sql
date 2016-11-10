
CREATE PROCEDURE [dbo].[Obtener_Estado_Movimiento] (
                @id_medio_pago INT = NULL,
                @campo_mp_1 VARCHAR(10) = NULL,
                @valor_1 VARCHAR(15) = NULL,
                @campo_mp_2 VARCHAR(10) = NULL,
                @valor_2 VARCHAR(15) = NULL,
                @campo_mp_3 VARCHAR(10) = NULL,
                @valor_3 VARCHAR(15) = NULL
)            
AS

SET NOCOUNT ON;

DECLARE @estado_movimiento VARCHAR(1) = NULL;
DECLARE @msg VARCHAR(255) = NULL;

BEGIN TRANSACTION;

BEGIN TRY

                IF(@id_medio_pago IN (14, 30, 42))
                BEGIN

                   SELECT estado_movimiento FROM estado_movimiento_mp
                   WHERE id_medio_pago = @id_medio_pago
                   AND campo_mp_1 = @campo_mp_1
                   AND valor_1 = @valor_1
                END

                ELSE
                  SELECT estado_movimiento FROM estado_movimiento_mp
                   WHERE id_medio_pago = @id_medio_pago
                   AND campo_mp_1 = @campo_mp_1
                   AND valor_1 = @valor_1
                   AND campo_mp_2 = @campo_mp_2
                   AND valor_2 = @valor_2

END TRY

BEGIN CATCH
                ROLLBACK TRANSACTION;
                SELECT @msg  = ERROR_MESSAGE();
                THROW  51000, @msg, 1;
END CATCH;

COMMIT TRANSACTION;

RETURN @estado_movimiento;


