
CREATE PROCEDURE [dbo].[Batch_Liq_PC_Control_Bonificacion_Disponible] (
  @fecha_proceso datetime
 ,@Usuario varchar(20)
 ,@id_log_proceso INT
 ,@Total_Cuentas_Bonificadas INT OUTPUT
 )
AS

DECLARE @ret_code INT;
--DECLARE @flag_ok INT;

declare @i INt
declare @id_cuenta int
declare @cuentas_Bonificadas_OK int = 0
declare @Cuenta_Control_Liquidacion int;
declare @importe_Bonificacion decimal (12,2)
declare @fecha_Alta_Bonificacion datetime
declare @fecha_Liberacion_Bonificacion datetime


DECLARE @Cuentas_Bonificadas table(
 id INT PRIMARY KEY IDENTITY(1, 1)
,id_cuenta INT null
,importe_bonificacion decimal (12,2)
,fecha_alta datetime
,fecha_liberacion datetime  )


BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
			insert into @Cuentas_Bonificadas (id_cuenta, importe_bonificacion, fecha_alta, fecha_liberacion)
			select id_cuenta, importe_bonificacion, fecha_alta, fecha_liberacion  from dbo.Bonificacion
			where flag_afectacion_saldo = 1
			and fecha_afectacion_saldo = @fecha_proceso

			set @Total_Cuentas_Bonificadas = @@rowcount

			SET @i = 1;

			WHILE (@i <= @Total_Cuentas_Bonificadas)
				BEGIN

					select @id_cuenta = id_cuenta
					,@importe_Bonificacion = importe_bonificacion
					,@fecha_Alta_Bonificacion = fecha_alta
					,@fecha_Liberacion_Bonificacion = fecha_liberacion
					from @Cuentas_Bonificadas
					where id = @i
					
					select @Cuenta_Control_Liquidacion = count(1) from Control_Liquidacion_Disponible 
					where id_cuenta = @id_cuenta 
					and id_codigo_operacion = 8

						if @Cuenta_Control_Liquidacion > 0
							begin
								update Control_Liquidacion_Disponible
								set Fecha_Base_de_Cashout = @fecha_Alta_Bonificacion
									,fecha_de_cashout = @fecha_Liberacion_Bonificacion
									,importe = importe + @importe_Bonificacion
								where id_cuenta = @id_cuenta 
								and id_codigo_operacion = 8
							end
						else
							begin
								Insert into Control_Liquidacion_Disponible
								(fecha_base_de_cashout,fecha_de_cashout,id_cuenta, id_codigo_operacion,importe)
								values
								(@fecha_Alta_Bonificacion,@fecha_Liberacion_Bonificacion,@id_cuenta,8,@importe_Bonificacion)
							end

							set @cuentas_Bonificadas_OK = @cuentas_Bonificadas_OK + 1
								
							--end

						set @i = @i + 1

					END	

					set @Total_Cuentas_Bonificadas = @cuentas_Bonificadas_OK

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END
