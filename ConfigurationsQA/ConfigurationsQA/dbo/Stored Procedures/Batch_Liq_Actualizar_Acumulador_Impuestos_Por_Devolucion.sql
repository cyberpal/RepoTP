
CREATE PROCEDURE [dbo].[Batch_Liq_Actualizar_Acumulador_Impuestos_Por_Devolucion] (
 @Id CHAR(36)
 ,@LocationIdentification INT
 ,@CreateTimestampTXOrig DATETIME
 ,@CreateTimestamp DATETIME
 ,@Amount DECIMAL(12, 2)
 ,@OriginalOperationAmount DECIMAL(12, 2)
 ,@OperationName VARCHAR(128)
 ,@OriginalOperationId CHAR(36)
 ,@Usuario VARCHAR(20)
 --,@id_motivo_ajuste_negativo INT
 ,@id_motivo_ajuste_positivo INT
 ,@nro_iibb varchar(20)
 ,@cod_prov_comprador  varchar(20)
 ,@cod_prov_vendedor varchar(20)
 ,@id_impuesto int
 ,@id_tipo_condicion_IIBB int
 ,@alicuota decimal(12,2)
 ,@Impuesto_tipo Int
 ,@Impuesto_A_Aplicar decimal(12,2) output
 ,@id_acumulador_impuesto int output
 )
AS
DECLARE @Impuestos_IIBB TABLE (
 id_impuesto_iibb INT PRIMARY KEY IDENTITY(1, 1)
 ,id_impuesto INT
 ,id_impuesto_tipo INT
 ,monto_calculado DECIMAL(12, 2) -- _devolucion DECIMAL(12, 2)
 ,minimo_no_imponible DECIMAL(12, 2)
 ,alicuota decimal(5,2)
 );
DECLARE @ret_code INT;
DECLARE @cant_filas INT;
DECLARE @i INT;
--DECLARE @id_impuesto INT;
DECLARE @cantidad_tx INT;
DECLARE @id_motivo_ajuste INT;
DECLARE @id_impuesto_tipo INT;
DECLARE @estado_tope INT;
DECLARE @monto_calculado_devolucion DECIMAL(12, 2);--impuesto calculado de la TX original
DECLARE @monto_aplicado DECIMAL(12, 2);
DECLARE @monto_tot_devolucion DECIMAL(12, 2);
DECLARE @monto_ajuste DECIMAL(12, 2);
DECLARE @importe_retencion DECIMAL(12, 2);
DECLARE @minimo_no_imponible DECIMAL(12, 2);
DECLARE @importe_total_tx DECIMAL(12, 2) = 0;
DECLARE @flag_supera_tope BIT = 0;
DECLARE @flag_dev_parcial BIT;
DECLARE @fecha_desde DATETIME = NULL;
DECLARE @fecha_hasta DATETIME = NULL;
declare @Monto_a_Ajustar DECIMAL(12, 2)
declare @porcentaje_exclusion_IIBB DECIMAL(5, 2)
declare @fecha_hasta_exclusion_IIBB DATETIME
declare @Alicuota_Orig DECIMAL (5,2)
--declare @id_tipo_condicion_IIBB INT
DECLARE @alicuota_tmp DECIMAL(12, 2) = 0;
DECLARE @base_de_calculo DECIMAL(12, 2) = 0;
DECLARE @tipo_aplicacion VARCHAR(20) = NULL;
DECLARE @tipo_base_de_calculo VARCHAR(20) = NULL;
DECLARE @tipo_periodo VARCHAR(20) = NULL;
DECLARE @cantidad_no_imponible int = NULL;
--declare @minimo_no_imponible2 DECIMAL(12, 2)



BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  SET @ret_code = 1;

  /*
	PRINT '/**INICIO -Batch_Liq_Actualizar_Acumulador_Impuestos_Por_Devolucion**/'
	PRINT '@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL');
	print ' '
	

PRINT '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
PRINT '@id_impuesto = ' + ISNULL(CAST(@id_impuesto AS VARCHAR(20)), 'NULL');
*/

select 
@minimo_no_imponible = IsNull(ipt.minimo_no_imponible,0)
from Configurations.dbo.Impuesto_Por_Tipo ipt
where id_impuesto_tipo = @Impuesto_tipo 

/*
PRINT '@ID = ' + ISNULL(CAST(@ID AS VARCHAR(50)), 'NULL');
PRINT '@Impuesto_tipo = ' + ISNULL(CAST(@Impuesto_tipo AS VARCHAR(50)), 'NULL');
PRINT '@minimo_no_imponible = ' + ISNULL(CAST(@minimo_no_imponible AS VARCHAR(20)), 'NULL'); 
*/

/*
print 'Entro al Batch_Liq_Actualizar_Acumulador_Impuestos_Por_Devolucion' 
PRINT '@Impuesto_tipo = ' + ISNULL(CAST(@Impuesto_tipo AS VARCHAR(20)), 'NULL'); 
PRINT '@Alicuota = ' + ISNULL(CAST(@Alicuota AS VARCHAR(20)), 'NULL'); 
PRINT '@minimo_no_imponible = ' + ISNULL(CAST(@minimo_no_imponible AS VARCHAR(20)), 'NULL'); 
*/

/*
IF (@nro_iibb IS NOT NULL)
 BEGIN	 
 print 'Entro por nro ingresos brutos conocido'
 		-- Buscar configuración por Jurisdicción
		SELECT @alicuota_tmp = ipo.alicuota,
			@tipo_aplicacion = tpo1.codigo,
			@tipo_base_de_calculo = tpo2.codigo,
			@tipo_periodo = tpo3.codigo,
			@minimo_no_imponible = ipo.minimo_no_imponible,-- Este dato importa para varias cosas
			@cantidad_no_imponible = ipo.cantidad_no_imponible, -- ESte dato se usa, tal vez pueda ser reemplazado
			@id_impuesto_tipo = ipo.id_impuesto_tipo
		FROM Impuesto_Por_Tipo ipo
		INNER JOIN Impuesto_Por_Jurisdiccion_IIBB ipb
			ON ipo.id_impuesto_tipo = ipb.id_impuesto_tipo
		INNER JOIN Jurisdiccion_IIBB jib
			ON jib.id_jurisdiccion_iibb = ipb.id_jurisdiccion_iibb
		INNER JOIN Configurations.dbo.Tipo AS tpo1
			ON ipo.id_tipo_aplicacion = tpo1.id_tipo
		INNER JOIN Configurations.dbo.Tipo AS tpo2
			ON ipo.id_base_de_calculo = tpo2.id_tipo
		INNER JOIN Configurations.dbo.Tipo tpo3
			ON ipo.id_tipo_periodo = tpo3.id_tipo
		WHERE ipo.id_impuesto = @id_impuesto
			AND ipo.flag_estado = 1
			AND ipo.id_tipo = @id_tipo_condicion_IIBB
			AND jib.codigo = LEFT(@nro_iibb, 3)
			AND CAST(ipo.fecha_vigencia_inicio AS DATE) <= CAST(@CreateTimestamp AS DATE)
			AND (
				ipo.fecha_vigencia_fin IS NULL
				OR CAST(ipo.fecha_vigencia_fin AS DATE) >= CAST(@CreateTimestamp AS DATE)
				);

		IF (@id_impuesto_tipo IS NULL)
			SELECT @id_impuesto_tipo = ipt.id_impuesto_tipo,
				@alicuota_tmp = ipt.alicuota,
				@tipo_aplicacion = tpo2.codigo,
				@tipo_base_de_calculo = tpo3.codigo,
				@tipo_periodo = tpo4.codigo,
				@minimo_no_imponible = ipt.minimo_no_imponible,
				@cantidad_no_imponible = ipt.cantidad_no_imponible
			FROM Configurations.dbo.Impuesto_Por_Tipo ipt
			INNER JOIN Configurations.dbo.Tipo tpo2
				ON ipt.id_tipo_aplicacion = tpo2.id_tipo
			INNER JOIN Configurations.dbo.Tipo tpo3
				ON ipt.id_base_de_calculo = tpo3.id_tipo
			INNER JOIN Configurations.dbo.Tipo tpo4
				ON ipt.id_tipo_periodo = tpo4.id_tipo
			WHERE ipt.id_tipo = @id_tipo_condicion_IIBB
				AND ipt.flag_estado = 1
				AND ipt.id_impuesto = @id_impuesto;
	

	 END

 ELSE -- No hhay nRO IIBB
	 BEGIN
	 print 'Entro x el else xx'
	  --@nro_iibb = NULL

		SELECT @alicuota_tmp = ipo.alicuota,
			@tipo_aplicacion = tpo1.codigo,
			@tipo_base_de_calculo = tpo2.codigo,
			@tipo_periodo = tpo3.codigo,
			@minimo_no_imponible = ipo.minimo_no_imponible,
			@cantidad_no_imponible = ipo.cantidad_no_imponible,
			@id_impuesto_tipo = ipo.id_impuesto_tipo
		FROM Configurations.dbo.Impuesto_Por_Tipo AS ipo
		INNER JOIN Configurations.dbo.Tipo AS tpo1
			ON ipo.id_tipo_aplicacion = tpo1.id_tipo
		INNER JOIN Configurations.dbo.Tipo AS tpo2
			ON ipo.id_base_de_calculo = tpo2.id_tipo
		INNER JOIN Configurations.dbo.Tipo tpo3
			ON ipo.id_tipo_periodo = tpo3.id_tipo
		WHERE ipo.id_impuesto = @id_impuesto
			AND ipo.id_tipo IS NULL
			AND ipo.flag_estado = 1
			AND CAST(ipo.fecha_vigencia_inicio AS DATE) <= CAST(@CreateTimestamp AS DATE)
			AND (
				ipo.fecha_vigencia_fin IS NULL
				OR CAST(ipo.fecha_vigencia_fin AS DATE) >= CAST(@CreateTimestamp AS DATE)
				);
	  
	 
			 PRINT '@alicuota_tmp 2 = ' + ISNULL(CAST(@alicuota_tmp AS VARCHAR(20)), 'NULL');
	 END;

	
	
    PRINT '@Id = ' + ISNULL(CAST(@Id AS VARCHAR(50)), 'NULL');
	PRINT '@LocationIdentification = ' + ISNULL(CAST(@LocationIdentification AS VARCHAR(20)), 'NULL');
	PRINT '@CreateTimestampTXOrig = ' + ISNULL(CAST(@CreateTimestampTXOrig AS VARCHAR(20)), 'NULL');
	PRINT '@CreateTimestamp = ' + ISNULL(CAST(@CreateTimestamp AS VARCHAR(20)), 'NULL');
	PRINT '@Amount = ' + ISNULL(CAST(@Amount AS VARCHAR(20)), 'NULL');
	PRINT '@OriginalOperationAmount = ' + ISNULL(CAST(@OriginalOperationAmount AS VARCHAR(20)), 'NULL');
	PRINT '@OperationName = ' + ISNULL(CAST(@OperationName AS VARCHAR(20)), 'NULL');
	PRINT '@OriginalOperationId = ' + ISNULL(CAST(@OriginalOperationId AS VARCHAR(20)), 'NULL');
	PRINT '@Usuario = ' + ISNULL(CAST(@Usuario AS VARCHAR(20)), 'NULL');
	PRINT '@minimo_no_imponible = ' + ISNULL(CAST(@minimo_no_imponible AS VARCHAR(20)), 'NULL');
	PRINT '@cantidad_no_imponible = ' + ISNULL(CAST(@cantidad_no_imponible AS VARCHAR(20)), 'NULL');
	PRINT '-----------'
*/
	--print 'Llego al insertar'
  --Obtener impuestos IIBB de la TX actual
  INSERT INTO @Impuestos_IIBB (
   id_impuesto
   ,id_impuesto_tipo
   ,monto_calculado --monto_calculado_devolucion
   ,minimo_no_imponible
   ,alicuota
   )
   /*
  SELECT ipt.id_impuesto
   ,ipt.id_impuesto_tipo
   ,ipt.monto_calculado --ipt.monto_calculado_devolucion
   ,@minimo_no_imponible2
   ,@alicuota
   --,ipo.minimo_no_imponible
  -- ,ipt.alicuota-- podria ser @alicuota
  FROM Configurations.dbo.Impuesto_Por_Transaccion ipt
  INNER JOIN Configurations.dbo.Impuesto imp ON ipt.id_impuesto = imp.id_impuesto --.codigo LIKE 'RET_IIBB%'
  INNER JOIN Configurations.dbo.Impuesto_Por_Tipo ipo ON ipo.id_impuesto = imp.id_impuesto
  INNER JOIN Configurations.dbo.Tipo tpo ON tpo.codigo = 'POR_CICLO'
   --AND tpo.id_grupo_tipo = 30
   where tpo.id_grupo_tipo = 30
   AND imp.id_impuesto = ipt.id_impuesto
   AND ipt.id_transaccion = @OriginalOperationId
  -- and ipo.minimo_no_imponible = @minimo_no_imponible
   --and ipo.cantidad_no_imponible = @cantidad_no_imponible
  GROUP BY ipt.id_impuesto
   ,ipt.monto_calculado --ipt.monto_calculado_devolucion
   ,ipt.id_impuesto_tipo
   --,ipo.minimo_no_imponible
   --,ipt.alicuota
   */
     SELECT ipt.id_impuesto
   ,ipt.id_impuesto_tipo
   ,ipt.monto_calculado --ipt.monto_calculado_devolucion
   ,@minimo_no_imponible
   ,@alicuota
   from Impuesto_Por_Transaccion ipt
   inner join Impuesto_Por_Tipo ipo on ipt.id_impuesto_tipo = ipo.id_impuesto_tipo
   INNER JOIN Configurations.dbo.Tipo tpo ON ipo.id_tipo_periodo = tpo.id_tipo
   where     ipt.id_transaccion = @OriginalOperationId
   --and tpo.id_grupo_tipo = 30
   and tpo.codigo = 'POR_CICLO'
   --GROUP BY ipt.id_impuesto
   --,ipt.monto_calculado 
   --,ipt.id_impuesto_tipo

     SET @cant_filas = @@ROWCOUNT;
	 --select * from  @Impuestos_IIBB

 --SELECT @id_motivo_ajuste = @id_motivo_ajuste_negativo
 SELECT @id_motivo_ajuste = @id_motivo_ajuste_positivo

  IF (@cant_filas > 0)
  BEGIN -- 1
 -- print 'Hay operaciones' + cast(@cant_filas as varchar(50))

   SET @i = 1;

   /*
   SELECT @id_motivo_ajuste = mje.id_motivo_ajuste
   FROM Configurations.dbo.Motivo_Ajuste mje
   WHERE mje.codigo = '14'
   */

 


 --  WHILE (@i <= @cant_filas)
   BEGIN -- 2
    SELECT @id_impuesto = ipb.id_impuesto
     ,@id_impuesto_tipo = ipb.id_impuesto_tipo
     ,@monto_calculado_devolucion = ipb.monto_calculado -- ipb.monto_calculado_devolucion
     ,@minimo_no_imponible = IsNull(ipb.minimo_no_imponible,0)
	 ,@Alicuota_Orig = ipb.alicuota
    FROM @Impuestos_IIBB ipb
    WHERE ipb.id_impuesto_iibb = @i;



    --Calcular ciclo facturacion para la TX actual
    EXEC @ret_code = Configurations.dbo.Calcular_Ciclo_Facturacion @CreateTimestamp
     ,@fecha_desde OUTPUT
     ,@fecha_hasta OUTPUT;

    IF (@ret_code = 0)
    BEGIN
     THROW 51000
      ,'Error en SP - Calcular_Ciclo_Facturacion - TX actual'
      ,1;
    END;
	
	/*
	PRINT '@OriginalOperationId= ' + ISNULL(CAST(@OriginalOperationId AS VARCHAR), 'NULL');
	PRINT '@monto_calculado_devolucion= ' + ISNULL(CAST(@monto_calculado_devolucion AS VARCHAR), 'NULL');
	PRINT '@Amount= ' + ISNULL(CAST(@Amount AS VARCHAR), 'NULL');
	PRINT '@OriginalOperationAmount= ' + ISNULL(CAST(@OriginalOperationAmount AS VARCHAR), 'NULL');
	*/
	

    --Calculo de importe_retencion para devolucion total/parcial
    SET @monto_aplicado = @Amount / @OriginalOperationAmount * @monto_calculado_devolucion;
	--PRINT '@monto_aplicado= ' + ISNULL(CAST(@monto_aplicado AS VARCHAR), 'NULL');

    SELECT @importe_total_tx = IsNull(apo.importe_total_tx,0)
     ,@flag_supera_tope = IsNull(apo.flag_supera_tope,0)
     ,@importe_retencion = IsNull(apo.importe_retencion,0)
    FROM Configurations.dbo.Acumulador_Impuesto apo
    WHERE apo.id_impuesto = @id_impuesto
     AND apo.id_cuenta = @LocationIdentification
     AND apo.fecha_desde = @fecha_desde
     AND apo.fecha_hasta = @fecha_hasta;

	/*
	 PRINT '@importe_total_tx= ' + ISNULL(CAST(@importe_total_tx AS VARCHAR), 'NULL');
	 PRINT '@Amount= ' + ISNULL(CAST(@Amount AS VARCHAR), 'NULL');
	 PRINT '@minimo_no_imponible= ' + ISNULL(CAST(@minimo_no_imponible AS VARCHAR), 'NULL');
	 PRINT '@flag_supera_tope= ' + ISNULL(CAST(@flag_supera_tope AS VARCHAR), 'NULL');
	 */


    --IF (@importe_total_tx - @Amount < @minimo_no_imponible)
	IF (@importe_total_tx - @Amount < @minimo_no_imponible)
	
    BEGIN --3

     IF (@flag_supera_tope = 1) -- Corresponde calculado por la operación y ajuste por lo anterior
		begin
		 -- SET @monto_ajuste = @importe_retencion;
		   set @Impuesto_A_Aplicar = @Alicuota_Orig * @Amount / 100
		   SET @monto_ajuste = @importe_retencion - @Impuesto_A_Aplicar;
		   	--PRINT '@Impuesto_A_Aplicar= ' + ISNULL(CAST(@Impuesto_A_Aplicar AS VARCHAR), 'NULL');
		end
	ELSE  -- BAja del mínimo no imponible, pero no superaba tope, es decir, estaba debajo del mismo. Corresponde sólo calculado
      SET @monto_ajuste = 0;

     SET @estado_tope = 0;
    END --3
    ELSE -- Queda por sobre el mínimo no imponible
		BEGIN	
		 --SET @monto_ajuste = @monto_aplicado;
		  SET @monto_ajuste = 0
		  set @Impuesto_A_Aplicar = @monto_aplicado;
		 SET @estado_tope = 1;
		END;
	--PRINT '@monto_ajuste= ' + ISNULL(CAST(@monto_ajuste AS VARCHAR), 'NULL');
    SET @monto_tot_devolucion = @Amount;

	  select 
	  --@LocationIdentification = LocationIdentification,
	  --@Amount = amount,
	  @porcentaje_exclusion_IIBB = sfc.porcentaje_exclusion_iibb,
	  @fecha_hasta_exclusion_IIBB = sfc.fecha_hasta_exclusion_IIBB
	  from Liquidacion_Tmp LIq
	  inner join Situacion_Fiscal_Cuenta SFC
	  on Liq.LocationIdentification = sfc.id_cuenta
	  and sfc.flag_vigente = 1
	  where id = @Id

    IF (@Amount < @OriginalOperationAmount)
		BEGIN
		 --Obtener cant.total de devoluciones parciales
		 SELECT @monto_tot_devolucion = ISNULL(SUM(Amount), 0)
		 FROM Transactions.dbo.Transactions
		 WHERE OriginalOperationId = @OriginalOperationId
		  AND CreateTimestamp <= @CreateTimestamp
		END;

    SET @flag_dev_parcial = IIF(@monto_tot_devolucion < @OriginalOperationAmount, 1, 0);

    --Actualizar acumulador impuestos
    EXEC @ret_code = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Impuestos @id_impuesto
     ,@LocationIdentification
     ,@fecha_desde
     ,@fecha_hasta
     ,@Amount
     ,@monto_aplicado
     ,@estado_tope
     ,@OperationName	
     ,@flag_dev_parcial
	 ,@porcentaje_exclusion_IIBB
	 ,@fecha_hasta_exclusion_IIBB
	 ,@CreateTimestamp
	 ,@alicuota
     ,@importe_retencion
     ,@cantidad_tx
	 ,@Monto_a_Ajustar
	 ,@id_Acumulador_Impuesto output;



    IF (@ret_code = 0)
    BEGIN
     THROW 51000
      ,'Error en SP - Batch_Liq_Actualizar_Acumulador_Impuestos'
      ,1;
    END;

    IF (@monto_ajuste > 0)
    BEGIN -- 4
     --Hacer ajuste por credito
     EXEC @ret_code = Configurations.dbo.Ajustes_Nuevo_Ajuste @LocationIdentification
      ,@id_motivo_ajuste
      ,@monto_ajuste
      ,'Ajuste positivo por IIBB.'
      ,@Usuario;

     --test
     --PRINT '**Ajuste Positivo - @monto_ajuste= ' + ISNULL(CAST(@monto_ajuste AS VARCHAR), 'NULL');

     IF (@ret_code = 0)
     BEGIN
      THROW 51000
       ,'Error en SP - Ajustes_Nuevo_Ajuste'
       ,1;
     END;
    END; --4

    SET @i += 1
   END; --2
  END; --1
 END TRY

 BEGIN CATCH
  PRINT ERROR_MESSAGE();

  SET @ret_code = 0;
 END CATCH

 RETURN @ret_code;
END


