CREATE TABLE [dbo].[Lista_Negra_Identificacion] (
    [id]                     INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_identificacion] INT          NULL,
    [numero_identificacion]  VARCHAR (30) NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Lista_Negra_Identificacion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Lista_Negra_Identificacion] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Lista_Negra_Identificacion_Tipo] FOREIGN KEY ([id_tipo_identificacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

