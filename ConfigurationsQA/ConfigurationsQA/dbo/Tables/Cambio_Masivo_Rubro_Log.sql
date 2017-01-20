CREATE TABLE [dbo].[Cambio_Masivo_Rubro_Log] (
    [id_cambio_masivo_rubro_log] INT           IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                  INT           NOT NULL,
    [codigo_actividad_afip]      VARCHAR (255) NOT NULL,
    [codigo_rubro]               VARCHAR (255) NOT NULL,
    [estado]                     VARCHAR (255) NOT NULL,
    [codigo]                     INT           NOT NULL,
    [mensaje]                    VARCHAR (255) NOT NULL,
    [fecha_alta]                 DATETIME      NULL,
    [usuario_alta]               VARCHAR (20)  NULL,
    [fecha_modificacion]         DATETIME      NULL,
    [usuario_modificacion]       VARCHAR (20)  NULL,
    [fecha_baja]                 DATETIME      NULL,
    [usuario_baja]               VARCHAR (20)  NULL,
    [id_cambio]                  INT           NOT NULL,
    [version]                    INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_cambio_masivo_rubro_log] ASC)
);

