CREATE TABLE [dbo].[Resumen_Analisis_De_Saldo] (
    [id_resumen]                 INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                  INT             NOT NULL,
    [fecha_de_analisis]          DATETIME        NOT NULL,
    [cantidad_ventas]            INT             NOT NULL,
    [importe_ventas]             DECIMAL (15, 2) NOT NULL,
    [cantidad_devoluciones]      INT             NOT NULL,
    [importe_devoluciones]       DECIMAL (15, 2) NOT NULL,
    [cantidad_cashout]           INT             NOT NULL,
    [importe_cashout]            DECIMAL (15, 2) NOT NULL,
    [cantidad_ajustes]           INT             NOT NULL,
    [importe_ajustes]            DECIMAL (15, 2) NOT NULL,
    [cantidad_contracargos]      INT             NOT NULL,
    [importe_contracargos]       DECIMAL (15, 2) NOT NULL,
    [cantidad_total_movimientos] INT             NOT NULL,
    [importe_total_movimientos]  DECIMAL (15, 2) NOT NULL,
    [saldo_en_cuenta]            DECIMAL (15, 2) NOT NULL,
    [diferencia_de_saldo]        DECIMAL (15, 2) NOT NULL,
    [log_movimientos_cuenta_ok]  BIT             NOT NULL,
    [flag_generar_detalle]       BIT             NOT NULL,
    [detalle_generado_ok]        BIT             NULL,
    CONSTRAINT [PK_Resumen_Analisis_De_Saldo] PRIMARY KEY CLUSTERED ([id_resumen] ASC)
);

