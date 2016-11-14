CREATE TABLE [dbo].[Fuente_Boton] (
    [id_fuente_boton]      INT           NOT NULL,
    [descripcion]          VARCHAR (20)  NULL,
    [valor]                VARCHAR (150) NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Fuente_Boton_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Fuente_Boton] PRIMARY KEY CLUSTERED ([id_fuente_boton] ASC) WITH (FILLFACTOR = 80)
);

