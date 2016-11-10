CREATE TABLE [dbo].[Primera_Vez_Banco_Cuenta] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT          NOT NULL,
    [id_banco]             INT          NOT NULL,
    [codigo_banco]         VARCHAR (3)  NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          DEFAULT ('0') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [fk_id_banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [fk_id_cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta])
);

