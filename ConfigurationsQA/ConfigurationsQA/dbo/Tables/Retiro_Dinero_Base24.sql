CREATE TABLE [dbo].[Retiro_Dinero_Base24] (
    [id_retiro_dinero_Base24]  INT             IDENTITY (1, 1) NOT NULL,
    [fecha_negocio]            DATETIME        NULL,
    [fecha_retiro_dinero]      DATETIME        NULL,
    [nro_transaccion_servicio] VARCHAR (6)     NULL,
    [cbu_usuario]              VARCHAR (22)    NOT NULL,
    [monto]                    DECIMAL (12, 2) NULL,
    [fecha_alta]               DATETIME        NULL,
    [usuario_alta]             VARCHAR (20)    NULL,
    [fecha_modificacion]       DATETIME        NULL,
    [usuario_modificacion]     VARCHAR (20)    NULL,
    [fecha_baja]               DATETIME        NULL,
    [usuario_baja]             VARCHAR (20)    NULL,
    [version]                  INT             NOT NULL,
    [estado_transaccion]       VARCHAR (20)    NULL,
    CONSTRAINT [PK_Retiro_Dinero_Base24] PRIMARY KEY CLUSTERED ([id_retiro_dinero_Base24] ASC) WITH (FILLFACTOR = 80)
);

