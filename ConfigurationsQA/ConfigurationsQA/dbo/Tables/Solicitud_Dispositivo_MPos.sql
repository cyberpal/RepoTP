CREATE TABLE [dbo].[Solicitud_Dispositivo_MPos] (
    [id_solicitud_dispositivo_mpos] INT          IDENTITY (1, 1) NOT NULL,
    [id_solicitante_cuenta]         INT          NOT NULL,
    [id_cuenta_destino]             INT          NOT NULL,
    [id_domicilio_entrega]          INT          NOT NULL,
    [id_modelo_dispositivo_mpos]    INT          NOT NULL,
    [id_estado]                     INT          NOT NULL,
    [id_canal]                      INT          NOT NULL,
    [fecha_alta]                    DATETIME     NULL,
    [usuario_alta]                  VARCHAR (20) NULL,
    [fecha_modificacion]            DATETIME     NULL,
    [usuario_modificacion]          VARCHAR (20) NULL,
    [fecha_baja]                    DATETIME     NULL,
    [usuario_baja]                  VARCHAR (20) NULL,
    [version]                       INT          CONSTRAINT [DF_Solicitud_Dispositivo_MPos_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Solicitud_Dispositivo_MPos] PRIMARY KEY CLUSTERED ([id_solicitud_dispositivo_mpos] ASC),
    CONSTRAINT [FK_Solicitante_Cuenta__Canal_Adhesion] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [FK_Solicitante_Cuenta__Estado] FOREIGN KEY ([id_estado]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Solicitud_Dispositivo_MPos__Cuenta] FOREIGN KEY ([id_cuenta_destino]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Solicitud_Dispositivo_MPos__Domicilio_Cuenta] FOREIGN KEY ([id_domicilio_entrega]) REFERENCES [dbo].[Domicilio_Cuenta] ([id_domicilio]),
    CONSTRAINT [FK_Solicitud_Dispositivo_MPos__Modelo_Disp_MPos] FOREIGN KEY ([id_modelo_dispositivo_mpos]) REFERENCES [dbo].[Modelo_Dispositivo_MPos] ([id_modelo_dispositivo_mpos]),
    CONSTRAINT [FK_Solicitud_Dispositivo_MPos__Solicitante_Cuenta] FOREIGN KEY ([id_solicitante_cuenta]) REFERENCES [dbo].[Solicitante_Cuenta] ([id_solicitante_cuenta])
);

