CREATE TABLE [dbo].[Promocion_Medio_Pago_Banco] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [id_promocion_mp]      INT          NOT NULL,
    [id_banco]             INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Promocion_Medio_Pago_Banco_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Promocion_Medio_Pago_Banco] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Promocion_Medio_Pago_Banco_Banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Promocion_Medio_Pago_Banco_Promocion_Medio_Pago] FOREIGN KEY ([id_promocion_mp]) REFERENCES [dbo].[Promocion_Medio_Pago] ([id_promocion_mp])
);

