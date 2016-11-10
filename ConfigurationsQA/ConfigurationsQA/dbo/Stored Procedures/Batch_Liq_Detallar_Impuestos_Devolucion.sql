

CREATE PROCEDURE [dbo].[Batch_Liq_Detallar_Impuestos_Devolucion] (
 @Id CHAR(36)
 ,@TaxAmount DECIMAL(12, 2)
 ,@Usuario VARCHAR(20)
 --,@id_motivo_ajuste_negativo int
 ,@id_motivo_ajuste_positivo int
 ,@nro_iibb varchar(20)
 ,@cod_prov_comprador varchar(20)
 ,@cod_prov_vendedor varchar(20)
 ,@id_tipo_condicion_IIBB int
 )
AS

DECLARE @tx_Id CHAR(36);
DECLARE @tx_TaxAmount DECIMAL(12, 2);
DECLARE @ret_code INT;
declare @id_impuesto int = 0
declare @id_cargo int = 0
declare @monto_calculado DECIMAL(12, 2)
declare @alicuota DECIMAL(12, 2)
declare @LocationIdentification int
declare @fecha_desde datetime = null
declare @fecha_hasta datetime = null
declare @Amount DECIMAL(12, 2)
declare @monto_calculado_impuesto decimal(12,2)
declare @estado_tope INT = 0;-- -1 (deshabilitado/cuando se aplica la 1ra vez se deshabilita) - 0 (no superado) - 1 (superado)
declare @porcentaje_exclusion_IIBB decimal(5,2)
declare @fecha_hasta_exclusion_IIBB datetime
declare @CreateTimestamp datetime
DECLARE @CreateTimestampTXOrig DATETIME
declare @OriginalOperationAmount DECIMAL(12, 2)
declare @importe_retencion decimal(12,2)
declare @cantidad_tx int
declare @Monto_a_Ajustar decimal(12,2)
declare @OriginalOperationId CHAR(36)
declare @tx_Amount DECIMAL(12, 2)
--declare @flag_supera_tope int
declare @Impuesto_A_Aplicar decimal(12,2)
declare @id_acumulador_impuesto int
declare @Impuesto_tipo Int


BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  -- Obtener ID y Cargo de la Transacción sobre la que se realiza la Devolución    
  
 

  select @OriginalOperationId = OriginalOperationId
  ,@CreateTimestamp = CreateTimestamp,
  @Amount = Amount
  --@Id_Cuenta = @LocationIdentification
  from dbo.Liquidacion_Tmp
  WHERE Id = @Id

  
  SELECT @tx_Id = Id
   ,@LocationIdentification = LocationIdentification
   ,@tx_Amount = Amount
   ,@tx_TaxAmount = TaxAmount
   ,@CreateTimestampTXOrig = CreateTimestamp
   ,@OriginalOperationAmount = Amount
  FROM Transactions.dbo.transactions
  WHERE Id = @OriginalOperationId 

	/*
	select @flag_supera_tope = flag_supera_tope 
	from dbo.Acumulador_Impuesto
	where id_cuenta = @LocationIdentification
	*/

	--print 'Entro al detallar'

	-- Obtiene datos necesarios desde la transacción original

	SELECT @id_impuesto =id_impuesto
   ,@id_cargo = id_cargo,   
  --,@monto_calculado = monto_calculado * IIF(@tx_TaxAmount = 0, 0, (@TaxAmount * 100 / @tx_TaxAmount)) / 100
  @monto_calculado =  alicuota * @Amount  / 100
   --,@monto_calculado = monto_calculado * IIF(@tx_TaxAmount = 0, 0, (@Amount * 100 / @tx_Amount)) / 100
   ,@alicuota = alicuota --* IIF(@tx_TaxAmount = 0, 0, (@TaxAmount / @tx_TaxAmount * 100)) / 100
   ,@Impuesto_tipo = id_impuesto_tipo
  FROM Configurations.dbo.Impuesto_Por_Transaccion
  WHERE id_transaccion = @tx_Id;  -- 


	--PRINT '/**INICIO -Batch_Liq_Detallar_Impuestos_Devolucion**/'
  --  PRINT '@Id = ' + ISNULL(CAST(@Id AS VARCHAR(20)), 'NULL');
	--PRINT '@tx_Id = ' + ISNULL(CAST(@tx_Id AS VARCHAR(20)), 'NULL');
	--PRINT '@alicuota = ' + ISNULL(CAST(@alicuota AS VARCHAR(20)), 'NULL');
	--PRINT '@Amount (Dev.) = ' + ISNULL(CAST(@Amount AS VARCHAR(20)), 'NULL');
	--PRINT '@monto_calculado (Orig.) = ' + ISNULL(CAST(@monto_calculado AS VARCHAR(20)), 'NULL');

-- Pruebo invertir el orden
  SET @ret_code = 1;

 EXEC @ret_code = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Impuestos_Por_Devolucion 
  @Id 
 ,@LocationIdentification 
 ,@CreateTimestampTXOrig
 ,@CreateTimestamp 
 ,@Amount 
 ,@OriginalOperationAmount 
 ,'DEVOLUCION'
 ,@OriginalOperationId 
 ,@Usuario
 ,@id_motivo_ajuste_positivo
 ,@nro_iibb
 ,@cod_prov_comprador 
 ,@cod_prov_vendedor
 ,@id_impuesto
 ,@id_tipo_condicion_IIBB
 ,@alicuota
 ,@Impuesto_tipo
 ,@Impuesto_A_Aplicar output  
 ,@id_acumulador_impuesto output

 -- Fin inversión

  -- Insertar el detalle de Cargos de la Devolución basado en los Cargos de la Transacción      
  INSERT INTO Configurations.dbo.Impuesto_Por_Transaccion (
   id_impuesto
   ,id_cargo
   ,id_transaccion
   ,monto_aplicado -- monto_calculado
   ,alicuota
   ,fecha_alta
   ,usuario_alta
   ,version
   ,monto_calculado
   ,id_acumulador_impuesto
   )
  SELECT @id_impuesto
   ,@id_cargo
   ,@Id
   --,iif(@flag_supera_tope = 1, @monto_calculado * -1, 0)
   --,0
   --, @monto_calculado * -1
   ,@Impuesto_A_Aplicar * -1
   ,@alicuota
   ,GETDATE()
   ,@Usuario
   ,0
   ,@monto_calculado * -1
   ,@id_acumulador_impuesto
  --FROM Configurations.dbo.Impuesto_Por_Transaccion
 -- WHERE id_transaccion = @tx_Id;

/*
  SET @ret_code = 1;

 EXEC @ret_code = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Impuestos_Por_Devolucion 
  @Id 
 ,@LocationIdentification 
 ,@CreateTimestampTXOrig
 ,@CreateTimestamp 
 ,@Amount 
 ,@OriginalOperationAmount 
 ,'DEVOLUCION'
 ,@OriginalOperationId 
 ,@Usuario
 ,@id_motivo_ajuste_positivo
 ,@nro_iibb
 ,@cod_prov_comprador 
 ,@cod_prov_vendedor
 ,@id_impuesto
 ,@id_tipo_condicion_IIBB
 */
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END


