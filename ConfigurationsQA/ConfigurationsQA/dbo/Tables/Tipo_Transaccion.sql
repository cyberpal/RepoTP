CREATE TABLE [dbo].[Tipo_Transaccion] (
    [id_tipo_transaccion]   INT          NOT NULL,
    [descripcion]           VARCHAR (50) NULL,
    [descripcion_a_mostrar] VARCHAR (20) NULL,
    [fecha_alta]            DATETIME     NULL,
    [usuario_alta]          VARCHAR (20) NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          CONSTRAINT [DF_Tipo_Transaccion_version] DEFAULT ((0)) NOT NULL,
    [vision]                VARCHAR (20) NULL,
    CONSTRAINT [PK_Tipo_Transaccion] PRIMARY KEY CLUSTERED ([id_tipo_transaccion] ASC) WITH (FILLFACTOR = 80)
);

