CREATE TABLE [dbo].[Notificacion_Enviada] (
    [id_notificacion_enviada] INT           IDENTITY (1, 1) NOT NULL,
    [id_notificacion]         INT           NOT NULL,
    [id_cuenta]               INT           NULL,
    [fecha_envio]             DATETIME      NOT NULL,
    [mail_destino]            VARCHAR (50)  NOT NULL,
    [mensaje]                 VARCHAR (MAX) NOT NULL,
    [hash]                    VARCHAR (512) NULL,
    [flag_leido]              BIT           CONSTRAINT [DF_Notificacion_Enviada_flag_leido] DEFAULT ((0)) NOT NULL,
    [operacion_asociada]      VARCHAR (100) NULL,
    [fecha_alta]              DATETIME      NULL,
    [usuario_alta]            VARCHAR (20)  NULL,
    [fecha_modificacion]      DATETIME      NULL,
    [usuario_modificacion]    VARCHAR (20)  NULL,
    [fecha_baja]              DATETIME      NULL,
    [usuario_baja]            VARCHAR (20)  NULL,
    [version]                 INT           CONSTRAINT [DF_Notificacion_Enviada_version] DEFAULT ((0)) NOT NULL,
    [flag_enviado]            BIT           NULL,
    CONSTRAINT [PK_Notificacion_Enviada] PRIMARY KEY CLUSTERED ([id_notificacion_enviada] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Notificacion_Enviada_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Notificacion_Enviada_Notificacion] FOREIGN KEY ([id_notificacion]) REFERENCES [dbo].[Notificacion] ([id_notificacion])
);


GO
CREATE NONCLUSTERED INDEX [IX_Notificacion_Enviada_Hash]
    ON [dbo].[Notificacion_Enviada]([hash] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Notificacion_Enviada_id_cuenta]
    ON [dbo].[Notificacion_Enviada]([id_cuenta] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Notificacion_Enviada_id_notificacion]
    ON [dbo].[Notificacion_Enviada]([id_notificacion] ASC) WITH (FILLFACTOR = 95);

