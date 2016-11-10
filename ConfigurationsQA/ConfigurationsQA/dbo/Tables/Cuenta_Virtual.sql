CREATE TABLE [dbo].[Cuenta_Virtual] (
    [id_cuenta_virtual]       INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]               INT             NOT NULL,
    [saldo_en_cuenta]         DECIMAL (12, 2) CONSTRAINT [DF_Cuenta_Virtual_saldo_en_c] DEFAULT ((0)) NOT NULL,
    [saldo_en_revision]       DECIMAL (12, 2) CONSTRAINT [DF_Cuenta_Virtual_saldo_en_r] DEFAULT ((0)) NOT NULL,
    [disponible]              DECIMAL (12, 2) CONSTRAINT [DF_Cuenta_Virtual_disponible] DEFAULT ((0)) NOT NULL,
    [id_proceso_modificacion] INT             NULL,
    [id_tipo_cashout]         INT             NULL,
    [fecha_alta]              DATETIME        NULL,
    [usuario_alta]            VARCHAR (20)    NULL,
    [fecha_modificacion]      DATETIME        NULL,
    [usuario_modificacion]    VARCHAR (20)    NULL,
    [fecha_baja]              DATETIME        NULL,
    [usuario_baja]            VARCHAR (20)    NULL,
    [version]                 INT             CONSTRAINT [DF_Cuenta_Virtual_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cuenta_Virtual] PRIMARY KEY CLUSTERED ([id_cuenta_virtual] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cuenta_Virtual_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Cuenta_Virtual_Proceso] FOREIGN KEY ([id_proceso_modificacion]) REFERENCES [dbo].[Proceso] ([id_proceso]),
    CONSTRAINT [FK_Cuenta_Virtual_Tipo] FOREIGN KEY ([id_tipo_cashout]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [idx_Actualizar_Cuenta_Virtual_Control]
    ON [dbo].[Cuenta_Virtual]([id_cuenta] ASC, [fecha_alta] ASC) WITH (FILLFACTOR = 95);

