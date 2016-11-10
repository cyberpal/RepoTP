CREATE TABLE [dbo].[TyC] (
    [id_version]           INT           IDENTITY (1, 1) NOT NULL,
    [version_TyC]          INT           NOT NULL,
    [fecha_vigencia_desde] DATETIME      NOT NULL,
    [fecha_vigencia_hasta] DATETIME      NULL,
    [path_texto]           VARCHAR (255) NOT NULL,
    [estado_activo]        BIT           NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_TyC_version] DEFAULT ((0)) NOT NULL,
    [id_tipo_tyc]          INT           DEFAULT ((98)) NOT NULL,
    CONSTRAINT [PK_TyC] PRIMARY KEY CLUSTERED ([id_version] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [fk_id_tipo_tyc] FOREIGN KEY ([id_tipo_tyc]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

