CREATE TABLE [dbo].[Color_Boton] (
    [id_color_boton]       INT          NOT NULL,
    [descripcion]          VARCHAR (20) NULL,
    [codigo_color]         VARCHAR (20) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Color_Boton_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Color_Boton] PRIMARY KEY CLUSTERED ([id_color_boton] ASC) WITH (FILLFACTOR = 80)
);

