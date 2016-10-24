﻿CREATE TABLE [dbo].[transactions] (
    [Id]                               CHAR (36)       NOT NULL,
    [CreateTimestamp]                  DATETIME        NULL,
    [UpdateTimestamp]                  DATETIME        NULL,
    [TransportTimestamp]               DATETIME        NULL,
    [RequestInputTimestamp]            DATETIME        NULL,
    [RequestOutputTimestamp]           DATETIME        NULL,
    [AnswerInputTimestamp]             DATETIME        NULL,
    [AnswerOutputTimestamp]            DATETIME        NULL,
    [DeviceIdentification]             VARCHAR (36)    NULL,
    [LocationIdentification]           INT             NULL,
    [ServiceName]                      VARCHAR (128)   NULL,
    [OperationName]                    VARCHAR (128)   NULL,
    [SequenceNumber]                   INT             NULL,
    [Status]                           INT             NULL,
    [UserIdentification]               VARCHAR (36)    NULL,
    [ProviderIdentification]           VARCHAR (36)    NULL,
    [ProviderTransactionID]            VARCHAR (64)    NULL,
    [DeviceTransactionID]              VARCHAR (64)    NULL,
    [SyncStatus]                       INT             NULL,
    [SyncTimestamp]                    DATETIME        NULL,
    [ProductIdentification]            INT             NULL,
    [RetrievalReferenceNumber]         VARCHAR (45)    NULL,
    [FacilitiesPayments]               INT             NULL,
    [FacilitiesType]                   CHAR (1)        NULL,
    [CurrencyCode]                     INT             NULL,
    [Amount]                           DECIMAL (12, 2) NULL,
    [FeeAmount]                        DECIMAL (12, 2) NULL,
    [TaxAmount]                        DECIMAL (12, 2) NULL,
    [ComissionAmount]                  DECIMAL (12, 2) NULL,
    [ServiceChargeAmount]              DECIMAL (12, 2) NULL,
    [MerchantIdentification]           VARCHAR (36)    NULL,
    [ProviderDeviceIdentification]     VARCHAR (36)    NULL,
    [ReverseStatus]                    INT             NULL,
    [ReverseTimestamp]                 DATETIME        NULL,
    [VoidStatus]                       INT             NULL,
    [VoidTimestamp]                    DATETIME        NULL,
    [VoidUserIdentification]           VARCHAR (36)    NULL,
    [RefundStatus]                     INT             NULL,
    [RefundTimestamp]                  DATETIME        NULL,
    [RefundUserIdentification]         VARCHAR (36)    NULL,
    [RefundAmount]                     DECIMAL (12, 2) NULL,
    [CloseStatus]                      INT             NULL,
    [CloseTimestamp]                   DATETIME        NULL,
    [CloseUserIdentification]          VARCHAR (36)    NULL,
    [SettlementStatus]                 INT             NULL,
    [SettlementTimestamp]              DATETIME        NULL,
    [SettlementUserIdentification]     VARCHAR (36)    NULL,
    [SettlementAmount]                 DECIMAL (12, 2) NULL,
    [SettlementTransactionId]          CHAR (36)       NULL,
    [RevisionStatus]                   INT             NULL,
    [RevisionTimestamp]                DATETIME        NULL,
    [RevisionReason]                   VARCHAR (64)    NULL,
    [RevisionSource]                   VARCHAR (36)    NULL,
    [BatchNumber]                      INT             NULL,
    [TicketNumber]                     INT             NULL,
    [ProviderBatchNumber]              INT             NULL,
    [ProviderTicketNumber]             INT             NULL,
    [ProviderTraceNumber]              BIGINT          NULL,
    [ProviderAuthorizationCode]        VARCHAR (8)     NULL,
    [CustomerIdentification]           VARCHAR (36)    NULL,
    [CredentialInputMode]              INT             NULL,
    [CredentialMask]                   VARCHAR (20)    NULL,
    [CredentialEncrypted]              VARCHAR (512)   NULL,
    [CredentialExpDate]                INT             NULL,
    [CredentialCardHash]               VARCHAR (80)    NULL,
    [CredentialHolderName]             VARCHAR (48)    NULL,
    [CredentialAddress]                VARCHAR (48)    NULL,
    [CredentialDocumentType]           VARCHAR (36)    NULL,
    [CredentialDocumentNumber]         VARCHAR (24)    NULL,
    [CredentialEmailAddress]           VARCHAR (64)    NULL,
    [DeviceFingerprint]                VARCHAR (36)    NULL,
    [ResultCode]                       INT             NULL,
    [ResultMessage]                    VARCHAR (255)   NULL,
    [ProviderResultCode]               VARCHAR (32)    NULL,
    [ProviderResultMessage]            VARCHAR (255)   NULL,
    [Channel]                          VARCHAR (36)    NULL,
    [CaptureAddress]                   VARCHAR (45)    NULL,
    [CaptureTimestamp]                 DATETIME        NULL,
    [RequestAddress]                   VARCHAR (45)    NULL,
    [RequestTimestamp]                 DATETIME        NULL,
    [AnswerAddress]                    VARCHAR (45)    NULL,
    [AnswerTimestamp]                  DATETIME        NULL,
    [RedirectURLOK]                    VARCHAR (255)   NULL,
    [RedirectURLError]                 VARCHAR (255)   NULL,
    [CredentialBirthday]               DATE            NULL,
    [BillHolderName]                   VARCHAR (48)    NULL,
    [BillHolderDocumentType]           VARCHAR (36)    NULL,
    [BillHolderDocumentNumber]         VARCHAR (24)    NULL,
    [ProviderCustomerCode]             INT             NULL,
    [ProviderCustomerAdditionalCode]   INT             NULL,
    [ChargeLatePaymentAmount]          DECIMAL (12, 2) NULL,
    [DifferenceBetweenFirstExpiration] INT             NULL,
    [DaysAfterFirstExpiration]         INT             NULL,
    [CouponExpirationDate]             DATE            NULL,
    [InvoiceExpirationDate]            DATETIME        NULL,
    [PaymentBarCode]                   VARCHAR (128)   NULL,
    [InvoiceBarCode]                   VARCHAR (128)   NULL,
    [LiquidationStatus]                INT             CONSTRAINT [DF_Txs_LiquidationStatus] DEFAULT ((0)) NOT NULL,
    [LiquidationTimestamp]             DATETIME        NULL,
    [ReconciliationStatus]             INT             CONSTRAINT [DF_Txs_ReconciliationStatus] DEFAULT ((0)) NOT NULL,
    [ReconciliationTimestamp]          DATETIME        NULL,
    [AvailableStatus]                  INT             CONSTRAINT [DF_Txs_AvailableStatus] DEFAULT ((0)) NOT NULL,
    [AvailableTimestamp]               DATETIME        NULL,
    [AvailableAmount]                  DECIMAL (12, 2) NULL,
    [BillingStatus]                    INT             CONSTRAINT [DF_Txs_BillingStatus] DEFAULT ((0)) NOT NULL,
    [BillingTimestamp]                 DATETIME        NULL,
    [ProcessorResultCode]              VARCHAR (16)    NULL,
    [ProcessorResultMessage]           VARCHAR (255)   NULL,
    [ButtonId]                         INT             NULL,
    [ButtonExternalId]                 VARCHAR (128)   NULL,
    [ButtonMinimumAmount]              DECIMAL (12, 2) NULL,
    [ButtonMaximumAmount]              DECIMAL (12, 2) NULL,
    [SaleConcept]                      VARCHAR (255)   NULL,
    [MerchantActivityCode]             INT             NULL,
    [ChargebackStatus]                 INT             NULL,
    [ChargebackTimestamp]              DATETIME        NULL,
    [ChargebackReason]                 VARCHAR (64)    NULL,
    [CashoutStatus]                    INT             CONSTRAINT [DF_Txs_CashoutStatus] DEFAULT ((0)) NOT NULL,
    [CashoutTimestamp]                 DATETIME        NULL,
    [FilingDeadline]                   DATETIME        NULL,
    [PaymentDeadline]                  DATETIME        NULL,
    [PaymentTimestamp]                 DATETIME        NULL,
    [PaymentStatus]                    INT             NULL,
    [CouponStatus]                     VARCHAR (50)    NULL,
    [CouponDaysBetweenExpDates]        INT             NULL,
    [CouponValidityDays]               INT             NULL,
    [CouponFee]                        DECIMAL (18)    NULL,
    [CouponSecondExpirationDate]       DATE            NULL,
    [CouponClientCode]                 VARCHAR (32)    NULL,
    [CouponSubscriber]                 VARCHAR (128)   NULL,
    [CouponOperationId]                VARCHAR (64)    NULL,
    [OriginalOperationId]              CHAR (36)       NULL,
    [TransactionStatus]                VARCHAR (20)    NULL,
    [ProductType]                      INT             NULL,
    [BankIdentification]               INT             NULL,
    [BuyerAccountIdentification]       INT             NULL,
    [PrivateRequestKey]                VARCHAR (48)    NULL,
    [PublicRequestKey]                 VARCHAR (48)    NULL,
    [PrivateAnswerKey]                 VARCHAR (48)    NULL,
    [PublicAnswerKey]                  VARCHAR (48)    NULL,
    [PublicIdentification]             DECIMAL (9)     NULL,
    [id_medio_pago_cuenta]             INT             NULL,
    [AmountBuyer]                      DECIMAL (12, 2) NULL,
    [FeeAmountBuyer]                   DECIMAL (12, 2) NULL,
    [TaxAmountBuyer]                   DECIMAL (12, 2) NULL,
    [PromotionIdentification]          INT             NULL,
    [AdditionalData]                   XML             NULL,
    [FraudResultCode]                  VARCHAR (16)    NULL,
    [FraudTransactionID]               VARCHAR (64)    NULL,
    [PresentationTimestamp]            DATETIME        NULL,
    [DocumentationTimestamp]           DATETIME        NULL,
    [DocumentationURL]                 VARCHAR (256)   NULL,
    [PushNotifyMethod]                 VARCHAR (64)    NULL,
    [PushNotifyEndpoint]               VARCHAR (256)   NULL,
    [PushNotifyStates]                 VARCHAR (256)   NULL,
    [PushNotifySentTimestamp]          DATETIME        NULL,
    [PushNotifyCounter]                INT             NULL,
    [Version]                          VARCHAR (10)    NULL,
    [BuyerIP]                          VARCHAR (15)    NULL,
    [SDK]                              VARCHAR (255)   NULL,
    [SDKVersion]                       VARCHAR (255)   NULL,
    [LenguageVersion]                  VARCHAR (255)   NULL,
    [PluginVersion]                    VARCHAR (255)   NULL,
    [ECommerceName]                    VARCHAR (255)   NULL,
    [ECommerceVersion]                 VARCHAR (255)   NULL,
    [CMSVersion]                       VARCHAR (255)   NULL,
    [flag_formulario_cargado]          BIT             NULL,
    [CashoutReleaseStatus]             INT             NULL,
    [CashoutReleaseTimestamp]          DATETIME        NULL,
    [MaxInstallments]                  INT             NULL
);

