CREATE TABLE [dbo].[Moneda] (
    [id_moneda]            INT          NOT NULL,
    [codigo]               VARCHAR (5)  NULL,
    [nombre]               VARCHAR (50) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Moneda_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Moneda] PRIMARY KEY CLUSTERED ([id_moneda] ASC) WITH (FILLFACTOR = 80)
);

