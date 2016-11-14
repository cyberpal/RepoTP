CREATE TABLE [dbo].[Log_Control_Liquidacion_Disponible] (
    [id_log_control] INT             IDENTITY (1, 1) NOT NULL,
    [id_log_proceso] INT             NULL,
    [id_transaccion] CHAR (36)       NULL,
    [importe]        DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Log_Control_Liquidacion_Disponible] PRIMARY KEY CLUSTERED ([id_log_control] ASC)
);

