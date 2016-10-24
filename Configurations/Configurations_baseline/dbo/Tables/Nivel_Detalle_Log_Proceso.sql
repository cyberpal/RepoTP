CREATE TABLE [dbo].[Nivel_Detalle_Log_Proceso] (
    [id_nivel_detalle_lp] INT          IDENTITY (1, 1) NOT NULL,
    [descripcion]         VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Nivel_Detalle_LP] PRIMARY KEY CLUSTERED ([id_nivel_detalle_lp] ASC) WITH (FILLFACTOR = 80)
);

