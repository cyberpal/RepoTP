


CREATE PROCEDURE [dbo].[Batch_Liq_Actualizar_Acumulador_Impuestos] (
 @IdImpuesto INT
 ,@IdCuenta INT -- Vendedor
 ,@FechaDesde DATETIME
 ,@FechaHasta DATETIME
 ,@Monto DECIMAL(12, 2)
 ,@monto_aplicado_impuesto DECIMAL(12, 2)
 ,@EstadoTope INT
 ,@OperationName VARCHAR(128)
 ,@FlagDevParcial BIT
 ,@porcentaje_exclusion_IIBB DECIMAL(5, 2)
 ,@fecha_hasta_exclusion_IIBB DATETIME
 ,@CreateTimestamp datetime
 ,@Alicuota decimal(5,2)
 ,@ImporteRetencion DECIMAL(12, 2) OUTPUT
 ,@CantidadTX INT OUTPUT
 ,@Monto_a_Ajustar DECIMAL(12, 2) OUTPUT
 ,@id_Acumulador_Impuesto int output
 )
AS
DECLARE @ret_code INT;
DECLARE @cantidad_tx INT = 1;
DECLARE @importe_retencion DECIMAL(12, 2) = 0;
DECLARE @flag_supera_tope BIT = IIF(@EstadoTope = 0, 0, 1);
declare @PorcentajeImpuesto decimal(12,2) = 100
--declare @id_Acumulador_Impuesto int

declare @Change varchar(20)

DECLARE @SummaryOfChanges TABLE(Change VARCHAR(20));  



BEGIN
 SET NOCOUNT ON;

 BEGIN TRY

  SET @Monto = IIF(UPPER(@OperationName) = 'DEVOLUCION', @Monto * - 1, @Monto);
  --set @PorcentajeImpuesto = 100.00 - (IIF(@fecha_hasta_exclusion_IIBB IS NULL
     --OR (CAST(@fecha_hasta_exclusion_IIBB AS DATE) >= CAST(@CreateTimestamp AS DATE)), @porcentaje_exclusion_IIBB, 0));

  SET @monto_aplicado_impuesto =  (IIF(UPPER(@OperationName) = 'DEVOLUCION', @monto_aplicado_impuesto * - 1, @monto_aplicado_impuesto)) ;
  SET @OperationName = ISNULL(@OperationName,'');
  SET @FlagDevParcial = ISNULL(@FlagDevParcial,0);

  SET @Monto_a_Ajustar = (SELECT importe_retencion FROM dbo.Acumulador_Impuesto AI
							WHERE AI.id_impuesto = @IdImpuesto 
							AND AI.id_cuenta = @IdCuenta
							AND AI.fecha_desde = @FechaDesde 
							AND AI.fecha_hasta = @FechaHasta )


   --test
   /*
  PRINT '[Batch_Liq_Actualizar_Acumulador_Impuestos]';
  PRINT '@Alicuota = ' + ISNULL(CAST(@Alicuota AS VARCHAR(20)), 'NULL');
  PRINT '@Monto_a_Ajustar (anterior) = ' + ISNULL(CAST(@Monto_a_Ajustar AS VARCHAR(20)), 'NULL');
  PRINT '@monto_aplicado_impuesto (Nueva) = ' + ISNULL(CAST(@monto_aplicado_impuesto AS VARCHAR(20)), 'NULL');
  PRINT '@OperationName (Nueva) = ' + ISNULL(CAST(@OperationName AS VARCHAR(20)), 'NULL');
 
  PRINT '@IdImpuesto = ' + ISNULL(CAST(@IdImpuesto AS VARCHAR(20)), 'NULL');
  PRINT '@IdCuenta = ' + ISNULL(CAST(@IdCuenta AS VARCHAR(20)), 'NULL');
   PRINT '[Fin Batch_Liq_Actualizar_Acumulador_Impuestos]';
   
   print ' ';
   */
   /*
  PRINT '@FechaDesde = ' + ISNULL(CAST(@FechaDesde AS VARCHAR(20)), 'NULL');
  PRINT '@FechaHasta = ' + ISNULL(CAST(@FechaHasta AS VARCHAR(20)), 'NULL');
  PRINT '@Monto = ' + ISNULL(CAST(@Monto AS VARCHAR(20)), 'NULL');
  PRINT '@monto_aplicado_impuesto = ' + ISNULL(CAST(@MontoCalculadoRetencion AS VARCHAR(20)), 'NULL');
  PRINT '@EstadoTope = ' + ISNULL(CAST(@EstadoTope AS VARCHAR(20)), 'NULL');
  PRINT '@OperationName = ' + ISNULL(CAST(@OperationName AS VARCHAR(20)), 'NULL');
  PRINT '@FlagDevParcial = ' + ISNULL(CAST(@FlagDevParcial AS VARCHAR(20)), 'NULL');  
  PRINT '@porcentaje_exclusion_IIBB = '  + ISNULL(CAST(@porcentaje_exclusion_IIBB AS VARCHAR(20)), 'null');
  PRINT '@fecha_hasta_exclusion_IIBB = '  + ISNULL(CAST(@fecha_hasta_exclusion_IIBB AS VARCHAR(20)), 'null');
  PRINT '@CreateTimestamp = '  + ISNULL(CAST(@CreateTimestamp AS VARCHAR(20)), 'null');
  PRINT '@ImporteRetencion = ' + ISNULL(CAST(@ImporteRetencion AS VARCHAR(20)), 'NULL');
  */
  


	  MERGE Configurations.dbo.Acumulador_Impuesto AS destino
	  USING (
	   SELECT @IdImpuesto
		,@IdCuenta
		,@FechaDesde
		,@FechaHasta
		,@cantidad_tx
		,@Monto
		,@monto_aplicado_impuesto
		--,@Monto_a_Ajustar -- nuevo
		,@flag_supera_tope
		,@Alicuota
		,@id_Acumulador_Impuesto
	   ) AS origen(id_impuesto, id_cuenta, fecha_desde, fecha_hasta, cantidad_tx, monto, monto_calculado_retencion, flag_supera_tope,alicuota,
	   id_acumulador_impuesto)
	   ON (
		 origen.id_impuesto = destino.id_impuesto
		 AND origen.id_cuenta = destino.id_cuenta
		 AND origen.fecha_desde = destino.fecha_desde
		 AND origen.fecha_hasta = destino.fecha_hasta
		 )

	  WHEN MATCHED
	   THEN
	   --set @Monto_a_Ajustar = @Monto_a_Ajustar
		UPDATE
		  --SET destino.cantidad_tx = destino.cantidad_tx + 1
		  SET destino.cantidad_tx = IIF(UPPER(@OperationName) <> 'DEVOLUCION',destino.cantidad_tx + 1,(IIF(@FlagDevParcial = 1, destino.cantidad_tx,destino.cantidad_tx - 1)))
		 ,destino.importe_total_tx = destino.importe_total_tx + origen.monto
		 ,destino.importe_retencion = destino.importe_retencion + origen.monto_calculado_retencion
		 ,destino.flag_supera_tope = origen.flag_supera_tope
		 ,@importe_retencion = destino.importe_retencion + origen.monto_calculado_retencion
		 ,@cantidad_tx = IIF(UPPER(@OperationName) <> 'DEVOLUCION',destino.cantidad_tx + 1,(IIF(@FlagDevParcial = 1, destino.cantidad_tx,destino.cantidad_tx - 1)))
		 ,destino.alicuota = @Alicuota
		 ,@id_Acumulador_Impuesto = destino.id_acumulador_impuesto

		 
	  WHEN NOT MATCHED
	   THEN
	  
		INSERT (
		 id_impuesto
		 ,id_cuenta
		 ,fecha_desde
		 ,fecha_hasta
		 ,cantidad_tx
		 ,importe_total_tx
		 ,importe_retencion
		 ,flag_supera_tope
		 ,Alicuota		
		 )
		VALUES (
		 origen.id_impuesto
		 ,origen.id_cuenta
		 ,origen.fecha_desde
		 ,origen.fecha_hasta
		 ,origen.cantidad_tx
		 ,origen.monto
		 ,origen.monto_calculado_retencion
		 ,origen.flag_supera_tope
		 ,origen.Alicuota		 
		 )

		OUTPUT $action INTO @SummaryOfChanges;
		
		SELECT @Change = Change 
		FROM @SummaryOfChanges  

		if @Change = 'INSERT'		
			set @id_Acumulador_Impuesto = SCOPE_IDENTITY()

		 
  SET @ImporteRetencion = @importe_retencion;
  SET @CantidadTX = @cantidad_tx;
  SET @ret_code = 1;

  --PRINT '@CantidadTX = ' + ISNULL(CAST(@CantidadTX AS VARCHAR(20)), 'NULL');
  --PRINT '@Monto_a_Ajustar = '  + ISNULL(CAST(@Monto_a_Ajustar AS VARCHAR(20)), 'null');
  --PRINT '@id_Acumulador_Impuesto = '  + ISNULL(CAST(@id_Acumulador_Impuesto AS VARCHAR(20)), 'null');
  --print '@@Change = '  + ISNULL(CAST(@Change AS VARCHAR(20)), 'null');
  
 -- print '               '

 END TRY

 BEGIN CATCH
  PRINT ERROR_MESSAGE();

  SET @ret_code = 0;
 END CATCH

 RETURN @ret_code;
END


