CREATE TABLE [dbo].[Archivo_abm_cuenta] (
    [id]                      INT           IDENTITY (1, 1) NOT NULL,
    [nombre_archivo]          VARCHAR (150) NULL,
    [cantidad_registros]      INT           NULL,
    [fecha]                   DATETIME      DEFAULT (getdate()) NULL,
    [archivo_alta_aceptados]  VARCHAR (150) NULL,
    [cantidad_aceptados]      INT           DEFAULT ((0)) NULL,
    [archivo_alta_rechazados] VARCHAR (150) NULL,
    [cantidad_rechazados]     INT           DEFAULT ((0)) NULL,
    [flag_procesado]          BIT           DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Archivo_abm_cuenta] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

