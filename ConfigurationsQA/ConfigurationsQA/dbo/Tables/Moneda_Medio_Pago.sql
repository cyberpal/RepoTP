CREATE TABLE [dbo].[Moneda_Medio_Pago] (
    [id_moneda_mp]           INT          NOT NULL,
    [id_medio_pago]          INT          NULL,
    [id_moneda]              INT          NULL,
    [moneda_mp_conciliacion] VARCHAR (5)  NULL,
    [moneda_mp_autorizacion] VARCHAR (5)  NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Moneda_Medio_Pago_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Moneda_Medio_Pago] PRIMARY KEY CLUSTERED ([id_moneda_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Moneda_Medio_Pago_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [FK_Moneda_Medio_Pago_Moneda] FOREIGN KEY ([id_moneda]) REFERENCES [dbo].[Moneda] ([id_moneda])
);

