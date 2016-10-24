CREATE TABLE [dbo].[Dato_Pendiente] (
    [id_dato_pendiente]    INT           IDENTITY (1, 1) NOT NULL,
    [id_cambio_pendiente]  INT           NOT NULL,
    [id_registro_destino]  INT           NOT NULL,
    [valor_pendiente]      VARCHAR (100) NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Dato_Pendiente_version] DEFAULT ((0)) NOT NULL,
    [tabla_destino]        VARCHAR (50)  NOT NULL,
    [campo_destino]        VARCHAR (50)  NOT NULL,
    [id_tipo_cambio]       INT           NULL,
    CONSTRAINT [PK_Dato_Pendiente] PRIMARY KEY CLUSTERED ([id_dato_pendiente] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Dato_Pendiente_Cambio_Pendiente] FOREIGN KEY ([id_cambio_pendiente]) REFERENCES [dbo].[Cambio_Pendiente] ([id_cambio_pendiente]),
    CONSTRAINT [FK_Dato_Pendiente_id_tipo_cambio] FOREIGN KEY ([id_tipo_cambio]) REFERENCES [dbo].[Tipo_Cambio_Pendiente] ([id_tipo_cambio])
);

