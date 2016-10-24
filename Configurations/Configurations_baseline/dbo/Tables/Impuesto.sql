CREATE TABLE [dbo].[Impuesto] (
    [id_impuesto]               INT          IDENTITY (1, 1) NOT NULL,
    [descripcion]               VARCHAR (60) NOT NULL,
    [flag_todas_provincias]     BIT          CONSTRAINT [DF_Impuesto_flag_todas_provincias] DEFAULT ((0)) NOT NULL,
    [id_provincia]              INT          NULL,
    [fecha_alta]                DATETIME     NULL,
    [usuario_alta]              VARCHAR (20) NULL,
    [fecha_modificacion]        DATETIME     NULL,
    [usuario_modificacion]      VARCHAR (20) NULL,
    [fecha_baja]                DATETIME     NULL,
    [usuario_baja]              VARCHAR (20) NULL,
    [version]                   INT          CONSTRAINT [DF_Impuesto_version] DEFAULT ((0)) NOT NULL,
    [codigo]                    VARCHAR (20) NOT NULL,
    [id_tipo_aplicacion]        INT          NULL,
    [id_motivo_ajuste_negativo] INT          NULL,
    [id_motivo_ajuste_positivo] INT          NULL,
    CONSTRAINT [PK_Impuesto] PRIMARY KEY CLUSTERED ([id_impuesto] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Impuesto_Provincia] FOREIGN KEY ([id_provincia]) REFERENCES [dbo].[Provincia] ([id_provincia])
);

