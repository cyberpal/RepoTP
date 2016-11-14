CREATE TABLE [dbo].[Motivo_Conciliacion_Manual] (
    [id_motivo_conciliacion_manual]     INT           IDENTITY (1, 1) NOT NULL,
    [codigo_motivo_conciliacion_manual] VARCHAR (8)   NOT NULL,
    [descripcion]                       VARCHAR (100) NOT NULL,
    [fecha_alta]                        DATETIME      NULL,
    [usuario_alta]                      VARCHAR (20)  NULL,
    [fecha_modificacion]                DATETIME      NULL,
    [usuario_modificacion]              VARCHAR (20)  NULL,
    [fecha_baja]                        DATETIME      NULL,
    [usuario_baja]                      VARCHAR (20)  NULL,
    [version]                           INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Motivo_Conciliacion_Manual] PRIMARY KEY CLUSTERED ([id_motivo_conciliacion_manual] ASC) WITH (FILLFACTOR = 80)
);

