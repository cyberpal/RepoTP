

CREATE PROCEDURE [dbo].[Batch_Liq_PC_Proc_Primera_Adhesion] (
 @id_promocion_comprador INT
 ,@id_tipo_aplicacion INT 
 ,@fecha_ult_proceso datetime
 ,@Usuario varchar(20)
 ,@Total_Medios_Pago_Validos INT = 0 OUTPUT
 )
AS
DECLARE @ret_code INT;
declare @fecha_inicio_promo datetime;
declare @fecha_fin_promo datetime;
declare @valor decimal(12,2);
--declare @plazo_liberacion int;
--declare @Total_Medios_Pago_Validos int;
declare @i INT;
declare @Id_Cuenta int; 
declare @fecha_Liberacion date;
declare @Bonificacion INt;
declare @Cantidad_Bonificacion Int
declare @id_Medio_Pago_Cuenta int;
declare @Cant_Insertados_Bonificacion int = 0;
declare @cant_tope_bonificaciones int
declare @acumulado_bonificaciones Int
declare @fecha_desde datetime
declare @plazo int
--declare @cashoutTimeStamp datetime
--declare @fecha_alta datetime


DECLARE @Medios_pago_validos table(
id_medio_pago_valido INT PRIMARY KEY IDENTITY(1, 1)
,id_cuenta INT null
,fecha_alta datetime null
,id_medio_pago_cuenta int null)

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY


		select @fecha_inicio_promo = fecha_inicio
		 ,@fecha_fin_promo = fecha_fin
		 ,@valor = valor
		 ,@plazo = plazo_liberacion
		 ,@cant_tope_bonificaciones = IsNull(cant_tope_bonificaciones,0)
		 ,@acumulado_bonificaciones = IsNull(acumulado_bonificaciones,0)
		 from Promocion_Comprador
		 where id_promocion_comprador = @id_promocion_comprador

		 if @acumulado_bonificaciones < @cant_tope_bonificaciones


		begin

 		insert into @Medios_pago_validos( id_cuenta,fecha_alta,id_medio_pago_cuenta)
		select MPC.id_cuenta, MPC.fecha_alta,id_medio_pago_cuenta
		from Configurations.dbo.Medio_Pago_Cuenta MPC
		inner join configurations.dbo.Cuenta Cta
		on  MPC.id_cuenta = Cta.id_cuenta
		where 
		--( fecha_alta > @fecha_ult_proceso or @fecha_ult_proceso is Null) 
		--and 
		( MPC.fecha_alta between @fecha_inicio_promo and @fecha_fin_promo )
		and ( id_estado_medio_pago = 39 or
		(id_estado_medio_pago = 42 and MPC.fecha_baja between @fecha_inicio_promo AND @fecha_fin_promo ))
		and Cta.id_estado_cuenta = 4

		set @Total_Medios_Pago_Validos = @@rowcount


	-- Verificar si hay que agregarlo tablas. Si existe no se hace nada, si no existe se agrega
			SET @i = 1;

			WHILE (@i <= @Total_Medios_Pago_Validos)
				begin
					select @Id_Cuenta = id_cuenta
					,@fecha_desde = fecha_alta
					,@id_Medio_Pago_Cuenta = id_medio_pago_cuenta
					from @Medios_pago_validos
					where id_medio_pago_valido = @i

					begin
					  WITH Dias_Habiles (
                                               dia_habil,
                                               nro_fila
                                               )
                               AS (
                                               SELECT CAST(fro.fecha AS DATE) AS dia_habil,
                                                               ROW_NUMBER() OVER (
                                                                               ORDER BY fro.fecha
                                                                               ) AS nro_fila
                                               FROM Configurations.dbo.Feriados fro
                                               WHERE fro.esFeriado = 0
                                                               AND fro.habilitado = 1
                                               )
                               SELECT @fecha_Liberacion = cast(DATETIMEFROMPARTS(DATEPART(yyyy, dia_habil), DATEPART(mm, dia_habil), DATEPART(dd, dia_habil), DATEPART(hh, @fecha_desde), DATEPART(mi, @fecha_desde), DATEPART(ss, @fecha_desde), DATEPART(ms, @fecha_desde)) as date)
                               FROM Dias_Habiles
                               WHERE nro_fila = (
                                                               SELECT TOP 1 nro_fila + @plazo
                                                               FROM Dias_Habiles
                                                               WHERE dia_habil <= CAST(@fecha_desde AS DATE)
                                                               ORDER BY dia_habil DESC
                                                               );
					end

					if not exists ( select 1  
									from Bonificacion
									where id_cuenta = @Id_Cuenta
									and id_promocion_comprador = @id_promocion_comprador )
						begin
							if @acumulado_bonificaciones < @cant_tope_bonificaciones
							begin
								insert into Bonificacion(id_promocion_comprador,id_cuenta,importe_bonificacion, fecha_liberacion,fecha_alta, usuario_alta)
								values
								(@id_promocion_comprador,@Id_Cuenta,@valor,@fecha_Liberacion,getdate(),@Usuario )

								set @Bonificacion = SCOPE_IDENTITY() --@@IDENTITY

								insert into Promocion_Primera_Adhesion(id_bonificacion,id_medio_pago_cuenta, fecha_alta, usuario_alta) values
								(@Bonificacion,@id_Medio_Pago_Cuenta,getdate(),@Usuario)

								set @Cant_Insertados_Bonificacion = @Cant_Insertados_Bonificacion + 1
								set @acumulado_bonificaciones = @acumulado_bonificaciones + 1
							end
						end
					SET @i += 1;

					update Promocion_Comprador
					set acumulado_bonificaciones = @acumulado_bonificaciones
					where id_promocion_comprador = @id_promocion_comprador

				end

				set @Total_Medios_Pago_Validos = @Cant_Insertados_Bonificacion
		end

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END
