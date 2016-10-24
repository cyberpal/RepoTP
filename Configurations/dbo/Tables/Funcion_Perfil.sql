CREATE TABLE [dbo].[Funcion_Perfil] (
    [id_funcion_perfil]    INT          IDENTITY (1, 1) NOT NULL,
    [id_perfil]            INT          NOT NULL,
    [id_funcion]           INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Funcion_Perfil_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Funcion_Perfil] PRIMARY KEY CLUSTERED ([id_funcion_perfil] ASC),
    CONSTRAINT [FK_Funcion_Perfil] FOREIGN KEY ([id_perfil]) REFERENCES [dbo].[Perfil] ([id_perfil]),
    CONSTRAINT [FK_Funcion_Perfil_Funcion] FOREIGN KEY ([id_funcion]) REFERENCES [dbo].[Funcion] ([id_funcion])
);

