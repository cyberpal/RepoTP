CREATE TABLE [dbo].[Apariencia_Boton] (
    [id_apariencia_boton]  INT          NOT NULL,
    [descripcion]          VARCHAR (20) NULL,
    [color_fondo]          VARCHAR (20) NULL,
    [color_fuente]         VARCHAR (20) NULL,
    [color_borde]          VARCHAR (20) NULL,
    [fuente]               VARCHAR (20) NULL,
    [tamanio]              VARCHAR (20) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Apariencia_Boton_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Apariencia_Boton] PRIMARY KEY CLUSTERED ([id_apariencia_boton] ASC) WITH (FILLFACTOR = 80)
);

