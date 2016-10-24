CREATE TABLE [dbo].[Configuracion_Log_Proceso] (
    [id_configuracion_log_proceso] INT IDENTITY (1, 1) NOT NULL,
    [id_proceso]                   INT NOT NULL,
    [id_nivel_detalle_lp]          INT NOT NULL,
    [id_tipo_historico_log]        INT NOT NULL,
    [valor_historico_log]          INT NOT NULL,
    CONSTRAINT [PK_Configuracion_Log_Proceso] PRIMARY KEY CLUSTERED ([id_configuracion_log_proceso] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([id_tipo_historico_log]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Configuracion_Log_Proceso_Proceso] FOREIGN KEY ([id_proceso]) REFERENCES [dbo].[Proceso] ([id_proceso])
);

