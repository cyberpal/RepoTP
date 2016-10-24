CREATE TABLE [dbo].[cargo_cuenta_BKP] (
    [id_cargo_cuenta]       INT             IDENTITY (1, 1) NOT NULL,
    [id_cargo]              INT             NULL,
    [id_cuenta]             INT             NULL,
    [id_tipo_aplicacion]    INT             NULL,
    [valor]                 DECIMAL (12, 2) NULL,
    [fecha_inicio_vigencia] DATETIME        NULL,
    [fecha_fin_vigencia]    DATETIME        NULL,
    [fecha_alta]            DATETIME        NULL,
    [usuario_alta]          VARCHAR (20)    NULL,
    [fecha_modificacion]    DATETIME        NULL,
    [usuario_modificacion]  VARCHAR (20)    NULL,
    [fecha_baja]            DATETIME        NULL,
    [usuario_baja]          VARCHAR (20)    NULL,
    [version]               INT             NOT NULL
);

