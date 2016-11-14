CREATE TABLE [dbo].[Grupo_Notificacion] (
    [id_grupo_notificacion] INT           NOT NULL,
    [nombre]                VARCHAR (100) NOT NULL,
    [fecha_alta]            DATETIME      NULL,
    [usuario_alta]          VARCHAR (20)  NULL,
    [fecha_modificacion]    DATETIME      NULL,
    [usuario_modificacion]  VARCHAR (20)  NULL,
    [fecha_baja]            DATETIME      NULL,
    [usuario_baja]          VARCHAR (20)  NULL,
    [version]               INT           CONSTRAINT [DF_Grupo_Notificacion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Grupo_Notificacion] PRIMARY KEY CLUSTERED ([id_grupo_notificacion] ASC) WITH (FILLFACTOR = 80)
);

