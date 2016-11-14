CREATE TABLE [dbo].[Cargo_Grupo_Rubro] (
    [id_cargo_grupo_rubro]  INT             IDENTITY (1, 1) NOT NULL,
    [id_cargo]              INT             NOT NULL,
    [id_grupo_rubro]        INT             NOT NULL,
    [id_tipo_aplicacion]    INT             NOT NULL,
    [valor]                 DECIMAL (12, 2) NOT NULL,
    [fecha_inicio_vigencia] DATETIME        NOT NULL,
    [fecha_fin_vigencia]    DATETIME        NULL,
    [fecha_alta]            DATETIME        NOT NULL,
    [usuario_alta]          VARCHAR (20)    NOT NULL,
    [fecha_modificacion]    DATETIME        NULL,
    [usuario_modificacion]  VARCHAR (20)    NULL,
    [fecha_baja]            DATETIME        NULL,
    [usuario_baja]          VARCHAR (20)    NULL,
    [version]               INT             CONSTRAINT [DF_Cargo_Grupo_Rubro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cargo_Grupo_Rubro] PRIMARY KEY CLUSTERED ([id_cargo_grupo_rubro] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cargo_Grupo_Rubro_Cargo] FOREIGN KEY ([id_cargo]) REFERENCES [dbo].[Cargo] ([id_cargo]),
    CONSTRAINT [FK_Cargo_Grupo_Rubro_Grupo_Rubro] FOREIGN KEY ([id_grupo_rubro]) REFERENCES [dbo].[Grupo_Rubro] ([id_grupo_rubro]),
    CONSTRAINT [FK_Cargo_Grupo_Rubro_Tipo] FOREIGN KEY ([id_tipo_aplicacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

