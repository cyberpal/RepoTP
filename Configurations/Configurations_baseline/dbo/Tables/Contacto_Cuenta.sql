CREATE TABLE [dbo].[Contacto_Cuenta] (
    [id_contacto]            INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]              INT          NOT NULL,
    [nombre_contacto]        VARCHAR (50) NULL,
    [apellido_contacto]      VARCHAR (50) NULL,
    [telefono_movil]         VARCHAR (10) NOT NULL,
    [id_tipo_identificacion] INT          NOT NULL,
    [numero_identificacion]  VARCHAR (20) NOT NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Contacto_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_operador_celular]    INT          NULL,
    CONSTRAINT [PK_Contacto_Cuenta] PRIMARY KEY CLUSTERED ([id_contacto] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Contacto_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Contacto_Cuenta_id_operador_celular] FOREIGN KEY ([id_operador_celular]) REFERENCES [dbo].[Operador_Celular] ([id_operador_celular]),
    CONSTRAINT [FK_Contacto_Cuenta_Tipo] FOREIGN KEY ([id_tipo_identificacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

