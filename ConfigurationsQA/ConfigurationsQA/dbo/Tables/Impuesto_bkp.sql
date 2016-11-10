CREATE TABLE [dbo].[Impuesto_bkp] (
    [id_impuesto]           INT          IDENTITY (1, 1) NOT NULL,
    [descripcion]           VARCHAR (60) NOT NULL,
    [flag_todas_provincias] BIT          NOT NULL,
    [id_provincia]          INT          NULL,
    [fecha_alta]            DATETIME     NULL,
    [usuario_alta]          VARCHAR (20) NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          NOT NULL,
    [codigo]                VARCHAR (20) NOT NULL
);

