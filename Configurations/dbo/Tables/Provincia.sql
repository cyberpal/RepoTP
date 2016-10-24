CREATE TABLE [dbo].[Provincia] (
    [id_provincia]            INT          NOT NULL,
    [codigo]                  VARCHAR (20) NULL,
    [nombre]                  VARCHAR (60) NULL,
    [fecha_alta]              DATETIME     NULL,
    [usuario_alta]            VARCHAR (20) NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Provincia_version] DEFAULT ((0)) NOT NULL,
    [codigo_aurus]            CHAR (1)     NOT NULL,
    [codigo_contable]         INT          NULL,
    [ultimo_certificado_iibb] INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Provincia] PRIMARY KEY CLUSTERED ([id_provincia] ASC) WITH (FILLFACTOR = 80)
);

