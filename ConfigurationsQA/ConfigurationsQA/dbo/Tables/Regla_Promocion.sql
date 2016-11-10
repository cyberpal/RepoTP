CREATE TABLE [dbo].[Regla_Promocion] (
    [id_regla_promocion]       INT            IDENTITY (1, 1) NOT NULL,
    [id_promocion]             INT            NOT NULL,
    [cant_cuotas_desde]        INT            NOT NULL,
    [cant_cuotas_hasta]        INT            NOT NULL,
    [bonificacion_cf_vendedor] DECIMAL (5, 2) NULL,
    [fecha_alta]               DATETIME       NULL,
    [usuario_alta]             VARCHAR (20)   NULL,
    [fecha_modificacion]       DATETIME       NULL,
    [usuario_modificacion]     VARCHAR (20)   NULL,
    [fecha_baja]               DATETIME       NULL,
    [usuario_baja]             VARCHAR (20)   NULL,
    [version]                  INT            CONSTRAINT [DF_Regla_Promocion_version] DEFAULT ((0)) NOT NULL,
    [tasa_directa_ingresada]   DECIMAL (5, 2) NULL,
    CONSTRAINT [PK_Regla_Promocion] PRIMARY KEY CLUSTERED ([id_regla_promocion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Regla_Promocion_id_promocion] FOREIGN KEY ([id_promocion]) REFERENCES [dbo].[Promocion] ([id_promocion])
);

