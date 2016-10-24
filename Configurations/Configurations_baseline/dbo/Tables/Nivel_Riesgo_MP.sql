CREATE TABLE [dbo].[Nivel_Riesgo_MP] (
    [id_nivel_riesgo]      INT          IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (3)  NOT NULL,
    [descripcion_corta]    VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_nivel_riesgo] ASC)
);

