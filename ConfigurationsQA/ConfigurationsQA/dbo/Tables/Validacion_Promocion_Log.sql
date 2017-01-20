CREATE TABLE [dbo].[Validacion_Promocion_Log] (
    [id_validacion_promocion_log] INT           IDENTITY (1, 1) NOT NULL,
    [id_validacion]               INT           NOT NULL,
    [id_cuenta]                   INT           NOT NULL,
    [nombre_cuenta]               VARCHAR (100) NULL,
    [id_promocion]                INT           NOT NULL,
    [estado]                      VARCHAR (20)  NOT NULL,
    [codigo_error]                INT           NOT NULL,
    [mensaje]                     VARCHAR (MAX) NOT NULL,
    [fecha_alta]                  DATETIME      NOT NULL,
    [usuario_alta]                VARCHAR (20)  NOT NULL,
    [fecha_modificacion]          DATETIME      NULL,
    [usuario_modificacion]        VARCHAR (20)  NULL,
    [fecha_baja]                  DATETIME      NULL,
    [usuario_baja]                VARCHAR (20)  NULL,
    [version]                     INT           NOT NULL,
    CONSTRAINT [PK_Validacion_Promocion_Log] PRIMARY KEY CLUSTERED ([id_validacion_promocion_log] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Validacion_Promocion_Log_Promocion] FOREIGN KEY ([id_promocion]) REFERENCES [dbo].[Promocion] ([id_promocion])
);

