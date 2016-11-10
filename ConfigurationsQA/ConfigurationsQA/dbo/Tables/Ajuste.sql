CREATE TABLE [dbo].[Ajuste] (
    [id_ajuste]            INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT             NOT NULL,
    [id_motivo_ajuste]     INT             NOT NULL,
    [estado_ajuste]        INT             NOT NULL,
    [monto_neto]           DECIMAL (12, 2) NOT NULL,
    [monto_impuesto]       DECIMAL (12, 2) NOT NULL,
    [observaciones]        VARCHAR (140)   NOT NULL,
    [facturacion_fecha]    DATETIME        NULL,
    [facturacion_estado]   INT             NULL,
    [fecha_alta]           DATETIME        NOT NULL,
    [usuario_alta]         VARCHAR (20)    NOT NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             NOT NULL,
    CONSTRAINT [PK_Ajuste] PRIMARY KEY CLUSTERED ([id_ajuste] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Ajuste_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Ajuste_Estado] FOREIGN KEY ([estado_ajuste]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Ajuste_Motivo_Ajuste] FOREIGN KEY ([id_motivo_ajuste]) REFERENCES [dbo].[Motivo_Ajuste] ([id_motivo_ajuste])
);

