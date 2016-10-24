CREATE TABLE [dbo].[Notificacion_Parametro] (
    [id]               INT           IDENTITY (1, 1) NOT NULL,
    [id_notificacion]  INT           NOT NULL,
    [nombre_parametro] VARCHAR (50)  NOT NULL,
    [valor_parametro]  VARCHAR (200) NULL,
    CONSTRAINT [PK_Notificacion_Parametro] PRIMARY KEY CLUSTERED ([id] ASC) WITH (FILLFACTOR = 80)
);

