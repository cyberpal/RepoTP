CREATE TABLE [dbo].[Jurisdiccion_IIBB] (
    [id_jurisdiccion_iibb] INT           IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20)  NOT NULL,
    [descripcion]          VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_Jurisdiccion_IIBB] PRIMARY KEY CLUSTERED ([id_jurisdiccion_iibb] ASC)
);

