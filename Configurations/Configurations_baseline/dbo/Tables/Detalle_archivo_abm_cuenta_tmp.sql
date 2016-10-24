CREATE TABLE [dbo].[Detalle_archivo_abm_cuenta_tmp] (
    [id_detalle] INT           IDENTITY (1, 1) NOT NULL,
    [id_archivo] INT           NULL,
    [detalle]    VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Detalle_archivo_abm_cuenta_tmp] PRIMARY KEY CLUSTERED ([id_detalle] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([id_archivo]) REFERENCES [dbo].[Archivo_abm_cuenta] ([id])
);

