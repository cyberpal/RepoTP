﻿CREATE TABLE [dbo].[Hist_Situacion_Fiscal_Cuenta] (
    [id_situacion_fiscal]        INT            NOT NULL,
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
    [version]                    INT            NOT NULL,
    [flag_validacion_excepcion]  BIT            NULL,
    [nro_inscripcion_IIBB]       VARCHAR (20)   NULL
);

