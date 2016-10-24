CREATE TABLE [dbo].[Detalle_Analisis_De_Saldo] (
    [id_detalle]             INT             IDENTITY (1, 1) NOT NULL,
    [fecha_de_analisis]      DATETIME        NOT NULL,
    [tipo_movimiento]        CHAR (3)        NOT NULL,
    [id_char]                CHAR (36)       NULL,
    [id_int]                 INT             NULL,
    [id_cuenta]              INT             NULL,
    [importe_movimiento]     DECIMAL (12, 2) NULL,
    [fecha_movimiento]       DATETIME        NULL,
    [id_log_proceso]         INT             NULL,
    [fecha_inicio_ejecucion] DATETIME        NULL,
    [fecha_fin_ejecucion]    DATETIME        NULL,
    [id_log_movimiento]      INT             NULL,
    [flag_impactar_en_saldo] BIT             NOT NULL,
    [impacto_en_saldo_ok]    BIT             NULL,
    CONSTRAINT [PK_Detalle_Analisis_De_Saldo] PRIMARY KEY CLUSTERED ([id_detalle] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Detalle_Analisis_De_Saldo]
    ON [dbo].[Detalle_Analisis_De_Saldo]([id_log_movimiento] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Detalle_Analisis_De_Saldo_1]
    ON [dbo].[Detalle_Analisis_De_Saldo]([id_cuenta] ASC, [id_log_proceso] ASC) WITH (FILLFACTOR = 95);

