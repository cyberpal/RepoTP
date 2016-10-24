CREATE TABLE [dbo].[Actividad_MP_Cuenta] (
    [id_actividad_mp]      INT             IDENTITY (1, 1) NOT NULL,
    [id_mp_cuenta]         INT             NOT NULL,
    [cant_tx_dia]          INT             CONSTRAINT [DF_Actividad_MP_cant_tx_di] DEFAULT ((0)) NULL,
    [monto_tx_dia]         DECIMAL (12, 2) CONSTRAINT [DF_Actividad_MP_monto_tx_d] DEFAULT ((0)) NULL,
    [fecha_compra]         DATETIME        NOT NULL,
    [id_log_proceso]       INT             NOT NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             CONSTRAINT [DF_Actividad_MP_version] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_Actividad_MP_Cuenta] PRIMARY KEY CLUSTERED ([id_actividad_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Actividad_MP_Cuenta_id_mp_cuenta] FOREIGN KEY ([id_mp_cuenta]) REFERENCES [dbo].[Medio_Pago_Cuenta] ([id_medio_pago_cuenta])
);

