CREATE TABLE [dbo].[Impuesto_General_MP] (
    [fecha_pago_desde]     DATETIME        NULL,
    [fecha_pago_hasta]     DATETIME        NULL,
    [percepciones]         DECIMAL (12, 2) NULL,
    [retenciones]          DECIMAL (12, 2) NULL,
    [cargos]               DECIMAL (12, 2) NULL,
    [otros_impuestos]      DECIMAL (12, 2) NULL,
    [id_medio_pago]        INT             NULL,
    [id_log_paso]          INT             NULL,
    [id_impuesto_general]  INT             IDENTITY (1, 1) NOT NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             CONSTRAINT [DF_Impuesto_General_MP_version] DEFAULT ((0)) NOT NULL,
    [solo_impuestos]       INT             NOT NULL,
    CONSTRAINT [PK_Impuestos_generales_de_marcas] PRIMARY KEY CLUSTERED ([id_impuesto_general] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Impuestos_generales_de_m_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

