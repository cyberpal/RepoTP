CREATE TABLE [dbo].[Nacionalidad] (
    [id_nacionalidad]      INT          NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Nacionalidad_version] DEFAULT ((0)) NOT NULL,
    [codigo]               VARCHAR (20) NOT NULL,
    [codigo_aurus]         INT          NOT NULL,
    CONSTRAINT [PK_Nacionalidad] PRIMARY KEY CLUSTERED ([id_nacionalidad] ASC) WITH (FILLFACTOR = 80)
);

