CREATE TABLE [dbo].[Log_Movimiento_Cuenta_Virtual] (
    [id_log_movimiento]         INT             IDENTITY (1, 1) NOT NULL,
    [id_tipo_movimiento]        INT             NOT NULL,
    [id_tipo_origen_movimiento] INT             NOT NULL,
    [id_log_proceso]            INT             NULL,
    [id_cuenta]                 INT             NOT NULL,
    [monto_disponible]          DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Vi_monto] DEFAULT ((0)) NULL,
    [disponible_anterior]       DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Vi_disponible] DEFAULT ((0)) NULL,
    [disponible_actual]         DECIMAL (12, 2) CONSTRAINT [DF_Log_Movim_disponible_actual] DEFAULT ((0)) NULL,
    [saldo_cuenta_anterior]     DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Vi_saldo_cuen] DEFAULT ((0)) NULL,
    [saldo_cuenta_actual]       DECIMAL (12, 2) CONSTRAINT [DF_Log_Movim_saldo_saldo_cuenta_actual] DEFAULT ((0)) NULL,
    [saldo_revision_anterior]   DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Vi_saldo_revi] DEFAULT ((0)) NULL,
    [saldo_revision_actual]     DECIMAL (12, 2) CONSTRAINT [DF_Log_Movim_saldo_revision_actual] DEFAULT ((0)) NULL,
    [fecha_alta]                DATETIME        NULL,
    [usuario_alta]              VARCHAR (20)    NULL,
    [fecha_modificacion]        DATETIME        NULL,
    [usuario_modificacion]      VARCHAR (20)    NULL,
    [fecha_baja]                DATETIME        NULL,
    [usuario_baja]              VARCHAR (20)    NULL,
    [version]                   INT             CONSTRAINT [DF_Log_Movimiento_Cuenta_Virtual_version] DEFAULT ((0)) NOT NULL,
    [monto_saldo_cuenta]        DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Virtual_monto_saldo_cuenta] DEFAULT ((0)) NULL,
    [monto_revision]            DECIMAL (12, 2) CONSTRAINT [DF_Log_Movimiento_Cuenta_Virtual_monto_revision] DEFAULT ((0)) NULL,
    [id_canal]                  INT             NULL,
    CONSTRAINT [PK_Log_Movimiento_Cuenta_Vi] PRIMARY KEY CLUSTERED ([id_log_movimiento] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Log_Movimiento_Cuenta_Vi_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Log_Movimiento_Cuenta_Vi_Tipo_id_tipo_movimiento] FOREIGN KEY ([id_tipo_movimiento]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Log_Movimiento_Cuenta_Vi_Tipo_id_tipo_origen_movimiento] FOREIGN KEY ([id_tipo_origen_movimiento]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Log_Movimiento_Cuenta_Virtual_Canal_Adhesion] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal])
);


GO
CREATE NONCLUSTERED INDEX [idx_BatchFacturacion_LogMoviCuentaVir]
    ON [dbo].[Log_Movimiento_Cuenta_Virtual]([id_cuenta] ASC, [fecha_alta] ASC)
    INCLUDE([disponible_actual], [saldo_cuenta_actual], [saldo_revision_actual]);

