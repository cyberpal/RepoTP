CREATE TABLE [dbo].[Promocion_Bonificacion_tmp] (
    [id_bonificacion]           INT             NOT NULL,
    [id_log_proceso]            INT             NULL,
    [id_cuenta]                 INT             NULL,
    [eMail]                     VARCHAR (50)    NULL,
    [fecha_envio_mail]          DATETIME        NULL,
    [flag_envio_mail]           BIT             NULL,
    [monto]                     DECIMAL (15, 2) NULL,
    [plazo_liberacion]          INT             NULL,
    [fecha_desde]               DATETIME        NULL,
    [fecha_hasta]               DATETIME        NULL,
    [tope_maximo]               DECIMAL (15, 2) NULL,
    [fecha_alta]                DATETIME        NULL,
    [usuario_alta]              VARCHAR (20)    NULL,
    [fecha_modificacion]        DATETIME        NULL,
    [usuario_modificacion]      VARCHAR (20)    NULL,
    [fecha_baja]                DATETIME        NULL,
    [id_promocion_comprador]    INT             NOT NULL,
    [cant_tope_bonificaciones]  INT             NULL,
    [fecha_tope_transferencias] DATETIME        NULL,
    CONSTRAINT [PK_Promocion_Bonificacion_tmp] PRIMARY KEY CLUSTERED ([id_bonificacion] ASC)
);

