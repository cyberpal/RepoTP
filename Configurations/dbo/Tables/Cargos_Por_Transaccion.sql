CREATE TABLE [dbo].[Cargos_Por_Transaccion] (
    [id_cargo_transaccion] INT             IDENTITY (1, 1) NOT NULL,
    [id_cargo]             INT             NOT NULL,
    [id_transaccion]       CHAR (36)       NOT NULL,
    [monto_calculado]      DECIMAL (12, 2) NOT NULL,
    [valor_aplicado]       DECIMAL (12, 2) NOT NULL,
    [id_tipo_aplicacion]   INT             NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        CONSTRAINT [DF_Cargos_Por_Transaccion_fecha_modificacion] DEFAULT (NULL) NULL,
    [usuario_modificacion] VARCHAR (20)    CONSTRAINT [DF_Cargos_Por_Transaccion_usuario_modificacion] DEFAULT (NULL) NULL,
    [fecha_baja]           DATETIME        CONSTRAINT [DF_Cargos_Por_Transaccion_fecha_baja] DEFAULT (NULL) NULL,
    [usuario_baja]         VARCHAR (20)    CONSTRAINT [DF_Cargos_Por_Transaccion_usuario_baja] DEFAULT (NULL) NULL,
    [version]              INT             CONSTRAINT [DF_Cargos_Por_Transaccion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Cargos_Por_Transaccion] PRIMARY KEY CLUSTERED ([id_cargo_transaccion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Cargos_Por_Transaccion_Id_Cargo] FOREIGN KEY ([id_cargo]) REFERENCES [dbo].[Cargo] ([id_cargo]),
    CONSTRAINT [FK_Cargos_Por_Transaccion_Id_Tipo] FOREIGN KEY ([id_tipo_aplicacion]) REFERENCES [dbo].[Tipo] ([id_tipo])
);


GO
CREATE NONCLUSTERED INDEX [IX_id_cargo]
    ON [dbo].[Cargos_Por_Transaccion]([id_cargo] ASC) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_id_transaccion]
    ON [dbo].[Cargos_Por_Transaccion]([id_transaccion] ASC) WITH (FILLFACTOR = 95);

