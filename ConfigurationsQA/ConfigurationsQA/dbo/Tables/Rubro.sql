CREATE TABLE [dbo].[Rubro] (
    [id_rubro]             INT          NOT NULL,
    [codigo_rubro]         VARCHAR (4)  NOT NULL,
    [descripcion]          VARCHAR (40) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Rubro_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Rubro] PRIMARY KEY CLUSTERED ([id_rubro] ASC) WITH (FILLFACTOR = 80)
);

