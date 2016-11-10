CREATE TABLE [dbo].[Log_Proceso_BKP] (
    [id_log_proceso]         INT          NOT NULL,
    [id_proceso]             INT          NULL,
    [fecha_inicio_ejecucion] DATETIME     NULL,
    [fecha_fin_ejecucion]    DATETIME     NULL,
    [fecha_desde_proceso]    DATETIME     NULL,
    [fecha_hasta_proceso]    DATETIME     NULL,
    [registros_afectados]    INT          NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          NOT NULL
);

