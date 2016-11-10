CREATE TABLE [dbo].[Comercio_Prisma_Aux] (
    [cuit]                 VARCHAR (11) NOT NULL,
    [id_banco]             INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL
);


GO
CREATE CLUSTERED INDEX [IX_CUIT]
    ON [dbo].[Comercio_Prisma_Aux]([cuit] ASC);

