CREATE TABLE [dbo].[Comentario_Cuenta] (
    [id_comentario]        INT           IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT           NOT NULL,
    [comentario]           VARCHAR (256) NOT NULL,
    [fecha_alta]           DATETIME      NOT NULL,
    [usuario_alta]         VARCHAR (20)  NOT NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Comentario_Cuenta] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Comentario_Cuenta] PRIMARY KEY CLUSTERED ([id_comentario] ASC),
    CONSTRAINT [FK_Comentario_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta])
);

