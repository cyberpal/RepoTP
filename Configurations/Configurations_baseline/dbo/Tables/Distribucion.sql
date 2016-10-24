CREATE TABLE [dbo].[Distribucion] (
    [id_distribucion]      INT          IDENTITY (1, 1) NOT NULL,
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
    CONSTRAINT [PK_Distribucion] PRIMARY KEY CLUSTERED ([id_distribucion] ASC) WITH (FILLFACTOR = 80)
);

