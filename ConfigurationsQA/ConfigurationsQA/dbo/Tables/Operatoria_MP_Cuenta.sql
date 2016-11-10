CREATE TABLE [dbo].[Operatoria_MP_Cuenta] (
    [id_operatoria_mp_cuenta] INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]               INT          NOT NULL,
    [id_medio_pago]           INT          NOT NULL,
    [cant_maxima_cuotas]      INT          NOT NULL,
    [nro_comercio_billetera]  VARCHAR (50) NULL,
    [nro_comercio_boton]      VARCHAR (50) NULL,
    [fecha_alta]              DATETIME     NOT NULL,
    [usuario_alta]            VARCHAR (20) NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Operatoria_MP_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Operatoria_MP_Cuenta] PRIMARY KEY CLUSTERED ([id_operatoria_mp_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Operatoria_MP_Cuenta_id_cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Operatoria_MP_Cuenta_id_medio_pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

