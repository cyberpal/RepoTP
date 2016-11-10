CREATE TABLE [dbo].[Disponible_control_txs_tmp] (
    [id_txs_tmp]             INT             IDENTITY (1, 1) NOT NULL,
    [Id]                     VARCHAR (36)    NULL,
    [LocationIdentification] INT             NULL,
    [CashoutTimestamp]       DATETIME        NULL,
    [Amount]                 DECIMAL (12, 2) NULL,
    CONSTRAINT [PK_Disponible_control_txs_tmp] PRIMARY KEY CLUSTERED ([id_txs_tmp] ASC)
);

