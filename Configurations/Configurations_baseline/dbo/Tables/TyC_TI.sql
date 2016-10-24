CREATE TABLE [dbo].[TyC_TI] (
    [id_version]           INT          IDENTITY (1, 1) NOT NULL,
    [version_TyC_TI]       INT          NOT NULL,
    [fecha_vigencia_desde] DATETIME     NOT NULL,
    [fecha_vigencia_hasta] DATETIME     NULL,
    [path_texto]           VARCHAR (64) NOT NULL,
    [estado_activo]        BIT          DEFAULT ((0)) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_TyC_TI_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TyC_TI] PRIMARY KEY CLUSTERED ([id_version] ASC)
);

