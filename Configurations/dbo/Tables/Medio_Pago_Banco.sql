CREATE TABLE [dbo].[Medio_Pago_Banco] (
    [id_medio_pago_banco]     INT          IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]           INT          NOT NULL,
    [id_banco]                INT          NOT NULL,
    [fecha_alta]              DATETIME     NULL,
    [usuario_alta]            VARCHAR (20) NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Medio_Pago_Banco_version] DEFAULT ((0)) NOT NULL,
    [red_opera]               VARCHAR (20) NULL,
    [flag_visible_formulario] BIT          DEFAULT ((0)) NULL,
    [flag_BVTP]               BIT          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Medio_Pago_Banco] PRIMARY KEY CLUSTERED ([id_medio_pago_banco] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Medio_Pago_Banco_Banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Medio_Pago_Banco_Medio_de_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [UQ_Medio_Pago_Banco] UNIQUE NONCLUSTERED ([id_medio_pago] ASC, [id_banco] ASC, [fecha_baja] ASC)
);

