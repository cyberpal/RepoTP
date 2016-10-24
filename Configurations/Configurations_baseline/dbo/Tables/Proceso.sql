CREATE TABLE [dbo].[Proceso] (
    [id_proceso]           INT          NOT NULL,
    [nombre]               VARCHAR (50) NOT NULL,
    [id_tipo_frecuencia]   INT          NOT NULL,
    [valor_frecuencia]     INT          NOT NULL,
    [version]              INT          CONSTRAINT [DF_Proceso_version] DEFAULT ((0)) NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    CONSTRAINT [PK_Proceso] PRIMARY KEY CLUSTERED ([id_proceso] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Proceso_Tipo] FOREIGN KEY ([id_tipo_frecuencia]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

