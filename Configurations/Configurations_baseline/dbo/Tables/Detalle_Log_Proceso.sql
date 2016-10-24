CREATE TABLE [dbo].[Detalle_Log_Proceso] (
    [id_detalle_log_proceso] INT           IDENTITY (1, 1) NOT NULL,
    [id_log_proceso]         INT           NOT NULL,
    [nombre_sp]              VARCHAR (50)  NOT NULL,
    [id_nivel_detalle_lp]    INT           NOT NULL,
    [fecha_alta]             DATETIME      NOT NULL,
    [detalle]                VARCHAR (200) NOT NULL,
    CONSTRAINT [PK_Detalle_Log_Proceso] PRIMARY KEY CLUSTERED ([id_detalle_log_proceso] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Detalle_Log_Proceso_Log_Proceso] FOREIGN KEY ([id_log_proceso]) REFERENCES [dbo].[Log_Proceso] ([id_log_proceso]),
    CONSTRAINT [FK_Detalle_Log_Proceso_Nivel_Detalle] FOREIGN KEY ([id_nivel_detalle_lp]) REFERENCES [dbo].[Nivel_Detalle_Log_Proceso] ([id_nivel_detalle_lp])
);

