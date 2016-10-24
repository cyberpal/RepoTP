CREATE TABLE [dbo].[Impuesto_Amex] (
    [id_impuesto_amex] INT          IDENTITY (1, 1) NOT NULL,
    [EpaTaxType]       INT          NOT NULL,
    [tipo_impuesto]    VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Impuesto_Amex] PRIMARY KEY CLUSTERED ([id_impuesto_amex] ASC) WITH (FILLFACTOR = 80)
);

