CREATE TABLE [dbo].[Notificacion_BKP0502015] (
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
    [version]               INT           NOT NULL
);

