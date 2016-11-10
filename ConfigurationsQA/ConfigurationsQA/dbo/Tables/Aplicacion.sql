CREATE TABLE [dbo].[Aplicacion] (
    [id_aplicacion]                INT          IDENTITY (1, 1) NOT NULL,
    [nombre_aplicacion]            CHAR (50)    NULL,
    [descripcion]                  CHAR (50)    NULL,
    [password]                     VARCHAR (50) NULL,
    [ip]                           CHAR (50)    NULL,
    [password_bloqueada]           BIT          CONSTRAINT [DF_Aplicacion_password_bloqueada] DEFAULT ((0)) NOT NULL,
    [intentos_login]               INT          CONSTRAINT [DF_Aplicacion_intentos_login] DEFAULT ((0)) NOT NULL,
    [fecha_ultimo_login]           DATETIME     NULL,
    [fecha_ultimo_bloqueo]         DATETIME     NULL,
    [fecha_alta]                   DATETIME     NULL,
    [usuario_alta]                 VARCHAR (20) NULL,
    [fecha_modificacion]           DATETIME     NULL,
    [usuario_modificacion]         VARCHAR (20) NULL,
    [fecha_baja]                   DATETIME     NULL,
    [usuario_baja]                 VARCHAR (20) NULL,
    [version]                      INT          CONSTRAINT [DF_Aplicacion_version] DEFAULT ((0)) NOT NULL,
    [ultima_modificacion_password] DATETIME     NOT NULL,
    CONSTRAINT [PK_Aplicacion] PRIMARY KEY CLUSTERED ([id_aplicacion] ASC)
);

