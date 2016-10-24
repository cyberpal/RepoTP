CREATE TABLE [dbo].[Item_Facturacion_tmp] (
    [i]                         INT             IDENTITY (1, 1) NOT NULL,
    [id_item_facturacion]       INT             NOT NULL,
    [id_ciclo_facturacion]      INT             NOT NULL,
    [id_cuenta]                 INT             NOT NULL,
    [anio]                      INT             NOT NULL,
    [mes]                       INT             NOT NULL,
    [suma_impuestos]            DECIMAL (18, 2) NOT NULL,
    [vuelta_facturacion]        VARCHAR (15)    NOT NULL,
    [id_log_vuelta_facturacion] INT             NULL,
    [identificador_carga_dwh]   INT             NULL,
    [impuestos_reales]          DECIMAL (18, 2) NULL,
    [tipo_comprobante]          CHAR (1)        NULL,
    [nro_comprobante]           INT             NULL,
    [fecha_comprobante]         DATE            NULL,
    [cuenta_aurus]              INT             NULL,
    [punto_venta]               CHAR (1)        NULL,
    [suma_cargos_aurus]         DECIMAL (18, 2) NULL,
    [letra_comprobante]         CHAR (1)        NULL,
    [fecha_carga_dw]            DATETIME        NULL,
    [dif_ajuste]                DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_Item_Facturacion_tmp] PRIMARY KEY CLUSTERED ([i] ASC) WITH (FILLFACTOR = 80)
);

