CREATE TABLE [dbo].[Saldo_De_Cuenta_Tmp] (
    [I]                      INT             NOT NULL,
    [LocationIdentification] INT             NULL,
    [Saldo]                  DECIMAL (12, 2) NULL,
    [CantidadCompras]        INT             NULL,
    CONSTRAINT [PK_Saldo_De_Cuenta_Tmp] PRIMARY KEY CLUSTERED ([I] ASC)
);

