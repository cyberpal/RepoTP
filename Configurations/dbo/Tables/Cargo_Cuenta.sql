CREATE TABLE [dbo].[Cargo_Cuenta] (
    [id_cargo_cuenta]       INT             IDENTITY (1, 1) NOT NULL,
    [id_cargo]              INT             NULL,
    [id_cuenta]             INT             NULL,
    [id_tipo_aplicacion]    INT             NULL,
    [valor]                 DECIMAL (12, 2) NULL,
    [fecha_inicio_vigencia] DATETIME        NULL,
    [fecha_fin_vigencia]    DATETIME        NULL,
    [fecha_alta]            DATETIME        NULL,
    [usuario_alta]          VARCHAR (20)    NULL,
    [fecha_modificacion]    DATETIME        NULL,
    [usuario_modificacion]  VARCHAR (20)    NULL,
    [fecha_baja]            DATETIME        NULL,
    [usuario_baja]          VARCHAR (20)    NULL,
    [version]               INT             CONSTRAINT [DF_Cargo_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cargo_Cuenta] PRIMARY KEY CLUSTERED ([id_cargo_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cargo_Cuenta_Cargo] FOREIGN KEY ([id_cargo]) REFERENCES [dbo].[Cargo] ([id_cargo]),
    CONSTRAINT [FK_Cargo_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Cargo_Cuenta_Tipo] FOREIGN KEY ([id_tipo_aplicacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

