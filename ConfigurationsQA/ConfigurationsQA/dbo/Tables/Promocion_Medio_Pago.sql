CREATE TABLE [dbo].[Promocion_Medio_Pago] (
    [id_promocion_mp]      INT          IDENTITY (1, 1) NOT NULL,
    [id_promocion]         INT          NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Promocion_Medio_Pago_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Promocion_Medio_Pago] PRIMARY KEY CLUSTERED ([id_promocion_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Promocion_Medio_Pago_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [FK_Promocion_Medio_Pago_Promocion] FOREIGN KEY ([id_promocion]) REFERENCES [dbo].[Promocion] ([id_promocion])
);

