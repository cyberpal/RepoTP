CREATE TABLE [dbo].[Cupones_tmp] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [id_conciliacion]  INT             NOT NULL,
    [numero_cuenta]    INT             NULL,
    [url]              VARCHAR (256)   NULL,
    [id_transaccion]   CHAR (36)       NULL,
    [e_mail]           VARCHAR (64)    NULL,
    [concepto]         VARCHAR (255)   NULL,
    [importe]          DECIMAL (12, 2) NULL,
    [nombre_comprador] VARCHAR (48)    NULL,
    [nombre_vendedor]  VARCHAR (256)   NULL,
    CONSTRAINT [PK_Id] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);

