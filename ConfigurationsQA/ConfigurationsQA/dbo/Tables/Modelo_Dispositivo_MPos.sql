CREATE TABLE [dbo].[Modelo_Dispositivo_MPos] (
    [id_modelo_dispositivo_mpos]          INT             IDENTITY (1, 1) NOT NULL,
    [codigo_modelo_dispositivo_mpos]      VARCHAR (20)    NOT NULL,
    [descripcion_modelo_dispositivo_mpos] VARCHAR (100)   NOT NULL,
    [precio_unitario]                     DECIMAL (12, 2) NOT NULL,
    [altura_pack]                         INT             NOT NULL,
    [largo_pack]                          INT             NOT NULL,
    [ancho_pack]                          INT             NOT NULL,
    [peso_pack]                           INT             NOT NULL,
    [fecha_alta]                          DATETIME        NULL,
    [usuario_alta]                        VARCHAR (20)    NULL,
    [fecha_modificacion]                  DATETIME        NULL,
    [usuario_modificacion]                VARCHAR (20)    NULL,
    [fecha_baja]                          DATETIME        NULL,
    [usuario_baja]                        VARCHAR (20)    NULL,
    [version]                             INT             CONSTRAINT [DF_Modelo_Dispositivo_MPos_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Modelo_Dispositivo_MPos] PRIMARY KEY CLUSTERED ([id_modelo_dispositivo_mpos] ASC)
);

