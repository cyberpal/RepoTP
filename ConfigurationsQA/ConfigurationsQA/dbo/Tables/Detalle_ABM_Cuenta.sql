CREATE TABLE [dbo].[Detalle_ABM_Cuenta] (
    [id_detalle_abm_cuenta]      INT          IDENTITY (1, 1) NOT NULL,
    [id_archivo_abm_cuenta]      INT          NOT NULL,
    [tipo_novedad]               CHAR (1)     NULL,
    [id_tipo_cuenta]             INT          NULL,
    [nombre_fantasia]            VARCHAR (50) NULL,
    [razon_social]               VARCHAR (50) NULL,
    [id_operador_celular]        INT          NULL,
    [telefono_movil]             VARCHAR (10) NULL,
    [telefono_fijo]              VARCHAR (10) NULL,
    [id_tipo_condicion_IVA]      INT          NULL,
    [id_tipo_condicion_IIBB]     INT          NULL,
    [actividad]                  VARCHAR (4)  NULL,
    [CUIT]                       VARCHAR (11) NULL,
    [CBU]                        VARCHAR (22) NULL,
    [id_tipo_cashout]            INT          NULL,
    [cantidad_mpos]              INT          NULL,
    [id_modelo_dispositivo_mpos] INT          NULL,
    [id_cuenta]                  INT          NULL,
    [fecha_alta]                 DATETIME     NOT NULL,
    [usuario_alta]               VARCHAR (20) NOT NULL,
    [fecha_modificacion]         DATETIME     NULL,
    [usuario_modificacion]       VARCHAR (20) NULL,
    [fecha_baja]                 DATETIME     NULL,
    [usuario_baja]               VARCHAR (20) NULL,
    [version]                    INT          CONSTRAINT [DF_Detalle_ABM_Cuentas_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Detalle_ABM_Cuenta] PRIMARY KEY CLUSTERED ([id_detalle_abm_cuenta] ASC),
    CONSTRAINT [FK_Detalle_ABM_Cuenta__Archivo_ABM_Cuenta] FOREIGN KEY ([id_archivo_abm_cuenta]) REFERENCES [dbo].[Archivo_ABM_Cuenta] ([id_archivo_abm_cuenta]),
    CONSTRAINT [FK_Detalle_ABM_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta])
);



