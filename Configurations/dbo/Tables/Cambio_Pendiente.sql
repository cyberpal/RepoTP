CREATE TABLE [dbo].[Cambio_Pendiente] (
    [id_cambio_pendiente]  INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT          NOT NULL,
    [id_estado_cambio]     INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Cambio_Pendiente_version] DEFAULT ((0)) NOT NULL,
    [fecha_resolucion]     DATETIME     NULL,
    [usuario_resolucion]   VARCHAR (20) NULL,
    CONSTRAINT [PK_Cambio_Pendiente] PRIMARY KEY CLUSTERED ([id_cambio_pendiente] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cambio_Pendiente_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Cambio_Pendiente_Estado] FOREIGN KEY ([id_estado_cambio]) REFERENCES [dbo].[Estado] ([id_estado])
);

