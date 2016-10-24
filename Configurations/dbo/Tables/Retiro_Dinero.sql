CREATE TABLE [dbo].[Retiro_Dinero] (
    [id_cuenta]                       INT             NULL,
    [monto]                           DECIMAL (12, 2) CONSTRAINT [DF_Retiro_Dinero_monto] DEFAULT ((0)) NULL,
    [id_informacion_bancaria_destino] INT             NULL,
    [cod_respuesta_interno]           INT             NULL,
    [cod_respuesta_servicio]          INT             NULL,
    [fecha_alta]                      DATETIME        NULL,
    [usuario_alta]                    VARCHAR (20)    NULL,
    [fecha_modificacion]              DATETIME        NULL,
    [usuario_modificacion]            VARCHAR (20)    NULL,
    [fecha_baja]                      DATETIME        NULL,
    [usuario_baja]                    VARCHAR (20)    NULL,
    [version]                         INT             CONSTRAINT [DF_Retiro_Dinero_version] DEFAULT ((0)) NOT NULL,
    [id_retiro_dinero]                INT             IDENTITY (1, 1) NOT NULL,
    [nro_control_servicio]            VARCHAR (4)     NULL,
    [nro_transaccion_servicio]        VARCHAR (6)     NULL,
    [estado_transaccion]              VARCHAR (20)    NULL,
    [canal]                           VARCHAR (20)    NULL,
    CONSTRAINT [PK_Retiro_Dinero] PRIMARY KEY CLUSTERED ([id_retiro_dinero] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Retiro_Dinero_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Retiro_Dinero_Informacion_Bancaria_Cuenta] FOREIGN KEY ([id_informacion_bancaria_destino]) REFERENCES [dbo].[Informacion_Bancaria_Cuenta] ([id_informacion_bancaria])
);

