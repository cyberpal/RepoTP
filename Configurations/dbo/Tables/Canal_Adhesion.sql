CREATE TABLE [dbo].[Canal_Adhesion] (
    [id_canal]             INT          NOT NULL,
    [nombre]               VARCHAR (20) NOT NULL,
    [nivel_riesgo]         VARCHAR (20) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_canal_adhesion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Canal_Adhesion] PRIMARY KEY CLUSTERED ([id_canal] ASC) WITH (FILLFACTOR = 80)
);

