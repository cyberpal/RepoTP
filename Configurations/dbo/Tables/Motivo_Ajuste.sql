CREATE TABLE [dbo].[Motivo_Ajuste] (
    [id_motivo_ajuste]        INT           IDENTITY (1, 1) NOT NULL,
    [nombre]                  VARCHAR (40)  NOT NULL,
    [codigo]                  INT           NULL,
    [descripcion]             VARCHAR (MAX) NOT NULL,
    [signo]                   CHAR (1)      CONSTRAINT [DF_Motivo_Ajuste_signo] DEFAULT ('+') NOT NULL,
    [facturable]              BIT           CONSTRAINT [DF_Motivo_Ajuste_facturable] DEFAULT ((0)) NOT NULL,
    [afecta_saldo_total]      BIT           CONSTRAINT [DF_Motivo_Ajuste_afecta_saldo_total] DEFAULT ((1)) NOT NULL,
    [afecta_saldo_disponible] BIT           CONSTRAINT [DF_Motivo_Ajuste_afecta_saldo_disponible] DEFAULT ((0)) NOT NULL,
    [afecta_saldo_revision]   BIT           CONSTRAINT [DF_Motivo_Ajuste_afecta_saldo_revision] DEFAULT ((0)) NOT NULL,
    [fecha_alta]              DATETIME      NOT NULL,
    [usuario_alta]            VARCHAR (20)  NOT NULL,
    [fecha_modificacion]      DATETIME      NULL,
    [usuario_modificacion]    VARCHAR (20)  NULL,
    [fecha_baja]              DATETIME      NULL,
    [usuario_baja]            VARCHAR (20)  NULL,
    [version]                 INT           CONSTRAINT [DF_Motivo_Ajuste_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Motivo_Ajuste] PRIMARY KEY CLUSTERED ([id_motivo_ajuste] ASC) WITH (FILLFACTOR = 80)
);

