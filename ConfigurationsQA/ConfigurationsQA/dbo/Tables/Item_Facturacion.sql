CREATE TABLE [dbo].[Item_Facturacion] (
    [id_item_facturacion]       INT             IDENTITY (1, 1) NOT NULL,
    [id_log_facturacion]        INT             NULL,
    [id_ciclo_facturacion]      INT             NOT NULL,
    [tipo]                      CHAR (3)        NOT NULL,
    [concepto]                  CHAR (3)        NOT NULL,
    [subconcepto]               CHAR (3)        NOT NULL,
    [id_cuenta]                 INT             NOT NULL,
    [anio]                      INT             NOT NULL,
    [mes]                       INT             NOT NULL,
    [suma_cargos]               DECIMAL (18, 2) NOT NULL,
    [suma_impuestos]            DECIMAL (18, 2) NOT NULL,
    [vuelta_facturacion]        VARCHAR (15)    CONSTRAINT [DF_Item_Facturacion_vuelta_facturacion] DEFAULT ('Pendiente') NOT NULL,
    [id_log_vuelta_facturacion] INT             NULL,
    [identificador_carga_dwh]   INT             NULL,
    [impuestos_reales]          DECIMAL (18, 2) NULL,
    [tipo_comprobante]          CHAR (1)        NULL,
    [nro_comprobante]           INT             NULL,
    [fecha_comprobante]         DATE            NULL,
    [fecha_alta]                DATETIME        NOT NULL,
    [usuario_alta]              VARCHAR (20)    NOT NULL,
    [fecha_modificacion]        DATETIME        NULL,
    [usuario_modificacion]      VARCHAR (20)    NULL,
    [fecha_baja]                DATETIME        NULL,
    [usuario_baja]              VARCHAR (20)    NULL,
    [version]                   INT             CONSTRAINT [DF_Item_Facturacion_version] DEFAULT ((0)) NOT NULL,
    [cuenta_aurus]              INT             NULL,
    [punto_venta]               CHAR (1)        NULL,
    [suma_cargos_aurus]         DECIMAL (18, 2) NULL,
    [fecha_desde_proceso]       DATETIME        NULL,
    [fecha_hasta_proceso]       DATETIME        NULL,
    [letra_comprobante]         CHAR (1)        NULL,
    [fecha_carga_dw]            DATETIME        NULL,
    CONSTRAINT [PK_Item_Facturacion] PRIMARY KEY CLUSTERED ([id_item_facturacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Item_Facturacion_Ciclo_Facturacion] FOREIGN KEY ([id_ciclo_facturacion]) REFERENCES [dbo].[Ciclo_Facturacion] ([id_ciclo_facturacion])
);


GO
CREATE NONCLUSTERED INDEX [idx_BatchFacturacion_ItemFacturacion]
    ON [dbo].[Item_Facturacion]([id_cuenta] ASC, [vuelta_facturacion] ASC, [fecha_alta] ASC);

