CREATE TABLE [dbo].[Limite] (
    [id_limite]                 INT             IDENTITY (1, 1) NOT NULL,
    [id_tipo_limite]            INT             NOT NULL,
    [id_tipo_aplicacion_limite] INT             NOT NULL,
    [id_tipo_condicion_IVA]     INT             NULL,
    [id_tipo_cuenta]            INT             NULL,
    [id_rubro]                  INT             NULL,
    [id_cuenta]                 INT             NULL,
    [trxs_diario]               INT             NULL,
    [trxs_mensual]              INT             NULL,
    [trxs_semestral]            INT             NULL,
    [importe_operacion]         DECIMAL (12, 2) NULL,
    [importe_diario]            DECIMAL (12, 2) NULL,
    [importe_mensual]           DECIMAL (12, 2) NULL,
    [importe_semestral]         DECIMAL (12, 2) NULL,
    [id_tipo_accion_limite]     INT             NOT NULL,
    [flag_permite_baja]         BIT             CONSTRAINT [DF_Limite_flag_permi] DEFAULT ((1)) NOT NULL,
    [fecha_alta]                DATETIME        NULL,
    [usuario_alta]              VARCHAR (20)    NULL,
    [fecha_modificacion]        DATETIME        NULL,
    [usuario_modificacion]      VARCHAR (20)    NULL,
    [fecha_baja]                DATETIME        NULL,
    [usuario_baja]              VARCHAR (20)    NULL,
    [version]                   INT             CONSTRAINT [DF_Limite_version] DEFAULT ((0)) NOT NULL,
    [grupo_limite]              INT             NULL,
    [id_tipo_identificacion]    INT             NULL,
    [numero_identificacion]     VARCHAR (20)    NULL,
    [sexo]                      VARCHAR (1)     NULL,
    [id_tipo_medio_pago]        INT             NULL,
    [id_banco]                  INT             NULL,
    [id_nivel_riesgo_mp]        INT             NULL,
    [id_canal]                  INT             NULL,
    CONSTRAINT [PK_Limite] PRIMARY KEY CLUSTERED ([id_limite] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Limite_id_banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Limite_id_nivel_riesgo_mp] FOREIGN KEY ([id_nivel_riesgo_mp]) REFERENCES [dbo].[Nivel_Riesgo_MP] ([id_nivel_riesgo]),
    CONSTRAINT [FK_Limite_id_tipo_identificacion] FOREIGN KEY ([id_tipo_identificacion]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Limite_id_tipo_medio_pago] FOREIGN KEY ([id_tipo_medio_pago]) REFERENCES [dbo].[Tipo_Medio_Pago] ([id_tipo_medio_pago]),
    CONSTRAINT [FK_Limite_Tipo_id_cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Limite_Tipo_id_rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro]),
    CONSTRAINT [FK_Limite_Tipo_id_tipo_accion_limite] FOREIGN KEY ([id_tipo_accion_limite]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Limite_Tipo_id_tipo_aplicacion_limite] FOREIGN KEY ([id_tipo_aplicacion_limite]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Limite_Tipo_id_tipo_condicion_IVA] FOREIGN KEY ([id_tipo_condicion_IVA]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Limite_Tipo_id_tipo_cuenta] FOREIGN KEY ([id_tipo_cuenta]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Limite_Tipo_id_tipo_limite] FOREIGN KEY ([id_tipo_limite]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [Limite_Canal_Adhesion_id_canal_fk] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal])
);


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizeBuyValidateRetrieveAlertLimitFiscal]
    ON [dbo].[Limite]([id_cuenta] ASC, [fecha_baja] ASC)
    INCLUDE([id_tipo_limite], [id_tipo_aplicacion_limite], [id_tipo_condicion_IVA], [trxs_mensual], [trxs_semestral], [importe_operacion], [importe_mensual], [importe_semestral], [id_tipo_accion_limite]);

