CREATE TABLE [dbo].[Mail_Grupo_Notificacion_Cuenta] (
    [id]                    INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]             INT          NOT NULL,
    [id_grupo_notificacion] INT          NOT NULL,
    [mail_destino]          VARCHAR (50) NULL,
    [fecha_alta]            DATETIME     NULL,
    [usuario_alta]          VARCHAR (20) NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          CONSTRAINT [DF_Mail_Grupo_Notificacion_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Mail_Grupo_Notificacion_] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Mail_Grupo_Notificacion__Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Mail_Grupo_Notificacion__Grupo_Notificacion] FOREIGN KEY ([id_grupo_notificacion]) REFERENCES [dbo].[Grupo_Notificacion] ([id_grupo_notificacion])
);

