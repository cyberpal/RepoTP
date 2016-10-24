CREATE TABLE [dbo].[Ajuste_Amex] (
    [id_ajuste_amex] INT          IDENTITY (1, 1) NOT NULL,
    [codigo]         VARCHAR (20) NOT NULL,
    [tipo_impuesto]  VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Ajuste_Amex] PRIMARY KEY CLUSTERED ([id_ajuste_amex] ASC) WITH (FILLFACTOR = 80)
);

