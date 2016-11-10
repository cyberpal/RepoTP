CREATE TABLE [dbo].[Motivo] (
    [id_motivo]            INT           IDENTITY (1, 1) NOT NULL,
    [id_grupo_motivo]      INT           NOT NULL,
    [codigo]               VARCHAR (20)  NOT NULL,
    [nombre]               VARCHAR (50)  NOT NULL,
    [descripcion]          VARCHAR (200) NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20)  DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME      DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20)  DEFAULT (NULL) NULL,
    [version]              INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_motivo] ASC),
    CONSTRAINT [FK_GRUPO_MOTIVO_ID_GRUPO_MOTIVO] FOREIGN KEY ([id_grupo_motivo]) REFERENCES [dbo].[Grupo_Motivo] ([id_grupo_motivo])
);

