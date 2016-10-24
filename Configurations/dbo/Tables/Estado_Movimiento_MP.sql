CREATE TABLE [dbo].[Estado_Movimiento_MP] (
    [id_estado_movimiento_mp] INT          NOT NULL,
    [id_medio_pago]           INT          NULL,
    [campo_mp_1]              VARCHAR (10) NULL,
    [valor_1]                 VARCHAR (15) NULL,
    [campo_mp_2]              VARCHAR (10) NULL,
    [valor_2]                 VARCHAR (15) NULL,
    [campo_mp_3]              VARCHAR (10) NULL,
    [valor_3]                 VARCHAR (15) NULL,
    [estado_movimiento]       CHAR (1)     NULL,
    [fecha_alta]              DATETIME     NOT NULL,
    [usuario_alta]            VARCHAR (20) NULL,
    [fecha_modificacion]      DATETIME     NULL,
    [usuario_modificacion]    VARCHAR (20) NULL,
    [fecha_baja]              DATETIME     NULL,
    [usuario_baja]            VARCHAR (20) NULL,
    [version]                 INT          CONSTRAINT [DF_Estado_Movimiento_MP_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Estado_Movimiento_MP] PRIMARY KEY CLUSTERED ([id_estado_movimiento_mp] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Estado_Movimiento_MP_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

