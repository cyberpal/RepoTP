CREATE TABLE [dbo].[VencMediosDePago_tmp] (
    [I]                      INT          NOT NULL,
    [id_medio_pago_cuenta]   INT          NULL,
    [id_cuenta]              INT          NULL,
    [codigo]                 VARCHAR (20) NULL,
    [denominacion1]          VARCHAR (80) NULL,
    [denominacion2]          VARCHAR (80) NULL,
    [mascara_numero_tarjeta] VARCHAR (20) NULL,
    [email]                  VARCHAR (50) NULL,
    [fecha_vencimiento]      VARCHAR (10) NULL,
    [flag_tipo_de_medio]     VARCHAR (20) NULL,
    [flag_error_informado]   BIT          NULL,
    [id_error_BIN]           VARCHAR (80) NULL,
    CONSTRAINT [PK_VencMediosDePago_tmp] PRIMARY KEY CLUSTERED ([I] ASC) WITH (FILLFACTOR = 80)
);

