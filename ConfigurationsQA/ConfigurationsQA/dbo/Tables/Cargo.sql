CREATE TABLE [dbo].[Cargo] (
    [id_cargo]             INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_cargo]        INT          NULL,
    [id_tipo_medio_pago]   INT          NOT NULL,
    [id_tipo_cuenta]       INT          NOT NULL,
    [id_base_de_calculo]   INT          NOT NULL,
    [id_canal]             INT          NULL,
    [flag_permite_baja]    BIT          CONSTRAINT [DF_Cargo_flag_permite_baja] DEFAULT ((0)) NOT NULL,
    [grupo_cargo]          INT          CONSTRAINT [DF_Cargo_grupo_cargo] DEFAULT ((1)) NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Cargo_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cargo] PRIMARY KEY CLUSTERED ([id_cargo] ASC),
    CONSTRAINT [FK_Cargo_Canal_Adhesion] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [FK_Cargo_Tipo_Cargo] FOREIGN KEY ([id_tipo_cargo]) REFERENCES [dbo].[Tipo_Cargo] ([id_tipo_cargo]),
    CONSTRAINT [FK_Cargo_Tipo_id_base_de_calculo] FOREIGN KEY ([id_base_de_calculo]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Cargo_Tipo_id_tipo_cuenta] FOREIGN KEY ([id_tipo_cuenta]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Cargo_Tipo_Medio_Pago] FOREIGN KEY ([id_tipo_medio_pago]) REFERENCES [dbo].[Tipo_Medio_Pago] ([id_tipo_medio_pago])
);

