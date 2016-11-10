CREATE TABLE [dbo].[Boton] (
    [id_boton]               INT             IDENTITY (1, 1) NOT NULL,
    [id_tipo_boton]          INT             NOT NULL,
    [id_cuenta]              INT             NOT NULL,
    [descripcion]            VARCHAR (MAX)   NULL,
    [monto_desde]            DECIMAL (12, 2) NOT NULL,
    [monto_hasta]            DECIMAL (12, 2) NULL,
    [imagen]                 VARCHAR (256)   NULL,
    [fuente]                 VARCHAR (MAX)   NULL,
    [flag_todos_mp]          BIT             NOT NULL,
    [url_pago_exitoso]       VARCHAR (MAX)   NULL,
    [url_pago_no_exitoso]    VARCHAR (MAX)   NULL,
    [id_tipo_concepto_boton] INT             NOT NULL,
    [color_borde]            VARCHAR (20)    NULL,
    [color_fondo]            VARCHAR (20)    NULL,
    [color_fuente]           VARCHAR (20)    NULL,
    [fecha_alta]             DATETIME        NULL,
    [fecha_baja]             DATETIME        NULL,
    [fecha_modificacion]     DATETIME        NULL,
    [flag_tipo_monto]        BIT             NULL,
    [tamanio]                VARCHAR (20)    NULL,
    [usuario_alta]           VARCHAR (20)    NULL,
    [usuario_baja]           VARCHAR (20)    NULL,
    [usuario_modificacion]   VARCHAR (20)    NULL,
    [version]                INT             CONSTRAINT [DF_Boton_version] DEFAULT ((0)) NOT NULL,
    [id_publico_boton]       VARCHAR (64)    NULL,
    [fuente_tipo]            VARCHAR (20)    NULL,
    [titulo]                 VARCHAR (255)   NULL,
    [texto]                  VARCHAR (10)    NULL,
    [flag_tipo_stock]        BIT             CONSTRAINT [DF_flag_tipo_stock] DEFAULT ((0)) NOT NULL,
    [logo]                   VARCHAR (256)   NULL,
    [stock]                  INT             NULL,
    [alto_boton]             VARCHAR (20)    NULL,
    [ancho_boton]            VARCHAR (20)    NULL,
    [id_apariencia_boton]    INT             NULL,
    [flag_reintento_tx]      BIT             NULL,
    [flag_habilitado]        BIT             NULL,
    [vencimiento]            DATETIME        NULL,
    CONSTRAINT [PK_Boton] PRIMARY KEY CLUSTERED ([id_boton] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_boton_apariencia_boton] FOREIGN KEY ([id_apariencia_boton]) REFERENCES [dbo].[Apariencia_Boton] ([id_apariencia_boton]),
    CONSTRAINT [FK_Boton_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Boton_Tipo_id_tipo_boton] FOREIGN KEY ([id_tipo_boton]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Boton_Tipo_id_tipo_concepto_boton] FOREIGN KEY ([id_tipo_concepto_boton]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [IX_Boton_id_cuenta]
    ON [dbo].[Boton]([id_cuenta] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Boton_id_publico_boton]
    ON [dbo].[Boton]([id_publico_boton] ASC) WITH (FILLFACTOR = 95);

