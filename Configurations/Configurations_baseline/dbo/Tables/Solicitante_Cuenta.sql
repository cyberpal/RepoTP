CREATE TABLE [dbo].[Solicitante_Cuenta] (
    [id_solicitante_cuenta]   INT           IDENTITY (1, 1) NOT NULL,
    [codigo_solicitante]      VARCHAR (20)  NOT NULL,
    [descripcion_solicitante] VARCHAR (100) NOT NULL,
    [id_rubro]                INT           NOT NULL,
    [prioridad_procesamiento] INT           NOT NULL,
    [ruta_entrada_archivo]    VARCHAR (256) NOT NULL,
    [ruta_salida_archivo]     VARCHAR (256) NOT NULL,
    [patron_nombre_archivo]   VARCHAR (256) NOT NULL,
    [fecha_alta]              DATETIME      NULL,
    [usuario_alta]            VARCHAR (20)  NULL,
    [fecha_modificacion]      DATETIME      NULL,
    [usuario_modificacion]    VARCHAR (20)  NULL,
    [fecha_baja]              DATETIME      NULL,
    [usuario_baja]            VARCHAR (20)  NULL,
    [version]                 INT           CONSTRAINT [DF_Solicitante_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Solicitante_Cuenta] PRIMARY KEY CLUSTERED ([id_solicitante_cuenta] ASC),
    CONSTRAINT [FK_Solicitante_Cuenta__Rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro]),
    CONSTRAINT [UK_Prioridad_Procesamiento] UNIQUE NONCLUSTERED ([prioridad_procesamiento] ASC)
);

