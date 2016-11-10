CREATE TABLE [dbo].[Detalle_Archivo] (
    [id_archivo] INT           NULL,
    [detalles]   VARCHAR (MAX) NULL,
    FOREIGN KEY ([id_archivo]) REFERENCES [dbo].[Archivo_Conciliacion] ([id])
);

