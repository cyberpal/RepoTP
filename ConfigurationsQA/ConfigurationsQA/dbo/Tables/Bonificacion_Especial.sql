CREATE TABLE [dbo].[Bonificacion_Especial] (
    [id_bonificacion_especial] INT             IDENTITY (1, 1) NOT NULL,
    [nombre]                   VARCHAR (100)   NULL,
    [fecha_inicio_vigencia]    DATE            NOT NULL,
    [fecha_fin_vigencia]       DATE            NOT NULL,
    [bonificacion_comprador]   DECIMAL (5, 2)  NULL,
    [tope_devolucion]          DECIMAL (12, 2) NULL,
    [plazo_devolucion]         INT             NOT NULL,
    [fecha_alta]               DATETIME        NULL,
    [usuario_alta]             VARCHAR (20)    NULL,
    [fecha_modificacion]       DATETIME        NULL,
    [usuario_modificacion]     VARCHAR (20)    NULL,
    [fecha_baja]               DATETIME        NULL,
    [usuario_baja]             VARCHAR (20)    NULL,
    [version]                  INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_id_bonificacion_especial] PRIMARY KEY CLUSTERED ([id_bonificacion_especial] ASC)
);

