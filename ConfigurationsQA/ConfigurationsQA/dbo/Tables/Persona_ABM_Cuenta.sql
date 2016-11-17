CREATE TABLE [dbo].[Persona_ABM_Cuenta] (
    [id_persona_abm_cuenta]  INT          IDENTITY (1, 1) NOT NULL,
    [id_detalle_abm_cuenta]  INT          NOT NULL,
    [nombre]                 VARCHAR (50) NOT NULL,
    [apellido]               VARCHAR (50) NOT NULL,
    [email]                  VARCHAR (50) NOT NULL,
    [id_genero]              CHAR (1)     NOT NULL,
    [id_nacionalidad]        INT          NULL,
    [id_tipo_identificacion] INT          NULL,
    [numero_identificacion]  VARCHAR (20) NOT NULL,
    [fecha_nacimiento]       DATE         NOT NULL,
    [fecha_alta]             DATETIME     NOT NULL,
    [usuario_alta]           VARCHAR (20) NOT NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Persona_ABM_Cuenta_version] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Persona_ABM_Cuenta] PRIMARY KEY CLUSTERED ([id_persona_abm_cuenta] ASC),
    CONSTRAINT [FK_Persona_ABM_Cuenta__Detalle_ABM_Cuenta] FOREIGN KEY ([id_detalle_abm_cuenta]) REFERENCES [dbo].[Detalle_ABM_Cuenta] ([id_detalle_abm_cuenta])
);



