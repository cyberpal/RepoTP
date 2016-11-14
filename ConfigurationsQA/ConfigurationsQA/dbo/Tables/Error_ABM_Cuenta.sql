CREATE TABLE [dbo].[Error_ABM_Cuenta] (
    [id_error_abm_cuenta]   INT          IDENTITY (1, 1) NOT NULL,
    [id_detalle_abm_cuenta] INT          NOT NULL,
    [id_mensaje]            INT          NOT NULL,
    [fecha_alta]            DATETIME     NOT NULL,
    [usuario_alta]          VARCHAR (20) NOT NULL,
    [fecha_modificacion]    DATETIME     NULL,
    [usuario_modificacion]  VARCHAR (20) NULL,
    [fecha_baja]            DATETIME     NULL,
    [usuario_baja]          VARCHAR (20) NULL,
    [version]               INT          CONSTRAINT [DF_Error_ABM_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Error_ABM_Cuenta] PRIMARY KEY CLUSTERED ([id_error_abm_cuenta] ASC),
    CONSTRAINT [FK_Error_ABM_Cuenta__Detalle_ABM_Cuenta] FOREIGN KEY ([id_detalle_abm_cuenta]) REFERENCES [dbo].[Detalle_ABM_Cuenta] ([id_detalle_abm_cuenta]),
    CONSTRAINT [FK_Error_ABM_Cuenta__Mensaje] FOREIGN KEY ([id_mensaje]) REFERENCES [dbo].[Mensaje] ([id_mensaje])
);

