CREATE TABLE [dbo].[Situacion_Fiscal_Cuenta] (
    [id_situacion_fiscal]        INT            IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                  INT            NULL,
    [numero_CUIT]                VARCHAR (11)   NULL,
    [razon_social]               VARCHAR (50)   NULL,
    [id_domicilio_facturacion]   INT            NULL,
    [id_tipo_condicion_IVA]      INT            NULL,
    [porcentaje_exclusion_iva]   DECIMAL (5, 2) NULL,
    [fecha_hasta_exclusion_IVA]  DATETIME       NULL,
    [id_tipo_condicion_IIBB]     INT            NULL,
    [porcentaje_exclusion_IIBB]  DECIMAL (5, 2) NULL,
    [fecha_hasta_exclusion_IIBB] DATETIME       NULL,
    [id_estado_documentacion]    INT            NOT NULL,
    [id_motivo_estado]           INT            NULL,
    [flag_vigente]               BIT            NULL,
    [fecha_inicio_vigencia]      DATE           NULL,
    [fecha_fin_vigencia]         DATE           NULL,
    [fecha_alta]                 DATETIME       NULL,
    [usuario_alta]               VARCHAR (20)   NULL,
    [fecha_modificacion]         DATETIME       NULL,
    [usuario_modificacion]       VARCHAR (20)   NULL,
    [fecha_baja]                 DATETIME       NULL,
    [usuario_baja]               VARCHAR (20)   NULL,
    [fecha_validacion]           DATETIME       NULL,
    [usuario_validador]          VARCHAR (20)   NULL,
    [version]                    INT            CONSTRAINT [DF_Situacion_Fiscal_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [flag_validacion_excepcion]  BIT            NULL,
    [nro_inscripcion_IIBB]       VARCHAR (20)   NULL,
    CONSTRAINT [PK_Situacion_Fiscal_Cuenta] PRIMARY KEY CLUSTERED ([id_situacion_fiscal] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Domicilio_Cuenta] FOREIGN KEY ([id_domicilio_facturacion]) REFERENCES [dbo].[Domicilio_Cuenta] ([id_domicilio]),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Estado] FOREIGN KEY ([id_estado_documentacion]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Motivo_Estado] FOREIGN KEY ([id_motivo_estado]) REFERENCES [dbo].[Motivo_Estado] ([id_motivo_estado]),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Tipo_id_tipo_condicion_IIBB] FOREIGN KEY ([id_tipo_condicion_IIBB]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Situacion_Fiscal_Cuenta_Tipo_id_tipo_condicion_IVA] FOREIGN KEY ([id_tipo_condicion_IVA]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizeBuyValidateRetrieveAlertLimitFiscal]
    ON [dbo].[Situacion_Fiscal_Cuenta]([id_cuenta] ASC, [flag_vigente] ASC);


GO

CREATE TRIGGER [Insert_History_Situacion_Fiscal_Cuenta] ON dbo.Situacion_Fiscal_Cuenta
	FOR UPDATE AS
	BEGIN
		IF EXISTS (select * from deleted)
		BEGIN
			INSERT INTO dbo.Hist_Situacion_Fiscal_Cuenta (id_situacion_fiscal, id_cuenta, numero_CUIT, razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_alta, usuario_alta, fecha_modificacion, usuario_modificacion, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB)
			SELECT id_situacion_fiscal, id_cuenta, numero_CUIT, razon_social, id_domicilio_facturacion, id_tipo_condicion_IVA, porcentaje_exclusion_iva, fecha_hasta_exclusion_IVA, id_tipo_condicion_IIBB, porcentaje_exclusion_IIBB, fecha_hasta_exclusion_IIBB, id_estado_documentacion, id_motivo_estado, flag_vigente, fecha_inicio_vigencia, fecha_fin_vigencia, fecha_modificacion, usuario_modificacion, NULL, NULL, fecha_baja, usuario_baja, fecha_validacion, usuario_validador, version, flag_validacion_excepcion, nro_inscripcion_IIBB FROM deleted
		END
END