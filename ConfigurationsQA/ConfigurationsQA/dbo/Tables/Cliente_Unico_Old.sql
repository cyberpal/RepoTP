CREATE TABLE [dbo].[Cliente_Unico_Old] (
    [Cliente_Unico_Id]      INT          NOT NULL,
    [tipo_identificacion]   VARCHAR (20) NULL,
    [numero_identificacion] VARCHAR (20) NULL,
    [sexo]                  VARCHAR (1)  NULL,
    [banco]                 CHAR (3)     NULL,
    [id_medio_pago]         INT          NULL,
    [nombre]                VARCHAR (50) NULL,
    [numero_tarjeta]        VARCHAR (20) NULL,
    [fecha_vencimiento]     VARCHAR (6)  NULL,
    [fecha_nacimiento]      DATETIME     NULL,
    [numero_cuit]           VARCHAR (11) NULL,
    [telefono_movil]        VARCHAR (10) NULL,
    [telefono_fijo]         VARCHAR (10) NULL,
    [calle]                 VARCHAR (30) NULL,
    [numero]                VARCHAR (10) NULL,
    [piso]                  VARCHAR (10) NULL,
    [departamento]          VARCHAR (10) NULL,
    [id_provincia]          SMALLINT     NULL,
    [codigo_postal]         VARCHAR (20) NULL,
    [nacionalidad]          VARCHAR (20) NULL,
    [fecha_alta]            DATETIME     NULL,
    [usuario_alta]          VARCHAR (20) NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          NOT NULL,
    CONSTRAINT [PK_Cliente_Unico_Id_Old] PRIMARY KEY CLUSTERED ([Cliente_Unico_Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_numero_identificacion]
    ON [dbo].[Cliente_Unico_Old]([numero_identificacion] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_numero_tarjeta]
    ON [dbo].[Cliente_Unico_Old]([numero_tarjeta] ASC);

