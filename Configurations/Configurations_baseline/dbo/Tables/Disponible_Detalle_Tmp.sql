CREATE TABLE [dbo].[Disponible_Detalle_Tmp] (
    [id_cuenta]           INT             NOT NULL,
    [id_codigo_operacion] INT             NOT NULL,
    [importe]             DECIMAL (12, 2) NOT NULL,
    [fecha_cashout]       DATE            NOT NULL,
    [id_transaccion]      CHAR (36)       NULL,
    [id_bonificacion]     INT             NULL
);

