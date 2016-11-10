CREATE TABLE [dbo].[Tipo_Cargo] (
    [id_tipo_cargo]        INT           IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20)  NOT NULL,
    [descripcion]          VARCHAR (100) NOT NULL,
    [signo]                CHAR (1)      CONSTRAINT [DF_Tipo_Cargo_signo] DEFAULT ('-') NOT NULL,
    [flag_configura_panel] BIT           NULL,
    [fecha_alta]           DATETIME      NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      CONSTRAINT [DF_Tipo_Cargo_fecha_modificacion] DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20)  CONSTRAINT [DF_Tipo_Cargo_usuario_modificacion] DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME      CONSTRAINT [DF_Tipo_Cargo_fecha_baja] DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20)  CONSTRAINT [DF_Tipo_Cargo_usuario_baja] DEFAULT (NULL) NULL,
    [version]              INT           CONSTRAINT [DF_Tipo_Cargo_version] DEFAULT ((0)) NOT NULL,
    [flag_aplica_iva]      BIT           NOT NULL,
    CONSTRAINT [PK_Tipo_Cargo] PRIMARY KEY CLUSTERED ([id_tipo_cargo] ASC) WITH (FILLFACTOR = 80)
);

