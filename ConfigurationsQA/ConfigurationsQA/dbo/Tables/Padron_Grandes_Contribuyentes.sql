CREATE TABLE [dbo].[Padron_Grandes_Contribuyentes] (
    [id]          INT          NOT NULL,
    [numero_CUIT] VARCHAR (11) NOT NULL,
    CONSTRAINT [PK_Padron_Grandes_Contribuy] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

