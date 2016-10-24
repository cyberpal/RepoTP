CREATE TABLE [dbo].[Disponible_Por_Cuenta_Tmp] (
    [I]                         INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]                 INT             NOT NULL,
    [denominacion]              VARCHAR (50)    NULL,
    [importe]                   DECIMAL (12, 2) NOT NULL,
    [disponible_anterior]       DECIMAL (12, 2) NULL,
    [disponible_actual]         DECIMAL (12, 2) NULL,
    [flag_disponible_ok]        BIT             DEFAULT ((0)) NOT NULL,
    [importe_liquidado]         DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [importe_cashout_actual]    DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [importe_cashout_pendiente] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [flag_liquidacion_ok]       BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Disponible_Por_Cuenta_Tmp] PRIMARY KEY CLUSTERED ([I] ASC)
);

