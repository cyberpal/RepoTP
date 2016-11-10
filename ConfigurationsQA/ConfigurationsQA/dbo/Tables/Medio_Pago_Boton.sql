CREATE TABLE [dbo].[Medio_Pago_Boton] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [id_boton]             INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Medio_Pago_Boton_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Medio_Pago_Boton] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Medio_Pago_Boton_Boton] FOREIGN KEY ([id_boton]) REFERENCES [dbo].[Boton] ([id_boton]),
    CONSTRAINT [FK_Medio_Pago_Boton_Medio_De_Pago] FOREIGN KEY ([id_medio_pago]) REFERENCES [dbo].[Medio_De_Pago] ([id_medio_pago])
);

