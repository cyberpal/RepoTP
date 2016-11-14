CREATE TABLE [dbo].[Tamanio_Boton] (
    [id_tamano_boton]      INT          NOT NULL,
    [descripcion]          VARCHAR (20) NULL,
    [valor]                VARCHAR (20) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Tamanio_Boton_version] DEFAULT ((0)) NOT NULL,
    [alto]                 FLOAT (53)   NULL,
    [ancho]                FLOAT (53)   NULL,
    CONSTRAINT [PK_Tamanio_Boton] PRIMARY KEY CLUSTERED ([id_tamano_boton] ASC) WITH (FILLFACTOR = 80)
);

