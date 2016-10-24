CREATE TABLE [dbo].[Log_Registracion_CBU] (
    [id_log]                         INT          NOT NULL,
    [id_informacion_bancaria_cuenta] INT          NOT NULL,
    [resultado_validacion]           VARCHAR (20) NULL,
    [fecha_alta]                     DATETIME     NOT NULL,
    [usuario_alta]                   VARCHAR (20) NULL,
    [fecha_modificacion]             DATETIME     NULL,
    [usuario_modificacion]           VARCHAR (20) NULL,
    [fecha_baja]                     DATETIME     NULL,
    [usuario_baja]                   VARCHAR (20) NULL,
    [version]                        INT          DEFAULT ('0') NOT NULL,
    CONSTRAINT [fk_id_informacion_bancaria_cuenta] FOREIGN KEY ([id_informacion_bancaria_cuenta]) REFERENCES [dbo].[Informacion_Bancaria_Cuenta] ([id_informacion_bancaria])
);

