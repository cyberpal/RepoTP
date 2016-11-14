CREATE TABLE [dbo].[Comercio_Prisma_Baja] (
    [cuit]                 VARCHAR (11) NOT NULL,
    [id_banco]             INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    CONSTRAINT [FK_Comercio_Prisma_Baja_id_banco] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco])
);

