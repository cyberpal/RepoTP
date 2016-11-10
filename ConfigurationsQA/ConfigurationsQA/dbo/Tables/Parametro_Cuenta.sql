CREATE TABLE [dbo].[Parametro_Cuenta] (
    [id_parametro_cuenta]        INT          IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                  INT          NOT NULL,
    [flag_reporte_comercio]      BIT          CONSTRAINT [DF_Parametro_Cuenta_flag_reporte_c] DEFAULT ((0)) NOT NULL,
    [fecha_alta]                 DATETIME     NOT NULL,
    [usuario_alta]               VARCHAR (20) NOT NULL,
    [fecha_modificacion]         DATETIME     NULL,
    [usuario_modificacion]       VARCHAR (20) NULL,
    [fecha_baja]                 DATETIME     NULL,
    [usuario_baja]               VARCHAR (20) NULL,
    [version]                    INT          CONSTRAINT [DF_Parametro_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [api_key]                    VARCHAR (64) NULL,
    [api_key_pruebas]            VARCHAR (64) NULL,
    [id_cuenta_pruebas]          INT          NULL,
    [flag_excepcion_cybersource] BIT          CONSTRAINT [DF_Parametro_Cuenta_flag_excepcion_cybersource] DEFAULT ((0)) NULL,
    [tope_cuotas_credito]        INT          NULL,
    [operatoria_TI]              INT          DEFAULT ((0)) NULL,
    [versión_TYC_TI]             INT          NULL,
    CONSTRAINT [PK_Parametro_Cuenta] PRIMARY KEY CLUSTERED ([id_parametro_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Parametro_Cuenta_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Parametro_Cuenta_TyC_TI] FOREIGN KEY ([versión_TYC_TI]) REFERENCES [dbo].[TyC_TI] ([id_version])
);


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizeBuyValidateRetrieveCuenta_ID_Cuenta]
    ON [dbo].[Parametro_Cuenta]([id_cuenta] ASC, [fecha_baja] ASC);

