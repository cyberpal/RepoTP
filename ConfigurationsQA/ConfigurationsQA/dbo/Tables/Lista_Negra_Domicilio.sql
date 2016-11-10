CREATE TABLE [dbo].[Lista_Negra_Domicilio] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [calle]                VARCHAR (50) NULL,
    [numero]               INT          NULL,
    [fecha_alta]           DATETIME     NULL,
    [usuario_alta]         VARCHAR (20) NULL,
    [fecha_modificacion]   DATETIME     NULL,
    [usuario_modificacion] VARCHAR (20) NULL,
    [fecha_baja]           DATETIME     NULL,
    [usuario_baja]         VARCHAR (20) NULL,
    [version]              INT          CONSTRAINT [DF_Lista_Negra_Domicilio_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Lista_Negra_Domicilio] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

