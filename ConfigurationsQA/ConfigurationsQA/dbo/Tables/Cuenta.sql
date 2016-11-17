CREATE TABLE [dbo].[Cuenta] (
    [id_cuenta]                    INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_cuenta]               INT          NOT NULL,
    [denominacion1]                VARCHAR (50) NOT NULL,
    [denominacion2]                VARCHAR (50) NOT NULL,
    [id_tipo_identificacion]       INT          NULL,
    [numero_identificacion]        VARCHAR (20) NULL,
    [numero_CUIT]                  VARCHAR (11) NULL,
    [sexo]                         VARCHAR (1)  NULL,
    [id_nacionalidad]              INT          NULL,
    [fecha_nacimiento]             DATETIME     NULL,
    [id_canal]                     INT          NOT NULL,
    [id_estado_cuenta]             INT          NOT NULL,
    [id_version_tyc]               INT          NULL,
    [flag_envio_novedades]         BIT          NULL,
    [fecha_alta]                   DATETIME     NULL,
    [usuario_alta]                 VARCHAR (20) NULL,
    [fecha_modificacion]           DATETIME     NULL,
    [usuario_modificacion]         VARCHAR (20) NULL,
    [fecha_baja]                   DATETIME     NULL,
    [usuario_baja]                 VARCHAR (20) NULL,
    [version]                      INT          CONSTRAINT [DF_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [telefono_movil]               VARCHAR (10) NULL,
    [telefono_fijo]                VARCHAR (10) NULL,
    [flag_cambio_pendiente]        BIT          DEFAULT ((0)) NULL,
    [flag_informado_a_facturacion] BIT          CONSTRAINT [DF_Cuenta_flag_informado_a_facturacion] DEFAULT ((0)) NULL,
    [id_operador_celular]          INT          NULL,
    [id_banco_adhesion]            INT          NULL,
    [flag_factor_validacion]       BIT          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Cuenta] PRIMARY KEY CLUSTERED ([id_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cuenta_Canal_Adhesion] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [FK_Cuenta_Estado] FOREIGN KEY ([id_estado_cuenta]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Cuenta_id_banco_adhesion] FOREIGN KEY ([id_banco_adhesion]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Cuenta_id_operador_celular] FOREIGN KEY ([id_operador_celular]) REFERENCES [dbo].[Operador_Celular] ([id_operador_celular]),
    CONSTRAINT [FK_Cuenta_Nacionalidad] FOREIGN KEY ([id_nacionalidad]) REFERENCES [dbo].[Nacionalidad] ([id_nacionalidad]),
    CONSTRAINT [FK_Cuenta_Tipo_id_tipo_cuenta] FOREIGN KEY ([id_tipo_cuenta]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Cuenta_Tipo_id_tipo_identificacion] FOREIGN KEY ([id_tipo_identificacion]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Cuenta_TyC] FOREIGN KEY ([id_version_tyc]) REFERENCES [dbo].[TyC] ([id_version])
);








GO
CREATE NONCLUSTERED INDEX [IX_id_tipo_cuenta]
    ON [dbo].[Cuenta]([id_tipo_cuenta] ASC) WITH (FILLFACTOR = 95);


GO

CREATE TRIGGER [dbo].[CREATE_API_KEY] ON [dbo].[Cuenta] FOR INSERT
AS 
BEGIN
	DECLARE @PRISMA VARCHAR(9) = 'TODOPAGO ';
	DECLARE @AUTO_GENERATE VARCHAR(46) = (SELECT CONVERT(VARCHAR(46), NEWID()));
	DECLARE @ID_CUENTA INT = (SELECT ID_CUENTA FROM INSERTED);	
	DECLARE @API_KEY VARCHAR(46) = (SELECT @PRISMA + CONVERT(VARCHAR(46), HashBytes('MD5', @AUTO_GENERATE), 2) AS 'API_KEY');
		
	WHILE (SELECT COUNT(*) FROM PARAMETRO_CUENTA WHERE API_KEY = @API_KEY) > 0	
	BEGIN
		set @AUTO_GENERATE = (SELECT CONVERT(VARCHAR(46), NEWID()));
		set @API_KEY = (SELECT @PRISMA + CONVERT(VARCHAR(46), HashBytes('MD5', @AUTO_GENERATE), 2) AS 'API_KEY');
	CONTINUE
	END

	BEGIN TRAN
	IF (SELECT 0 FROM PARAMETRO_CUENTA WHERE id_cuenta = @ID_CUENTA) = 0
		UPDATE configurations.dbo.PARAMETRO_CUENTA SET API_KEY = @API_KEY, FECHA_MODIFICACION = GETDATE(), USUARIO_MODIFICACION = 'trigger_api_key' WHERE ID_CUENTA = @ID_CUENTA;
	ELSE
		INSERT INTO configurations.dbo.PARAMETRO_CUENTA (ID_CUENTA,FLAG_REPORTE_COMERCIO,FECHA_ALTA,USUARIO_ALTA,FECHA_MODIFICACION,USUARIO_MODIFICACION,
		FECHA_BAJA,USUARIO_BAJA,VERSION,API_KEY) VALUES (@ID_CUENTA,0,GETDATE(),'trigger_api_key',NULL,NULL,NULL,NULL,0,@API_KEY);
	COMMIT TRAN
END

GO

CREATE TRIGGER [Insert_History_Estado_Cuenta] ON dbo.Cuenta
	FOR UPDATE AS
	BEGIN						
		IF EXISTS (select * from deleted) AND EXISTS (select * from inserted)		
		BEGIN
			DECLARE @envio_mail INT;
			SET @envio_mail = (SELECT 1 FROM inserted i,deleted d where d.id_estado_cuenta = 4 and i.id_estado_cuenta in (5,6,7,8));

			IF @envio_mail = 1
				BEGIN
					INSERT INTO dbo.Hist_Estado_Cuenta (id_cuenta,id_tipo_cuenta,denominacion1,denominacion2,id_tipo_identificacion,numero_identificacion,numero_CUIT,sexo,id_nacionalidad,fecha_nacimiento,id_canal,id_estado_cuenta,id_version_tyc,flag_envio_novedades,fecha_alta,usuario_alta,fecha_modificacion,usuario_modificacion,fecha_baja,usuario_baja,version,telefono_movil,telefono_fijo,flag_cambio_pendiente,flag_informado_a_facturacion,id_operador_celular,id_banco_adhesion,flag_factor_validacion, flag_envio_mail)
					SELECT id_cuenta,id_tipo_cuenta,denominacion1,denominacion2,id_tipo_identificacion,numero_identificacion,numero_CUIT,sexo,id_nacionalidad,fecha_nacimiento,id_canal,id_estado_cuenta,id_version_tyc,flag_envio_novedades,fecha_modificacion,usuario_modificacion,NULL,NULL,fecha_baja,usuario_baja,version,telefono_movil,telefono_fijo,flag_cambio_pendiente,flag_informado_a_facturacion,id_operador_celular,id_banco_adhesion,flag_factor_validacion,0 FROM deleted;
				END
			ELSE
				BEGIN
					INSERT INTO dbo.Hist_Estado_Cuenta (id_cuenta,id_tipo_cuenta,denominacion1,denominacion2,id_tipo_identificacion,numero_identificacion,numero_CUIT,sexo,id_nacionalidad,fecha_nacimiento,id_canal,id_estado_cuenta,id_version_tyc,flag_envio_novedades,fecha_alta,usuario_alta,fecha_modificacion,usuario_modificacion,fecha_baja,usuario_baja,version,telefono_movil,telefono_fijo,flag_cambio_pendiente,flag_informado_a_facturacion,id_operador_celular,id_banco_adhesion,flag_factor_validacion, flag_envio_mail)
					SELECT id_cuenta,id_tipo_cuenta,denominacion1,denominacion2,id_tipo_identificacion,numero_identificacion,numero_CUIT,sexo,id_nacionalidad,fecha_nacimiento,id_canal,id_estado_cuenta,id_version_tyc,flag_envio_novedades,fecha_modificacion,usuario_modificacion,NULL,NULL,fecha_baja,usuario_baja,version,telefono_movil,telefono_fijo,flag_cambio_pendiente,flag_informado_a_facturacion,id_operador_celular,id_banco_adhesion,flag_factor_validacion,2 FROM deleted;
				END
			END
	END

GO

