CREATE TABLE [dbo].[Usuario_Cuenta] (
    [id_usuario_cuenta]            INT           IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                    INT           NULL,
    [eMail]                        VARCHAR (50)  NOT NULL,
    [mail_confirmado]              BIT           NULL,
    [id_pregunta_seguridad]        INT           NULL,
    [respuesta_pregunta_seguridad] VARCHAR (50)  NULL,
    [password]                     VARCHAR (50)  NULL,
    [ultimas_password]             VARCHAR (100) NULL,
    [password_bloqueada]           BIT           NOT NULL,
    [intentos_login]               INT           NOT NULL,
    [ultima_modificacion_password] DATETIME      NULL,
    [fecha_ultimo_login]           DATETIME      NULL,
    [ip_ultimo_login]              VARCHAR (20)  NULL,
    [fecha_alta]                   DATETIME      NULL,
    [usuario_alta]                 VARCHAR (20)  NULL,
    [fecha_modificacion]           DATETIME      NULL,
    [usuario_modificacion]         VARCHAR (20)  NULL,
    [fecha_baja]                   DATETIME      NULL,
    [usuario_baja]                 VARCHAR (20)  NULL,
    [version]                      INT           CONSTRAINT [DF_Usuario_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_estado_mail]               INT           NULL,
    [perfil]                       VARCHAR (20)  NULL,
    [fecha_ultimo_bloqueo]         DATETIME      NULL,
    [id_perfil]                    INT           DEFAULT (NULL) NULL,
    [id_tipo_usuario]              INT           DEFAULT (NULL) NULL,
    CONSTRAINT [PK_Usuario_Cuenta] PRIMARY KEY CLUSTERED ([id_usuario_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Usuario_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Usuario_Cuenta_id_estado_mail] FOREIGN KEY ([id_estado_mail]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Usuario_Cuenta_Pregunta_Seguridad] FOREIGN KEY ([id_pregunta_seguridad]) REFERENCES [dbo].[Pregunta_Seguridad] ([id_pregunta_seguridad]),
    CONSTRAINT [FK_UsuarioCuenta_Perfil] FOREIGN KEY ([id_perfil]) REFERENCES [dbo].[Perfil] ([id_perfil]),
    CONSTRAINT [FK_UsuarioCuenta_TipoUsuario] FOREIGN KEY ([id_tipo_usuario]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [IX_Usuario_Cuenta_id_cuenta]
    ON [dbo].[Usuario_Cuenta]([id_cuenta] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Usuario_Cuenta_id_pregunta_seguridad]
    ON [dbo].[Usuario_Cuenta]([id_pregunta_seguridad] ASC) WITH (FILLFACTOR = 95);

