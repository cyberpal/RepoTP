CREATE TABLE [dbo].[Mail_Notificacion] (
    [id]                   INT          NOT NULL,
    [id_notificacion]      INT          NOT NULL,
    [mail_destino]         VARCHAR (50) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Mail_Notificacion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Mail_Notificacion] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Mail_Notificacion_Notificacion] FOREIGN KEY ([id_notificacion]) REFERENCES [dbo].[Notificacion] ([id_notificacion])
);

