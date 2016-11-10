CREATE TABLE [dbo].[Motivo_Estado] (
    [id_motivo_estado]     INT           NOT NULL,
    [id_estado]            INT           NULL,
    [codigo]               VARCHAR (20)  NOT NULL,
    [descripcion]          VARCHAR (100) NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Motivo_Estado_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Motivo_Estado] PRIMARY KEY CLUSTERED ([id_motivo_estado] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Motivo_Estado_Estado] FOREIGN KEY ([id_estado]) REFERENCES [dbo].[Estado] ([id_estado])
);

