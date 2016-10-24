CREATE TABLE [dbo].[Tipo_Dato_Pendiente_Cuenta] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [tipo_dato_pendiente]  VARCHAR (30) NOT NULL,
    [id_tipo_cuenta]       INT          NOT NULL,
    [id_tipo_cambio]       INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Tipo_Dato_Pendiente_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_Tipo_Dato_Pendiente_Cuenta] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Tipo_Dato_Pendiente_Cuenta_id_tipo_cambio] FOREIGN KEY ([id_tipo_cambio]) REFERENCES [dbo].[Tipo_Cambio_Pendiente] ([id_tipo_cambio]),
    CONSTRAINT [FK_Tipo_Dato_Pendiente_Cuenta_id_tipo_cuenta] FOREIGN KEY ([id_tipo_cuenta]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

