CREATE TABLE [dbo].[Localidad] (
    [id_localidad]         INT          NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [id_provincia]         INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Localidad_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Localidad] PRIMARY KEY CLUSTERED ([id_localidad] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Localidad_Provincia] FOREIGN KEY ([id_provincia]) REFERENCES [dbo].[Provincia] ([id_provincia])
);

