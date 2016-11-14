CREATE TABLE [dbo].[Historico_Mail_Cuenta] (
    [id_historico_mail_cuenta] INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                INT          NOT NULL,
    [email]                    VARCHAR (50) NOT NULL,
    [id_estado_mail]           INT          NOT NULL,
    [fecha_alta]               DATETIME     NOT NULL,
    [usuario_alta]             VARCHAR (20) NOT NULL,
    [fecha_modificacion]       DATETIME     NULL,
    [usuario_modificacion]     VARCHAR (20) NULL,
    [fecha_baja]               DATETIME     NULL,
    [usuario_baja]             VARCHAR (20) NULL,
    [version]                  INT          CONSTRAINT [DF_Historico_Mail_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [hash]                     VARCHAR (50) NULL,
    CONSTRAINT [PK_id_historico_mail_cuenta] PRIMARY KEY CLUSTERED ([id_historico_mail_cuenta] ASC),
    CONSTRAINT [FK_Historico_Mail_Cuenta_id_cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Historico_Mail_Cuenta_id_estado_mail] FOREIGN KEY ([id_estado_mail]) REFERENCES [dbo].[Estado] ([id_estado])
);

