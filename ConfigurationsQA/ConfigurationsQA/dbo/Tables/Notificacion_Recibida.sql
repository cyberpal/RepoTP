CREATE TABLE [dbo].[Notificacion_Recibida] (
    [id_notificacion_recibida] INT           IDENTITY (1, 1) NOT NULL,
    [id_notificacion]          INT           NOT NULL,
    [id_cuenta]                INT           NULL,
    [nombre]                   VARCHAR (100) NOT NULL,
    [eMail]                    VARCHAR (50)  NOT NULL,
    [fecha_recepcion]          DATETIME      NOT NULL,
    [mensaje]                  VARCHAR (MAX) NOT NULL,
    [fecha_alta]               DATETIME      NULL,
    [usuario_alta]             VARCHAR (20)  NULL,
    [fecha_modificacion]       DATETIME      NULL,
    [usuario_modificacion]     VARCHAR (20)  NULL,
    [fecha_baja]               DATETIME      NULL,
    [usuario_baja]             VARCHAR (20)  NULL,
    [version]                  INT           CONSTRAINT [DF_Notificacion_Recibida_version] DEFAULT ((0)) NOT NULL,
    [puesto]                   VARCHAR (50)  NULL,
    [empresa]                  VARCHAR (50)  NULL,
    [telefono_contacto]        VARCHAR (10)  NULL,
    CONSTRAINT [PK_Notificacion_Recibida] PRIMARY KEY CLUSTERED ([id_notificacion_recibida] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Notificacion_Recibida_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Notificacion_Recibida_Notificacion] FOREIGN KEY ([id_notificacion]) REFERENCES [dbo].[Notificacion] ([id_notificacion])
);

