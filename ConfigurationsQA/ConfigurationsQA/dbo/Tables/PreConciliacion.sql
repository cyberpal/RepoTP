CREATE TABLE [dbo].[PreConciliacion] (
    [id_preconciliacion]        INT          IDENTITY (1, 1) NOT NULL,
    [id_transaccion]            CHAR (36)    NULL,
    [id_log_paso]               INT          NULL,
    [flag_preconciliada]        BIT          NOT NULL,
    [id_preconciliacion_manual] INT          NULL,
    [fecha_alta]                DATETIME     NULL,
    [usuario_alta]              VARCHAR (20) NULL,
    [fecha_modificacion]        DATETIME     NULL,
    [usuario_modificacion]      VARCHAR (20) NULL,
    [fecha_baja]                DATETIME     NULL,
    [usuario_baja]              VARCHAR (20) NULL,
    [version]                   INT          NOT NULL,
    [id_movimiento_decidir]     INT          NULL,
    CONSTRAINT [PK_PreConciliacion] PRIMARY KEY CLUSTERED ([id_preconciliacion] ASC) WITH (FILLFACTOR = 80)
);

