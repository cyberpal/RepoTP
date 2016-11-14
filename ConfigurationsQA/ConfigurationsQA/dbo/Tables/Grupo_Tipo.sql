CREATE TABLE [dbo].[Grupo_Tipo] (
    [id_grupo_tipo]        INT          NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Grupo_Tipo_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Grupo_Tipo] PRIMARY KEY CLUSTERED ([id_grupo_tipo] ASC) WITH (FILLFACTOR = 80)
);

