CREATE TABLE [dbo].[cte_prueba_tmp] (
    [id_cuenta]                  INT             NULL,
    [fecha_procesada]            DATETIME        NULL,
    [cant_tx_dia_TC]             INT             NULL,
    [cant_tx_dia_TD]             INT             NULL,
    [cant_tx_dia_cupon]          INT             NULL,
    [cant_tx_dia_cupon_vencido]  INT             NULL,
    [cant_tx_dia_cashOut]        INT             NULL,
    [cant_tx_dia_TC_mPos]        INT             NULL,
    [cant_tx_dia_TD_mPos]        INT             NULL,
    [monto_tx_dia_TC]            DECIMAL (12, 2) NULL,
    [monto_tx_dia_TD]            DECIMAL (12, 2) NULL,
    [monto_tx_dia_cupon]         DECIMAL (12, 2) NULL,
    [monto_tx_dia_cupon_vencido] DECIMAL (12, 2) NULL,
    [monto_tx_dia_cashOut]       DECIMAL (12, 2) NULL,
    [monto_tx_dia_TC_mPos]       DECIMAL (12, 2) NULL,
    [monto_tx_dia_TD_mPos]       DECIMAL (12, 2) NULL
);

