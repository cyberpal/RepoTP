CREATE TABLE [dbo].[Medio_Pago_Banco_PROD] (
    [id_medio_pago_banco]  INT          IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [id_banco]             INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Medio_Pago_Banco_version_PROD] DEFAULT ((0)) NOT NULL,
    [red_opera]            VARCHAR (20) NULL,
    CONSTRAINT [PK_Medio_Pago_Banco_PROD] PRIMARY KEY CLUSTERED ([id_medio_pago_banco] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [UQ_Medio_Pago_Banco_PROD] UNIQUE NONCLUSTERED ([id_medio_pago] ASC, [id_banco] ASC, [fecha_baja] ASC)
);

