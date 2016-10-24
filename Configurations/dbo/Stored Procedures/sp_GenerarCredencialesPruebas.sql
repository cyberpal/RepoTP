CREATE PROCEDURE [dbo].[sp_GenerarCredencialesPruebas] ( 
		@idCuenta int,
		@idTipoCuenta int,
		@mail varchar(50),
		@clave varchar(50),
		@idPreguntaSeguridad int,
		@respuestaPreguntaSeguridad varchar(50),
		@apiKeyPruebas varchar(64)
)

AS 

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @idCuentaTmp int
	DECLARE @idTipoIdentificacion int
	DECLARE @numeroIdentificacion varchar(20)
	DECLARE @numeroCuit varchar(11)
	DECLARE @idDomicilioFacturacion int
	DECLARE @idParametroCuenta int


BEGIN TRY

	-- Validamos todos los parametros de entrada, menos idCuenta que puede ser NULL.

	IF (@idTipoCuenta IS NULL)
		THROW 51000, 'El parametro idTipoCuenta es NULL.', 1;

	IF (@mail IS NULL)
		THROW 51000, 'El parametro mail es NULL.', 1;

	IF (@clave IS NULL)
		THROW 51000, 'El parametro clave es NULL.', 1;

	IF (@idPreguntaSeguridad IS NULL)
		THROW 51000, 'El parametro idPreguntaSeguridad es NULL.', 1;

	IF (@respuestaPreguntaSeguridad IS NULL)
		THROW 51000, 'El parametro respuestaPreguntaSeguridad es NULL.', 1;

	IF (@apiKeyPruebas IS NULL)
		THROW 51000, 'El parametro apiKeyPruebas es NULL.', 1;

	IF (@idTipoCuenta NOT IN (27,28,29))
		THROW 51000, 'El parametro idTipoCuenta no es valido.', 1;

	
	-- Inicializamos algunas variables segun idTipoCuenta.

	IF (@idTipoCuenta = 27)
		BEGIN
			SET @idTipoIdentificacion = 21
			SET @numeroIdentificacion = '12345678'
			SET @numeroCuit = NULL
		END
	ELSE IF (@idTipoCuenta = 28)
		BEGIN
			SET @idTipoIdentificacion = 21
			SET @numeroIdentificacion = '12345678'
			SET @numeroCuit = '20123456784'
		END
	ELSE IF (@idTipoCuenta = 29)
		BEGIN
			SET @idTipoIdentificacion = NULL
			SET @numeroIdentificacion = NULL
			SET @numeroCuit = '30123456789'
		END
	

	
	BEGIN TRANSACTION

	-- Verificamos si existe el mail buscando el id_cuenta asociado

	SELECT @idCuentaTmp = id_cuenta FROM Usuario_Cuenta WHERE eMail = @mail
			
	
	-- Si existe la cuenta para el mail que viene por parametros, entonces
	-- actualizamos la columna "api_key" de la tabla "Parametro_Cuenta"

	IF (@idCuentaTmp IS NOT NULL) 
		BEGIN
			UPDATE Parametro_Cuenta
				SET api_key = @apiKeyPruebas, 
					api_key_pruebas = @apiKeyPruebas,
					fecha_modificacion = GETDATE(), 
					usuario_modificacion = 'API_Key_SP'
			WHERE id_cuenta = @idCuentaTmp
		END

	
	-- Si no existe la cuenta para el mail que viene por parametros, entonces 
	-- generamos toda la estructura de datos.
	
	IF (@idCuentaTmp IS NULL) 
		BEGIN

			-- Realizamos inserciones en Cuenta, Contacto_Cuenta, Cuenta_Virtual, Domicilio_Cuenta, 
			-- Situacion_Fiscal_Cuenta, Usuario_Cuenta, Parametro_Cuenta

			INSERT INTO Cuenta  ( id_tipo_cuenta,    denominacion1,    denominacion2, id_tipo_identificacion, numero_identificacion, numero_CUIT, sexo, id_nacionalidad, fecha_nacimiento, id_canal, id_estado_cuenta, id_version_tyc, flag_envio_novedades, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version, telefono_movil, telefono_fijo, flag_cambio_pendiente, flag_informado_a_facturacion, id_operador_celular, id_banco_adhesion, flag_factor_validacion)
						VALUES  (  @idTipoCuenta, 'Prueba Empresa', 'Prueba Empresa',  @idTipoIdentificacion, @numeroIdentificacion, @numeroCuit, NULL,            NULL,             NULL,        1,                4,              1,                    1,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0,   '1134567890',  '1144891088',                     0,                            0,                   3,              NULL,                   NULL)

			SET @idCuentaTmp = SCOPE_IDENTITY() -- Obtengo el nuevo id de la cuenta que acabo de insertar.

			INSERT INTO Contacto_Cuenta (    id_cuenta, nombre_contacto, apellido_contacto, telefono_movil, id_tipo_identificacion, numero_identificacion, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version, id_operador_celular)
								VALUES  (@idCuentaTmp,          'Juan',           'Perez',   '1145678901',                     21,            '23456789',  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0,                   3)

			INSERT INTO Cuenta_Virtual (    id_cuenta, saldo_en_cuenta, saldo_en_revision, disponible, id_proceso_modificacion, id_tipo_cashout, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version)
								VALUES ( @idCuentaTmp,            0.00,              0.00,       0.00,                    NULL,              62,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0)

			INSERT INTO Domicilio_Cuenta ( id_tipo_domicilio,    id_cuenta,   calle, numero, piso, departamento, id_localidad, id_provincia, codigo_postal, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version, flag_vigente)
								 VALUES  (                30, @idCuentaTmp, 'Calle', '1234', NULL,         NULL,           11,            1,        '1010',  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0,            0)

			INSERT INTO Domicilio_Cuenta ( id_tipo_domicilio,    id_cuenta,   calle, numero, piso, departamento, id_localidad, id_provincia, codigo_postal, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version, flag_vigente)
								 VALUES  (                31, @idCuentaTmp, 'Calle', '1234', NULL,         NULL,           11,            1,        '1010',  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0,            1)

			SET @idDomicilioFacturacion = SCOPE_IDENTITY()

			IF (@idTipoCuenta = 27)
				BEGIN
					INSERT INTO Situacion_Fiscal_Cuenta (    id_cuenta, numero_CUIT,        razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB)
												 VALUES ( @idCuentaTmp, @numeroCuit, 'Prueba Particular',  @idDomicilioFacturacion,                     1,                     NULL,                      NULL,                   NULL,                      NULL,                       NULL,                      20,             NULL,            1,                  NULL,               NULL,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,             NULL,              NULL,       0,                         0,                 NULL)
				END

			IF (@idTipoCuenta = 28)
				BEGIN
					INSERT INTO Situacion_Fiscal_Cuenta (    id_cuenta, numero_CUIT,  razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB)
												 VALUES ( @idCuentaTmp, @numeroCuit, 'Prueba Prof',  @idDomicilioFacturacion,                     1,                     NULL,                      NULL,                   NULL,                      NULL,                       NULL,                      20,             NULL,            0,                  NULL,               NULL,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,             NULL,              NULL,       0,                         0,                 NULL)

					INSERT INTO Situacion_Fiscal_Cuenta (    id_cuenta, numero_CUIT,  razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB)
												 VALUES ( @idCuentaTmp, @numeroCuit, 'Prueba Prof',  @idDomicilioFacturacion,                     4,                     NULL,                      NULL,                     10,                      NULL,                       NULL,                      17,             NULL,            1,             GETDATE(),               NULL,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,        GETDATE(),      'API_Key_SP',       0,                         1,                 NULL)
				END

			IF (@idTipoCuenta = 29)
				BEGIN
					INSERT INTO Situacion_Fiscal_Cuenta (    id_cuenta,   numero_CUIT,     razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB)
												 VALUES ( @idCuentaTmp,   @numeroCuit, 'Prueba Empresa',  @idDomicilioFacturacion,                     4,                     NULL,                      NULL,                     10,                      NULL,                       NULL,                      17,             NULL,            1,             GETDATE(),               NULL,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,        GETDATE(),      'API_Key_SP',       0,                         1,                 NULL)
				END


			INSERT INTO Usuario_Cuenta (    id_cuenta, eMail, mail_confirmado, id_pregunta_seguridad, respuesta_pregunta_seguridad, password, ultimas_password, password_bloqueada, intentos_login, ultima_modificacion_password, fecha_ultimo_login, ip_ultimo_login, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version, id_estado_mail,perfil, id_perfil, id_tipo_usuario)
								VALUES ( @idCuentaTmp, @mail,               1,  @idPreguntaSeguridad,  @respuestaPreguntaSeguridad,   @clave,             NULL,                  0,              0,                         NULL,               NULL,            NULL,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0,           NULL,  NULL, 3        , 110)


			-- Tenemos que generar un registro en Parametro_Cuenta para almacenar la APIKey.
			-- Primero verificamos si existe el registro insertado en Parametro_Cuenta para ver si realizamos un update o un insert.
			-- Esto es porque cuando se crea la Cuenta hay un trigger asociado que genera el APIKey en la tabla Parametro_Cuenta.

			SELECT @idParametroCuenta = id_parametro_cuenta FROM Parametro_Cuenta WHERE id_cuenta = @idCuentaTmp

			IF (@idParametroCuenta IS NULL) 
				BEGIN
					INSERT INTO Parametro_Cuenta (    id_cuenta, flag_reporte_comercio, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, version,        api_key, api_key_pruebas, id_cuenta_pruebas)
										  VALUES ( @idCuentaTmp,                     0,  GETDATE(), 'API_Key_SP',               NULL,                 NULL,       NULL,         NULL,       0, @apiKeyPruebas,  @apiKeyPruebas, @idCuentaTmp)
				END
			ELSE
				BEGIN
					UPDATE Parametro_Cuenta SET  fecha_modificacion = GETDATE() ,usuario_modificacion = 'API_Key_SP' ,api_key = @apiKeyPruebas ,api_key_pruebas = @apiKeyPruebas WHERE id_parametro_cuenta = @idParametroCuenta
				END


		END

		SELECT @idCuentaTmp AS id_cuenta, '00000' as status
		
		COMMIT TRANSACTION

END TRY

BEGIN CATCH
	
	PRINT ERROR_MESSAGE();
	
	IF (@@TRANCOUNT != 0)
		ROLLBACK TRANSACTION
    
	SELECT @idCuentaTmp AS id_cuenta, '2106' as status

END CATCH;

END