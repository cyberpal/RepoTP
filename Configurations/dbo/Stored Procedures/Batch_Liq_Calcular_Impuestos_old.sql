    
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Impuestos_old] (    
 @Id CHAR(36)    
 ,@CreateTimestamp DATETIME    
 ,@LocationIdentification INT    
 ,@Usuario VARCHAR(20)    
 ,@TaxAmount DECIMAL(12, 2) OUTPUT    
 )    
AS    
--Tabla temp.para Cargos_Por_Transaccion    
DECLARE @Cargos_Por_Transaccion TABLE (    
 id_cargo_trasaccion INT PRIMARY KEY IDENTITY(1, 1)    
 ,id_cargo INT    
 ,monto_calculado DECIMAL(12, 2)    
 );    
--Tabla temp.para Impuestos_Por_Cuenta    
DECLARE @Impuestos_Por_Cta TABLE (    
 id_impuesto_por_cta INT PRIMARY KEY IDENTITY(1, 1)    
 ,numero_CUIT VARCHAR(11)    
 ,razon_social VARCHAR(50)    
 ,id_domicilio_facturacion INT    
 ,id_tipo_condicion_IVA INT    
 ,fecha_hasta_exclusion_IVA DATETIME    
 ,porcentaje_exclusion_iva DECIMAL(5, 2)    
 ,id_tipo_condicion_IIBB INT    
 ,fecha_hasta_exclusion_IIBB DATETIME    
 ,porcentaje_exclusion_IIBB DECIMAL(5, 2)    
 ,id_impuesto INT    
 ,tipo_impuesto VARCHAR(20)    
 );    
--Tabla temp.para Impuesto_Por_Transaccion         
DECLARE @Impuestos_Por_TX TABLE (    
 id_impuesto_por_transaccion INT PRIMARY KEY IDENTITY(1, 1)    
 ,id_cargo INT    
 ,id_impuesto INT    
 ,monto_calculado DECIMAL(12, 2)    
 ,alicuota DECIMAL(12, 2)    
 );    
DECLARE @i INT;    
DECLARE @j INT;    
DECLARE @impuestos_count INT;    
DECLARE @cargos_count INT;    
DECLARE @tipo_impuesto VARCHAR(20);    
DECLARE @monto_calculado_cargo DECIMAL(12, 2);    
DECLARE @monto_calculado_impuesto DECIMAL(12, 2);    
DECLARE @alicuota DECIMAL(12, 2);    
DECLARE @id_cargo INT;    
DECLARE @id_impuesto INT;    
DECLARE @id_tipo_condicion_IVA INT;    
DECLARE @ret_code INT = 1;--sin errores    
    
BEGIN    
 SET NOCOUNT ON;    
    
 BEGIN TRY    
  --Obtener cargos por transaccion    
  INSERT INTO @Cargos_Por_Transaccion (    
   id_cargo    
   ,monto_calculado    
   )    
  SELECT cpn.id_cargo    
   ,cpn.monto_calculado --valor cargo    
  FROM Configurations.dbo.Cargos_Por_Transaccion cpn    
  WHERE cpn.id_transaccion = @Id;    
    
  --Obtener impuestos de la cuenta    
  INSERT INTO @Impuestos_Por_Cta (    
   numero_CUIT    
   ,razon_social    
   ,id_domicilio_facturacion    
   ,id_tipo_condicion_IVA    
   ,fecha_hasta_exclusion_IVA    
   ,porcentaje_exclusion_iva    
   ,id_tipo_condicion_IIBB    
   ,fecha_hasta_exclusion_IIBB    
   ,porcentaje_exclusion_IIBB    
   ,id_impuesto    
   ,tipo_impuesto    
   )    
  --Obtener tipos de impuesto por cuenta    
  SELECT sfc.numero_CUIT AS numeroCUIT    
   ,sfc.razon_social AS razonSocial    
   ,sfc.id_domicilio_facturacion AS idDomicilioFacturacion    
   ,sfc.id_tipo_condicion_IVA AS idTipoCondicionIVA    
   ,sfc.fecha_hasta_exclusion_IVA AS fechaHastaExclusionIVA    
   ,sfc.porcentaje_exclusion_iva AS porcentajeExclusionIVA    
   ,sfc.id_tipo_condicion_IIBB AS idTipoCondicionIIBB    
   ,sfc.fecha_hasta_exclusion_IIBB AS fechaHastaExclusionIIBB    
   ,sfc.porcentaje_exclusion_IIBB AS porcentajeExclusionIIBB    
   ,ipo.id_impuesto AS idImpuesto    
   ,ipo.codigo AS tipoImpuesto    
  FROM Configurations.dbo.Impuesto AS ipo    
   ,Configurations.dbo.Situacion_Fiscal_Cuenta AS sfc    
  INNER JOIN Configurations.dbo.Domicilio_Cuenta AS dca ON sfc.id_cuenta = dca.id_cuenta    
   AND sfc.id_domicilio_facturacion = dca.id_domicilio    
  WHERE sfc.id_cuenta = @LocationIdentification    
   AND sfc.flag_vigente = 1    
   AND (    
    ipo.id_provincia = dca.id_provincia    
    OR ipo.flag_todas_provincias = 1    
    );    
    
  BEGIN TRANSACTION    
    
  SET @impuestos_count = (    
    SELECT COUNT(*)    
    FROM @Impuestos_Por_Cta    
    );    
  SET @cargos_count = (    
    SELECT COUNT(*)    
    FROM @Cargos_Por_Transaccion    
    );    
  SET @i = 1;    
    
  --Iterar cada cargo    
  WHILE (@i <= @cargos_count)    
  BEGIN --1    
   --datos del cargo actual    
   SELECT @id_cargo = cpn.id_cargo    
    ,@monto_calculado_cargo = cpn.monto_calculado    
   FROM @Cargos_Por_Transaccion cpn    
   WHERE cpn.id_cargo_trasaccion = @i    
    
   SET @j = 1;    
    
   --Iterar cada impuesto    
   WHILE (@j <= @impuestos_count)    
   BEGIN --2    
    SELECT @id_impuesto = ipa.id_impuesto    
     ,@tipo_impuesto = ipa.tipo_impuesto    
     ,@id_tipo_condicion_IVA = ipa.id_tipo_condicion_IVA    
    FROM @Impuestos_Por_Cta ipa    
    WHERE id_impuesto_por_cta = @j;    
    
    IF (@tipo_impuesto = 'IVA')    
     --SP RF8    
     EXEC @ret_code = Configurations.dbo.Batch_Liq_Calcular_Impuestos_IVA_Cargos_old @id_cargo    
      ,@CreateTimestamp    
   ,@id_tipo_condicion_IVA    
      ,@monto_calculado_cargo    
      ,@monto_calculado_impuesto OUTPUT    
      ,@alicuota OUTPUT;    
    
    IF (@ret_code = 0) THROW 51000    
     ,'Error en SP - Batch_Liq_Calcular_Impuestos_IVA_Cargos'    
     ,1;    
     /*    
   ELSE IF(@tipo_impuesto = 'AGIP')    
   --SP RF9    
   ELSE IF(@tipo_impuesto = 'ARBA')    
   --SP RF10    
   ELSE IF(@tipo_impuesto = 'IVA_RG_2126')    
   --SP RF11    
   ELSE IF(@tipo_impuesto = 'IVA_RG_2408')    
   --SP RF12    
   */    
     --Insertar en tabla temp. @Impuestos_Por_TX    
     INSERT INTO @Impuestos_Por_TX (    
      id_cargo    
      ,id_impuesto    
      ,monto_calculado    
      ,alicuota    
      )    
     VALUES (    
      @id_cargo    
      ,@id_impuesto    
      ,@monto_calculado_impuesto    
      ,@alicuota    
      )    
    
    SET @j += 1;    
   END;--2    
    
   SET @i += 1;    
  END;--1    
    
  --Insertar en tabla Impuesto_Por_Transaccion    
  INSERT INTO Configurations.dbo.Impuesto_Por_Transaccion (    
   id_transaccion    
   ,id_cargo    
   ,id_impuesto    
   ,monto_calculado    
   ,alicuota    
   ,fecha_alta    
   ,usuario_alta    
   ,version    
   )    
  SELECT @Id    
   ,ipx.id_cargo    
   ,ipx.id_impuesto    
   ,ipx.monto_calculado    
   ,ipx.alicuota    
   ,GETDATE()    
   ,@Usuario    
   ,0    
  FROM @Impuestos_Por_TX ipx;    
    
  COMMIT TRANSACTION;    
    
  SELECT @TaxAmount = ISNULL(SUM(monto_calculado), 0)    
  FROM @Impuestos_Por_TX;    
    
  SET @ret_code = 1;    
 END TRY    
    
 BEGIN CATCH    
  ROLLBACK TRANSACTION;    
    
  SET @ret_code = 0;--en caso de excepcion fuera del THROW    
  SET @TaxAmount = 0;    
    
  PRINT ERROR_MESSAGE();  
    
 END CATCH    
    
 RETURN @ret_code;    
END