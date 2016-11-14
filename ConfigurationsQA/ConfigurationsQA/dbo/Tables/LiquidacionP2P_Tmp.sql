CREATE TABLE [dbo].[LiquidacionP2P_Tmp] (
    [id]                INT             NOT NULL,
    [id_p2p]            INT             NULL,
    [id_cuenta_origen]  INT             NULL,
    [id_cuenta_destino] INT             NULL,
    [monto]             DECIMAL (12, 2) NULL,
    [id_transaccion]    VARCHAR (36)    NULL,
    [fecha_alta]        DATETIME        NULL,
    CONSTRAINT [PK__Liquidac__3213E83F24A2DC3B] PRIMARY KEY CLUSTERED ([id] ASC)
);

