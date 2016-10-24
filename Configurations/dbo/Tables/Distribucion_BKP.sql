CREATE TABLE [dbo].[Distribucion_BKP] (
    [id_transaccion]       CHAR (36)    NULL,
    [id_log_paso]          INT          NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          NOT NULL,
    [flag_procesado]       BIT          NOT NULL,
    [fecha_distribucion]   DATETIME     NULL,
    [id_distribucion]      INT          NOT NULL
);

