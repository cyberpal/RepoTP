CREATE TABLE [dbo].[cuit_multicuenta] (
    [id_cuit_multicuenta]  INT          IDENTITY (1, 1) NOT NULL,
    [numero_CUIT]          VARCHAR (11) NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20) DEFAULT (NULL) NULL,
    [version]              INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_cuit_multicuenta] ASC)
);

