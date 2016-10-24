CREATE TABLE [dbo].[Padron_Regimen_Simplificado] (
    [id]          INT          NOT NULL,
    [numero_CUIT] VARCHAR (11) NOT NULL,
    CONSTRAINT [PK_Padron_Regimen_Simplific] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

