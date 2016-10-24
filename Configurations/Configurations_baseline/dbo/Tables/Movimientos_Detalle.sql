CREATE TABLE [dbo].[Movimientos_Detalle] (
    [id_movimiento] INT IDENTITY (1, 1) NOT NULL,
    [id_detalle]    INT NOT NULL,
    CONSTRAINT [PK_Movimientos_Detalle] PRIMARY KEY CLUSTERED ([id_movimiento] ASC)
);

