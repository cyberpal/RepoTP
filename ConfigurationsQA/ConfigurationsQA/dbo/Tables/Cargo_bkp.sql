CREATE TABLE [dbo].[Cargo_bkp] (
    [id_cargo]             INT             IDENTITY (1, 1) NOT NULL,
    [id_tipo_medio_pago]   INT             NULL,
    [id_tipo_cuenta]       INT             NULL,
    [id_base_de_calculo]   INT             NULL,
    [id_tipo_aplicacion]   INT             NULL,
    [valor]                DECIMAL (12, 2) NULL,
    [flag_estado]          BIT             NOT NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             NOT NULL,
    [flag_permite_baja]    BIT             NOT NULL,
    [id_tipo_cargo]        INT             NULL,
    [grupo_cargo]          INT             NULL,
    [id_grupo_rubro]       INT             NULL
);

