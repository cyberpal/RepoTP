CREATE TABLE [dbo].[Relacion_Banco_CU] (
    [id_banco_cu]          INT          NOT NULL,
    [cod_banco_cu]         VARCHAR (3)  NOT NULL,
    [id_tipo_medio_pago]   INT          NOT NULL,
    [cod_banco_ext]        VARCHAR (3)  NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          NULL,
    CONSTRAINT [uc_relacion_banco_cu] UNIQUE NONCLUSTERED ([id_banco_cu] ASC, [id_tipo_medio_pago] ASC, [cod_banco_ext] ASC)
);

