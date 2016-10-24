CREATE TABLE [dbo].[Medio_Pago_Cuenta] (
    [id_medio_pago_cuenta]      INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                 INT             NOT NULL,
    [id_banco]                  INT             NOT NULL,
    [encript_numero_tarjeta]    VARCHAR (500)   NOT NULL,
    [mascara_numero_tarjeta]    VARCHAR (20)    NOT NULL,
    [hash_numero_tarjeta]       VARCHAR (256)   NOT NULL,
    [fecha_vencimiento]         VARCHAR (6)     NOT NULL,
    [id_estado_medio_pago]      INT             NOT NULL,
    [flag_favorito]             BIT             CONSTRAINT [DF_Medio_Pago_Cuenta_flag_favotrito] DEFAULT ((0)) NOT NULL,
    [monto_a_validar]           DECIMAL (12, 2) NULL,
    [id_nivel_riesgo]           INT             NOT NULL,
    [fecha_alta]                DATETIME        NULL,
    [usuario_alta]              VARCHAR (20)    NULL,
    [fecha_modificacion]        DATETIME        NULL,
    [usuario_modificacion]      VARCHAR (20)    NULL,
    [fecha_baja]                DATETIME        NULL,
    [usuario_baja]              VARCHAR (20)    NULL,
    [version]                   INT             CONSTRAINT [DF_Medio_Pago_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_medio_pago]             INT             NOT NULL,
    [id_tipo_medio_pago]        INT             NULL,
    [medio_notificado]          BIT             DEFAULT ((0)) NOT NULL,
    [id_transaccion_validacion] VARCHAR (36)    NULL,
    [flag_montoAcreditado]      BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_medio_pago_cuenta] PRIMARY KEY CLUSTERED ([id_medio_pago_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Medio_Pago_Cuenta_id_banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Medio_Pago_Cuenta_id_cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Medio_Pago_Cuenta_id_estado_medio_pago] FOREIGN KEY ([id_estado_medio_pago]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Medio_Pago_Cuenta_id_medio_pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago]),
    CONSTRAINT [FK_MPC_tipo_medio_pago] FOREIGN KEY ([id_tipo_medio_pago]) REFERENCES [dbo].[Tipo_Medio_Pago] ([id_tipo_medio_pago])
);


GO
CREATE NONCLUSTERED INDEX [IX_Medio_Pago_Cuenta_id_cuenta]
    ON [dbo].[Medio_Pago_Cuenta]([id_cuenta] ASC, [hash_numero_tarjeta] ASC, [fecha_baja] ASC) WITH (FILLFACTOR = 95);

