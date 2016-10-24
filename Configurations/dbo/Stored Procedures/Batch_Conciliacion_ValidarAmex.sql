
CREATE PROCEDURE dbo.Batch_Conciliacion_ValidarAmex (@id_log_proceso INT)
AS

DECLARE @resultado_proceso BIT = 0;
DECLARE @id_log_paso INT;
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @archivo_entrada VARCHAR(100) = NULL;
DECLARE @cod_medio_pago VARCHAR(4) = 'AMEX';
DECLARE @id_medio_pago INT;
DECLARE @fecha_ejecucion DATETIME = NULL;
DECLARE @registros_procesados INT = 0;
DECLARE @importe_procesados DECIMAL(12, 2) = 0;
DECLARE @id INT;
DECLARE @id_moneda INT;
DECLARE @cont_cabecera INT;
DECLARE @contreg_archivo INT;
DECLARE @cont_sumario INT;
DECLARE @contfilas_sumario INT;
DECLARE @cont_trailer INT;
DECLARE @contfilas_trailer INT;
DECLARE @conttag_cabecera INT;
DECLARE @conttag_trailer INT;
DECLARE @cont_establecimiento INT;
DECLARE @cod_moneda VARCHAR(3);
DECLARE @monto_sumcargo DECIMAL(16, 2);
DECLARE @monto_notacargo DECIMAL(16, 2);
DECLARE @formato_parametro VARCHAR(15);
DECLARE @nro_comercio VARCHAR(10);
DECLARE @pos_inicial_mascara INT;
DECLARE @cantidad_pos_mascara INT;
DECLARE @ValidacionResultadoMov VARCHAR(250);
DECLARE @CampoMP1 VARCHAR(10);
DECLARE @Valor1 VARCHAR(15);


DECLARE @info_amex TABLE (
 Id INT PRIMARY KEY IDENTITY(1, 1)
 ,TipoReg CHAR(1)
 ,TipoImpuesto VARCHAR(20)
 ,CodigoAjuste VARCHAR(10)
 ,TotalCargoCuotas DECIMAL(16, 2)
 ,IdCodOp INT
 ,Importe DECIMAL(12, 2)
 ,SignoImporte CHAR(1)
 ,IdMoneda INT
 ,CantidadCuotas INT
 ,FechaMovimiento DATETIME
 ,FechaPago DATETIME
 ,ValidacionResultadoMov VARCHAR(250)
 ,NroLote VARCHAR(15)
 ,NroCupon INT
 ,NroTarjeta NVARCHAR(50)
 ,HashNroTarjeta VARCHAR(80)
 ,MaskNroTarjeta VARCHAR(20)
 ,CargosMarcaPorMovimiento DECIMAL(12, 2)
 ,SignoCargosMarcaPorMovimiento CHAR(1)
 ,ImpServNotaCargo DECIMAL(16, 2)
 ,ImpDescAjuste DECIMAL(16, 2)
 ,ImpAcelAjuste DECIMAL(16, 2)
 ,NroAutorizacion VARCHAR(8) 
 ,CampoMP1 VARCHAR(10)
 ,Valor1 VARCHAR(15)
 ,CampoMP2 VARCHAR(10)
 ,Valor2 VARCHAR(15)
 ,CampoMP3 VARCHAR(10)
 ,Valor3 VARCHAR(15)
);

SET NOCOUNT ON;

BEGIN TRY
 BEGIN TRANSACTION;

SELECT TOP 1 @id = (id)
 ,@archivo_entrada = nombre_archivo
FROM Configurations.dbo.Archivo_Conciliacion
WHERE flag_procesado = 0
 AND descripcion = @cod_medio_pago;

SELECT TOP 1 @fecha_ejecucion = fecha_inicio_ejecucion
FROM Configurations.dbo.Log_Paso_Proceso
WHERE archivo_entrada = @archivo_entrada
 AND resultado_proceso = 1

EXEC Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso
 ,1
 ,@cod_medio_pago
 ,@archivo_entrada
 ,'bpbatch'
 ,@id_log_paso = @id_log_paso OUTPUT;

SELECT @cont_trailer = SUM(ISNULL(CAST(Q1.xml_data AS XML).value('(/amex/t)[12]', 'INT'),0))
 ,@contfilas_trailer = COUNT(1)
 ,@cont_sumario = SUM(ISNULL(CAST(Q1.xml_data2 AS XML).value('(/amex/t)[16]', 'INT'),0))
 ,@contfilas_sumario = SUM(ISNULL(Q1.ContFilasSumario,0))
 ,@monto_sumcargo = SUM(ISNULL(CAST(Q1.xml_data2 AS XML).value('(/amex/t)[11]', 'DECIMAL(16,2)'),0) / 100)
 ,@monto_notacargo = SUM(ISNULL(CAST(Q1.xml_data3 AS XML).value('(/amex/t)[12]', 'DECIMAL(16,2)'),0) / 100)
 ,@conttag_cabecera = SUM(ISNULL(Q1.ContTagCabecera,0))
 ,@conttag_trailer = SUM(ISNULL(Q1.ContTrailer,0))
 ,@cont_establecimiento = COUNT(DISTINCT Establecimiento)
 ,@cod_moneda = MAX(ISNULL(CAST(Q1.xml_data4 AS XML).value('(/amex/t)[13]', 'VARCHAR(3)'),0))
FROM (SELECT (CASE WHEN SUBSTRING(detalles, 45, 1) = '9'THEN CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') END) xml_data
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '3' THEN CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') END) xml_data2
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN 1 END) ContFilasSumario
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') END) xml_data3	
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '1' THEN CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') END) xml_data4	
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '0' THEN 1 END) ContTagCabecera
	,(CASE WHEN SUBSTRING(detalles, 45, 1) = '9' THEN 1 END) ContTrailer
	,SUBSTRING(detalles,1,10) Establecimiento
 FROM Configurations.dbo.Detalle_Archivo
 WHERE id_archivo = @id 
 ) Q1

IF (@fecha_ejecucion IS NOT NULL)
BEGIN
 SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
END
ELSE IF (@cont_sumario <> @contfilas_sumario)
BEGIN
 SET @motivo_rechazo = 'La cantidad de notas de cargo no son coincidentes';
END
ELSE IF (@monto_sumcargo <> @monto_notacargo)
BEGIN
 SET @motivo_rechazo = 'La sumatoria de las notas de cargo no son coincidentes';
END
ELSE IF (@conttag_cabecera <> @conttag_trailer)
BEGIN
 SET @motivo_rechazo = 'La cantidad de reg.de cabecera/trailer no son coincidentes';
END
ELSE IF(@conttag_trailer <> @cont_establecimiento)
BEGIN
	SET @motivo_rechazo = 'Debe existir un reg.de cabecera/cierre por cada establecimiento';
END
ELSE IF (@cont_trailer <> @contfilas_trailer)
BEGIN
 SET @motivo_rechazo = 'La cantidad de reg.del archivo no coincide con la cant.definida en el trailer';
END
ELSE
BEGIN
	SELECT 
	@id_medio_pago = mp.id_medio_pago, 
	@nro_comercio = mp.nro_comercio, 
	@id_moneda = mmp.id_moneda 
	FROM medio_de_pago mp
	INNER JOIN Configurations.dbo.Moneda_Medio_Pago mmp 
	ON mp.id_medio_pago = mmp.id_medio_pago
	WHERE (mp.codigo = @cod_medio_pago
	AND mp.flag_habilitado > 0)
	AND mmp.moneda_mp_conciliacion = @cod_moneda;

	INSERT INTO @info_amex (
	 TipoReg
	 ,CodigoAjuste
	 ,TotalCargoCuotas
	 ,Importe
	 ,CantidadCuotas
	 ,FechaMovimiento
	 ,FechaPago
	 ,ValidacionResultadoMov
	 ,NroCupon
	 ,NroTarjeta
	 ,ImpServNotaCargo
	 ,ImpDescAjuste
	 ,ImpAcelAjuste
	 ,NroAutorizacion
	 ,CampoMP1
	 ,Valor1
	 ,CampoMP2
	 ,Valor2
	 ,CampoMP3
	 ,Valor3	 
	 )
	SELECT SUBSTRING(detalles, 45, 1)	 
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '5' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[15]', 'VARCHAR(10)')
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(16,2)') / 100
	   ELSE NULL END)	 
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(16,2)') / 100)
	   ELSE ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'DECIMAL(16,2)') / 100) END)
	 ,(CASE WHEN SUBSTRING(detalles,45,1) = '4' THEN CAST(CONVERT(xml,'<amex><t>' + REPLACE(detalles,',','</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[15]','INT')
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[8]', 'DATETIME')
	   ELSE NULL END)
	 ,CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[2]', 'DATETIME')	 
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CONCAT ('ACCR,',CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[17]', 'VARCHAR(2)'),';')
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'INT')
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[11]', 'NVARCHAR(50)')
	   ELSE CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[14]', 'NVARCHAR(50)') END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[22]', 'DECIMAL(16,2)') / 100
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '5' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[10]', 'DECIMAL(16,2)') / 100
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '5' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(16,2)') / 100
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles, 45, 1) = '4' THEN CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[10]', 'VARCHAR(8)')
	   ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles,45,1) = '4' THEN 'ACCR' ELSE NULL END)
	 ,(CASE WHEN SUBSTRING(detalles,45,1) = '4' THEN CAST(CONVERT(xml,'<amex><t>' + REPLACE(detalles,',','</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[17]','VARCHAR(2)')
	   ELSE NULL END)
	 ,'0'
	 ,'0'
	 ,'0'
	 ,'0'
	FROM Configurations.dbo.Detalle_Archivo
	WHERE id_archivo = @id AND SUBSTRING(detalles, 45, 1) IN ('4','5');

	UPDATE inf
	SET
		TipoImpuesto = (CASE WHEN inf.TipoReg = '5' THEN (SELECT tipo_impuesto FROM Configurations.dbo.Ajuste_Amex WHERE codigo = inf.CodigoAjuste)	ELSE NULL END),
		CantidadCuotas = (CASE WHEN inf.TipoReg = '4' THEN IIF(inf.CantidadCuotas=0,1,inf.CantidadCuotas) ELSE NULL END)
	FROM @info_amex inf;

	SELECT TOP(1) @ValidacionResultadoMov = ValidacionResultadoMov,
				  @CampoMP1 = CampoMP1,
				  @Valor1 = Valor1 
	FROM @info_amex inf WHERE TipoReg = '4' ORDER BY Id DESC;
	
	UPDATE inf
	  SET ValidacionResultadoMov = @ValidacionResultadoMov,
		  CampoMP1 = @CampoMP1,
		  Valor1 = @Valor1
	FROM @info_amex inf
	WHERE inf.TipoReg = '5';

	SELECT @formato_parametro = ccn.formato_parametro, 
		   @pos_inicial_mascara = ccn.pos_inicial_mascara, 
		   @cantidad_pos_mascara = ccn.cantidad_pos_mascara       
	FROM Configurations.dbo.Configuracion_Conciliacion ccn 
	WHERE ccn.id_medio_pago = @id_medio_pago;

	UPDATE inf
	SET IdCodOp = (CASE WHEN inf.TipoReg = '5' AND inf.TipoImpuesto = 'contracargo' THEN 2 
				   WHEN inf.TotalCargoCuotas >= 0 THEN 1 ELSE 3 END),
		NroTarjeta = REPLACE(inf.NroTarjeta,'*','')
	FROM @info_amex inf;

	UPDATE inf
	 SET SignoImporte = (SELECT signo FROM Configurations.dbo.Codigo_Operacion WHERE id_codigo_operacion = inf.IdCodOp),
	 HashNroTarjeta = (CASE WHEN @formato_parametro = 'mask' THEN CAST(NULL AS VARCHAR(80)) ELSE CAST(NULL AS VARCHAR(80)) END),
	 MaskNroTarjeta = IIF(@formato_parametro <> 'mask',NULL,inf.NroTarjeta),
	 CargosMarcaPorMovimiento = (CASE WHEN inf.TipoReg = '4' THEN ABS(ImpServNotaCargo) ELSE ABS(ImpDescAjuste+ImpAcelAjuste) END)
	FROM @info_amex inf;

	UPDATE inf
	 SET SignoCargosMarcaPorMovimiento = (CASE WHEN inf.CargosMarcaPorMovimiento >= 0 THEN '+' ELSE '-' END)
	FROM @info_amex inf;	

	--Movimiento_Presentado_MP
	INSERT INTO Configurations.dbo.Movimiento_Presentado_MP (
	 importe
	 ,signo_importe
	 ,moneda
	 ,cantidad_cuotas
	 ,nro_tarjeta
	 ,fecha_movimiento
	 ,nro_autorizacion
	 ,nro_cupon
	 ,nro_agrupador_boton
	 ,cargos_marca_por_movimiento
	 ,signo_cargos_marca_por_movimiento
	 ,id_log_paso
	 ,id_medio_pago
	 ,id_codigo_operacion
	 ,fecha_pago
	 ,nro_lote
	 ,validacion_resultado_mov
	 ,fecha_alta
	 ,usuario_alta
	 ,version
	 ,mask_nro_tarjeta
	 ,campo_mp_1
	 ,valor_1
	 ,campo_mp_2
	 ,valor_2
	 ,campo_mp_3
	 ,valor_3
	 )
	SELECT Importe
	 ,SignoImporte
	 ,@id_moneda
	 ,CantidadCuotas
	 ,NroTarjeta
	 ,FechaMovimiento
	 ,NroAutorizacion
	 ,NroCupon
	 ,@nro_comercio
	 ,CargosMarcaPorMovimiento
	 ,SignoCargosMarcaPorMovimiento
	 ,@id_log_paso
	 ,@id_medio_pago
	 ,IdCodOp
	 ,FechaPago
	 ,NroLote
	 ,ValidacionResultadoMov
	 ,GETDATE()
	 ,'bpbatch'
	 ,0
	 ,MaskNroTarjeta
	 ,CampoMP1
	 ,Valor1
	 ,CampoMP2
	 ,Valor2
	 ,CampoMP3
	 ,Valor3
	FROM @info_amex 
	WHERE TipoReg = 4 OR (TipoReg = 5 AND TipoImpuesto NOT IN('C','R','O','P'));

	--Impuesto_General_MP
	INSERT INTO Configurations.dbo.Impuesto_General_MP
        (fecha_pago_desde
        ,fecha_pago_hasta
        ,percepciones
        ,retenciones
        ,cargos
        ,otros_impuestos
        ,id_medio_pago
        ,id_log_paso
        ,fecha_alta
        ,usuario_alta
        ,version
        ,solo_impuestos)
	SELECT 
	  Q1.FechaPago
	 ,Q1.FechaPago
	 ,SUM(Q1.P)
	 ,SUM(Q1.R)
	 ,SUM(Q1.C)
	 ,SUM(Q1.O)
	 ,Q1.IdMedioPago
	 ,@id_log_paso 
	 ,GETDATE()
	 ,'bpbatch'
	 ,0
	 ,1 
	FROM ( 
	 SELECT @id_medio_pago AS IdMedioPago
	  ,( CASE WHEN imx.tipo_impuesto = 'C'THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(15,2)') / 100)
		ELSE 0 END) 'C'
	  ,(CASE WHEN imx.tipo_impuesto = 'R'THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(15,2)') / 100)
		ELSE 0 END) 'R'
	  ,CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[2]', 'CHAR(8)') 'FechaPago'
	  ,(CASE WHEN imx.tipo_impuesto = 'P' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(15,2)') / 100)
		ELSE 0 END) 'P'
	  ,(CASE WHEN imx.tipo_impuesto = 'O' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[12]', 'DECIMAL(15,2)') / 100)
		ELSE 0 END) 'O' --Otros
	 FROM Configurations.dbo.Detalle_Archivo
	 INNER JOIN Configurations.dbo.Impuesto_Amex imx ON imx.EpaTaxType = CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[7]', 'INT')
	 WHERE id_archivo = @id AND SUBSTRING(detalles, 45, 1) = '2' 
	 UNION ALL 
	 SELECT @id_medio_pago AS IdMedioPago
	  ,(CASE WHEN amx.tipo_impuesto = 'C' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'DECIMAL(16,2)') / 100)
		ELSE 0 END) 'C'
	  ,(CASE WHEN amx.tipo_impuesto = 'R' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'DECIMAL(16,2)') / 100)
		ELSE 0 END) 'R'
	  ,CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[2]', 'CHAR(8)') 'FechaPago'
	  ,(CASE WHEN amx.tipo_impuesto = 'P' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'DECIMAL(16,2)') / 100)
		ELSE 0 END) 'P'
	  ,(CASE WHEN amx.tipo_impuesto = 'O' THEN ABS(CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[9]', 'DECIMAL(16,2)') / 100)
		ELSE 0 END) 'O'
	 FROM Configurations.dbo.Detalle_Archivo
	 INNER JOIN Configurations.dbo.Ajuste_Amex amx ON amx.codigo = CAST(CONVERT(XML, '<amex><t>' + REPLACE(detalles, ',', '</t><t>') + '</t></amex>') AS XML).value('(/amex/t)[15]', 'VARCHAR(10)')
	 WHERE id_archivo = @id AND SUBSTRING(detalles, 45, 1) = '5'
	 ) Q1
	GROUP BY Q1.FechaPago,Q1.IdMedioPago;

  SELECT	
	@importe_procesados = SUM(CASE WHEN SignoImporte = '-' THEN importe * -1 ELSE importe END),
	@registros_procesados = COUNT(1)
  FROM @info_amex
  WHERE TipoReg = 4 OR (TipoReg = 5 AND TipoImpuesto NOT IN('C','R','O','P'));

  SET @resultado_proceso = 1;
END;--else

UPDATE Configurations.dbo.Archivo_Conciliacion
SET flag_procesado = 1
WHERE id = @id;

EXEC Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso
 ,@archivo_entrada
 ,NULL
 ,@resultado_proceso
 ,@motivo_rechazo
 ,@registros_procesados
 ,@importe_procesados
 ,0
 ,0
 ,0
 ,0
 ,0
 ,0
 ,'bpbatch';


 COMMIT TRANSACTION;

 RETURN 1;
END TRY

BEGIN CATCH
 IF (@@TRANCOUNT > 0)
  ROLLBACK TRANSACTION;

 THROW;
END CATCH;
