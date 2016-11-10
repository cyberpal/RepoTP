CREATE TABLE [dbo].[Detalle_Archivo_ABM_Cuenta_Tmp] (
    [id_detalle_tmp]        INT           IDENTITY (1, 1) NOT NULL,
    [id_archivo_abm_cuenta] INT           NOT NULL,
    [detalle]               VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Detalle_Archivo_ABM_Cuenta_tmp] PRIMARY KEY CLUSTERED ([id_detalle_tmp] ASC),
    CONSTRAINT [FK_Detalle_Archivo_ABM_Cuenta_Tmp__Archivo_ABM_Cuenta] FOREIGN KEY ([id_archivo_abm_cuenta]) REFERENCES [dbo].[Archivo_ABM_Cuenta] ([id_archivo_abm_cuenta])
);

