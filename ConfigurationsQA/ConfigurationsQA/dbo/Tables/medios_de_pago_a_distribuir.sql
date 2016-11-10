CREATE TABLE [dbo].[medios_de_pago_a_distribuir] (
    [id_mpd]        SMALLINT     IDENTITY (1, 1) NOT NULL,
    [id_medio_pago] INT          NULL,
    [codigo]        VARCHAR (20) NULL,
    CONSTRAINT [PK_medios_de_pago_a_distribuir] PRIMARY KEY CLUSTERED ([id_mpd] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_medios_de_pago_a_distribuir_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

