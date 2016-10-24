CREATE TABLE [dbo].[Facturacion_Items_Ajuste_tmp] (
    [I]                INT             NOT NULL,
    [id_ajuste]        INT             NULL,
    [id_cuenta]        INT             NULL,
    [id_motivo_ajuste] INT             NULL,
    [estado_ajuste]    INT             NULL,
    [signo]            CHAR (1)        NULL,
    [monto_neto]       DECIMAL (18, 2) NULL,
    [monto_impuesto]   DECIMAL (18, 2) NULL,
    [fecha_alta]       DATETIME        NULL,
    [usuario_alta]     VARCHAR (20)    NULL,
    CONSTRAINT [PK_Facturacion_Items_Ajuste_tmp] PRIMARY KEY CLUSTERED ([I] ASC) WITH (FILLFACTOR = 80)
);

