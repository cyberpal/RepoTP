CREATE TABLE [dbo].[Codigo_Operacion_Medio_Pago] (
    [id_codigo_operacion_mp] INT          NOT NULL,
    [id_medio_pago]          INT          NULL,
    [id_codigo_operacion]    INT          NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Codigo_Operacion_Medio_Pago_version] DEFAULT ((0)) NOT NULL,
    [campo_mp_1]             VARCHAR (10) NULL,
    [valor_1]                VARCHAR (15) NULL,
    [campo_mp_2]             VARCHAR (10) NULL,
    [valor_2]                VARCHAR (15) NULL,
    [campo_mp_3]             VARCHAR (10) NULL,
    [valor_3]                VARCHAR (15) NULL,
    CONSTRAINT [PK_Codigo_Operacion_Medio_Pago] PRIMARY KEY CLUSTERED ([id_codigo_operacion_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Codigo_Operacion_Medio_Pago_Codigo_Operacion] FOREIGN KEY ([id_codigo_operacion]) REFERENCES [dbo].[Codigo_Operacion] ([id_codigo_operacion]),
    CONSTRAINT [FK_Codigo_Operacion_Medio_Pago_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

