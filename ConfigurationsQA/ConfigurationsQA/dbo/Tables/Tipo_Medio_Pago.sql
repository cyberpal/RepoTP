CREATE TABLE [dbo].[Tipo_Medio_Pago] (
    [id_tipo_medio_pago]       INT          NOT NULL,
    [codigo]                   VARCHAR (20) CONSTRAINT [DF_Tipo_Medio_Pago_codigo] DEFAULT ('') NOT NULL,
    [nombre]                   VARCHAR (20) NOT NULL,
    [flag_permite_anulacion]   BIT          CONSTRAINT [DF_Tipo_Medio_Pago_flag_permite_anulacion] DEFAULT ((0)) NOT NULL,
    [flag_permite_devolucion]  BIT          CONSTRAINT [DF_Tipo_Medio_Pago_flag_permi] DEFAULT ((0)) NOT NULL,
    [plazo_devolucion]         INT          CONSTRAINT [DF_Tipo_Medio_Pago_plazo_devo] DEFAULT (NULL) NULL,
    [flag_opera_cuotas]        BIT          CONSTRAINT [DF_Tipo_Medio_Pago_flag_opera] DEFAULT ((0)) NOT NULL,
    [id_tipo_acreditacion]     INT          NOT NULL,
    [fecha_alta]               DATETIME     NULL,
    [usuario_alta]             VARCHAR (20) NULL,
    [fecha_modificacion]       DATETIME     NULL,
    [usuario_modificacion]     VARCHAR (20) NULL,
    [fecha_baja]               DATETIME     NULL,
    [usuario_baja]             VARCHAR (20) NULL,
    [version]                  INT          CONSTRAINT [DF_Tipo_Medio_Pago_version] DEFAULT ((0)) NOT NULL,
    [flag_permite_contracargo] BIT          DEFAULT ((0)) NOT NULL,
    [flag_permitido_billetera] BIT          CONSTRAINT [DF_TipoMP_permitido_billetera] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Tipo_Medio_Pago] PRIMARY KEY CLUSTERED ([id_tipo_medio_pago] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Tipo_Medio_Pago_Tipo] FOREIGN KEY ([id_tipo_acreditacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

