CREATE TABLE [dbo].[Impuesto_Por_Tipo_bkp] (
    [id_impuesto]          INT             NOT NULL,
    [id_tipo]              INT             NULL,
    [id_tipo_aplicacion]   INT             NULL,
    [id_base_de_calculo]   INT             NULL,
    [alicuota]             DECIMAL (12, 2) NULL,
    [minimo_no_imponible]  DECIMAL (12, 2) NULL,
    [flag_estado]          BIT             NOT NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             NOT NULL,
    [id_impuesto_tipo]     INT             IDENTITY (1, 1) NOT NULL
);

