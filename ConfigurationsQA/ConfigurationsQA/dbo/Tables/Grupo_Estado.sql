CREATE TABLE [dbo].[Grupo_Estado] (
    [id_grupo_estado]      INT          NOT NULL,
    [codigo]               VARCHAR (20) CONSTRAINT [DF_Grupo_Estado_codigo] DEFAULT ('') NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Grupo_Estado_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Grupo_Estado] PRIMARY KEY CLUSTERED ([id_grupo_estado] ASC) WITH (FILLFACTOR = 80)
);

