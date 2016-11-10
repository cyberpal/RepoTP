CREATE TABLE [dbo].[Impuesto_Por_Jurisdiccion_IIBB] (
    [id_impuesto_jurisdiccion_iibb] INT IDENTITY (1, 1) NOT NULL,
    [id_impuesto_tipo]              INT NOT NULL,
    [id_jurisdiccion_iibb]          INT NOT NULL,
    CONSTRAINT [PK_Impuesto_Por_Jurisdiccion_IIBB] PRIMARY KEY CLUSTERED ([id_impuesto_jurisdiccion_iibb] ASC),
    CONSTRAINT [FK_Impuesto_Por_Jurisdiccion_IIBB_Impuesto_Tipo] FOREIGN KEY ([id_impuesto_tipo]) REFERENCES [dbo].[Impuesto_Por_Tipo] ([id_impuesto_tipo]),
    CONSTRAINT [FK_Impuesto_Por_Jurisdiccion_IIBB_Jurisdiccion_IIBB] FOREIGN KEY ([id_jurisdiccion_iibb]) REFERENCES [dbo].[Jurisdiccion_IIBB] ([id_jurisdiccion_iibb])
);

