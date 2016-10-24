CREATE TABLE [dbo].[CBU_Pendientes_Tmp] (
    [Id]                     INT           IDENTITY (1, 1) NOT NULL,
    [cuit]                   VARCHAR (11)  NULL,
    [entidad_solicitante]    VARCHAR (3)   NULL,
    [id_cuenta]              INT           NULL,
    [fecha_inicio_pendiente] DATE          NULL,
    [fecha_vencimiento]      DATE          NULL,
    [entidad_registrada]     VARCHAR (3)   NULL,
    [razon_social]           VARCHAR (100) NULL,
    [cbu]                    VARCHAR (22)  NULL,
    [id_banco]               INT           NULL,
    [tipo_acreditacion]      VARCHAR (14)  NULL,
    [motivo]                 VARCHAR (12)  NULL,
    [accion]                 VARCHAR (10)  NULL,
    CONSTRAINT [PK_CBU_Pendientes_Tmp] PRIMARY KEY CLUSTERED ([Id] ASC)
);

