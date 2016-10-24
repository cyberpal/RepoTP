CREATE TABLE [dbo].[Analisis_Saldos_Tmp] (
    [I]                      INT             NOT NULL,
    [tipo]                   CHAR (3)        NOT NULL,
    [id_char]                CHAR (36)       NULL,
    [id_int]                 INT             NULL,
    [id_cuenta]              INT             NULL,
    [importe]                DECIMAL (12, 2) NULL,
    [fecha]                  DATETIME        NULL,
    [id_log_proceso]         INT             NULL,
    [fecha_inicio_ejecucion] DATETIME        NULL,
    [fecha_fin_ejecucion]    DATETIME        NULL,
    [id_log_movimiento]      INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Analisis_Saldos_Tmp]
    ON [dbo].[Analisis_Saldos_Tmp]([id_log_movimiento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Analisis_Saldos_Tmp_1]
    ON [dbo].[Analisis_Saldos_Tmp]([id_cuenta] ASC, [id_log_proceso] ASC) WITH (FILLFACTOR = 95);

