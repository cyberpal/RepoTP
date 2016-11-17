CREATE TABLE [dbo].[TransaccionesMedioPago_tmp] (
    [TransaccionesMedioPagoID]                    INT             IDENTITY (1, 1) NOT NULL,
    [id_transaccion]                              VARCHAR (36)    NULL,
    [tipo]                                        VARCHAR (1)     NULL,
    [id_cuenta]                                   INT             NULL,
    [BCRA_cuenta]                                 INT             NULL,
    [BCRA_emisor_tarjeta]                         INT             NULL,
    [signo_importe]                               CHAR (1)        NULL,
    [importe]                                     DECIMAL (12, 2) NULL,
    [cargo_marca]                                 DECIMAL (12, 2) NULL,
    [cargo_boton]                                 DECIMAL (12, 2) NULL,
    [impuesto_boton]                              DECIMAL (12, 2) NULL,
    [fecha_liberacion_cashout]                    DATETIME        NULL,
    [flag_esperando_impuestos_generales_de_marca] BIT             NULL,
    [id_impuesto_general]                         INT             NULL,
    [impuesto]                                    DECIMAL (12, 2) NULL
);



