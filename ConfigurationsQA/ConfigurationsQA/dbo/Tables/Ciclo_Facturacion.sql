CREATE TABLE [dbo].[Ciclo_Facturacion] (
    [id_ciclo_facturacion] INT          NOT NULL,
    [dia_de_ejecucion]     INT          NOT NULL,
    [dia_inicio]           INT          NOT NULL,
    [dia_tope_incluido]    INT          NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Ciclo_Facturacion_version] DEFAULT ((0)) NOT NULL,
    [meses_desplazamiento] INT          CONSTRAINT [DF_Ciclo_Facturacion__meses_desp] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Ciclo_Facturacion] PRIMARY KEY CLUSTERED ([id_ciclo_facturacion] ASC) WITH (FILLFACTOR = 80)
);

