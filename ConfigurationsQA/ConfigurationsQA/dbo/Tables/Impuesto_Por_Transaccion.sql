CREATE TABLE [dbo].[Impuesto_Por_Transaccion] (
    [id_impuesto_por_transaccion] INT             IDENTITY (1, 1) NOT NULL,
    [id_transaccion]              CHAR (36)       NOT NULL,
    [id_cargo]                    INT             NULL,
    [id_impuesto]                 INT             NOT NULL,
    [monto_aplicado]              DECIMAL (12, 2) NULL,
    [alicuota]                    DECIMAL (12, 2) NULL,
    [fecha_alta]                  DATETIME        NULL,
    [usuario_alta]                VARCHAR (20)    NULL,
    [fecha_modificacion]          DATETIME        NULL,
    [usuario_modificacion]        VARCHAR (20)    NULL,
    [fecha_baja]                  DATETIME        NULL,
    [usuario_baja]                VARCHAR (20)    NULL,
    [version]                     INT             NOT NULL,
    [monto_calculado]             DECIMAL (12, 2) NULL,
    [monto_calculado_devolucion]  DECIMAL (12, 2) NULL,
    [id_impuesto_tipo]            INT             NULL,
    [id_acumulador_impuesto]      INT             NULL,
    [ProviderTransactionID]       VARCHAR (64)    NULL,
    [CreateTimestamp]             DATETIME        NULL,
    [SaleConcept]                 VARCHAR (255)   NULL,
    [CredentialEmailAddress]      VARCHAR (64)    NULL,
    [Amount]                      DECIMAL (12, 2) NULL,
    [FeeAmount]                   DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Impuesto_Por_Transaccion] PRIMARY KEY CLUSTERED ([id_impuesto_por_transaccion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Impuesto_Por_Transaccion_Acumulador_Impuesto] FOREIGN KEY ([id_acumulador_impuesto]) REFERENCES [dbo].[Acumulador_Impuesto] ([id_acumulador_impuesto]),
    CONSTRAINT [FK_Impuesto_Por_Transaccion_Impuesto_Tipo] FOREIGN KEY ([id_impuesto_tipo]) REFERENCES [dbo].[Impuesto_Por_Tipo] ([id_impuesto_tipo])
);


GO
CREATE NONCLUSTERED INDEX [IX_id_transaccion]
    ON [dbo].[Impuesto_Por_Transaccion]([id_transaccion] ASC)
    INCLUDE([id_cargo], [id_impuesto], [monto_aplicado], [alicuota]) WITH (FILLFACTOR = 95);

