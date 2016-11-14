CREATE TABLE [dbo].[Grupo_Motivo] (
    [id_grupo_motivo]      INT          IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20) NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20) DEFAULT (NULL) NULL,
    [version]              INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_grupo_motivo] ASC)
);

