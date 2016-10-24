CREATE TABLE [dbo].[CUIT_Condicionado] (
    [id_cuit_condicionado]  INT          IDENTITY (1, 1) NOT NULL,
    [numero_CUIT]           VARCHAR (11) NOT NULL,
    [id_banco]              INT          NOT NULL,
    [fecha_inicio_vigencia] DATE         NOT NULL,
    [fecha_fin_vigencia]    DATE         NOT NULL,
    [id_documento]          INT          NOT NULL,
    [id_motivo_alta]        INT          NOT NULL,
    [id_motivo_baja]        INT          DEFAULT (NULL) NULL,
    [fecha_alta]            DATETIME     NOT NULL,
    [usuario_alta]          VARCHAR (20) NOT NULL,
    [fecha_modificacion]    DATETIME     DEFAULT (NULL) NULL,
    [usuario_modificacion]  VARCHAR (20) DEFAULT (NULL) NULL,
    [fecha_baja]            DATETIME     DEFAULT (NULL) NULL,
    [usuario_baja]          VARCHAR (20) DEFAULT (NULL) NULL,
    [version]               INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id_cuit_condicionado] ASC),
    CONSTRAINT [FK_BANCO_ID_BANCO] FOREIGN KEY ([id_banco]) REFERENCES [dbo].[Banco] ([id_banco]),
    CONSTRAINT [FK_DOCUMENTO_ID_DOCUMENTO] FOREIGN KEY ([id_documento]) REFERENCES [dbo].[Documento] ([id_documento]),
    CONSTRAINT [FK_MOTIVO_ID_MOTIVO_ALTA] FOREIGN KEY ([id_motivo_alta]) REFERENCES [dbo].[Motivo] ([id_motivo]),
    CONSTRAINT [FK_MOTIVO_ID_MOTIVO_BAJA] FOREIGN KEY ([id_motivo_baja]) REFERENCES [dbo].[Motivo] ([id_motivo])
);

