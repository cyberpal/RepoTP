CREATE TABLE [dbo].[Tipo] (
    [id_tipo]              INT           NOT NULL,
    [id_grupo_tipo]        INT           NOT NULL,
    [codigo]               VARCHAR (20)  NULL,
    [descripcion]          VARCHAR (100) NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Tipo_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Tipo] PRIMARY KEY CLUSTERED ([id_tipo] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Tipo_Grupo_Tipo] FOREIGN KEY ([id_grupo_tipo]) REFERENCES [dbo].[Grupo_Tipo] ([id_grupo_tipo]),
    UNIQUE NONCLUSTERED ([codigo] ASC) WITH (FILLFACTOR = 80)
);

