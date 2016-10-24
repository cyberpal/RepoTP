CREATE TABLE [dbo].[Feriados] (
    [fecha]      DATETIME NULL,
    [esFeriado]  BIT      NOT NULL,
    [diaSemana]  TINYINT  NULL,
    [diasEnMes]  TINYINT  NULL,
    [habilitado] BIT      CONSTRAINT [DF_Feriados_habilitado] DEFAULT ((1)) NOT NULL
);

