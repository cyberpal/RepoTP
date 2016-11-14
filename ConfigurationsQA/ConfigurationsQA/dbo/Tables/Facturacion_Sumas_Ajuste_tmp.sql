CREATE TABLE [dbo].[Facturacion_Sumas_Ajuste_tmp] (
    [I]                    INT             NOT NULL,
    [id_cuenta]            INT             NULL,
    [suma_monto_neto]      DECIMAL (18, 2) NULL,
    [suma_monto_impuesto]  DECIMAL (18, 2) NULL,
    [id_log_facturacion]   INT             NULL,
    [id_ciclo_facturacion] INT             NULL,
    [tipo]                 CHAR (3)        NULL,
    [concepto]             CHAR (3)        NULL,
    [subconcepto]          CHAR (3)        NULL,
    [anio]                 INT             NULL,
    [mes]                  INT             NULL,
    [vuelta_facturacion]   VARCHAR (15)    NULL,
    [tipo_comprobante]     CHAR (1)        NULL,
    [version]              INT             NULL,
    [fecha_desde_proceso]  DATETIME        NULL,
    [fecha_hasta_proceso]  DATETIME        NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    CONSTRAINT [PK_Facturacion_Sumas_Ajuste_tmp] PRIMARY KEY CLUSTERED ([I] ASC) WITH (FILLFACTOR = 80)
);

