CREATE TABLE [dbo].[Procesar_Facturacion_tmp] (
    [I]                      INT             IDENTITY (1, 1) NOT NULL,
    [id]                     VARCHAR (36)    NULL,
    [LocationIdentification] INT             NULL,
    [LiquidationTimeStamp]   DATETIME        NULL,
    [LiquidationStatus]      INT             NULL,
    [BillingTimeStamp]       DATETIME        NULL,
    [BillingStatus]          INT             NULL,
    [CreateTimeStamp]        DATETIME        NULL,
    [FeeAmount]              DECIMAL (15, 2) NULL,
    [TaxAmount]              DECIMAL (15, 2) NULL,
    [OperationName]          VARCHAR (128)   NULL,
    [ProviderTransactionID]  VARCHAR (64)    NULL,
    [saleConcept]            VARCHAR (255)   NULL,
    [CredentialEmailAddress] VARCHAR (64)    NULL,
    [amount]                 DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Procesar_Facturacion_tmp] PRIMARY KEY CLUSTERED ([I] ASC) WITH (FILLFACTOR = 80)
);

