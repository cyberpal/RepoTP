CREATE TABLE [dbo].[Facturacion_NovedadesCtas_tmp] (
    [I]                      INT          NOT NULL,
    [Empr]                   VARCHAR (6)  NULL,
    [id_cuenta]              INT          NULL,
    [RazonSocial]            VARCHAR (50) NULL,
    [Calle]                  VARCHAR (30) NULL,
    [Nro]                    VARCHAR (10) NULL,
    [Piso]                   VARCHAR (10) NULL,
    [Dto]                    VARCHAR (10) NULL,
    [Localidad]              VARCHAR (50) NULL,
    [Pais]                   CHAR (1)     NULL,
    [ProvCodigo]             VARCHAR (20) NULL,
    [Cp]                     VARCHAR (20) NULL,
    [TEFijo]                 VARCHAR (10) NULL,
    [Fantasia]               VARCHAR (50) NULL,
    [Mail]                   VARCHAR (50) NULL,
    [CUIT]                   VARCHAR (50) NULL,
    [Cod_IVA]                INT          NULL,
    [id_tipo_condicion_IIBB] INT          NULL,
    [DNI]                    VARCHAR (20) NULL,
    [Tipo_Novedad]           VARCHAR (20) NULL,
    CONSTRAINT [PK_Facturacion_NovedadesCtas_tmp] PRIMARY KEY CLUSTERED ([I] ASC) WITH (FILLFACTOR = 80)
);

