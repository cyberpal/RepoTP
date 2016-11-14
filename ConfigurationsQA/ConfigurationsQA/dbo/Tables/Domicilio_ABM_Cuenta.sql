CREATE TABLE [dbo].[Domicilio_ABM_Cuenta] (
    [id_domicilio_abm_cuenta] INT          IDENTITY (1, 1) NOT NULL,
    [id_detalle_abm_cuenta]   INT          NOT NULL,
    [id_tipo_domicilio]       INT          NOT NULL,
    [calle]                   VARCHAR (30) NULL,
    [numero]                  VARCHAR (10) NULL,
    [departamento]            VARCHAR (10) NULL,
    [id_localidad]            INT          NOT NULL,
    [id_provincia]            INT          NOT NULL,
    [codigo_postal]           VARCHAR (20) NULL,
    [fecha_alta]              DATETIME     NOT NULL,
    [usuario_alta]            VARCHAR (20) NOT NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Domicilio_ABM_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Domicilio_ABM_Cuenta] PRIMARY KEY CLUSTERED ([id_domicilio_abm_cuenta] ASC),
    CONSTRAINT [FK_Domicilio_ABM_Cuenta__Detalle_ABM_Cuenta] FOREIGN KEY ([id_detalle_abm_cuenta]) REFERENCES [dbo].[Detalle_ABM_Cuenta] ([id_detalle_abm_cuenta]),
    CONSTRAINT [FK_Domicilio_ABM_Cuenta__Localidad] FOREIGN KEY ([id_localidad]) REFERENCES [dbo].[Localidad] ([id_localidad]),
    CONSTRAINT [FK_Domicilio_ABM_Cuenta__Provincia] FOREIGN KEY ([id_provincia]) REFERENCES [dbo].[Provincia] ([id_provincia]),
    CONSTRAINT [FK_Domicilio_ABM_Cuenta__Tipo] FOREIGN KEY ([id_tipo_domicilio]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

