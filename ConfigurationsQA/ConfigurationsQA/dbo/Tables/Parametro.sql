CREATE TABLE [dbo].[Parametro] (
    [id_parametro]         INT           IDENTITY (1, 1) NOT NULL,
    [id_tipo_parametro]    INT           NULL,
    [codigo]               VARCHAR (20)  NULL,
    [nombre]               VARCHAR (100) NULL,
    [valor]                VARCHAR (256) NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Parametro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Parametro] PRIMARY KEY CLUSTERED ([id_parametro] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Parametro_Tipo_Parametro] FOREIGN KEY ([id_tipo_parametro]) REFERENCES [dbo].[Tipo_Parametro] ([id_tipo_parametro])
);

