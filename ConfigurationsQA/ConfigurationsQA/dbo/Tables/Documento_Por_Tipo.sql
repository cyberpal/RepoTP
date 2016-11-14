CREATE TABLE [dbo].[Documento_Por_Tipo] (
    [id]                   INT          NOT NULL,
    [id_tipo_condicion]    INT          NULL,
    [id_tipo_documento]    INT          NULL,
    [flag_requerido]       BIT          NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Documento_Por_Tipo_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Documento_Por_Tipo] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Documento_Por_Tipo_Tipo_id_tipo_condicion] FOREIGN KEY ([id_tipo_condicion]) REFERENCES [dbo].[Tipo] ([id_tipo]),
    CONSTRAINT [FK_Documento_Por_Tipo_Tipo_id_tipo_documento] FOREIGN KEY ([id_tipo_documento]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

