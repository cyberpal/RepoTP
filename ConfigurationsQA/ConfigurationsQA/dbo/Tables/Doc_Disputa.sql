CREATE TABLE [dbo].[Doc_Disputa] (
    [id_doc_disputa]       INT          IDENTITY (1, 1) NOT NULL,
    [id_documento]         INT          NOT NULL,
    [id_disputa]           INT          NOT NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Doc_Disputa_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_doc_disputa] PRIMARY KEY CLUSTERED ([id_doc_disputa] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_doc_disputa_id_documento] FOREIGN KEY ([id_documento]) REFERENCES [dbo].[Documento] ([id_documento])
);

