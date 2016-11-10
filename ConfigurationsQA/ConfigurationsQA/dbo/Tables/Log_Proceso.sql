CREATE TABLE [dbo].[Log_Proceso] (
    [id_log_proceso]         INT          IDENTITY (1, 1) NOT NULL,
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
    [version]                INT          CONSTRAINT [DF_Log_Proceso_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Log_Proceso] PRIMARY KEY CLUSTERED ([id_log_proceso] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Log_Proceso_Proceso] FOREIGN KEY ([id_proceso]) REFERENCES [dbo].[Proceso] ([id_proceso])
);

