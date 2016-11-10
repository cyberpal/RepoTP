CREATE TABLE [dbo].[Volumen_Regla_Promocion] (
    [id_volumen_rp]            INT             IDENTITY (1, 1) NOT NULL,
    [id_regla_promocion]       INT             NOT NULL,
    [volumen_vta_desde]        DECIMAL (18, 2) NULL,
    [volumen_vta_hasta]        DECIMAL (18, 2) NULL,
    [bonificacion_cf_vendedor] DECIMAL (5, 2)  NULL,
    [fecha_alta]               DATETIME        NULL,
    [usuario_alta]             VARCHAR (20)    NULL,
    [fecha_modificacion]       DATETIME        NULL,
    [usuario_modificacion]     VARCHAR (20)    NULL,
    [fecha_baja]               DATETIME        NULL,
    [usuario_baja]             VARCHAR (20)    NULL,
    [version]                  INT             CONSTRAINT [DF_Volumen_Regla_Promocion_version] DEFAULT ((0)) NOT NULL,
    [tasa_directa_ingresada]   DECIMAL (5, 2)  NULL,
    CONSTRAINT [PK_Volumen_Regla_Promocion] PRIMARY KEY CLUSTERED ([id_volumen_rp] ASC),
    CONSTRAINT [FK_Regla_Promocion] FOREIGN KEY ([id_regla_promocion]) REFERENCES [dbo].[Regla_Promocion] ([id_regla_promocion])
);

