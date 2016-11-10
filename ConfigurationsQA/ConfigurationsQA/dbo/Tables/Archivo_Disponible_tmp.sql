CREATE TABLE [dbo].[Archivo_Disponible_tmp] (
    [nombre_archivo] VARCHAR (100) NULL,
    [registro]       VARCHAR (200) NULL,
    [flag_mail]      BIT           DEFAULT ((0)) NOT NULL
);

