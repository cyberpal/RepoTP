CREATE TABLE [dbo].[Log_Validacion_Link] (
    [id_log_validacion_link] INT          IDENTITY (1, 1) NOT NULL,
    [numero_tarjeta]         VARCHAR (20) NOT NULL,
    [codigo_banco]           VARCHAR (4)  NOT NULL,
    [tipo_documento]         VARCHAR (3)  NOT NULL,
    [numero_documento]       VARCHAR (20) NOT NULL,
    [resultado_validacion]   VARCHAR (2)  NOT NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id_log_validacion_link] ASC)
);

