CREATE TABLE [dbo].[Site_Transaccion] (
    [id_site_transaccion]      INT          IDENTITY (1, 1) NOT NULL,
    [tipo_transaccion]         VARCHAR (50) NOT NULL,
    [id_tipo_concepto_boton]   INT          NULL,
    [flag_transaccion_con_cvv] BIT          DEFAULT ((0)) NOT NULL,
    [id_vertical_cs]           INT          NULL,
    [id_canal]                 INT          NULL,
    [nro_agrupador_decidir]    INT          NOT NULL,
    [fecha_alta]               DATETIME     NOT NULL,
    [usuario_alta]             VARCHAR (20) NOT NULL,
    [fecha_modificacion]       DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion]     VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]               DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]             VARCHAR (20) DEFAULT (NULL) NULL,
    [version]                  INT          CONSTRAINT [DF_Site_Transaccion_version] DEFAULT ((0)) NOT NULL,
    [tipo_pago]                VARCHAR (50) DEFAULT ('ONLINE') NOT NULL,
    [id_grupo_rubro]           INT          NULL,
    CONSTRAINT [PK_Site_Transaccion] PRIMARY KEY CLUSTERED ([id_site_transaccion] ASC),
    CONSTRAINT [fk_id_canal] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [fk_id_grupo_rubro] FOREIGN KEY ([id_grupo_rubro]) REFERENCES [dbo].[Grupo_Rubro] ([id_grupo_rubro]),
    CONSTRAINT [fk_id_tipo_concepto_boton] FOREIGN KEY ([id_tipo_concepto_boton]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [fk_id_vertical_cs] FOREIGN KEY ([id_vertical_cs]) REFERENCES [dbo].[Vertical_Cybersource] ([id_vertical_CS])
);

