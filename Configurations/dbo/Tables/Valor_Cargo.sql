CREATE TABLE [dbo].[Valor_Cargo] (
    [id_valor_cargo]        INT             IDENTITY (1, 1) NOT NULL,
    [id_cargo]              INT             NOT NULL,
    [id_tipo_aplicacion]    INT             NULL,
    [valor]                 DECIMAL (12, 2) NULL,
    [fecha_inicio_vigencia] DATETIME        NOT NULL,
    [fecha_fin_vigencia]    DATETIME        NULL,
    [fecha_alta]            DATETIME        NOT NULL,
    [usuario_alta]          VARCHAR (20)    NOT NULL,
    [fecha_modificacion]    DATETIME        NULL,
    [usuario_modificacion]  VARCHAR (20)    NULL,
    [fecha_baja]            DATETIME        NULL,
    [usuario_baja]          VARCHAR (20)    NULL,
    [version]               INT             CONSTRAINT [DF_Valor_Cargo_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Valor_Cargo] PRIMARY KEY CLUSTERED ([id_valor_cargo] ASC),
    CONSTRAINT [FK_Valor_Cargo_Tipo] FOREIGN KEY ([id_tipo_aplicacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

