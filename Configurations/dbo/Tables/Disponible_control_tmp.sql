CREATE TABLE [dbo].[Disponible_control_tmp] (
    [id_tmp]                  INT             IDENTITY (1, 1) NOT NULL,
    [Id_cuenta]               INT             NULL,
    [Denominacion]            VARCHAR (100)   NULL,
    [fecha_de_cashout]        DATE            NULL,
    [Importe_Liquidado]       DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Importe_Disponibilizado] DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Importe_Cashout_Actual]  DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [Importe_Pendiente]       DECIMAL (12, 2) DEFAULT ((0)) NULL,
    [flag_control]            BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Disponible_control_tmp] PRIMARY KEY CLUSTERED ([id_tmp] ASC)
);

