CREATE TABLE [dbo].[Plan] (
    [id_plan]              INT          NOT NULL,
    [id_medio_pago]        INT          NULL,
    [nombre]               VARCHAR (20) NULL,
    [transmite_valor]      INT          NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Plan_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Plan] PRIMARY KEY CLUSTERED ([id_plan] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Plan_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

