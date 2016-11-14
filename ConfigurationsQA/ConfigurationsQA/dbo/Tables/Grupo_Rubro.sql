CREATE TABLE [dbo].[Grupo_Rubro] (
    [id_grupo_rubro]       INT          IDENTITY (1, 1) NOT NULL,
    [codigo_grupo_rubro]   VARCHAR (4)  NOT NULL,
    [descripcion]          VARCHAR (40) NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Grupo_Rubro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Grupo_Rubro] PRIMARY KEY CLUSTERED ([id_grupo_rubro] ASC),
    UNIQUE NONCLUSTERED ([codigo_grupo_rubro] ASC)
);

