CREATE TABLE [dbo].[ACL_BANCO] (
    [id_acl_banco]         INT           NOT NULL,
    [id_banco]             INT           NOT NULL,
    [description]          VARCHAR (100) NOT NULL,
    [CN]                   VARCHAR (512) NOT NULL,
    [fecha_desde]          DATETIME      NOT NULL,
    [fecha_hasta]          DATETIME      NOT NULL,
    [usuario_alta]         VARCHAR (20)  NULL,
    [fecha_modificacion]   DATETIME      DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20)  DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME      DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20)  DEFAULT (NULL) NULL,
    [version]              INT           DEFAULT ('0') NOT NULL,
    PRIMARY KEY CLUSTERED ([id_acl_banco] ASC),
    CONSTRAINT [fk_id_banco_2] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco])
);

