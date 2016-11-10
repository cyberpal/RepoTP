
CREATE PROCEDURE [dbo].[Batch_Liq_PC_ObtenerRegistros_Bonificaciones] (
@id_log_proceso INT,
@usuario VARCHAR(20),
@cant_Mails_A_Enviar INT OUTPUT
)

AS

DECLARE @ret_code INT;



--DECLARE @max_id_bonificacion INT

BEGIN
 SET NOCOUNT ON;

  BEGIN TRY
		
		DELETE from configurations.dbo.Promocion_Bonificacion_tmp
		WHERE flag_envio_mail=1
		AND fecha_envio_mail IS NOT NULL
		
		--SELECT @max_id_bonificacion= max(isnull(id_bonificacion,0)) from Configurations.dbo.Promocion_Bonificacion_tmp
		
		INSERT INTO configurations.dbo.Promocion_Bonificacion_tmp 
		(
			id_bonificacion,
			id_log_proceso,
			id_cuenta,
			eMail,
			monto,
			plazo_liberacion,
			fecha_desde,
			fecha_hasta,
			tope_maximo,
			fecha_alta,
			usuario_alta,
			id_promocion_comprador,
			cant_tope_bonificaciones,
			fecha_tope_transferencias
			)
		SELECT 
		    id_bonificacion, 
			@id_log_proceso,
			b.id_cuenta,
			uc.eMail,
			pc.valor,
			pc.plazo_liberacion,
			pc.fecha_inicio,
			pc.fecha_fin,
			pc.tope_maximo,
			getdate(),
			@usuario,
			b.id_promocion_comprador,
			pc.cant_tope_bonificaciones,
			case 
				when t.codigo = 'TOPE_CASHOUT_ANIO'
					then dateadd(yyyy,tope_retiro_dinero,pc.fecha_inicio)
				when t.codigo = 'TOPE_CASHOUT_MES'
					then dateadd(mm,tope_retiro_dinero,pc.fecha_inicio)
				when t.codigo = 'TOPE_CASHOUT_DIA'
					then dateadd(dd,tope_retiro_dinero,pc.fecha_inicio)
			end
		FROM Configurations.dbo.Bonificacion B
		inner join configurations.dbo.Usuario_Cuenta UC
		on b.id_cuenta = Uc.id_cuenta
		inner join Configurations.dbo.promocion_comprador pc
		on b.id_promocion_comprador=pc.id_promocion_comprador
		inner join tipo T
		on pc.unidad_tiempo_tope_retiro_dinero = t.id_tipo
		where ( Uc.fecha_baja is null or (Uc.fecha_alta <= getdate() and Uc.fecha_baja >= getdate()))
		and ( B.flag_envio_mail = 0 or B.flag_envio_mail is NULL)
		and B.fecha_envio_mail is null
		and NOT EXISTS (
					SELECT 1
					--FROM Configurations.dbo.Bonificacion bn
					FROM Promocion_Bonificacion_tmp tmp
					WHERE tmp.id_cuenta=b.id_cuenta
					AND tmp.id_promocion_comprador=b.id_promocion_comprador
					--AND tmp.flag_envio_mail=0 or tmp.flag_envio_mail is NULL
					--AND tmp.fecha_envio_mail is NULL
					);

		SET @cant_Mails_A_Enviar = @@ROWCOUNT;
		
 SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END


