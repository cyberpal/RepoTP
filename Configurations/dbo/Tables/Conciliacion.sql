CREATE TABLE [dbo].[Conciliacion] (
    [id_conciliacion]        INT          NOT NULL,
    [id_transaccion]         CHAR (36)    NULL,
    [id_log_paso]            INT          NULL,
    [flag_aceptada_marca]    BIT          CONSTRAINT [DF_Conciliacion_flag_aceptada_marca] DEFAULT ((0)) NOT NULL,
    [flag_conciliada]        BIT          CONSTRAINT [DF_Conciliacion_flag_conciliada] DEFAULT ((0)) NOT NULL,
    [id_conciliacion_manual] INT          NULL,
    [flag_contracargo]       BIT          CONSTRAINT [DF_Conciliacion_flag_contracargo] DEFAULT ((0)) NOT NULL,
    [id_disputa]             INT          NULL,
    [fecha_alta]             DATETIME     NULL,
    [usuario_alta]           VARCHAR (20) NULL,
    [fecha_modificacion]     DATETIME     NULL,
    [usuario_modificacion]   VARCHAR (20) NULL,
    [fecha_baja]             DATETIME     NULL,
    [usuario_baja]           VARCHAR (20) NULL,
    [version]                INT          CONSTRAINT [DF_Conciliacion_version] DEFAULT ((0)) NOT NULL,
    [flag_distribuida]       BIT          CONSTRAINT [DF_Conciliacion_flag_distribuida] DEFAULT ((0)) NOT NULL,
    [id_movimiento_mp]       INT          NULL,
    [flag_notificado]        BIT          CONSTRAINT [DF_Conciliacion_flag_notificado] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Conciliacion] PRIMARY KEY CLUSTERED ([id_conciliacion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_Conciliacion_Conciliacion_Manual] FOREIGN KEY ([id_conciliacion_manual]) REFERENCES [dbo].[Conciliacion_Manual] ([id_conciliacion_manual]),
    CONSTRAINT [FK_Conciliacion_Movimiento_Presentado_MP] FOREIGN KEY ([id_movimiento_mp]) REFERENCES [dbo].[Movimiento_Presentado_MP] ([id_movimiento_mp])
);

