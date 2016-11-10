CREATE TABLE [dbo].[Regla_Operacion] (
    [id_regla_operacion]      INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_cuenta]          INT          NULL,
    [id_rubro]                INT          NULL,
    [id_cuenta]               INT          NULL,
    [id_tipo_regla_operacion] INT          NULL,
    [flag_permite_operacion]  BIT          CONSTRAINT [DF_Tipo_Liberacion_flag_permi] DEFAULT ((0)) NOT NULL,
    [flag_permite_baja]       BIT          CONSTRAINT [DF_Tipo_Liberacion_flag_baja] DEFAULT ((1)) NOT NULL,
    [fecha_alta]              DATETIME     NULL,
    [usuario_alta]            VARCHAR (20) NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Regla_Operacion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Tipo_Liberacion] PRIMARY KEY CLUSTERED ([id_regla_operacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Regla_Operacion_Tipo] FOREIGN KEY ([id_tipo_regla_operacion]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Tipo_Liberacion_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Tipo_Liberacion_Rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro]),
    CONSTRAINT [FK_Tipo_Liberacion_Tipo] FOREIGN KEY ([id_tipo_cuenta]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

