CREATE TABLE [dbo].[Domicilio_Cuenta] (
    [id_domicilio]         INT          IDENTITY (1, 1) NOT NULL,
    [id_tipo_domicilio]    INT          NOT NULL,
    [id_cuenta]            INT          NOT NULL,
    [calle]                VARCHAR (30) NULL,
    [numero]               VARCHAR (10) NULL,
    [piso]                 VARCHAR (10) NULL,
    [departamento]         VARCHAR (10) NULL,
    [id_localidad]         INT          NULL,
    [id_provincia]         INT          NULL,
    [codigo_postal]        VARCHAR (20) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Domicilio_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [flag_vigente]         BIT          CONSTRAINT [DF_Domicilio_cuenta_flag_vigente] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Domicilio_Cuenta] PRIMARY KEY CLUSTERED ([id_domicilio] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Domicilio_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Domicilio_Cuenta_Localidad] FOREIGN KEY ([id_localidad]) REFERENCES [dbo].[Localidad] ([id_localidad]),
    CONSTRAINT [FK_Domicilio_Cuenta_Provincia] FOREIGN KEY ([id_provincia]) REFERENCES [dbo].[Provincia] ([id_provincia]),
    CONSTRAINT [FK_Domicilio_Cuenta_Tipo] FOREIGN KEY ([id_tipo_domicilio]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizeBuyValidateRetrieveCuenta]
    ON [dbo].[Domicilio_Cuenta]([id_cuenta] ASC, [fecha_baja] ASC, [flag_vigente] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_cuenta_Fecha_Flag]
    ON [dbo].[Domicilio_Cuenta]([id_cuenta] ASC, [fecha_baja] ASC, [flag_vigente] ASC) WITH (FILLFACTOR = 95);

