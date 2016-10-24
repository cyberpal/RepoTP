CREATE TABLE [dbo].[Detalle_Facturacion] (
    [id_detalle_facturacion] INT             IDENTITY (1, 1) NOT NULL,
    [id_item_facturacion]    INT             NOT NULL,
    [id_transaccion]         CHAR (36)       NOT NULL,
    [fecha_alta]             DATETIME        NOT NULL,
    [usuario_alta]           VARCHAR (20)    NOT NULL,
    [version]                INT             CONSTRAINT [DF_Detalle_Facturacion_version] DEFAULT ((0)) NOT NULL,
    [ProviderTransactionID]  VARCHAR (64)    NULL,
    [createTimestamp]        DATETIME        NULL,
    [saleConcept]            VARCHAR (255)   NULL,
    [CredentialEmailAddress] VARCHAR (64)    NULL,
    [amount]                 DECIMAL (12, 2) NULL,
    [feeAmount]              DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Detalle_Facturacion] PRIMARY KEY CLUSTERED ([id_detalle_facturacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK__Detalle_F_id_items_fact] FOREIGN KEY ([id_item_facturacion]) REFERENCES [dbo].[Item_Facturacion] ([id_item_facturacion])
);

