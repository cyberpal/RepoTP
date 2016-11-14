CREATE TABLE [dbo].[Codigo_Operacion] (
    [id_codigo_operacion]  INT          NOT NULL,
    [codigo_operacion]     VARCHAR (20) NULL,
    [descripcion]          VARCHAR (20) NULL,
    [signo]                CHAR (1)     NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Codigo_Operacion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Codigo_Operacion] PRIMARY KEY CLUSTERED ([id_codigo_operacion] ASC) WITH (FILLFACTOR = 80)
);

