CREATE TABLE [dbo].[Documento] (
    [id_documento]         INT             IDENTITY (1, 1) NOT NULL,
    [id_cuenta]            INT             NULL,
    [id_tipo_documento]    INT             NOT NULL,
    [documento]            VARBINARY (MAX) NOT NULL,
    [fecha_alta]           DATETIME        NULL,
    [usuario_alta]         VARCHAR (20)    NULL,
    [fecha_modificacion]   DATETIME        NULL,
    [usuario_modificacion] VARCHAR (20)    NULL,
    [fecha_baja]           DATETIME        NULL,
    [usuario_baja]         VARCHAR (20)    NULL,
    [version]              INT             CONSTRAINT [DF_Documento_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Documento] PRIMARY KEY CLUSTERED ([id_documento] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Documento_Cuenta] FOREIGN KEY ([id_cuenta]) REFERENCES [dbo].[Cuenta] ([id_cuenta]),
    CONSTRAINT [FK_Documento_Tipo] FOREIGN KEY ([id_tipo_documento]) REFERENCES [dbo].[Tipo] ([id_tipo])
);

