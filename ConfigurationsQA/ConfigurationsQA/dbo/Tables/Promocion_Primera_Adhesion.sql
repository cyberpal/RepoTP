CREATE TABLE [dbo].[Promocion_Primera_Adhesion] (
    [id_promocion_primera_adhesion] INT          IDENTITY (1, 1) NOT NULL,
    [id_bonificacion]               INT          NOT NULL,
    [id_medio_pago_cuenta]          INT          NOT NULL,
    [fecha_alta]                    DATETIME     NOT NULL,
    [usuario_alta]                  VARCHAR (20) NOT NULL,
    [fecha_modificacion]            DATETIME     NULL,
    [usuario_modificacion]          VARCHAR (20) NULL,
    [fecha_baja]                    DATETIME     NULL,
    [usuario_baja]                  VARCHAR (20) NULL,
    [version]                       INT          CONSTRAINT [DF_Promocion_Primera_Adhesion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Promocion_Primera_Adhesion] PRIMARY KEY CLUSTERED ([id_promocion_primera_adhesion] ASC),
    CONSTRAINT [FK_Promocion_Primera_Adhesion_Bonificacion] FOREIGN KEY ([id_bonificacion]) REFERENCES [dbo].[Bonificacion] ([id_bonificacion]),
    CONSTRAINT [FK_Promocion_Primera_Adhesion_Medio_Pago_Cuenta] FOREIGN KEY ([id_medio_pago_cuenta]) REFERENCES [dbo].[Medio_Pago_Cuenta] ([id_medio_pago_cuenta])
);

