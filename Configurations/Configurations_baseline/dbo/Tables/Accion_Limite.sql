CREATE TABLE [dbo].[Accion_Limite] (
    [id_accion_limite]          INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_limite]            INT          NOT NULL,
    [id_tipo_aplicacion_limite] INT          NOT NULL,
    [id_tipo_accion_limite]     INT          NOT NULL,
    [fecha_alta]                DATETIME     NOT NULL,
    [usuario_alta]              VARCHAR (20) NOT NULL,
    [fecha_modificacion]        DATETIME     NULL,
    [usuario_modificacion]      VARCHAR (20) NULL,
    [fecha_baja]                DATETIME     NULL,
    [usuario_baja]              VARCHAR (20) NULL,
    [version]                   INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_accion_limite] ASC),
    CONSTRAINT [FK_Accion_Limite_id_tipo_accion_limite] FOREIGN KEY ([id_tipo_accion_limite]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Accion_Limite_id_tipo_aplicacion_limite] FOREIGN KEY ([id_tipo_aplicacion_limite]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Accion_Limite_id_tipo_limite] FOREIGN KEY ([id_tipo_limite]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

