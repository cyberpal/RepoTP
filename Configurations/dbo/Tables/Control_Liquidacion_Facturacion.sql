CREATE TABLE [dbo].[Control_Liquidacion_Facturacion] (
    [I_control]              INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]              INT             NULL,
    [numero_CUIT]            VARCHAR (11)    NULL,
    [eMail]                  VARCHAR (50)    NULL,
    [saldo_pendiente]        DECIMAL (15, 2) NULL,
    [saldo_revision]         DECIMAL (15, 2) NULL,
    [saldo_disponible]       DECIMAL (15, 2) NULL,
    [suma_cargos_aurus]      DECIMAL (15, 2) NULL,
    [tipo_comprobante_fact]  CHAR (1)        NULL,
    [total_liquidado]        DECIMAL (15, 2) NULL,
    [tipo_comprobante_liqui] CHAR (1)        NULL,
    [posee_diferencia]       BIT             NULL,
    [id_ciclo_facturacion]   INT             NULL,
    [anio]                   INT             NULL,
    [mes]                    INT             NULL,
    [fecha_alta]             DATETIME        NULL,
    [usuario_alta]           VARCHAR (20)    NULL,
    [fecha_modificacion]     DATETIME        NULL,
    [usuario_modificacion]   VARCHAR (20)    NULL,
    CONSTRAINT [PK_Control_Liquidacion_Facturacion] PRIMARY KEY CLUSTERED ([I_control] ASC) WITH (FILLFACTOR = 80)
);

