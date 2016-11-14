CREATE TABLE [dbo].[Perfil_Cuenta] (
    [id_perfil_cuenta]     INT          IDENTITY (1, 1) NOT NULL,
    [id_perfil]            INT          NOT NULL,
    [id_cuenta]            INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id_perfil_cuenta] ASC),
    CONSTRAINT [FK_Perfil_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Perfil_Cuenta_Perfil] FOREIGN KEY ([id_perfil]) REFERENCES [dbo].[Perfil] ([id_perfil])
);

