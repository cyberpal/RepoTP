CREATE TABLE [dbo].[Codigo_Respuesta_Resolutor] (
    [id]                   INT           NOT NULL,
    [id_resolutor]         INT           NOT NULL,
    [codigo_respuesta]     VARCHAR (20)  NOT NULL,
    [descripcion]          VARCHAR (200) NULL,
    [id_mensaje]           INT           NOT NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Codigo_Respuesta_Resolutor_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_Codigo_Respuesta_Resolutor] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Codigo_Respuesta_Resolutor_id_mensaje] FOREIGN KEY ([id_mensaje]) REFERENCES [dbo].[Mensaje] ([id_mensaje]),
    CONSTRAINT [FK_Codigo_Respuesta_Resolutor_id_resolutor] FOREIGN KEY ([id_resolutor]) REFERENCES [dbo].[Resolutor_Transaccion] ([id_resolutor])
);

