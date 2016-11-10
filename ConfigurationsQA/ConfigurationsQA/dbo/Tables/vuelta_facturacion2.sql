CREATE TABLE [dbo].[vuelta_facturacion2] (
    [nro_item]               CHAR (10)       NULL,
    [descripcion_item]       VARCHAR (50)    NULL,
    [descripcion_rango]      VARCHAR (50)    NULL,
    [nro_grupo_item]         INT             NULL,
    [descripcion_grupo_item] VARCHAR (50)    NULL,
    [tipo_comprobante]       CHAR (1)        NULL,
    [fecha_comprobante]      DATE            NULL,
    [nro_cliente]            INT             NOT NULL,
    [descripcion_cliente]    VARCHAR (50)    NULL,
    [nro_comprobante]        INT             NULL,
    [importe]                NUMERIC (18, 2) NULL,
    [importe_neto]           NUMERIC (18, 2) NULL,
    [importe_iva]            NUMERIC (18, 2) NULL,
    [importe_neto_pesos]     NUMERIC (18, 2) NULL,
    [importe_iva_pesos]      NUMERIC (18, 2) NULL,
    [campania]               INT             NULL,
    [id_vuelta_facturacion]  INT             NOT NULL
);

