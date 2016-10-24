CREATE TABLE [dbo].[Historico_Mail_Cta_copia] (
    [id_historico_mail_cta] INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]             INT          NOT NULL,
    [email]                 VARCHAR (50) NOT NULL,
    [id_estado_mail]        INT          NOT NULL,
    [fecha_alta]            DATETIME     NOT NULL,
    [usuario_alta]          VARCHAR (20) NOT NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          NOT NULL,
    CONSTRAINT [PK_id_historico_mail_cta] PRIMARY KEY CLUSTERED ([id_historico_mail_cta] ASC)
);

