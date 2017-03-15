CREATE TABLE [dbo].[Cuentas_CashOut_tmp] (
    [id_cuenta]           INT             NULL,
    [nombre_completo]     VARCHAR (100)   NULL,
    [numero_cuit]         VARCHAR (11)    NULL,
    [id_usuario_cuenta]   INT             NULL,
    [disponible]          DECIMAL (12, 2) NULL,
    [cbu_cuenta_banco]    VARCHAR (22)    NULL,
    [url_ws_cashout]      VARCHAR (256)   NULL,
    [url_ws_notificacion] VARCHAR (256)   NULL,
    [url_ws_login_batch]  VARCHAR (256)   NULL
);

