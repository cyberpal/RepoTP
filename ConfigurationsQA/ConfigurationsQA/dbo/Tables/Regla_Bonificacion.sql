CREATE TABLE [dbo].[Regla_Bonificacion] (
    [id_regla_bonificacion]     INT            IDENTITY (1, 1) NOT NULL,
    [id_tasa_mp]                INT            NULL,
    [fecha_desde]               DATE           NOT NULL,
    [fecha_hasta]               DATE           NULL,
    [id_banco]                  INT            NULL,
    [id_cuenta]                 INT            NULL,
    [dia_semana]                VARCHAR (7)    NULL,
    [bonificacion_cf_comprador] BIT            CONSTRAINT [DF_Regla_Bonificacion_bonificación_cf_comprador] DEFAULT ((0)) NOT NULL,
    [bonificacion_cf_vendedor]  DECIMAL (5, 2) NULL,
    [id_promocion]              INT            NULL,
    [fecha_alta]                DATETIME       NULL,
    [usuario_alta]              VARCHAR (20)   NULL,
    [fecha_modificacion]        DATETIME       NULL,
    [usuario_modificacion]      VARCHAR (20)   NULL,
    [fecha_baja]                DATETIME       NULL,
    [usuario_baja]              VARCHAR (20)   NULL,
    [version]                   INT            CONSTRAINT [DF_Regla_Bonificacion_version] DEFAULT ((0)) NOT NULL,
    [id_regla_promocion]        INT            NULL,
    [id_rubro]                  INT            NULL,
    [tasa_directa_ingresada]    DECIMAL (5, 2) NULL,
    [flag_tasa_directa]         BIT            CONSTRAINT [DF_Regla_Bonificacion_flag_tasa_directa] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Regla_Bonificacion] PRIMARY KEY CLUSTERED ([id_regla_bonificacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Regla_Bonificacion_Banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_Regla_Bonificacion_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Regla_Bonificacion_id_regla_promocion] FOREIGN KEY ([id_regla_promocion]) REFERENCES [dbo].[Regla_Promocion] ([id_regla_promocion]),
    CONSTRAINT [FK_Regla_Bonificacion_Promocion] FOREIGN KEY ([id_promocion]) REFERENCES [dbo].[Promocion] ([id_promocion]),
    CONSTRAINT [FK_Regla_Bonificacion_Tasa_MP] FOREIGN KEY ([id_tasa_mp]) REFERENCES [dbo].[Tasa_MP] ([id_tasa_mp]),
    CONSTRAINT [FK_Regla_Promocion_id_rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro])
);


GO
CREATE NONCLUSTERED INDEX [Regla_Bonificacion_Fecha_baja_ID_Banco]
    ON [dbo].[Regla_Bonificacion]([fecha_baja] ASC, [id_banco] ASC, [id_cuenta] ASC)
    INCLUDE([id_tasa_mp], [fecha_desde], [fecha_hasta], [dia_semana]) WITH (FILLFACTOR = 95);

