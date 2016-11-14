CREATE TABLE [dbo].[Rango_Bin_20160405] (
    [id_rango_bin]              INT          IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]             INT          NOT NULL,
    [longitud_prefijo]          INT          NOT NULL,
    [bin_desde]                 VARCHAR (19) NOT NULL,
    [bin_hasta]                 VARCHAR (19) NOT NULL,
    [fecha_alta]                DATETIME     NULL,
    [usuario_alta]              VARCHAR (20) NULL,
    [fecha_modificacion]        DATETIME     NULL,
    [usuario_modificacion]      VARCHAR (20) NULL,
    [fecha_baja]                DATETIME     NULL,
    [usuario_baja]              VARCHAR (20) NULL,
    [version]                   INT          NOT NULL,
    [longitud_busqueda]         INT          NOT NULL,
    [flag_bin_local]            BIT          NOT NULL,
    [flag_controla_vencimiento] BIT          NOT NULL
);

