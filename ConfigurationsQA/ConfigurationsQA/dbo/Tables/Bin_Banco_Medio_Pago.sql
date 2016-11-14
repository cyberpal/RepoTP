CREATE TABLE [dbo].[Bin_Banco_Medio_Pago] (
    [id_bin_banco_mp]      INT          IDENTITY (1, 1) NOT NULL,
    [bin]                  VARCHAR (8)  NOT NULL,
    [id_banco]             INT          NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id_bin_banco_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Bin_Banco_Medio_Pago_Banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Bin_Banco_Medio_Pago_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [UQ_Bin_Banco_Medio_Pago] UNIQUE NONCLUSTERED ([bin] ASC, [id_banco] ASC, [id_medio_pago] ASC, [fecha_baja] ASC)
);

