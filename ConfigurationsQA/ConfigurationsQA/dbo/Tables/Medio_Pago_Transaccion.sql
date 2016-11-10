CREATE TABLE [dbo].[Medio_Pago_Transaccion] (
    [id_medio_pago_transaccion] INT          IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]             INT          NULL,
    [id_transaccion]            CHAR (36)    NULL,
    [fecha_alta]                DATETIME     NULL,
    [usuario_alta]              VARCHAR (30) NULL,
    [fecha_baja]                DATETIME     NULL,
    [usuario_baja]              VARCHAR (30) NULL,
    CONSTRAINT [PK_Medio_Pago_Transaccion] PRIMARY KEY CLUSTERED ([id_medio_pago_transaccion] ASC),
    CONSTRAINT [FK_Medio_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [Unique_Medio_Pago_Por_Transaccion] UNIQUE NONCLUSTERED ([id_medio_pago] ASC, [id_transaccion] ASC)
);

