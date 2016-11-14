
CREATE PROCEDURE [dbo].[Borrar_Promociones] (
  @id_promo     INT,
  @id_cuenta    INT,
  @fecha_inicio DATE,
  @fecha_fin    DATE,
  @usuario      VARCHAR(20)
)
AS
DECLARE @fecha_fin_vigente DATE = DATEADD(DD, -1, @fecha_inicio);
DECLARE @PromocionTerminar AS TABLE(
  id_promocion INT NOT NULL
)
DECLARE @PromocionBorrar AS TABLE(
  id_promocion INT NOT NULL
)
DECLARE @Promo_cant_cuotas_desde INT
DECLARE @Promo_cant_cuotas_hasta INT
DECLARE @Promo_id_medio_pago INT
DECLARE @Promo_id_banco INT
DECLARE @Promo_id_rubro INT
DECLARE @Promo_flag_aplica_lunes BIT
DECLARE @Promo_flag_aplica_martes BIT
DECLARE @Promo_flag_aplica_miercoles BIT
DECLARE @Promo_flag_aplica_jueves BIT
DECLARE @Promo_flag_aplica_viernes BIT
DECLARE @Promo_flag_aplica_sabado BIT
DECLARE @Promo_flag_aplica_domingo BIT
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE)


BEGIN
  SELECT
    @Promo_cant_cuotas_desde = [cant_cuotas_desde],
    @Promo_cant_cuotas_hasta = [cant_cuotas_hasta],
    @Promo_id_medio_pago = [id_medio_pago],
    @Promo_id_banco = [id_banco],
    @Promo_flag_aplica_lunes = [flag_aplica_lunes],
    @Promo_flag_aplica_martes = [flag_aplica_martes],
    @Promo_flag_aplica_miercoles = [flag_aplica_miercoles],
    @Promo_flag_aplica_jueves = [flag_aplica_jueves],
    @Promo_flag_aplica_viernes = [flag_aplica_viernes],
    @Promo_flag_aplica_sabado = [flag_aplica_sabado],
    @Promo_flag_aplica_domingo = [flag_aplica_domingo],
    @Promo_id_rubro = id_rubro
  FROM [Configurations].[dbo].[Promocion]
  WHERE [id_promocion] = @id_promo

  -- Promos vigentes que colisionan
  INSERT INTO @PromocionTerminar SELECT [id_promocion]
                                 FROM [Configurations].[dbo].[Promocion]
                                 WHERE
                                   [id_cuenta] = @id_cuenta AND
                                   (([flag_aplica_lunes] = 1 AND @Promo_flag_aplica_lunes = 1) OR
                                    ([flag_aplica_martes] = 1 AND @Promo_flag_aplica_martes = 1) OR
                                    ([flag_aplica_miercoles] = 1 AND @Promo_flag_aplica_miercoles = 1) OR
                                    ([flag_aplica_jueves] = 1 AND @Promo_flag_aplica_jueves = 1) OR
                                    ([flag_aplica_viernes] = 1 AND @Promo_flag_aplica_viernes = 1) OR
                                    ([flag_aplica_sabado] = 1 AND @Promo_flag_aplica_sabado = 1) OR
                                    ([flag_aplica_domingo] = 1 AND @Promo_flag_aplica_domingo = 1)
                                   ) AND
                                   ((@Promo_id_rubro IS NULL AND [id_rubro] IS NULL) OR (@Promo_id_rubro = [id_rubro])) AND
                                   (@Promo_id_banco IS NULL OR ([id_banco] IS NULL OR [id_banco] = @Promo_id_banco)) AND
                                   (@Promo_id_medio_pago IS NULL OR ([id_medio_pago] IS NULL OR [id_medio_pago] = @Promo_id_medio_pago)) AND
                                   [cant_cuotas_desde] <= @Promo_cant_cuotas_hasta AND
                                   [cant_cuotas_hasta] >= @Promo_cant_cuotas_desde AND
                                   [fecha_inicio_vigencia] <= @Hoy AND
                                   ([fecha_fin_vigencia] IS NULL OR [fecha_fin_vigencia] >= @fecha_inicio) AND
                                   [fecha_baja] IS NULL;

  -- Promos futuras que colisionan
  INSERT INTO @PromocionBorrar SELECT [id_promocion]
                               FROM [Configurations].[dbo].[Promocion]
                               WHERE
                                 [id_cuenta] = @id_cuenta AND
                                 (([flag_aplica_lunes] = 1 AND @Promo_flag_aplica_lunes = 1) OR
                                  ([flag_aplica_martes] = 1 AND @Promo_flag_aplica_martes = 1) OR
                                  ([flag_aplica_miercoles] = 1 AND @Promo_flag_aplica_miercoles = 1) OR
                                  ([flag_aplica_jueves] = 1 AND @Promo_flag_aplica_jueves = 1) OR
                                  ([flag_aplica_viernes] = 1 AND @Promo_flag_aplica_viernes = 1) OR
                                  ([flag_aplica_sabado] = 1 AND @Promo_flag_aplica_sabado = 1) OR
                                  ([flag_aplica_domingo] = 1 AND @Promo_flag_aplica_domingo = 1)
                                 ) AND
                                 ((@Promo_id_rubro IS NULL AND [id_rubro] IS NULL) OR (@Promo_id_rubro = [id_rubro])) AND
                                 (@Promo_id_banco IS NULL OR ([id_banco] IS NULL OR [id_banco] = @Promo_id_banco)) AND
                                 (@Promo_id_medio_pago IS NULL OR ([id_medio_pago] IS NULL OR [id_medio_pago] = @Promo_id_medio_pago)) AND
                                 [cant_cuotas_desde] <= @Promo_cant_cuotas_hasta AND
                                 [cant_cuotas_hasta] >= @Promo_cant_cuotas_desde AND
                                 [fecha_inicio_vigencia] > @Hoy AND
                                 (@fecha_fin IS NULL OR [fecha_inicio_vigencia] <= @fecha_fin) AND
                                 ([fecha_fin_vigencia] IS NULL OR [fecha_fin_vigencia] >= @fecha_inicio) AND
                                 [fecha_baja] IS NULL;

  -- Termina las promos vigentes que colisionan
  UPDATE [Configurations].[dbo].[Promocion]
  SET [fecha_fin_vigencia] = @fecha_fin_vigente,
    [fecha_modificacion]   = @Hoy,
    [usuario_modificacion] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionTerminar)

  UPDATE [Configurations].[dbo].[Regla_Bonificacion]
  SET [fecha_hasta]        = @fecha_fin_vigente,
    [fecha_modificacion]   = @Hoy,
    [usuario_modificacion] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionTerminar) AND
    [fecha_desde] <= @fecha_fin_vigente AND
    ([fecha_hasta] IS NULL OR [fecha_hasta] > @fecha_fin_vigente)


  UPDATE [Configurations].[dbo].[Regla_Bonificacion]
  SET [fecha_baja] = @Hoy,
    [usuario_baja] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionTerminar) AND
    [fecha_desde] > @fecha_fin_vigente

  -- Da de baja las promos futuras que colisionan

  UPDATE [Configurations].[dbo].[Promocion]
  SET [fecha_baja] = @Hoy,
    [usuario_baja] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionBorrar)

  UPDATE [Configurations].[dbo].[Regla_Promocion]
  SET [fecha_baja] = @Hoy,
    [usuario_baja] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionBorrar)

  UPDATE v
  SET v.[fecha_baja] = @Hoy,
    v.[usuario_baja] = @usuario
  FROM [Configurations].[dbo].[volumen_regla_promocion] v
    INNER JOIN [Configurations].[dbo].[Regla_Promocion] r ON r.id_regla_promocion = v.id_regla_promocion
  WHERE
    r.[id_promocion] IN (SELECT id_promocion
                         FROM @PromocionBorrar)

  UPDATE [Configurations].[dbo].[Regla_Bonificacion]
  SET [fecha_baja] = @Hoy,
    [usuario_baja] = @usuario
  WHERE
    [id_promocion] IN (SELECT id_promocion
                       FROM @PromocionBorrar)
END;

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-------------------  SP CLONAR PROMOCION
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

--Si no existe el SP entonces crearlo
IF OBJECT_ID('[dbo].[Clonar_Promocion]') IS NULL
  EXEC ('CREATE PROCEDURE [dbo].[Clonar_Promocion] AS SET NOCOUNT ON;')

