CREATE TABLE [dbo].[Resolutor_Transaccion] (
    [id_resolutor]         INT          NOT NULL,
    [codigo_resolutor]     VARCHAR (20) NOT NULL,
    [descripcion]          VARCHAR (20) NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NOT NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Resolutor_Transaccion_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_resolutor] PRIMARY KEY CLUSTERED ([id_resolutor] ASC) WITH (FILLFACTOR = 80)
);

