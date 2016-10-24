CREATE TABLE [dbo].[Perfil] (
    [id_perfil]            INT           IDENTITY (1, 1) NOT NULL,
    [codigo_perfil]        VARCHAR (20)  NOT NULL,
    [nombre]               VARCHAR (50)  NOT NULL,
    [descripcion]          VARCHAR (100) NULL,
    [tipo_perfil]          INT           NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Perfil] PRIMARY KEY CLUSTERED ([id_perfil] ASC),
    CONSTRAINT [FK_Perfil_Tipo] FOREIGN KEY ([tipo_perfil]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

