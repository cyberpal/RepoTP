CREATE TABLE [dbo].[Notificacion] (
    [id_notificacion]       INT           NOT NULL,
    [id_grupo_notificacion] INT           NULL,
    [nombre]                VARCHAR (100) NOT NULL,
    [descripcion]           VARCHAR (100) NULL,
    [destino]               VARCHAR (20)  NULL,
    [asunto]                VARCHAR (100) NULL,
    [template]              IMAGE         NULL,
    [flag_activa]           BIT           NULL,
    [fecha_alta]            DATETIME      NULL,
    [usuario_alta]          VARCHAR (20)  NULL,
    [fecha_modificacion]    DATETIME      NULL,
    [usuario_modificacion]  VARCHAR (20)  NULL,
    [fecha_baja]            DATETIME      NULL,
    [usuario_baja]          VARCHAR (20)  NULL,
    [version]               INT           CONSTRAINT [DF_Notificacion_version] DEFAULT ((0)) NOT NULL,
    [mail_origen]           VARCHAR (50)  NOT NULL,
    [orden]                 INT           NULL,
    CONSTRAINT [PK_Notificacion] PRIMARY KEY CLUSTERED ([id_notificacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Notificacion_Grupo_Notificacion] FOREIGN KEY ([id_grupo_notificacion]) REFERENCES [dbo].[Grupo_Notificacion] ([id_grupo_notificacion])
);

