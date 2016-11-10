
CREATE PROCEDURE [dbo].[Clonar_Promocion] (
  @id_promocion          INT,
  @id_cuenta             INT,
  @fecha_inicio_vigencia DATE,
  @fecha_fin_vigencia    DATE,
  @usuario               VARCHAR(20),
  @id_promocion_clon     INT OUTPUT
)
AS
DECLARE @Promocion TABLE(
  [nombre]                    VARCHAR(50)  NOT NULL,
  [descripcion]               VARCHAR(100) NULL,
  [cant_cuotas_desde]         INT          NOT NULL,
  [cant_cuotas_hasta]         INT          NOT NULL,
  [fecha_inicio_vigencia]     DATE         NOT NULL,
  [fecha_fin_vigencia]        DATE         NOT NULL,
  [fecha_alta]                DATETIME     NULL,
  [usuario_alta]              VARCHAR(20)  NULL,
  [fecha_modificacion]        DATETIME     NULL,
  [usuario_modificacion]      VARCHAR(20)  NULL,
  [fecha_baja]                DATETIME     NULL,
  [usuario_baja]              VARCHAR(20)  NULL,
  [version]                   INT          NOT NULL,
  [id_medio_pago]             INT          NULL,
  [id_banco]                  INT          NULL,
  [id_cuenta]                 INT          NULL,
  [id_rubro]                  INT          NULL,
  [flag_aplica_lunes]         BIT          NOT NULL,
  [flag_aplica_martes]        BIT          NOT NULL,
  [flag_aplica_miercoles]     BIT          NOT NULL,
  [flag_aplica_jueves]        BIT          NOT NULL,
  [flag_aplica_viernes]       BIT          NOT NULL,
  [flag_aplica_sabado]        BIT          NOT NULL,
  [flag_aplica_domingo]       BIT          NOT NULL,
  [bonificacion_cf_comprador] BIT          NOT NULL,
  [id_motivo_estado]          INT          NULL,
  [id_estado_procesamiento]   INT          NOT NULL,
  [id_tipo_aplicacion]        INT          NOT NULL
);
DECLARE @Regla_Promocion TABLE(
  [i]                        INT IDENTITY (1, 1),
  [id_regla_promocion]       INT           NOT NULL,
  [id_promocion]             INT           NOT NULL,
  [cant_cuotas_desde]        INT           NOT NULL,
  [cant_cuotas_hasta]        INT           NOT NULL,
  [bonificacion_cf_vendedor] DECIMAL(5, 2) NULL,
  [fecha_alta]               DATETIME      NULL,
  [usuario_alta]             VARCHAR(20)   NULL,
  [fecha_modificacion]       DATETIME      NULL,
  [usuario_modificacion]     VARCHAR(20)   NULL,
  [fecha_baja]               DATETIME      NULL,
  [usuario_baja]             VARCHAR(20)   NULL,
  [version]                  INT           NOT NULL,
  [tasa_directa_ingresada]   DECIMAL(5, 2) NULL,
  [id_regla_promocion_clon]  INT
);
DECLARE @i INT = 1;
DECLARE @max_i INT;
DECLARE @id_regla_promocion_clon INT;
DECLARE @Volumen_Regla_Promocion TABLE(
  [id_regla_promocion]       INT            NOT NULL,
  [volumen_vta_desde]        DECIMAL(18, 2) NULL,
  [volumen_vta_hasta]        DECIMAL(18, 2) NULL,
  [bonificacion_cf_vendedor] DECIMAL(5, 2)  NULL,
  [fecha_alta]               DATETIME       NULL,
  [usuario_alta]             VARCHAR(20)    NULL,
  [fecha_modificacion]       DATETIME       NULL,
  [usuario_modificacion]     VARCHAR(20)    NULL,
  [fecha_baja]               DATETIME       NULL,
  [usuario_baja]             VARCHAR(20)    NULL,
  [version]                  INT            NOT NULL,
  [tasa_directa_ingresada]   DECIMAL(5, 2)  NULL
);
DECLARE @Regla_Bonificacion TABLE(
  [id_tasa_mp]                INT           NOT NULL,
  [fecha_desde]               DATE          NOT NULL,
  [fecha_hasta]               DATE          NULL,
  [id_banco]                  INT           NULL,
  [id_cuenta]                 INT           NULL,
  [dia_semana]                VARCHAR(7)    NULL,
  [bonificacion_cf_comprador] BIT           NOT NULL,
  [bonificacion_cf_vendedor]  DECIMAL(5, 2) NULL,
  [id_promocion]              INT           NULL,
  [fecha_alta]                DATETIME      NULL,
  [usuario_alta]              VARCHAR(20)   NULL,
  [fecha_modificacion]        DATETIME      NULL,
  [usuario_modificacion]      VARCHAR(20)   NULL,
  [fecha_baja]                DATETIME      NULL,
  [usuario_baja]              VARCHAR(20)   NULL,
  [version]                   INT           NOT NULL,
  [id_regla_promocion]        INT           NULL,
  [id_rubro]                  INT           NULL,
  [tasa_directa_ingresada]    DECIMAL(5, 2) NULL,
  [flag_tasa_directa]         BIT           NOT NULL
);

BEGIN
  -- Clonar el registro de la tabla Promoción
  INSERT INTO @Promocion (
    [nombre],
    [descripcion],
    [cant_cuotas_desde],
    [cant_cuotas_hasta],
    [fecha_inicio_vigencia],
    [fecha_fin_vigencia],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [id_medio_pago],
    [id_banco],
    [id_cuenta],
    [id_rubro],
    [flag_aplica_lunes],
    [flag_aplica_martes],
    [flag_aplica_miercoles],
    [flag_aplica_jueves],
    [flag_aplica_viernes],
    [flag_aplica_sabado],
    [flag_aplica_domingo],
    [bonificacion_cf_comprador],
    [id_motivo_estado],
    [id_estado_procesamiento],
    [id_tipo_aplicacion]
  )
    SELECT
      p.[nombre],
      p.[descripcion],
      p.[cant_cuotas_desde],
      p.[cant_cuotas_hasta],
      isnull(@fecha_inicio_vigencia, p.[fecha_inicio_vigencia]),
      isnull(@fecha_fin_vigencia, p.[fecha_fin_vigencia]),
      getdate(),
      @usuario,
      NULL,
      NULL,
      NULL,
      NULL,
      0,
      p.[id_medio_pago],
      p.[id_banco],
      isnull(@id_cuenta, p.[id_cuenta]),
      p.[id_rubro],
      p.[flag_aplica_lunes],
      p.[flag_aplica_martes],
      p.[flag_aplica_miercoles],
      p.[flag_aplica_jueves],
      p.[flag_aplica_viernes],
      p.[flag_aplica_sabado],
      p.[flag_aplica_domingo],
      p.[bonificacion_cf_comprador],
      p.[id_motivo_estado],
      p.[id_estado_procesamiento],
      p.[id_tipo_aplicacion]
    FROM [Configurations].[dbo].[Promocion] p
    WHERE p.[id_promocion] = @id_promocion;

  -- Crear nueva Promoción
  INSERT INTO [Configurations].[dbo].[Promocion] (
    [nombre],
    [descripcion],
    [cant_cuotas_desde],
    [cant_cuotas_hasta],
    [fecha_inicio_vigencia],
    [fecha_fin_vigencia],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [id_medio_pago],
    [id_banco],
    [id_cuenta],
    [id_rubro],
    [flag_aplica_lunes],
    [flag_aplica_martes],
    [flag_aplica_miercoles],
    [flag_aplica_jueves],
    [flag_aplica_viernes],
    [flag_aplica_sabado],
    [flag_aplica_domingo],
    [bonificacion_cf_comprador],
    [id_motivo_estado],
    [id_estado_procesamiento],
    [id_tipo_aplicacion]
  )
    SELECT
      [nombre],
      [descripcion],
      [cant_cuotas_desde],
      [cant_cuotas_hasta],
      [fecha_inicio_vigencia],
      [fecha_fin_vigencia],
      [fecha_alta],
      [usuario_alta],
      [fecha_modificacion],
      [usuario_modificacion],
      [fecha_baja],
      [usuario_baja],
      [version],
      [id_medio_pago],
      [id_banco],
      [id_cuenta],
      [id_rubro],
      [flag_aplica_lunes],
      [flag_aplica_martes],
      [flag_aplica_miercoles],
      [flag_aplica_jueves],
      [flag_aplica_viernes],
      [flag_aplica_sabado],
      [flag_aplica_domingo],
      [bonificacion_cf_comprador],
      [id_motivo_estado],
      [id_estado_procesamiento],
      [id_tipo_aplicacion]
    FROM @Promocion;

  -- Obtener el nuevo ID de Promoción
  SET @id_promocion_clon = scope_identity();

  IF (@id_promocion_clon IS NOT NULL)
    BEGIN
      -- Obtener las Reglas de Promoción de origen
      INSERT INTO @Regla_Promocion (
        [id_regla_promocion],
        [id_promocion],
        [cant_cuotas_desde],
        [cant_cuotas_hasta],
        [bonificacion_cf_vendedor],
        [fecha_alta],
        [usuario_alta],
        [fecha_modificacion],
        [usuario_modificacion],
        [fecha_baja],
        [usuario_baja],
        [version],
        [tasa_directa_ingresada]
      )
        SELECT
          [id_regla_promocion],
          @id_promocion_clon,
          rp.[cant_cuotas_desde],
          rp.[cant_cuotas_hasta],
          rp.[bonificacion_cf_vendedor],
          getdate(),
          @usuario,
          NULL,
          NULL,
          NULL,
          NULL,
          0,
          rp.[tasa_directa_ingresada]
        FROM [Configurations].[dbo].[Regla_Promocion] rp
        WHERE rp.[id_promocion] = @id_promocion;

      SET @max_i = @@rowcount;

      WHILE (@i <= @max_i)
        BEGIN
          -- Insertar las nuevas Reglas de Promoción
          INSERT INTO [Configurations].[dbo].[Regla_Promocion] (
            [id_promocion],
            [cant_cuotas_desde],
            [cant_cuotas_hasta],
            [bonificacion_cf_vendedor],
            [fecha_alta],
            [usuario_alta],
            [fecha_modificacion],
            [usuario_modificacion],
            [fecha_baja],
            [usuario_baja],
            [version],
            [tasa_directa_ingresada]
          )
            SELECT
              [id_promocion],
              [cant_cuotas_desde],
              [cant_cuotas_hasta],
              [bonificacion_cf_vendedor],
              [fecha_alta],
              [usuario_alta],
              [fecha_modificacion],
              [usuario_modificacion],
              [fecha_baja],
              [usuario_baja],
              [version],
              [tasa_directa_ingresada]
            FROM @Regla_Promocion
            WHERE [i] = @i;

          SET @id_regla_promocion_clon = scope_identity();

          IF (@id_regla_promocion_clon IS NULL)
            BEGIN; THROW 50002, 'No se pudo obtener el id de la nueva regla de promoción', 1;
        END

      -- Reservar el nuevo ID
      UPDATE @Regla_Promocion
      SET [id_regla_promocion_clon] = @id_regla_promocion_clon
      WHERE [i] = @i;

      SET @i += 1;
    END;

  -- Obtener los volúmenes origen
  INSERT INTO @Volumen_Regla_Promocion (
    [id_regla_promocion],
    [volumen_vta_desde],
    [volumen_vta_hasta],
    [bonificacion_cf_vendedor],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [tasa_directa_ingresada]
  )
    SELECT
      rp.[id_regla_promocion_clon],
      vrp.[volumen_vta_desde],
      vrp.[volumen_vta_hasta],
      vrp.[bonificacion_cf_vendedor],
      getdate(),
      @usuario,
      NULL,
      NULL,
      NULL,
      NULL,
      0,
      vrp.[tasa_directa_ingresada]
    FROM [Configurations].[dbo].[Volumen_Regla_Promocion] vrp
      INNER JOIN @Regla_Promocion rp
        ON vrp.[id_regla_promocion] = rp.[id_regla_promocion];

  -- Insertar los nuevos volúmenes
  INSERT INTO [Configurations].[dbo].[Volumen_Regla_Promocion] (
    [id_regla_promocion],
    [volumen_vta_desde],
    [volumen_vta_hasta],
    [bonificacion_cf_vendedor],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [tasa_directa_ingresada]
  )
    SELECT
      [id_regla_promocion],
      [volumen_vta_desde],
      [volumen_vta_hasta],
      [bonificacion_cf_vendedor],
      [fecha_alta],
      [usuario_alta],
      [fecha_modificacion],
      [usuario_modificacion],
      [fecha_baja],
      [usuario_baja],
      [version],
      [tasa_directa_ingresada]
    FROM @Volumen_Regla_Promocion;

  -- Obtener las Reglas de Bonificación origen
  INSERT INTO @Regla_Bonificacion (
    [id_tasa_mp],
    [fecha_desde],
    [fecha_hasta],
    [id_banco],
    [id_cuenta],
    [dia_semana],
    [bonificacion_cf_comprador],
    [bonificacion_cf_vendedor],
    [id_promocion],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [id_regla_promocion],
    [id_rubro],
    [tasa_directa_ingresada],
    [flag_tasa_directa]
  )
    SELECT
      rb.[id_tasa_mp],
      rb.[fecha_desde],
      rb.[fecha_hasta],
      rb.[id_banco],
      isnull(@id_cuenta, rb.[id_cuenta]),
      rb.[dia_semana],
      rb.[bonificacion_cf_comprador],
      rb.[bonificacion_cf_vendedor],
      @id_promocion_clon,
      getdate(),
      @usuario,
      NULL,
      NULL,
      NULL,
      NULL,
      0,
      rp.[id_regla_promocion_clon],
      rb.[id_rubro],
      rb.[tasa_directa_ingresada],
      rb.[flag_tasa_directa]
    FROM [Configurations].[dbo].[Regla_Bonificacion] rb
      INNER JOIN @Regla_Promocion rp
        ON rb.[id_regla_promocion] = rp.[id_regla_promocion]
    WHERE rb.[id_promocion] = @id_promocion AND
          rb.[fecha_desde] >= @fecha_inicio_vigencia;

  INSERT INTO @Regla_Bonificacion (
    [id_tasa_mp],
    [fecha_desde],
    [fecha_hasta],
    [id_banco],
    [id_cuenta],
    [dia_semana],
    [bonificacion_cf_comprador],
    [bonificacion_cf_vendedor],
    [id_promocion],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [id_regla_promocion],
    [id_rubro],
    [tasa_directa_ingresada],
    [flag_tasa_directa]
  )
    SELECT
      rb.[id_tasa_mp],
      @fecha_inicio_vigencia,
      rb.[fecha_hasta],
      rb.[id_banco],
      @id_cuenta,
      rb.[dia_semana],
      rb.[bonificacion_cf_comprador],
      rb.[bonificacion_cf_vendedor],
      @id_promocion_clon,
      getdate(),
      @usuario,
      NULL,
      NULL,
      NULL,
      NULL,
      0,
      rp.[id_regla_promocion_clon],
      rb.[id_rubro],
      rb.[tasa_directa_ingresada],
      rb.[flag_tasa_directa]
    FROM [Configurations].[dbo].[Regla_Bonificacion] rb
      INNER JOIN @Regla_Promocion rp
        ON rb.[id_regla_promocion] = rp.[id_regla_promocion]
    WHERE rb.[id_promocion] = @id_promocion AND
          rb.[fecha_desde] < @fecha_inicio_vigencia AND
          rb.[fecha_hasta] >= @fecha_inicio_vigencia;

  -- Insertar las nuevas Reglas de Bonificación
  INSERT INTO [Configurations].[dbo].[Regla_Bonificacion] (
    [id_tasa_mp],
    [fecha_desde],
    [fecha_hasta],
    [id_banco],
    [id_cuenta],
    [dia_semana],
    [bonificacion_cf_comprador],
    [bonificacion_cf_vendedor],
    [id_promocion],
    [fecha_alta],
    [usuario_alta],
    [fecha_modificacion],
    [usuario_modificacion],
    [fecha_baja],
    [usuario_baja],
    [version],
    [id_regla_promocion],
    [id_rubro],
    [tasa_directa_ingresada],
    [flag_tasa_directa]
  )
    SELECT
      [id_tasa_mp],
      [fecha_desde],
      [fecha_hasta],
      [id_banco],
      [id_cuenta],
      [dia_semana],
      [bonificacion_cf_comprador],
      [bonificacion_cf_vendedor],
      [id_promocion],
      [fecha_alta],
      [usuario_alta],
      [fecha_modificacion],
      [usuario_modificacion],
      [fecha_baja],
      [usuario_baja],
      [version],
      [id_regla_promocion],
      [id_rubro],
      [tasa_directa_ingresada],
      [flag_tasa_directa]
    FROM @Regla_Bonificacion;
END;
ELSE
BEGIN;
THROW 50001, 'No se pudo obtener el id de la nueva promoción', 1;
END;

RETURN @id_promocion_clon;
END;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-------------------  SP REEMPLAZAR PROMOCION
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--Si no existe el SP entonces crearlo
IF OBJECT_ID('[dbo].[Reemplazar_Promocion]') IS NULL
  EXEC ('CREATE PROCEDURE [dbo].[Reemplazar_Promocion] AS SET NOCOUNT ON;')

