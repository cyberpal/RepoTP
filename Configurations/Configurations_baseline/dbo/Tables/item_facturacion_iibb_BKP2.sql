CREATE TABLE [dbo].[item_facturacion_iibb_BKP2] (
    [id_retencion_iibb]      INT             NOT NULL,
    [codigo_provincia]       VARCHAR (1)     NULL,
    [codigo_cliente_externo] VARCHAR (15)    NULL,
    [cuit]                   VARCHAR (15)    NULL,
    [razon_social]           VARCHAR (50)    NULL,
    [direccion]              VARCHAR (200)   NULL,
    [localidad]              VARCHAR (20)    NULL,
    [numero_iibb]            VARCHAR (13)    NULL,
    [regimen]                VARCHAR (100)   NULL,
    [fecha_pago]             DATETIME        NULL,
    [base_imponible]         DECIMAL (15, 2) NULL,
    [alicuota]               DECIMAL (15, 2) NULL,
    [importe_retenido]       DECIMAL (15, 2) NULL,
    [id_tipo_condicion_IIBB] INT             NULL,
    [numero_retencion]       VARCHAR (20)    NULL,
    [id_impuesto]            INT             NULL,
    [jurisdiccion]           INT             NULL,
    [id_acumulador_impuesto] INT             NULL
);

