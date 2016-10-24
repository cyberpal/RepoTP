CREATE TABLE [dbo].[Actividad_Cuenta] (
    [id_cuenta]            INT          NOT NULL,
    [actividad_declarada]  VARCHAR (50) NULL,
    [id_actividad_AFIP]    INT          NULL,
    [id_rubro]             INT          NULL,
    [id_estado_actividad]  INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [fecha_validacion]     DATETIME     NULL,
    [usuario_validador]    VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Actividad_Cuenta_version] DEFAULT ((0)) NOT NULL,
    [id_actividad_cuenta]  INT          IDENTITY (1, 1) NOT NULL,
    [flag_vigente]         BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Actividad_Cuenta] PRIMARY KEY CLUSTERED ([id_actividad_cuenta] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Actividad_Cuenta_Actividad_AFIP] FOREIGN KEY ([id_actividad_AFIP]) REFERENCES [dbo].[Actividad_AFIP] ([id_actividad_AFIP]),
    CONSTRAINT [FK_Actividad_Cuenta_Estado] FOREIGN KEY ([id_estado_actividad]) REFERENCES [dbo].[Estado] ([id_estado]),
    CONSTRAINT [FK_Actividad_Cuenta_Rubro] FOREIGN KEY ([id_rubro]) REFERENCES [dbo].[Rubro] ([id_rubro])
);


GO
CREATE NONCLUSTERED INDEX [IX_Actividad_Cuenta_Actividad_AFIP]
    ON [dbo].[Actividad_Cuenta]([id_actividad_AFIP] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Actividad_Cuenta_Estado_actividad]
    ON [dbo].[Actividad_Cuenta]([id_estado_actividad] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_Actividad_Cuenta_id_rubro]
    ON [dbo].[Actividad_Cuenta]([id_rubro] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [idx_AuthorizeBuyValidateRetrieveCuenta]
    ON [dbo].[Actividad_Cuenta]([id_cuenta] ASC, [fecha_baja] ASC);

