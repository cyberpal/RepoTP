CREATE TABLE [dbo].[Validar_Ajuste_Log] (
    [id_validar_ajuste_log] INT           IDENTITY (1, 1) NOT NULL,
    [id_ajuste]             INT           NOT NULL,
    [id_validacion]         INT           NOT NULL,
    [estado]                VARCHAR (20)  NOT NULL,
    [codigo]                INT           NOT NULL,
    [mensaje]               VARCHAR (255) NOT NULL,
    [fecha_alta]            DATETIME      NOT NULL,
    [usuario_alta]          VARCHAR (20)  NOT NULL,
    [fecha_modificacion]    DATETIME      NULL,
    [usuario_modificacion]  VARCHAR (20)  NULL,
    [fecha_baja]            DATETIME      NULL,
    [usuario_baja]          VARCHAR (20)  NULL,
    [version]               INT           CONSTRAINT [DF_Validar_Ajuste_Log] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Validar_Ajuste_Log] PRIMARY KEY CLUSTERED ([id_validar_ajuste_log] ASC),
    CONSTRAINT [FK_Validar_Ajuste_Log_Ajuste] FOREIGN KEY ([id_ajuste]) REFERENCES [dbo].[Ajuste] ([id_ajuste])
);

