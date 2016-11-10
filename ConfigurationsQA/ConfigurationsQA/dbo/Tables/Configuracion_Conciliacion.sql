CREATE TABLE [dbo].[Configuracion_Conciliacion] (
    [id_parametro]         INT          NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [parametro]            VARCHAR (50) NULL,
    [campo_Transactions]   VARCHAR (50) NULL,
    [campo_Mov_pres_mp]    VARCHAR (50) NULL,
    [formato_parametro]    VARCHAR (15) NULL,
    [pos_inicial_mascara]  INT          NULL,
    [cantidad_pos_mascara] INT          NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([id_parametro] ASC) WITH (FILLFACTOR = 80),
    FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

