CREATE TABLE [dbo].[Bin_Banco_Medio_Pago_20160405] (
    [id_bin_banco_mp]      INT          IDENTITY (1, 1) NOT NULL,
    [bin]                  VARCHAR (8)  NOT NULL,
    [id_banco]             INT          NOT NULL,
    [id_medio_pago]        INT          NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          NULL
);

