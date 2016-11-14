CREATE TABLE [dbo].[Pregunta_Seguridad] (
    [id_pregunta_seguridad] INT           NOT NULL,
    [pregunta_seguridad]    VARCHAR (100) NOT NULL,
    [fecha_alta]            DATETIME      NULL,
    [usuario_alta]          VARCHAR (20)  NULL,
    [fecha_modificacion]    DATETIME      NULL,
    [usuario_modificacion]  VARCHAR (20)  NULL,
    [fecha_baja]            DATETIME      NULL,
    [usuario_baja]          VARCHAR (20)  NULL,
    [version]               INT           CONSTRAINT [DF_Pregunta_Seguridad_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Pregunta_Seguridad] PRIMARY KEY CLUSTERED ([id_pregunta_seguridad] ASC) WITH (FILLFACTOR = 80)
);

