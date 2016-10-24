CREATE TABLE [dbo].[Detalle_Ajuste_Facturacion] (
    [id_detalle_facturacion] INT          IDENTITY (1, 1) NOT NULL,
    [id_item_facturacion]    INT          NOT NULL,
    [id_ajuste]              INT          NOT NULL,
    [fecha_alta]             DATETIME     NOT NULL,
    [usuario_alta]           VARCHAR (20) NOT NULL,
    [version]                INT          NOT NULL,
    CONSTRAINT [PK_Detalle_Ajuste_Facturacion] PRIMARY KEY CLUSTERED ([id_detalle_facturacion] ASC) WITH (FILLFACTOR = 80)
);

