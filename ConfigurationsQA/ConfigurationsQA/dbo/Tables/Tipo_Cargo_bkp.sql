CREATE TABLE [dbo].[Tipo_Cargo_bkp] (
    [id_tipo_cargo]        INT           IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20)  NOT NULL,
    [descripcion]          VARCHAR (100) NOT NULL,
    [signo]                CHAR (1)      NOT NULL,
    [flag_configura_panel] BIT           NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           NOT NULL
);

