CREATE TABLE [dbo].[Tasa_MP] (
    [id_tasa_mp]            INT            IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]         INT            NOT NULL,
    [cant_cuotas]           INT            NOT NULL,
    [coeficiente]           DECIMAL (6, 4) NOT NULL,
    [tasa_directa]          DECIMAL (5, 2) NOT NULL,
    [tna]                   DECIMAL (5, 2) NOT NULL,
    [fecha_alta]            DATETIME       NULL,
    [usuario_alta]          VARCHAR (20)   NULL,
    [fecha_modificacion]    DATETIME       NULL,
    [usuario_modificacion]  VARCHAR (20)   NULL,
    [fecha_baja]            DATETIME       NULL,
    [usuario_baja]          VARCHAR (20)   NULL,
    [version]               INT            CONSTRAINT [DF_Tasa_MP_version] DEFAULT ((0)) NOT NULL,
    [fecha_inicio_vigencia] DATE           NOT NULL,
    [fecha_fin_vigencia]    DATE           NULL,
    CONSTRAINT [PK_Tasa_MP] PRIMARY KEY CLUSTERED ([id_tasa_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Tasa_MP_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

