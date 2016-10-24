CREATE TABLE [dbo].[Vertical_Cybersource] (
    [id_vertical_CS]       INT          NOT NULL,
    [codigo_vertical]      VARCHAR (20) NOT NULL,
    [description]          VARCHAR (40) NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20) DEFAULT (NULL) NULL,
    [version]              INT          DEFAULT ('0') NOT NULL,
    PRIMARY KEY CLUSTERED ([id_vertical_CS] ASC)
);

