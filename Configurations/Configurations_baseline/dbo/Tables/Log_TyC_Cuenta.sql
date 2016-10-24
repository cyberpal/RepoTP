CREATE TABLE [dbo].[Log_TyC_Cuenta] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [id_tyc]               INT          NOT NULL,
    [id_cuenta]            INT          NOT NULL,
    [id_canal]             INT          NOT NULL,
    [fecha_aprobacion]     DATETIME     NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          NOT NULL,
    CONSTRAINT [PK_Log_TyC_Cuenta] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_id_tyc] FOREIGN KEY ([id_tyc]) REFERENCES [dbo].[TyC] ([id_version]),
    CONSTRAINT [FK_Log_TyC_Cuenta_Canal_Adhesion] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [FK_Log_TyC_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta])
);

