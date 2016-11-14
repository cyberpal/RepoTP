CREATE TABLE [dbo].[Bin_Banco_Medio_Pago_PROD] (
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
    CONSTRAINT [UQ_Bin_Banco_Medio_Pago_PROD] UNIQUE NONCLUSTERED ([bin] ASC, [id_banco] ASC, [id_medio_pago] ASC, [fecha_baja] ASC)
);

