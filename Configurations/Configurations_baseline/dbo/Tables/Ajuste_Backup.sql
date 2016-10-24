CREATE TABLE [dbo].[Ajuste_Backup] (
    [id_ajuste]            INT             NOT NULL,
    [id_codigo_operacion]  INT             NOT NULL,
    [id_cuenta]            INT             NOT NULL,
    [monto]                NUMERIC (18, 2) NOT NULL,
    [id_motivo_ajuste]     INT             NOT NULL,
    [estado_ajuste]        VARCHAR (20)    NOT NULL,
    [fecha_alta]           DATETIME        NOT NULL,
    [usuario_alta]         VARCHAR (20)    NOT NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             NOT NULL
);

