CREATE TABLE [dbo].[Archivo_ABM_Cuenta] (
    [id_archivo_abm_cuenta]   INT           IDENTITY (1, 1) NOT NULL,
    [id_solicitante_cuenta]   INT           NOT NULL,
    [nombre_archivo]          VARCHAR (256) NOT NULL,
    [cantidad_registros]      INT           CONSTRAINT [DF_Archivo_ABM_Cuenta_cantidad_registros] DEFAULT ((0)) NOT NULL,
    [fecha_archivo]           DATETIME      CONSTRAINT [DF_Archivo_ABM_Cuenta_fecha_archivo] DEFAULT (getdate()) NOT NULL,
    [archivo_alta_aceptados]  VARCHAR (256) NULL,
    [cantidad_aceptados]      INT           CONSTRAINT [DF_Archivo_ABM_Cuenta_cantidad_aceptados] DEFAULT ((0)) NOT NULL,
    [archivo_alta_rechazados] VARCHAR (256) NULL,
    [cantidad_rechazados]     INT           CONSTRAINT [DF_Archivo_ABM_Cuenta_cantidad_rechazados] DEFAULT ((0)) NOT NULL,
    [flag_procesado]          BIT           CONSTRAINT [DF_Archivo_ABM_Cuenta_flag_procesado] DEFAULT ((0)) NOT NULL,
    [resultado_proceso]       BIT           DEFAULT ((0)) NOT NULL,
    [motivo_rechazo]          VARCHAR (150) NULL,
    [fecha_alta]              DATETIME      DEFAULT (getdate()) NOT NULL,
    [usuario_alta]            VARCHAR (20)  NOT NULL,
    [fecha_modificacion]      DATETIME      NULL,
    [usuario_modificacion]    VARCHAR (20)  NULL,
    [fecha_baja]              DATETIME      NULL,
    [usuario_baja]            VARCHAR (20)  NULL,
    [version]                 INT           CONSTRAINT [DF_Archivo_ABM_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Archivo_ABM_Cuenta] PRIMARY KEY CLUSTERED ([id_archivo_abm_cuenta] ASC),
    CONSTRAINT [FK_Archivo_ABM_Cuenta__Solicitante_Cuenta] FOREIGN KEY ([id_solicitante_cuenta]) REFERENCES [dbo].[Solicitante_Cuenta] ([id_solicitante_cuenta])
);

