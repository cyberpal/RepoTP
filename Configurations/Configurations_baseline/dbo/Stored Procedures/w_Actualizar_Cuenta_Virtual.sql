CREATE PROCEDURE dbo.w_Actualizar_Cuenta_Virtual ( 
             @monto_disponible decimal (12,2) = NULL,
             @validacion_disponible decimal (12,2) = NULL,
             @monto_saldo_en_cuenta decimal (12,2) = NULL,
             @validacion_saldo_en_cuenta decimal (12,2) = NULL,
             @monto_saldo_en_revision decimal (12,2) = NULL,
             @validacion_saldo_en_revision decimal (12,2) = NULL,
             @id_cuenta int,
             @usuario_alta varchar (20) = NULL,
             @id_tipo_movimiento int,
             @id_tipo_origen_movimiento int,
             @id_log_proceso int = NULL
)            AS
BEGIN

	DECLARE @ret INTEGER;

    EXEC @ret = Actualizar_Cuenta_Virtual 
             @monto_disponible,
             @validacion_disponible,
             @monto_saldo_en_cuenta,
             @validacion_saldo_en_cuenta,
             @monto_saldo_en_revision,
             @validacion_saldo_en_revision,
             @id_cuenta,
             @usuario_alta,
             @id_tipo_movimiento,
             @id_tipo_origen_movimiento,
             @id_log_proceso;

    
  	SELECT @ret as RetCode;
  	
END