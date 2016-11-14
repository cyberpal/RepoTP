CREATE PROCEDURE [dbo].[Obtener_cbu_pendientes]      
AS      
SET NOCOUNT ON;      
      
DECLARE @dias INT;      
DECLARE @i INT = 1;      
DECLARE @count INT;      
DECLARE @cuit VARCHAR(11);      
DECLARE @entidad_solicitante VARCHAR(3);      
DECLARE @id_cuenta INT;      
DECLARE @fecha_inicio_pendiente DATE;      
DECLARE @fecha_vencimiento DATE;      
DECLARE @es_cuit_condicionado BIT;      
DECLARE @motivo VARCHAR(12);      
DECLARE @accion VARCHAR(10);      
DECLARE @entidad_registrada VARCHAR(3);      
DECLARE @msg VARCHAR(max);      
      
BEGIN      
 BEGIN TRY      
  -- Obtener plazo de días de espera para confirmar el nuevo CBU.      
  SELECT @dias = par.valor      
  FROM Configurations.dbo.Parametro par      
  WHERE codigo = 'dias_conf_CBU';      
      
  -- Limpiar tablas temporales      
  TRUNCATE TABLE Configurations.dbo.CBU_Pendientes_Tmp;      
      
  TRUNCATE TABLE Configurations.dbo.CUIT_A_Informar_Tmp;      
      
  BEGIN TRANSACTION;      
      
  -- Obtener CBUs pendientes de confirmar      
  INSERT INTO Configurations.dbo.CBU_Pendientes_Tmp (      
   cuit,      
   entidad_solicitante,      
   id_cuenta,      
   fecha_inicio_pendiente,      
   fecha_vencimiento,      
   entidad_registrada,      
   razon_social,      
   cbu,      
   id_banco,      
   tipo_acreditacion,      
   motivo,      
   accion      
   )      
  SELECT icb.cuit,      
   isnull(bco.codigo, bco2.codigo),      
   icb.id_cuenta,      
   cast(icb.fecha_inicio_pendiente AS DATE),      
   cast((icb.fecha_inicio_pendiente + @dias) AS DATE),      
   NULL,
  (
  CASE
	WHEN cta.id_tipo_cuenta = 29       
	   THEN ltrim(rtrim(cta.denominacion1))       
	ELSE ltrim(left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)), 50))
	END
  ),
   icb.cbu_cuenta_banco,      
   isnull(bco.id_banco, bco2.id_banco),      
   tpo.codigo,      
   NULL,      
   (      
    CASE       
     WHEN est.codigo = 'CBU_FORZADO_EXC'      
      THEN 'CONFIRMAR'      
     ELSE NULL      
     END      
    )      
  FROM Configurations.dbo.Informacion_Bancaria_Cuenta icb      
  INNER JOIN Configurations.dbo.Cuenta cta      
   ON icb.id_cuenta = cta.id_cuenta      
  INNER JOIN Configurations.dbo.Tipo tpo      
   ON icb.id_tipo_cashout_solicitado = tpo.id_tipo      
    AND tpo.id_grupo_tipo = 18      
  INNER JOIN Configurations.dbo.Estado est      
   ON est.id_estado = icb.id_estado_informacion_bancaria      
  LEFT JOIN Configurations.dbo.Banco bco      
   ON ICB.fiid_banco = bco.codigo      
  LEFT JOIN Configurations.dbo.Banco bco2      
   ON ICB.fiidOrigenLink = bco2.codigo      
  WHERE icb.flag_vigente = 0      
   AND icb.fecha_baja IS NULL      
   AND est.codigo IN (      
    'CBU_PEND-HABILITAR',      
    'CBU_FORZADO_EXC'      
    )      
   AND est.id_grupo_estado = 11;      
      
  COMMIT TRANSACTION;      
      
  -- Para cada CBU pendiente en la tabla temporal      
  SELECT @count = count(*)      
  FROM Configurations.dbo.CBU_Pendientes_Tmp;      
      
  WHILE @i <= @count      
  BEGIN      
  set @entidad_registrada = null;  
   -- Obtener datos del CBU      
   SELECT @cuit = cpt.cuit,      
    @entidad_solicitante = cpt.entidad_solicitante,      
    @id_cuenta = cpt.id_cuenta,      
    @fecha_inicio_pendiente = cpt.fecha_inicio_pendiente,      
    @fecha_vencimiento = cpt.fecha_vencimiento,      
    @accion = cpt.accion      
   FROM Configurations.dbo.CBU_Pendientes_Tmp cpt      
   WHERE cpt.Id = @i;      
      
   -- Obtener entidad en la que el CUIT está registrado (si existe)      
   SELECT @entidad_registrada = isnull(bco.codigo, bco2.codigo)      
   FROM Configurations.dbo.Informacion_Bancaria_Cuenta icb      
   LEFT JOIN Configurations.dbo.Banco bco      
    ON ICB.fiid_banco = bco.codigo      
   LEFT JOIN Configurations.dbo.Banco bco2      
    ON ICB.fiidOrigenLink = bco2.codigo      
   WHERE icb.cuit = @cuit    
    AND icb.flag_vigente = 1;      
      
   -- Determinar el motivo      
   IF (@entidad_registrada IS NULL)      
    SET @motivo = 'ALTA';      
   ELSE      
    SET @motivo = 'MODIFICACION';      
      
   -- Si no se determinó acción a tomar      
   IF (@accion IS NULL)      
   BEGIN      
    -- Determinar si el CUIT está condicionado      
    SET @es_cuit_condicionado = (      
      SELECT CASE       
        WHEN c.cantidad_bancos > 0      
         THEN 1      
        ELSE 0      
        END      
      FROM (      
       SELECT count(*) AS cantidad_bancos      
       FROM Configurations.dbo.CUIT_Condicionado cco      
       INNER JOIN Configurations.dbo.Banco bco      
        ON cco.id_banco = bco.id_banco      
       WHERE cco.numero_CUIT = @cuit      
        AND cast(getdate() AS DATE) BETWEEN cco.fecha_inicio_vigencia      
         AND cco.fecha_fin_vigencia      
        AND cco.fecha_alta BETWEEN @fecha_inicio_pendiente      
         AND @fecha_vencimiento      
        AND cco.fecha_baja IS NULL      
        AND (      
         (      
          bco.codigo <> @entidad_solicitante      
          AND @motivo = 'ALTA'      
          )      
         OR (      
          bco.codigo = @entidad_registrada      
          AND @motivo = 'MODIFICACION'      
          )      
         )      
       ) c      
      );      
      
    -- Rechazar si no se venció el plazo de espera y el CUIT está condicionado      
    IF (      
      --cast(getdate() AS DATE) <= @fecha_vencimiento      
      --AND      
       @es_cuit_condicionado = 1      
      )      
     SET @accion = 'RECHAZAR';      
      
    -- Confirmar si se venció el plazo de espera y el CUIT no está condicionado      
    IF (      
      cast(getdate() AS DATE) > @fecha_vencimiento      
      AND @es_cuit_condicionado = 0      
      )      
     SET @accion = 'CONFIRMAR';      
      
    -- Informar si no se venció el plazo de espera y el CUIT no está condicionado      
    IF (      
      cast(getdate() AS DATE) <= @fecha_vencimiento      
      AND @es_cuit_condicionado = 0      
      )      
     SET @accion = 'INFORMAR';      
   END;      
      
   -- Si hay que informar      
   IF (@accion = 'INFORMAR')      
   BEGIN      
    -- Obtener los Bancos a los que hay que informar para un Alta      
    IF (@entidad_registrada IS NULL)      
    BEGIN      
     BEGIN TRANSACTION;      
      
     INSERT INTO Configurations.dbo.CUIT_A_Informar_Tmp      
     SELECT cpa.cuit,      
      @id_cuenta,      
      bco.codigo      
     FROM Configurations.dbo.Comercio_Prisma cpa      
     INNER JOIN Configurations.dbo.Banco bco      
      ON cpa.id_banco = bco.id_banco      
     WHERE cpa.cuit = @cuit      
      AND cpa.fecha_baja IS NULL      
      AND bco.codigo <> @entidad_solicitante;      
      
     COMMIT TRANSACTION;      
    END;      
      
    -- Obtener Banco al que hay que informar la Modificación      
    IF (@entidad_registrada IS NOT NULL)      
    BEGIN      
     BEGIN TRANSACTION;      
      
     INSERT INTO Configurations.dbo.CUIT_A_Informar_Tmp      
     SELECT cpa.cuit,      
      @id_cuenta,      
      bco.codigo      
     FROM Configurations.dbo.Comercio_Prisma cpa      
     INNER JOIN Configurations.dbo.Banco bco      
      ON cpa.id_banco = bco.id_banco      
     WHERE cpa.cuit = @cuit      
      AND cpa.fecha_baja IS NULL      
      AND bco.codigo = @entidad_registrada;      
      
     COMMIT TRANSACTION;      
    END;      
   END;      
      
   -- Actualizar temporal de CBUs pendientes      
   BEGIN TRANSACTION;      
      
   UPDATE Configurations.dbo.CBU_Pendientes_Tmp      
   SET entidad_registrada = @entidad_registrada,      
    motivo = @motivo,      
    accion = @accion      
   WHERE id = @i;      
      
   COMMIT TRANSACTION;      
      
   SET @i = @i + 1;      
  END;      
 END TRY      
      
 BEGIN CATCH      
  IF @@TRANCOUNT > 0      
   ROLLBACK TRANSACTION;      
      
  SELECT @msg = ERROR_MESSAGE();      
      
  THROW 51000,      
   @Msg,      
   1;      
 END CATCH;      
      
 RETURN 1;      
END;
