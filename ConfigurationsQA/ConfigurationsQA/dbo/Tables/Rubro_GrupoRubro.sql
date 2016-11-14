CREATE TABLE [dbo].[Rubro_GrupoRubro] (
    [id_rubro_gruporubro]   INT          IDENTITY (1, 1) NOT NULL,
    [id_grupo_rubro]        INT          NOT NULL,
    [id_rubro]              INT          NOT NULL,
    [fecha_inicio_vigencia] DATETIME     NOT NULL,
    [fecha_fin_vigencia]    DATETIME     NULL,
    [fecha_alta]            DATETIME     NOT NULL,
    [usuario_alta]          VARCHAR (20) NOT NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          CONSTRAINT [DF_Rubro_GrupoRubro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Rubro_GrupoRubro] PRIMARY KEY CLUSTERED ([id_rubro_gruporubro] ASC),
    CONSTRAINT [fk_rubro_gruporubro_id_grupo_rubro] FOREIGN KEY ([id_grupo_rubro]) REFERENCES [dbo].[Grupo_Rubro] ([id_grupo_rubro]),
    CONSTRAINT [fk_rubro_gruporubro_id_rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro])
);

