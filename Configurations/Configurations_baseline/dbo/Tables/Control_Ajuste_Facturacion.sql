CREATE TABLE [dbo].[Control_Ajuste_Facturacion] (
    [id_control]           INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT             NOT NULL,
    [id_ciclo_facturacion] INT             NOT NULL,
    [anio]                 INT             NOT NULL,
    [mes]                  INT             NOT NULL,
    [tipo_comprobante]     CHAR (1)        NOT NULL,
    [total_ajuste]         DECIMAL (12, 2) NOT NULL,
    CONSTRAINT [PK_Control_Ajuste_Facturacion] PRIMARY KEY CLUSTERED ([id_control] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Control_Aj_Ciclo_Facturacion] FOREIGN KEY ([id_ciclo_facturacion]) REFERENCES [dbo].[Ciclo_Facturacion] ([id_ciclo_facturacion])
);

