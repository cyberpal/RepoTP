
CREATE PROCEDURE [dbo].[Batch_Liq_PC_Afectacion_Saldo_Cuenta] (
  @fecha_proceso datetime
 ,@Usuario varchar(20)
 ,@id_log_proceso INT
 ,@Total_Cuentas_a_Bonificar INT OUTPUT
 )
AS

DECLARE @ret_code INT;
DECLARE @flag_ok INT;
--declare @Total_Cuentas_a_Bonificar Int
declare @i INt
declare @id_cuenta int
declare @id_tipo_movimiento INT
declare @id_tipo_origen_movimiento INT
declare @importe_Bonificacion decimal (12,2)
declare @cuentas_Bonificadas INT = 0
declare @Cuenta_Control_Liquidacion int;
declare @fecha_Alta_Bonificacion datetime
declare @fecha_Liberacion_Bonificacion datetime



DECLARE @Cuentas_a_Bonificar table(
 id INT PRIMARY KEY IDENTITY(1, 1)
,id_cuenta INT null
,importe_bonificacion decimal (12,2)
,fecha_alta datetime
,fecha_liberacion datetime )




BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
			select @id_tipo_movimiento = id_tipo 
			from tipo where codigo = 'MOV_CRED'

			select @id_tipo_origen_movimiento = id_tipo 
			from tipo where codigo = 'ORIG_PROCESO'

			insert into @Cuentas_a_Bonificar (id_cuenta, importe_bonificacion, fecha_alta, fecha_liberacion)
			select id_cuenta, importe_bonificacion, fecha_alta, fecha_liberacion 
			from Bonificacion
			where flag_afectacion_saldo = 0

			set @Total_Cuentas_a_Bonificar = @@rowcount

			SET @i = 1;

			WHILE (@i <= @Total_Cuentas_a_Bonificar)
				BEGIN
					select @id_cuenta = id_cuenta
					,@importe_Bonificacion = importe_bonificacion
					,@fecha_Alta_Bonificacion = fecha_alta
					,@fecha_Liberacion_Bonificacion = fecha_liberacion
					from @Cuentas_a_Bonificar
					where id = @i
              

					EXEC @flag_ok = Configurations.dbo.Actualizar_Cuenta_Virtual NULL,
						NULL,
						@importe_Bonificacion, --@saldo,
						NULL,
						NULL,
						NULL,
						@id_cuenta, -- bonificacion.id_cuenta
						@Usuario,
						@id_tipo_movimiento,
						@id_tipo_origen_movimiento,
						@id_log_proceso;

						IF (@flag_ok = 0)
						BEGIN
							PRINT '@i= ' + @i;
							PRINT 'Actualizar_Cuenta_Virtual - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
						END;

						IF (@flag_ok = 1)
							begin
								update Bonificacion
								set fecha_afectacion_saldo = cast(getDate() as DAte),--@fecha_proceso,
								flag_afectacion_saldo = 1
								where flag_afectacion_saldo = 0
								and id_cuenta = @id_cuenta

								set @cuentas_Bonificadas = @cuentas_Bonificadas + 1
								
							end

						set @i = @i + 1

					END	

					set @Total_Cuentas_a_Bonificar = @cuentas_Bonificadas

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END

