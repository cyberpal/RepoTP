CREATE TABLE [dbo].[Tipo_Parametro] (
    [id_tipo_parametro]    INT           NOT NULL,
    [nombre]               VARCHAR (100) NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Tipo_Parametro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Tipo_Parametro] PRIMARY KEY CLUSTERED ([id_tipo_parametro] ASC) WITH (FILLFACTOR = 80)
);

