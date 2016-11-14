CREATE TABLE [dbo].[Acumulador_Impuesto] (
    [id_acumulador_impuesto] INT             IDENTITY (1, 1) NOT NULL,
    [id_impuesto]            INT             NOT NULL,
    [id_cuenta]              INT             NOT NULL,
    [fecha_desde]            DATETIME        NULL,
    [fecha_hasta]            DATETIME        NULL,
    [cantidad_tx]            INT             NULL,
    [importe_total_tx]       DECIMAL (12, 2) NULL,
    [importe_retencion]      DECIMAL (12, 2) NULL,
    [flag_supera_tope]       BIT             NULL,
    [fecha_facturacion]      DATETIME        NULL,
    [alicuota]               DECIMAL (5, 2)  NULL,
    CONSTRAINT [PK_Acumulador_Impuesto] PRIMARY KEY CLUSTERED ([id_acumulador_impuesto] ASC)
);

