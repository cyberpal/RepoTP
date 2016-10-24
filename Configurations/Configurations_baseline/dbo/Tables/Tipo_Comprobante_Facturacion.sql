CREATE TABLE [dbo].[Tipo_Comprobante_Facturacion] (
    [id_tipo_comprobante_fact] INT          NOT NULL,
    [tipo_comprobante]         CHAR (1)     NOT NULL,
    [punto_venta]              CHAR (1)     NOT NULL,
    [fecha_alta]               DATETIME     NOT NULL,
    [usuario_alta]             VARCHAR (20) NOT NULL,
    [fecha_modificacion]       DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion]     VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]               DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]             DATETIME     DEFAULT (NULL) NULL,
    [version]                  INT          DEFAULT ('0') NOT NULL,
    [letra_comprobante]        CHAR (1)     NULL,
    PRIMARY KEY CLUSTERED ([id_tipo_comprobante_fact] ASC)
);

