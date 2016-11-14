CREATE TABLE [dbo].[Paso_Proceso] (
    [id_paso_proceso]      INT          NOT NULL,
    [id_proceso]           INT          NULL,
    [paso]                 INT          NOT NULL,
    [nombre]               VARCHAR (80) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Paso_Proceso_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Paso_Proceso] PRIMARY KEY CLUSTERED ([id_paso_proceso] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Paso_Proceso_Proceso] FOREIGN KEY ([id_proceso]) REFERENCES [dbo].[Proceso] ([id_proceso])
);

