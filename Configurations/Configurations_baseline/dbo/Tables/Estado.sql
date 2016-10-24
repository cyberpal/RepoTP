CREATE TABLE [dbo].[Estado] (
    [id_estado]            INT           NOT NULL,
    [id_grupo_estado]      INT           NOT NULL,
    [Codigo]               VARCHAR (20)  CONSTRAINT [DF_Estado_Codigo] DEFAULT ('') NOT NULL,
    [nombre]               VARCHAR (50)  NOT NULL,
    [descripcion]          VARCHAR (200) NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Estado_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Estado] PRIMARY KEY CLUSTERED ([id_estado] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Estado_Grupo_Estado] FOREIGN KEY ([id_grupo_estado]) REFERENCES [dbo].[Grupo_Estado] ([id_grupo_estado])
);

