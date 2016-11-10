CREATE TABLE [dbo].[Actividad_AFIP] (
    [id_actividad_AFIP]     INT           NOT NULL,
    [codigo_actividad_AFIP] VARCHAR (6)   NOT NULL,
    [descripcion]           VARCHAR (256) NOT NULL,
    [fecha_alta]            DATETIME      NULL,
    [usuario_alta]          VARCHAR (20)  NULL,
    [fecha_modificacion]    DATETIME      NULL,
    [usuario_modificacion]  VARCHAR (20)  NULL,
    [fecha_baja]            DATETIME      NULL,
    [usuario_baja]          VARCHAR (20)  NULL,
    [version]               INT           CONSTRAINT [DF_Actividad_AFIP_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Actividad_AFIP] PRIMARY KEY CLUSTERED ([id_actividad_AFIP] ASC) WITH (FILLFACTOR = 80)
);

