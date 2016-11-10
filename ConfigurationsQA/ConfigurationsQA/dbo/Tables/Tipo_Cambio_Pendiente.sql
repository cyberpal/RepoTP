CREATE TABLE [dbo].[Tipo_Cambio_Pendiente] (
    [id_tipo_cambio]       INT          IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20) NOT NULL,
    [tabla_destino]        VARCHAR (50) NOT NULL,
    [campo_destino]        VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Tipo_Cambio_Pendiente_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_tipo_cambio] PRIMARY KEY CLUSTERED ([id_tipo_cambio] ASC) WITH (FILLFACTOR = 80)
);

