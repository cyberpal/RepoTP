CREATE TABLE [dbo].[Contracargos_tmp] (
    [id_transaccion]   VARCHAR (36)  NULL,
    [fecha_pago]       VARCHAR (10)  NULL,
    [id_log_proceso]   VARCHAR (8)   NULL,
    [id_movimiento_mp] INT           NULL,
    [id_log_paso]      INT           NULL,
    [id_conciliacion]  INT           NULL,
    [body_json]        VARCHAR (200) NULL,
    [url_servicio]     VARCHAR (200) NULL
);

