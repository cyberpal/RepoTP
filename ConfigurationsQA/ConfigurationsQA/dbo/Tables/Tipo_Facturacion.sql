CREATE TABLE [dbo].[Tipo_Facturacion] (
    [id_tipo_facturacion]     INT          NOT NULL,
    [id_tipo]                 INT          NOT NULL,
    [codigo_facturacion]      INT          NOT NULL,
    [descripcion_facturacion] VARCHAR (50) NOT NULL,
    [descripcion_corta]       VARCHAR (30) NOT NULL,
    [fecha_alta]              DATETIME     NOT NULL,
    [usuario_alta]            VARCHAR (20) NOT NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          NOT NULL,
    CONSTRAINT [id_tipo_facturacion] PRIMARY KEY CLUSTERED ([id_tipo_facturacion] ASC) WITH (FILLFACTOR = 80)
);

