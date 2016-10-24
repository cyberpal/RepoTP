CREATE TABLE [dbo].[Operador_Celular] (
    [id_operador_celular]  INT          IDENTITY (1, 1) NOT NULL,
    [codigo]               VARCHAR (20) NOT NULL,
    [descripcion]          VARCHAR (30) NOT NULL,
    [fecha_alta]           DATETIME     NOT NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Operador_Celular_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_operador_celular] PRIMARY KEY CLUSTERED ([id_operador_celular] ASC) WITH (FILLFACTOR = 80)
);

