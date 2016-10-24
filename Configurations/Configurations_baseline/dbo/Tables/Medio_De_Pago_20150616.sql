﻿CREATE TABLE [dbo].[Medio_De_Pago_20150616] (
    [id_medio_pago]                    INT             NOT NULL,
    [id_tipo_medio_pago]               INT             NOT NULL,
    [nro_comercio]                     VARCHAR (50)    NULL,
    [flag_habilitado]                  CHAR (1)        NULL,
    [flag_control_vencimiento]         BIT             NULL,
    [flag_codigo_seguridad]            BIT             NULL,
    [longitud_codigo_seguridad]        INT             NULL,
    [flag_ultimos_4digitos]            BIT             NULL,
    [flag_opera_cuotas]                BIT             NULL,
    [flag_opera_planes]                BIT             NULL,
    [cuota_minima_plan]                INT             NULL,
    [flag_opera_dolares]               BIT             NOT NULL,
    [flag_permite_preautorizacion]     BIT             NOT NULL,
    [flag_control_monto_tx]            BIT             NULL,
    [monto_minimo_tx]                  DECIMAL (12, 2) NULL,
    [monto_maximo_tx]                  DECIMAL (12, 2) NULL,
    [plazo_pago_marca]                 INT             NOT NULL,
    [margen_espera_pago_marca]         INT             NOT NULL,
    [plazo_resolucion_disputa_marca]   INT             NOT NULL,
    [plazo_resolucion_disputa_cuenta]  INT             NOT NULL,
    [usuario_alta]                     VARCHAR (20)    NULL,
    [fecha_alta]                       DATETIME        NULL,
    [usuario_baja]                     VARCHAR (20)    NULL,
    [fecha_baja]                       DATETIME        NULL,
    [codigo]                           VARCHAR (20)    NULL,
    [nombre]                           VARCHAR (50)    NULL,
    [id_mp_decidir]                    INT             NOT NULL,
    [fecha_modificacion]               DATETIME        NULL,
    [flag_opera_con_banco]             BIT             NOT NULL,
    [flag_opera_datos_adicionales]     BIT             NOT NULL,
    [longitud_max_tarjeta]             INT             NULL,
    [longitud_min_tarjeta]             INT             NULL,
    [plazo_primer_vto]                 INT             NULL,
    [plazo_segundo_vto]                INT             NULL,
    [porcentaje_recargo_vto]           DECIMAL (12, 2) NULL,
    [tope_primer_vto]                  INT             NULL,
    [usuario_modificacion]             VARCHAR (20)    NULL,
    [version]                          INT             NOT NULL,
    [flag_informa_rubro]               BIT             NULL,
    [plazo_devolucion]                 INT             NULL,
    [flag_permite_anulacion]           BIT             NOT NULL,
    [flag_permite_devolucion]          BIT             NOT NULL,
    [flag_permite_segundo_vto]         BIT             NULL,
    [logo]                             VARCHAR (256)   NULL,
    [tipo_codigo_barra]                VARCHAR (50)    NULL,
    [url_mp]                           VARCHAR (256)   NULL,
    [flag_permite_contracargo]         BIT             NOT NULL,
    [flag_permite_transaccion_sin_cvv] BIT             NOT NULL,
    [orden]                            INT             NULL,
    [id_resolutor]                     INT             NULL,
    [cant_maxima_cuotas_mp]            INT             NULL,
    [cant_maxima_cuotas_boton]         INT             NULL,
    [texto_codigo_seguridad]           VARCHAR (255)   NULL,
    [imagen_codigo_seguridad]          VARCHAR (50)    NULL,
    [flag_permite_devolucion_sin_cvv]  BIT             NOT NULL
);

