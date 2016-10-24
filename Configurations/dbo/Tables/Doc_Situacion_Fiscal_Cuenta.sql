CREATE TABLE [dbo].[Doc_Situacion_Fiscal_Cuenta] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [id_documento]         INT          NULL,
    [id_situacion_fiscal]  INT          NULL,
    [id_estado_documento]  INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [fecha_validacion]     DATETIME     NULL,
    [usuario_validador]    VARCHAR (50) NULL,
    [version]              INT          CONSTRAINT [DF_Doc_Situacion_Fiscal_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_motivo_estado]     INT          NULL,
    CONSTRAINT [PK_Doc_Situacion_Fiscal_Cue] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Doc_Situacion_Fiscal_Cue_Documento] FOREIGN KEY ([id_documento]) REFERENCES [dbo].[Documento] ([id_documento]),
    CONSTRAINT [FK_Doc_Situacion_Fiscal_Cue_Estado] FOREIGN KEY ([id_estado_documento]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Doc_Situacion_Fiscal_Cue_Situacion_Fiscal_Cuenta] FOREIGN KEY ([id_situacion_fiscal]) REFERENCES [dbo].[Situacion_Fiscal_Cuenta] ([id_situacion_fiscal]),
    CONSTRAINT [FK_Doc_Situacion_Fiscal_Cuenta_Motivo_Estado] FOREIGN KEY ([id_motivo_estado]) REFERENCES [dbo].[Motivo_Estado] ([id_motivo_estado])
);

