

CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Impuestos] (
-- Se agrega nuevo paràmetro
 @Id CHAR(36)
 ,@CreateTimestamp DATETIME
 ,@LocationIdentification INT
 ,@BuyerAccountIdentification INT
 ,@Usuario VARCHAR(20)
 ,@Amount DECIMAL(12, 2)
 ,@idTipoMovimientoDebito INT
 ,@idTipoOrigenMovimiento INT
 ,@OperationName varchar(128)
 ,@idLogProceso INT
 ,@ProviderTransactionID            VARCHAR (64)    
 ,@SaleConcept                      VARCHAR (255)   
 ,@CredentialEmailAddress           VARCHAR (64)    
 ,@FeeAmount                        DECIMAL (12, 2) 
 ,@TaxAmount DECIMAL(12, 2) OUTPUT
 ,@id_motivo_ajuste_negativo INT OUTPUT
 ,@id_motivo_ajuste_positivo INT OUTPUT
 ,@nro_iibb VARCHAR(20) output
 ,@cod_prov_comprador VARCHAR(20) output
 ,@cod_prov_vendedor VARCHAR(20) output
 ,@id_impuesto int output
 ,@id_tipo_condicion_IIBB int output
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
 ,id_tipo_condicion_IVA INT
 ,id_tipo_condicion_IIBB INT
 ,id_impuesto INT
 ,id_motivo_ajuste_negativo INT
 ,id_motivo_ajuste_positivo INT
 ,tipo_impuesto VARCHAR(20)
 ,nro_iibb VARCHAR(20)
 ,cod_ap_iibb VARCHAR(20)
 ,porcentaje_exclusion_IIBB DECIMAL(5, 2)
 ,fecha_hasta_exclusion_IIBB DATETIME
 );
--Tabla temp.para Impuesto_Por_Transaccion           
DECLARE @Impuestos_Por_TX TABLE (
 id_impuesto_por_transaccion INT PRIMARY KEY IDENTITY(1, 1)
 ,id_cargo INT
 ,id_impuesto INT
 ,monto_aplicado DECIMAL(12, 2) -- monto_calculado DECIMAL(12, 2)
 ,monto_calculado  DECIMAL(12, 2) -- _devolucion DECIMAL(12, 2)
 ,alicuota DECIMAL(12, 2)
 ,aplica_acumulacion BIT
 ,ProviderTransactionID            VARCHAR (64)    NULL
 ,CreateTimestamp                  DATETIME        NULL
 ,SaleConcept                      VARCHAR (255)   NULL
 ,CredentialEmailAddress           VARCHAR (64)    NULL
 ,Amount                           DECIMAL (12, 2) NULL
 ,FeeAmount                        DECIMAL (12, 2) NULL
 ,id_impuesto_tipo INT
 ,id_acumulador_impuesto int
 );
DECLARE @i INT;
DECLARE @j INT;
DECLARE @k INT;
DECLARE @impuestos_count INT;
DECLARE @cargos_count INT;
DECLARE @tipo_impuesto VARCHAR(20);
DECLARE @monto_calculado_cargo DECIMAL(12, 2);
DECLARE @monto_total_cargos DECIMAL(12, 2);
DECLARE @monto_aplicado_impuesto DECIMAL(12, 2);
DECLARE @monto_calculado DECIMAL(12, 2);
DECLARE @porcentaje_exclusion_IIBB DECIMAL(5, 2);
DECLARE @importe_retencion DECIMAL(12, 2);
DECLARE @alicuota DECIMAL(12, 2);
DECLARE @id_cargo INT;
--DECLARE @id_impuesto INT;
--DECLARE @id_tipo_condicion_IIBB INT;
DECLARE @id_tipo_condicion_IVA INT;
--DECLARE @id_motivo_ajuste_negativo INT;
--DECLARE @id_motivo_ajuste_positivo INT;
DECLARE @ret_code INT = 1;--sin errores
DECLARE @aplica_acumulacion BIT;
DECLARE @aplica_impuesto BIT;
DECLARE @estado_tope INT;-- -1 (inhabilitado/ya se aplico la 1ra vez) - 0(no superado) - 1 (superado)
DECLARE @id_prov_comprador INT;
DECLARE @id_prov_vendedor INT;
DECLARE @cantidad_tx INT;
DECLARE @id_impuesto_tipo INT;
--DECLARE @cod_prov_comprador VARCHAR(20);
--DECLARE @cod_prov_vendedor VARCHAR(20);
DECLARE @cod_ap_iibb VARCHAR(20);
DECLARE @cod_tipo_cond_iibb_vendedor VARCHAR(20);
--DECLARE @nro_iibb VARCHAR(20);
DECLARE @fecha_hasta_exclusion_IIBB DATETIME;
DECLARE @fecha_desde DATETIME = NULL;
DECLARE @fecha_hasta DATETIME = NULL;
DECLARE @Monto_a_Ajustar DECIMAL(12,2) = 0;
declare @id_Acumulador_Impuesto int

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY

   --test
  --PRINT 'INICIO - [Batch_Liq_Calcular_Impuestos] - ID = ' + CAST(@Id AS VARCHAR(36));

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
   id_tipo_condicion_IVA
   ,id_impuesto
   ,tipo_impuesto
   )
  --Obtener tipos de impuesto por cuenta      
  SELECT sfc.id_tipo_condicion_IVA AS idTipoCondicionIVA
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
    )
   AND ipo.codigo = 'IVA';

     EXEC @ret_code = Configurations.dbo.Batch_Liq_Obtener_Provincia_Comprador @Id
   ,@id_prov_comprador OUTPUT;

  --test
  --PRINT 'Batch_Liq_Obtener_Provincia_Comprador - @id_prov_comprador = ' + ISNULL(CAST(@id_prov_comprador AS VARCHAR(20)), 'NULL');
 -- print ' '

  IF (@ret_code = 0)
  BEGIN
   THROW 51000
    ,'Error en SP - Batch_Liq_Obtener_Provincia_Comprador'
    ,1;
  END;

  SELECT @cod_prov_comprador = pva.codigo
  FROM Configurations.dbo.Provincia pva
  WHERE pva.id_provincia = @id_prov_comprador;

  --Obtener cod.prov.del vendedor/nro.iibb
  SELECT @cod_prov_vendedor = pva.codigo
   ,@nro_iibb = sfc.nro_inscripcion_IIBB
   ,@id_tipo_condicion_IIBB = sfc.id_tipo_condicion_IIBB
   ,@cod_tipo_cond_iibb_vendedor = tpo.codigo
   ,@porcentaje_exclusion_IIBB = sfc.porcentaje_exclusion_IIBB
   ,@fecha_hasta_exclusion_IIBB = sfc.fecha_hasta_exclusion_IIBB
  FROM Configurations.dbo.Domicilio_Cuenta AS dca
  INNER JOIN Configurations.dbo.Situacion_Fiscal_Cuenta AS sfc ON dca.id_cuenta = sfc.id_cuenta
   AND sfc.id_domicilio_facturacion = dca.id_domicilio
  INNER JOIN Configurations.dbo.Provincia AS pva ON dca.id_provincia = pva.id_provincia
   AND sfc.id_cuenta = @LocationIdentification
   AND sfc.flag_vigente = 1
  INNER JOIN Configurations.dbo.Tipo AS tpo ON sfc.id_tipo_condicion_IIBB = tpo.id_tipo;


  --Obtener impuestos IIBB
 
 -- Inserta nuevamente ahora para lo que NO ES IVA
  INSERT INTO @Impuestos_Por_Cta (
   id_tipo_condicion_IIBB
   ,id_impuesto
   ,id_motivo_ajuste_negativo
   ,id_motivo_ajuste_positivo
   ,tipo_impuesto
   ,nro_iibb
   ,cod_ap_iibb
   ,porcentaje_exclusion_IIBB
   ,fecha_hasta_exclusion_IIBB
   )
  SELECT @id_tipo_condicion_IIBB AS tipoCondIIBB
   ,ipo.id_impuesto AS idImpuesto
   ,ipo.id_motivo_ajuste_negativo AS motivoAjusteNegativo
   ,ipo.id_motivo_ajuste_positivo as motivoAjustePositivo
   ,ipo.codigo AS tipoImpuesto
   ,@nro_iibb AS nroIIBB
   ,tpo.codigo AS codAplicIIBB
   ,@porcentaje_exclusion_IIBB AS porcExclIIBB
   ,@fecha_hasta_exclusion_IIBB AS fechaHastaExclIIBB
  FROM Configurations.dbo.Impuesto AS ipo
  INNER JOIN Configurations.dbo.Tipo AS tpo ON ipo.id_tipo_aplicacion = tpo.id_tipo
  INNER JOIN Configurations.dbo.Provincia pva ON ipo.id_provincia = pva.id_provincia
   AND (
    (
     tpo.codigo = 'APLICA_VENDEDOR'
     AND pva.codigo = @cod_prov_vendedor
     )
    OR (
     tpo.codigo = 'APLICA_COMPRADOR'
     AND pva.codigo = @cod_prov_comprador
     )
    )
   AND ipo.codigo <> 'IVA'

	 -- PRINT '[Batch_Liq_Calcular_Impuestos]';
	 -- PRINT '@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL');

  --END;
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
     ,@id_tipo_condicion_IIBB = ipa.id_tipo_condicion_IIBB
     ,@nro_iibb = ipa.nro_iibb
     ,@cod_ap_iibb = ipa.cod_ap_iibb
     ,@id_motivo_ajuste_negativo = ipa.id_motivo_ajuste_negativo
	 ,@id_motivo_ajuste_positivo = ipa.id_motivo_ajuste_positivo
    FROM @Impuestos_Por_Cta ipa
    WHERE id_impuesto_por_cta = @j;

    IF (@tipo_impuesto = 'IVA')
    BEGIN --3
     --SP RF8      
     EXEC @ret_code = Configurations.dbo.Batch_Liq_Calcular_Impuestos_IVA_Cargos @id_cargo
      ,@CreateTimestamp
      ,@id_tipo_condicion_IVA
      ,@monto_calculado_cargo
      ,@monto_aplicado_impuesto OUTPUT
      ,@alicuota OUTPUT;

     IF (@ret_code = 0)
     BEGIN
      THROW 51000
       ,'Error en SP - Batch_Liq_Calcular_Impuestos_IVA_Cargos'
       ,1;
     END
     ELSE
     BEGIN
      --Insertar en tabla temp. @Impuestos_Por_TX      
      INSERT INTO @Impuestos_Por_TX (
       id_cargo
       ,id_impuesto
       ,monto_aplicado -- monto_calculado
       ,alicuota
       ,aplica_acumulacion
	   ,monto_calculado
	   ,ProviderTransactionID 
	   ,CreateTimestamp       
	   ,SaleConcept           
	   ,CredentialEmailAddress
	   ,Amount                
	   ,FeeAmount             
	   ,id_impuesto_tipo
       )
      VALUES (
       @id_cargo
       ,@id_impuesto
       ,@monto_aplicado_impuesto
       ,@alicuota
       ,@aplica_acumulacion
	   ,@monto_aplicado_impuesto
	   ,@ProviderTransactionID 
	   ,@CreateTimestamp       
	   ,@SaleConcept           
	   ,@CredentialEmailAddress
	   ,@Amount                
	   ,@FeeAmount             
	   ,@id_impuesto_tipo
       )
     END;
    END;--3
	
	/*  
	  PRINT '[Batch_Liq_Calcular_Impuestos]';
	  PRINT '@id_cargo = ' + ISNULL(CAST(@id_cargo AS VARCHAR(20)), 'NULL');
	  PRINT '@id_impuesto = ' + ISNULL(CAST(@id_impuesto AS VARCHAR(20)), 'NULL');
      PRINT '@Alicuota = ' + ISNULL(CAST(@Alicuota AS VARCHAR(20)), 'NULL');
	  PRINT ' ';
	  */

    SET @j += 1;
   END;--2      

   SET @i += 1;
  END;--1  

  --Impuestos IIBB (solo aplica por transaccion)
  --Iterar cada impuesto 
  SET @k = 1;

  WHILE (@k <= @impuestos_count)
  BEGIN --4     
   SELECT @id_impuesto = ipa.id_impuesto
    ,@tipo_impuesto = ipa.tipo_impuesto
    --,@id_tipo_condicion_IVA = ipa.id_tipo_condicion_IVA
    ,@id_tipo_condicion_IIBB = ipa.id_tipo_condicion_IIBB
    ,@nro_iibb = ipa.nro_iibb
    ,@cod_ap_iibb = ipa.cod_ap_iibb
    ,@id_motivo_ajuste_negativo = ipa.id_motivo_ajuste_negativo
	,@id_motivo_ajuste_positivo = ipa.id_motivo_ajuste_positivo
   FROM @Impuestos_Por_Cta ipa
   WHERE id_impuesto_por_cta = @k;

  
   --test
   /*
   PRINT '**Impuestos IIBB (solo aplica por transaccion)**';
   PRINT '@tipo_impuesto = ' + ISNULL(CAST(@tipo_impuesto AS VARCHAR(20)), 'NULL');
   PRINT '@id_motivo_ajuste_negativo = ' + ISNULL(CAST(@id_motivo_ajuste_negativo AS VARCHAR(20)), 'NULL');
   PRINT '@id_motivo_ajuste_positivo = ' + ISNULL(CAST(@id_motivo_ajuste_positivo AS VARCHAR(20)), 'NULL');
   PRINT '@cod_ap_iibb = ' + ISNULL(CAST(@cod_ap_iibb AS VARCHAR(20)), 'NULL');
   PRINT '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
   PRINT ' ';
   */

   SET @aplica_impuesto = IIF(@cod_ap_iibb = 'APLICA_VENDEDOR'
     OR (
      @cod_ap_iibb = 'APLICA_COMPRADOR'
      AND @cod_prov_comprador IS NOT NULL
      ), 1, 0);

   --Procesar solo IIBB
   IF @aplica_impuesto = 1

   BEGIN --5

   
    --test
   
	--PRINT '/**INICIO - Configurations.dbo.Batch_Liq_Calcular_IIBB**/'
   -- PRINT '@id_cargo = ' + ISNULL(CAST(@id_cargo AS VARCHAR(20)), 'NULL');
    --PRINT '@CreateTimestamp = ' + ISNULL(CAST(@CreateTimestamp AS VARCHAR(20)), 'NULL');
    --PRINT '@Amount = ' + ISNULL(CAST(@Amount AS VARCHAR(20)), 'NULL');
    --PRINT '@monto_calculado_cargo = ' + ISNULL(CAST(@monto_calculado_cargo AS VARCHAR(20)), 'NULL');
   -- PRINT '@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL');
    --PRINT '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
    --PRINT '@porcentaje_exclusion_IIBB = ' + ISNULL(CAST(@porcentaje_exclusion_IIBB AS VARCHAR(20)), 'NULL');
    --PRINT '@fecha_hasta_exclusion_IIBB = ' + ISNULL(CAST(@fecha_hasta_exclusion_IIBB AS VARCHAR(20)), 'NULL');
   -- PRINT '@LocationIdentification = ' + ISNULL(CAST(@LocationIdentification AS VARCHAR(20)), 'NULL');
   -- PRINT '@id_impuesto = ' + ISNULL(CAST(@id_impuesto AS VARCHAR(20)), 'NULL');
	--PRINT '@OperationName = ' + ISNULL(CAST(@OperationName AS VARCHAR(20)), 'NULL');
   -- PRINT '/***/';
	
	

    SELECT @monto_total_cargos = ISNULL(SUM(monto_calculado), 0)
    FROM @Cargos_Por_Transaccion

	set @monto_aplicado_impuesto = 0;
    EXEC @ret_code = Configurations.dbo.Batch_Liq_Calcular_IIBB
  
	 --@id_cargo,
     @CreateTimestamp
     ,@Amount
     ,@monto_total_cargos
     ,@nro_iibb
     ,@id_tipo_condicion_IIBB
     ,@cod_tipo_cond_iibb_vendedor
     ,@porcentaje_exclusion_IIBB
     ,@fecha_hasta_exclusion_IIBB
     ,@LocationIdentification
     ,@id_impuesto
	 --,@cod_prov_vendedor
	 --,@OperationName
     ,@monto_aplicado_impuesto OUTPUT
     ,@alicuota OUTPUT
     ,@aplica_acumulacion OUTPUT
     ,@estado_tope OUTPUT
	 ,@id_impuesto_tipo OUTPUT
	 ,@Monto_a_Ajustar OUTPUT
	 
	 /*
	 PRINT '              '
	 PRINT 'SALIDA       Batch_Liq_Calcular_IIBB'	 	
	 PRINT '@OperationName = ' + ISNULL(CAST(@OperationName AS VARCHAR(20)), 'NULL');
	 PRINT '@monto_aplicado_impuesto = ' + ISNULL(CAST(@monto_aplicado_impuesto AS VARCHAR(20)), 'NULL');
	*/

    SET @aplica_impuesto = @ret_code;

    --Acumulacion
    IF (
      @aplica_impuesto = 1
      AND @aplica_acumulacion = 1
      )
     --IF (@aplica_acumulacion = 1)
    BEGIN --6
     IF (
       @fecha_desde IS NULL
       OR @fecha_hasta IS NULL
       )
     BEGIN --7
      --Calcular ciclo facturacion
      EXEC @ret_code = Configurations.dbo.Calcular_Ciclo_Facturacion @CreateTimestamp
       ,@fecha_desde OUTPUT
       ,@fecha_hasta OUTPUT;

      IF (@ret_code = 0)
      BEGIN
       THROW 51000
        ,'Error en SP - Calcular_Ciclo_Facturacion'
        ,1;
      END;
     END;--7


 -- ,@FlagDevParcial BIT


     --Actualizar acumulador impuestos
     EXEC @ret_code = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Impuestos @id_impuesto
      ,@LocationIdentification
      ,@fecha_desde
      ,@fecha_hasta
      ,@Amount
      ,@monto_aplicado_impuesto
      ,@estado_tope
      ,@OperationName
	  ,NULL
	  ,@porcentaje_exclusion_IIBB
      ,@fecha_hasta_exclusion_IIBB
	  ,@CreateTimestamp
	  ,@alicuota
      ,@importe_retencion OUTPUT
      ,@cantidad_tx OUTPUT
	  ,@Monto_a_Ajustar OUTPUT
	  ,@id_Acumulador_Impuesto output;

     IF (@ret_code = 0)
     BEGIN
      THROW 51000
       ,'Error en SP - Batch_Liq_Actualizar_Acumulador_Impuestos'
       ,1;
     END;

     SET @monto_calculado = @monto_aplicado_impuesto;
     --El impuesto solo se cobra si el tope de excencion se supero o esta deshabilitado
     SET @monto_aplicado_impuesto = IIF(@estado_tope = 0, 0, @monto_aplicado_impuesto);

	 --			 print ' ----------Ajuste negativo----------'
	 --PRINT '@id_motivo_ajuste_negativo = ' + ISNULL(CAST(@id_motivo_ajuste_negativo AS VARCHAR(20)), 'NULL');
     
	 --Ajuste negativo
     --se aplica para las TX anteriores a la actual
     IF (
       @importe_retencion > 0
       AND @estado_tope = 1
       AND @cantidad_tx > 1
       )
     BEGIN --8

     if @Monto_a_Ajustar != 0
		begin


		  EXEC @ret_code = Configurations.dbo.Ajustes_Nuevo_Ajuste @LocationIdentification
		   ,@id_motivo_ajuste_negativo
		   ,@Monto_a_Ajustar -- @importe_retencion
		   ,'Ajuste negativo por IIBB.'
		   ,@Usuario;
		end

      IF (@ret_code = 0)
      BEGIN
       THROW 51000
        ,'Error en SP - Ajustes_Nuevo_Ajuste'
        ,1;
      END;
     END;--8
    END;--6 (@aplica_acumulacion)
   END;--5 (@tipo_impuesto)

   IF (@aplica_impuesto = 1)
   BEGIN
    --Insertar en tabla temp. @Impuestos_Por_TX      
    INSERT INTO @Impuestos_Por_TX (
     id_cargo
     ,id_impuesto
     ,monto_aplicado -- monto_calculado
     ,monto_calculado -- _devolucion
     ,alicuota
     ,aplica_acumulacion
	 ,id_impuesto_tipo
	 ,id_acumulador_impuesto
	   ,ProviderTransactionID 
	   ,CreateTimestamp       
	   ,SaleConcept           
	   ,CredentialEmailAddress
	   ,Amount                
	   ,FeeAmount    
     )
    VALUES (
     @id_cargo
     ,@id_impuesto
     ,@monto_aplicado_impuesto
     ,@monto_calculado
     ,@alicuota
     ,@aplica_acumulacion
	 ,@id_impuesto_tipo
	 ,@id_Acumulador_Impuesto
	   ,@ProviderTransactionID 
	   ,@CreateTimestamp       
	   ,@SaleConcept           
	   ,@CredentialEmailAddress
	   ,@Amount                
	   ,@FeeAmount      
     )
   END;

   SET @k += 1;
  END;--4 (while)
  	  /*
	  print '----------------------'
	  PRINT '@id_cargo = ' + ISNULL(CAST(@id_cargo AS VARCHAR(20)), 'NULL');
	  PRINT '@id_impuesto = ' + ISNULL(CAST(@id_impuesto AS VARCHAR(20)), 'NULL');
      PRINT '@Alicuota = ' + ISNULL(CAST(@Alicuota AS VARCHAR(20)), 'NULL');
	  */

  --Insertar en tabla Impuesto_Por_Transaccion      
  INSERT INTO Configurations.dbo.Impuesto_Por_Transaccion (
   id_transaccion
   ,id_cargo
   ,id_impuesto
   ,monto_aplicado --monto_calculado
   ,monto_calculado --monto_calculado_devolucion
   ,alicuota
   ,fecha_alta
   ,usuario_alta
   ,version
   ,ProviderTransactionID
   ,CreateTimestamp
   ,SaleConcept
   ,CredentialEmailAddress
   ,Amount
   ,FeeAmount
   ,id_impuesto_tipo
   ,id_acumulador_impuesto
   )
  SELECT @Id
   ,ipx.id_cargo
   ,ipx.id_impuesto
   ,ipx.monto_aplicado --monto_calculado
   ,ipx.monto_calculado -- _devolucion
   ,ipx.alicuota
   ,GETDATE()
   ,@Usuario
   ,0
   ,ProviderTransactionID 
   ,CreateTimestamp       
   ,SaleConcept           
   ,CredentialEmailAddress
   ,Amount                
   ,FeeAmount             
   ,ipx.id_impuesto_tipo
   ,ipx.id_acumulador_impuesto
  FROM @Impuestos_Por_TX ipx;

  SELECT @TaxAmount = SUM(ISNULL(monto_aplicado, 0)) --ISNULL(SUM(monto_calculado), 0)
  FROM @Impuestos_Por_TX;

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;--en caso de excepcion fuera del THROW      
  SET @TaxAmount = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END


