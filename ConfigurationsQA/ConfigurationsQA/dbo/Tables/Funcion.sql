CREATE TABLE [dbo].[Funcion] (
    [id_funcion]               INT           IDENTITY (1, 1) NOT NULL,
    [codigo_funcion]           VARCHAR (100) NOT NULL,
    [nombre]                   VARCHAR (50)  NOT NULL,
    [descripcion]              VARCHAR (50)  NULL,
    [tipo_funcion]             VARCHAR (50)  NULL,
    [accion]                   VARCHAR (50)  NULL,
    [id_canal]                 INT           NULL,
    [fecha_alta]               DATETIME      NULL,
    [usuario_alta]             VARCHAR (20)  NULL,
    [fecha_modificacion]       DATETIME      NULL,
    [usuario_modificacion]     VARCHAR (20)  NULL,
    [fecha_baja]               DATETIME      NULL,
    [usuario_baja]             VARCHAR (20)  NULL,
    [version]                  INT           CONSTRAINT [DF_Funcion_version] DEFAULT ((0)) NOT NULL,
    [id_funcion_padre]         INT           NULL,
    [habilitada_perfil_custom] BIT           NULL,
    CONSTRAINT [PK_Funcion] PRIMARY KEY CLUSTERED ([id_funcion] ASC),
    CONSTRAINT [FK_Funcion_Canal] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal])
);

