CREATE TABLE [dbo].[Padron_Mensual_Rentas] (
    [id]          INT             NOT NULL,
    [numero_CUIT] VARCHAR (11)    NOT NULL,
    [alicuota]    DECIMAL (12, 2) NOT NULL,
    CONSTRAINT [PK_Padron_Mensual_Rentas] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

