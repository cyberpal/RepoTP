CREATE TABLE [dbo].[Padron_Alto_Riesgo_Fiscal] (
    [id]          INT          NOT NULL,
    [numero_CUIT] VARCHAR (11) NOT NULL,
    CONSTRAINT [PK_Padron_Alto_Riesgo_Fisca] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

