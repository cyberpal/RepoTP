CREATE TABLE [dbo].[Informacion_Bancaria_Cuenta] (
    [id_informacion_bancaria]        INT           IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                      INT           NOT NULL,
    [cbu_cuenta_banco]               VARCHAR (22)  NOT NULL,
    [numero_cuenta_banco]            VARCHAR (19)  NULL,
    [fiid_banco]                     VARCHAR (4)   NULL,
    [fiidOrigenLink]                 VARCHAR (4)   NULL,
    [nombre_banco]                   VARCHAR (50)  NULL,
    [nombre_titular]                 VARCHAR (100) NULL,
    [cuit]                           VARCHAR (11)  NOT NULL,
    [resultado_validacion]           VARCHAR (2)   NULL,
    [flag_default]                   BIT           CONSTRAINT [DF_IBC_flag_default] DEFAULT ((0)) NOT NULL,
    [flag_vigente]                   BIT           CONSTRAINT [DF_IBC_flag_vigente] DEFAULT ((0)) NOT NULL,
    [fecha_alta]                     DATETIME      NULL,
    [usuario_alta]                   VARCHAR (20)  NULL,
    [fecha_modificacion]             DATETIME      NULL,
    [usuario_modificacion]           VARCHAR (20)  NULL,
    [fecha_baja]                     DATETIME      NULL,
    [usuario_baja]                   VARCHAR (20)  NULL,
    [version]                        INT           CONSTRAINT [DF_Informacion_Bancaria_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_tipo_cuenta_banco]           INT           NULL,
    [id_moneda_cuenta_banco]         INT           NULL,
    [id_tipo_cashout]                INT           NULL,
    [flag_preenrolado]               BIT           DEFAULT ((0)) NOT NULL,
    [id_estado_informacion_bancaria] INT           NULL,
    [id_tipo_cashout_solicitado]     INT           NULL,
    [id_motivo_estado]               INT           NULL,
    [id_canal]                       INT           NULL,
    [fecha_inicio_pendiente]         DATETIME      NULL,
    CONSTRAINT [PK_Informacion_Bancaria_Cue] PRIMARY KEY CLUSTERED ([id_informacion_bancaria] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([id_moneda_cuenta_banco]) REFERENCES [dbo].[Moneda] ([id_moneda]),
    FOREIGN KEY ([id_tipo_cuenta_banco]) REFERENCES [dbo].[Parametro] ([id_parametro]),
    CONSTRAINT [FK_IBC_id_tipo_cashout] FOREIGN KEY ([id_tipo_cashout]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [fk_id_canal1] FOREIGN KEY ([id_canal]) REFERENCES [dbo].[Canal_Adhesion] ([id_canal]),
    CONSTRAINT [fk_id_motivo_estado] FOREIGN KEY ([id_motivo_estado]) REFERENCES [dbo].[Motivo_Estado] ([id_motivo_estado]),
    CONSTRAINT [fk_id_tipo_cashout_solicitado] FOREIGN KEY ([id_tipo_cashout_solicitado]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Informacion_Bancaria_Cue_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_INFORMACION_BANCARIA_ESTADO] FOREIGN KEY ([id_estado_informacion_bancaria]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [fk_is_estado_informacion_bancaria] FOREIGN KEY ([id_estado_informacion_bancaria]) REFERENCES [dbo].[Estado] ([id_estado])
);


GO
CREATE NONCLUSTERED INDEX [IX_id_Cuenta]
    ON [dbo].[Informacion_Bancaria_Cuenta]([id_cuenta] ASC) WITH (FILLFACTOR = 95);

