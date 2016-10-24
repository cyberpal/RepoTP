CREATE TABLE [dbo].[Movimientos_conciliados_manual_tmp] (
    [id_conciliacion_manual] INT          NULL,
    [id_transaccion]         VARCHAR (36) NULL,
    [id_movimiento_mp]       INT          NULL,
    [flag_aceptada_marca]    BIT          NULL,
    [flag_contracargo]       BIT          NULL,
    [codigo]                 VARCHAR (20) NULL
);

