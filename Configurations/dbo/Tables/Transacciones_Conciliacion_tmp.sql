CREATE TABLE [dbo].[Transacciones_Conciliacion_tmp] (
    [Id]                        VARCHAR (36)    NULL,
    [InvoiceBarCode]            VARCHAR (128)   NULL,
    [Amount]                    DECIMAL (12, 2) NULL,
    [ProductIdentification]     INT             NULL,
    [CurrencyCode]              INT             NULL,
    [CredentialCardHash]        VARCHAR (80)    NULL,
    [CredentialMask]            VARCHAR (20)    NULL,
    [ProviderAuthorizationCode] VARCHAR (8)     NULL,
    [CreateTimestamp]           DATE            NULL,
    [FacilitiesPayments]        INT             NULL,
    [TicketNumber]              INT             NULL,
    [CouponStatus]              VARCHAR (50)    NULL,
    [TransactionStatus]         VARCHAR (20)    NULL,
    [TaxAmount]                 DECIMAL (12, 2) NULL,
    [FeeAmount]                 DECIMAL (12, 2) NULL,
    [LocationIdentification]    INT             NULL,
    [SaleConcept]               VARCHAR (255)   NULL,
    [CredentialEmailAddress]    VARCHAR (64)    NULL,
    [CredentialHolderName]      VARCHAR (48)    NULL
);

