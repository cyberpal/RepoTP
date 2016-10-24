CREATE TABLE [dbo].[Acumulador_Promociones] (
    [id_acumulador_promociones] INT             IDENTITY (1, 1) NOT NULL,
    [id_promocion]              INT             NULL,
    [fecha_transaccion]         DATETIME        NULL,
    [cuenta_transaccion]        INT             NULL,
    [importe_total_tx]          DECIMAL (12, 2) NULL,
    [cantidad_tx]               INT             NULL,
    CONSTRAINT [PK_Acumulador_Promociones] PRIMARY KEY CLUSTERED ([id_acumulador_promociones] ASC),
    CONSTRAINT [FK_Acumulador_Promociones_Promocion] FOREIGN KEY ([id_promocion]) REFERENCES [dbo].[Promocion] ([id_promocion])
);

