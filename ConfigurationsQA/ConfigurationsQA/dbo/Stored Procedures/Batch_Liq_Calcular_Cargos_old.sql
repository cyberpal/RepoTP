
  
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Cargos_old] (    
 @Id CHAR(36)    
 ,@CreateTimestamp DATETIME    
 ,@LocationIdentification INT    
 ,@ProductIdentification INT    
 ,@Amount DECIMAL(12, 2)    
 ,@PromotionIdentification INT    
 ,@FacilitiesPayments INT    
 ,@ButtonCode VARCHAR(20)    
 ,@Usuario VARCHAR(20)    
 ,@FeeAmount DECIMAL(12, 2) OUTPUT    
 )    
AS    
DECLARE @id_base_de_calculo INT;    
DECLARE @Cargos TABLE (    
 id INT PRIMARY KEY IDENTITY(1, 1)    
 ,id_cargo INT    
 ,monto_calculado DECIMAL(12, 2)    
 ,valor_aplicado DECIMAL(12, 2)    
 ,id_tipo_aplicacion INT    
 ,codigo_aplicacion VARCHAR(20)    
 ,codigo_tipo_cargo VARCHAR(20)    
 );    
DECLARE @i INT;    
DECLARE @cargos_count INT;    
DECLARE @id_cargo INT;    
DECLARE @codigo_tipo_cargo VARCHAR(20);    
DECLARE @valor_aplicado DECIMAL(12, 2);    
DECLARE @id_tipo_aplicacion INT;    
DECLARE @codigo_aplicacion VARCHAR(20);    
DECLARE @bonificacion_cf_vendedor DECIMAL(5, 2);    
DECLARE @tasa_directa DECIMAL(5, 2);    
DECLARE @ret_code INT;    
DECLARE @monto_total_tx DECIMAL(12, 2);    
DECLARE @codigo_tipo_promocion VARCHAR(20);    
DECLARE @id_promocion INT;    
    
BEGIN    
 SET NOCOUNT ON;    
    
 BEGIN TRY    
  IF (@ButtonCode = 'CPTO_BTN_AJ_CTGO')    
   SET @FeeAmount = 0;    
  ELSE    
  BEGIN    
   SELECT @id_base_de_calculo = tpo.id_tipo    
   FROM Configurations.dbo.Tipo tpo    
   WHERE tpo.Codigo = (    
     CASE     
      WHEN @FacilitiesPayments = 1    
       THEN 'BC_TX_PAGO'    
      ELSE 'BC_TX_CUOTAS'    
      END    
     );    
    
   INSERT INTO @Cargos (    
    id_cargo    
    ,monto_calculado    
    ,valor_aplicado    
    ,id_tipo_aplicacion    
    ,codigo_aplicacion    
    ,codigo_tipo_cargo    
    )    
   SELECT cgo.id_cargo    
    ,0    
    ,cgo.valor    
    ,tpo.id_tipo    
    ,tpo.codigo    
    ,tcg.codigo    
   FROM Configurations.dbo.Cargo cgo    
    ,Configurations.dbo.Medio_De_Pago mdp    
    ,Configurations.dbo.Cuenta cta    
    ,Configurations.dbo.Tipo tpo    
    ,Configurations.dbo.Tipo_Cargo tcg    
   WHERE cgo.id_tipo_medio_pago = mdp.id_tipo_medio_pago    
    AND mdp.id_medio_pago = @ProductIdentification    
    AND cgo.id_tipo_cuenta = cta.id_tipo_cuenta    
    AND cta.id_cuenta = @LocationIdentification    
    AND cgo.id_tipo_aplicacion = tpo.id_tipo    
    AND cgo.flag_estado = 1    
    AND cgo.id_tipo_cargo = tcg.id_tipo_cargo    
    AND cgo.id_base_de_calculo = @id_base_de_calculo    
    AND tcg.id_tipo_cargo = 1    
       
   UNION    
       
   SELECT cgo.id_cargo    
    ,0    
    ,cgo.valor    
    ,NULL    
    ,NULL    
    ,tcg.codigo    
   FROM Configurations.dbo.Cargo cgo    
    ,Configurations.dbo.Medio_De_Pago mdp    
    ,Configurations.dbo.Cuenta cta    
    ,Configurations.dbo.Tipo_Cargo tcg    
   WHERE cgo.id_tipo_medio_pago = mdp.id_tipo_medio_pago    
    AND mdp.id_medio_pago = @ProductIdentification    
    AND cgo.id_tipo_cuenta = cta.id_tipo_cuenta    
    AND cta.id_cuenta = @LocationIdentification    
    AND cgo.flag_estado = 1    
    AND cgo.id_tipo_cargo = tcg.id_tipo_cargo    
    AND cgo.id_base_de_calculo = @id_base_de_calculo    
    AND tcg.id_tipo_cargo = 2    
    
   SET @i = 1;    
    
   SELECT @cargos_count = COUNT(*)    
   FROM @Cargos;    
    
   BEGIN TRANSACTION    
    
   WHILE (@i <= @cargos_count)    
   BEGIN    
    SELECT @id_cargo = id_cargo    
     ,@codigo_tipo_cargo = codigo_tipo_cargo    
    FROM @Cargos    
    WHERE id = @i;    
    
    IF (@codigo_tipo_cargo = 'COMISION')    
    BEGIN    
     SELECT @valor_aplicado = cca.valor    
      ,@id_tipo_aplicacion = cca.id_tipo_aplicacion    
      ,@codigo_aplicacion = tpo.codigo    
     FROM Configurations.dbo.Cargo_Cuenta cca    
      ,Configurations.dbo.Tipo tpo    
     WHERE cca.id_tipo_aplicacion = tpo.id_tipo    
      AND cca.id_cargo = @id_cargo    
      AND cca.id_cuenta = @LocationIdentification    
      AND CAST(cca.fecha_inicio_vigencia AS DATE) <= CAST(@CreateTimestamp AS DATE)    
      AND (    
       cca.fecha_fin_vigencia IS NULL    
       OR CAST(cca.fecha_fin_vigencia AS DATE) >= CAST(@CreateTimestamp AS DATE)    
       );    
    
     IF (@valor_aplicado IS NOT NULL)    
      UPDATE @Cargos    
      SET valor_aplicado = @valor_aplicado    
       ,id_tipo_aplicacion = @id_tipo_aplicacion    
       ,codigo_aplicacion = @codigo_aplicacion    
      WHERE Id = @i;    
    
     SELECT @valor_aplicado = cgo.valor_aplicado    
      ,@codigo_aplicacion = cgo.codigo_aplicacion    
     FROM @Cargos cgo    
     WHERE id = @i;    
    
     UPDATE @Cargos    
     SET monto_calculado = (    
       CASE     
        WHEN @codigo_aplicacion = 'AP_PORCENTAJE'    
         THEN @Amount * (@valor_aplicado / 100)    
        ELSE 0    
        END    
       )    
     WHERE id = @i;    
    END    
    
    IF (@codigo_tipo_cargo = 'COSTO_FIN_V')    
    BEGIN --1        
     SELECT @bonificacion_cf_vendedor = rbn.bonificacion_cf_vendedor    
      ,@tasa_directa = tmp.tasa_directa    
      ,@codigo_tipo_promocion = tpo.codigo    
      ,@id_promocion = pmn.id_promocion    
     FROM Configurations.dbo.Regla_Bonificacion rbn    
      ,Configurations.dbo.Tasa_MP tmp    
      ,Configurations.dbo.Promocion pmn    
      ,Configurations.dbo.Tipo tpo    
     WHERE rbn.id_tasa_mp = tmp.id_tasa_mp    
      AND rbn.id_regla_bonificacion = @PromotionIdentification    
      AND rbn.id_promocion = pmn.id_promocion    
      AND pmn.id_tipo_aplicacion = tpo.id_tipo    
      AND tpo.id_grupo_tipo = 25;    
    
     IF (    
       @PromotionIdentification IS NULL    
       OR @bonificacion_cf_vendedor = 100    
       )    
     BEGIN --2        
      UPDATE @Cargos    
      SET monto_calculado = 0    
       ,valor_aplicado = 0    
      WHERE id = @i;    
     END --2             
     ELSE IF (@bonificacion_cf_vendedor IS NULL)    
     BEGIN --3              
      IF (@codigo_tipo_promocion = 'PROMO_VTA_MES_CTA')    
      BEGIN --4        
       SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)    
       FROM Configurations.dbo.Acumulador_Promociones aps    
       WHERE CAST(aps.fecha_transaccion AS DATE) >= DATEADD(month, DATEDIFF(month, 0, CAST(@CreateTimestamp AS DATE)), 0)    
        AND CAST(aps.fecha_transaccion AS DATE) <= CAST(@CreateTimestamp AS DATE)    
        AND aps.cuenta_transaccion = @LocationIdentification    
        AND aps.id_promocion = @id_promocion    
      END --4        
      ELSE IF (@codigo_tipo_promocion = 'PROMO_VTA_TOTAL_CTA')    
      BEGIN --5        
       SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)    
       FROM Configurations.dbo.Acumulador_Promociones aps    
       WHERE aps.cuenta_transaccion = @LocationIdentification    
        AND aps.id_promocion = @id_promocion    
      END --5        
      ELSE IF (@codigo_tipo_promocion = 'PROMO_VTA_TOTAL')    
      BEGIN --6               
       SELECT @monto_total_tx = ISNULL(SUM(aps.importe_total_tx), 0)    
       FROM Configurations.dbo.Acumulador_Promociones aps    
       WHERE aps.id_promocion = @id_promocion;    
      END --6        
    
      SELECT @bonificacion_cf_vendedor = v.bonificacion_cf_vendedor    
       ,@tasa_directa = tmp.tasa_directa    
      FROM Configurations.dbo.Regla_Bonificacion rb    
      INNER JOIN Configurations.dbo.Regla_Promocion rp ON rb.id_regla_promocion = rp.id_regla_promocion    
      INNER JOIN Configurations.dbo.Volumen_Regla_Promocion v ON rp.id_regla_promocion = v.id_regla_promocion    
      INNER JOIN Configurations.dbo.Tasa_MP tmp ON rb.id_tasa_mp = tmp.id_tasa_mp    
      WHERE rb.id_regla_bonificacion = @PromotionIdentification    
       AND v.volumen_vta_desde <= @monto_total_tx    
       AND (    
        v.volumen_vta_hasta IS NULL    
        OR v.volumen_vta_hasta >= @monto_total_tx    
        );    
    
      UPDATE @Cargos    
      SET monto_calculado = CAST(@Amount * (@tasa_directa / 100) * ((100 - ISNULL(@bonificacion_cf_vendedor,0)) / 100) AS DECIMAL(12, 2))    
       ,valor_aplicado = IIF(@bonificacion_cf_vendedor IS NULL, 0, 100 - @bonificacion_cf_vendedor)    
      WHERE id = @i;    
     END --3       
     ELSE IF (    
       @bonificacion_cf_vendedor IS NOT NULL    
       AND @bonificacion_cf_vendedor <> 100    
       AND @codigo_tipo_promocion = 'PROMO_CTAS'    
       )    
     BEGIN --7           
      UPDATE @Cargos    
      SET monto_calculado = CAST(@Amount * (@tasa_directa / 100) * ((100 - ISNULL(@bonificacion_cf_vendedor,0)) / 100) AS DECIMAL(12, 2))    
       ,valor_aplicado = IIF(@bonificacion_cf_vendedor IS NULL, 0, 100 - @bonificacion_cf_vendedor)    
      WHERE id = @i;    
     END --7      
    END --1        
    
    INSERT INTO Configurations.dbo.Cargos_Por_Transaccion (    
     id_cargo    
     ,id_transaccion    
     ,monto_calculado    
     ,valor_aplicado    
     ,id_tipo_aplicacion    
     ,fecha_alta    
     ,usuario_alta    
     ,version    
     )    
    SELECT id_cargo    
     ,@Id    
     ,monto_calculado    
     ,valor_aplicado    
     ,id_tipo_aplicacion    
     ,GETDATE()    
     ,@Usuario    
     ,0    
    FROM @Cargos    
    WHERE id = @i;    
    
    SET @i += 1;    
   END    
    
   COMMIT TRANSACTION;    
    
   SELECT @FeeAmount = ISNULL(SUM(monto_calculado), 0)    
   FROM @Cargos;    
  END    
    
  SET @ret_code = 1;    
 END TRY    
    
 BEGIN CATCH    
  ROLLBACK TRANSACTION;    
    
  SET @ret_code = 0;    
    
  PRINT ERROR_MESSAGE();    
 END CATCH    
    
 RETURN @ret_code;    
END
