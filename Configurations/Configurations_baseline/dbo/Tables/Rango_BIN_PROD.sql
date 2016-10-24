CREATE TABLE [dbo].[Rango_BIN_PROD] (
    [id_rango_bin]              INT          NOT NULL,
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
    [version]                   INT          CONSTRAINT [DF_Rango_BIN_version_PROD] DEFAULT ((0)) NOT NULL,
    [longitud_busqueda]         INT          NULL,
    [flag_bin_local]            BIT          DEFAULT ((1)) NOT NULL,
    [flag_controla_vencimiento] BIT          DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Rango_BIN_PROD] PRIMARY KEY CLUSTERED ([id_rango_bin] ASC) WITH (FILLFACTOR = 80)
);

