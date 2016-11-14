CREATE TABLE [dbo].[Inconsistencia_En_Transaccion] (
    [id_inconsistencia]     INT           IDENTITY (1, 1) NOT NULL,
    [fecha_de_verificacion] DATETIME      NOT NULL,
    [id_log_proceso]        INT           NOT NULL,
    [id_transaccion]        VARCHAR (36)  NOT NULL,
    [campo]                 VARCHAR (100) NOT NULL,
    [valor_en_operations]   VARCHAR (512) NULL,
    [valor_en_transactions] VARCHAR (512) NULL,
    CONSTRAINT [PK_Inconsistencia_En_Transaccion] PRIMARY KEY CLUSTERED ([id_inconsistencia] ASC) WITH (FILLFACTOR = 80)
);

