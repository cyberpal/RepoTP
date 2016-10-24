CREATE TABLE [dbo].[Mensaje] (
    [id_mensaje]           INT           NOT NULL,
    [codigo_mensaje]       INT           NOT NULL,
    [evento]               VARCHAR (100) NULL,
    [mensaje]              VARCHAR (MAX) NULL,
    [formato]              VARCHAR (256) NULL,
    [fecha_alta]           DATETIME      NOT NULL,
    [usuario_alta]         VARCHAR (20)  NOT NULL,
    [fecha_modificacion]   DATETIME      NULL,
    [usuario_modificacion] VARCHAR (20)  NULL,
    [fecha_baja]           DATETIME      NULL,
    [usuario_baja]         VARCHAR (20)  NULL,
    [version]              INT           CONSTRAINT [DF_Mensaje_version] DEFAULT ((0)) NOT NULL,
    [motivo_rechazo]       VARCHAR (256) NULL,
    [flag_reintento_tx]    BIT           NULL,
    CONSTRAINT [PK_Mensaje] PRIMARY KEY CLUSTERED ([id_mensaje] ASC) WITH (FILLFACTOR = 80)
);

