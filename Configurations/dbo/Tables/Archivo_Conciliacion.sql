CREATE TABLE [dbo].[Archivo_Conciliacion] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [nombre_archivo] VARCHAR (150) NULL,
    [descripcion]    VARCHAR (100) NULL,
    [flag_procesado] BIT           DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

