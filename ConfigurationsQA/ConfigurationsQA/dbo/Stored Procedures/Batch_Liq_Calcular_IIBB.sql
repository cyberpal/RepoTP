﻿
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_IIBB] (
	--@IdCargo INT,
	@CreateTimestamp DATETIME,
	@Amount DECIMAL(12, 2),
	@MontoTotalCargos DECIMAL(12, 2),
	@nro_iibb VARCHAR(20),
	@id_tipo_condicion_IIBB INT,
	@cod_tipo_cond_iibb_vendedor VARCHAR(20),
	@porcentaje_exclusion_IIBB DECIMAL(5, 2),
	@fecha_hasta_exclusion_IIBB DATETIME,
	@LocationIdentification INT,
	@IdImpuesto INT,
	@monto_aplicado_impuesto DECIMAL(12, 2) OUTPUT,
	@Alicuota DECIMAL(12, 2) OUTPUT,
	@AplicaAcumulacion BIT OUTPUT,
	@EstadoTope INT OUTPUT,
	@IdImpuestoTipo INT OUTPUT,
	@Monto_a_Ajustar DECIMAL(12, 2) OUTPUT
	)
AS
DECLARE @alicuota_tmp DECIMAL(12, 2) = 0;
DECLARE @base_de_calculo DECIMAL(12, 2) = 0;
DECLARE @tipo_aplicacion VARCHAR(20) = NULL;
DECLARE @tipo_base_de_calculo VARCHAR(20) = NULL;
DECLARE @tipo_periodo VARCHAR(20) = NULL;
DECLARE @errMsg VARCHAR(255) = NULL;
DECLARE @nombreSP VARCHAR(50) = 'Batch_Liq_Calcular_IIBB';
DECLARE @minimo_no_imponible DECIMAL(12, 2)
DECLARE @cantidad_no_imponible INT;
DECLARE @cantidad_ac_tx INT;
DECLARE @importe_total_ac_tx DECIMAL(12, 2);
DECLARE @fecha_desde DATETIME;
DECLARE @fecha_hasta DATETIME;
DECLARE @ret_code INT = 1;--sin errores
DECLARE @flag_supera_tope BIT;
DECLARE @estado_tope INT = 0;-- -1 (deshabilitado/cuando se aplica la 1ra vez se deshabilita) - 0 (no superado) - 1 (superado)
DECLARE @tipo_calculo INT = 0;-- 0 (sin calculo) - 1 (calcula solo impuesto) - 2 (calcula impuesto + retencion)
DECLARE @id_impuesto_tipo INT;
DECLARE @cant_filas INT;

SET NOCOUNT ON;

BEGIN TRY
	/*
 PRINT 'test Batch_Liq_Calcular_IIBB'
 PRINT '**@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL') + '**';
 PRINT '@IdImpuesto = ' + ISNULL(CAST(@IdImpuesto AS VARCHAR(20)), 'NULL');
 */
	IF (@cod_tipo_cond_iibb_vendedor = 'IIBB_EXENTO')
	BEGIN
		SET @errMsg = @nombreSP + ' - ' + 'El vendedor se encuentra exento para el impuesto de IIBB';

		THROW 51000,
			@errMsg,
			1;
	END;

	--PRINT '@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL');
	--print '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
	IF (@nro_iibb IS NOT NULL)
	BEGIN
		-- Buscar configuración por Jurisdicción
		SELECT @alicuota_tmp = ipo.alicuota,
			@tipo_aplicacion = tpo1.codigo,
			@tipo_base_de_calculo = tpo2.codigo,
			@tipo_periodo = tpo3.codigo,
			@minimo_no_imponible = ipo.minimo_no_imponible,
			@cantidad_no_imponible = ipo.cantidad_no_imponible,
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
		WHERE ipo.id_impuesto = @IdImpuesto
			AND ipo.flag_estado = 1
			AND ipo.id_tipo = @id_tipo_condicion_IIBB
			AND jib.codigo = LEFT(@nro_iibb, 3)
			AND CAST(ipo.fecha_vigencia_inicio AS DATE) <= CAST(@CreateTimestamp AS DATE)
			AND (
				ipo.fecha_vigencia_fin IS NULL
				OR CAST(ipo.fecha_vigencia_fin AS DATE) >= CAST(@CreateTimestamp AS DATE)
				);

		-- Si no se encontró información por Jurisdicción, entonces buscar por tipo de condición de IIBB
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
				AND ipt.id_impuesto = @IdImpuesto;


	END
	ELSE --@nro_iibb = NULL
	BEGIN
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
		WHERE ipo.id_impuesto = @IdImpuesto
			AND ipo.id_tipo IS NULL
			AND ipo.flag_estado = 1
			AND CAST(ipo.fecha_vigencia_inicio AS DATE) <= CAST(@CreateTimestamp AS DATE)
			AND (
				ipo.fecha_vigencia_fin IS NULL
				OR CAST(ipo.fecha_vigencia_fin AS DATE) >= CAST(@CreateTimestamp AS DATE)
				);
			/*
	PRINT '@tipo_aplicacion 2= ' + ISNULL(CAST(@tipo_aplicacion AS VARCHAR(20)), 'NULL');
	PRINT '@id_impuesto_tipo = ' + ISNULL(CAST(@id_impuesto_tipo AS VARCHAR(20)), 'NULL');
	PRINT '@CreateTimestamp = ' + ISNULL(CAST(@CreateTimestamp AS VARCHAR(20)), 'NULL');
	*/
	END;

	/*
	PRINT '@nro_iibb = ' + ISNULL(CAST(@nro_iibb AS VARCHAR(20)), 'NULL');
	PRINT '@IdImpuesto = ' + ISNULL(CAST(@IdImpuesto AS VARCHAR(20)), 'NULL');
	PRINT '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
	PRINT '@alicuota_tmp = ' + ISNULL(CAST(@alicuota_tmp AS VARCHAR(20)), 'NULL');
	*/
	IF (@alicuota_tmp IS NULL)
	BEGIN
		SET @errMsg = @nombreSP + ' - ' + 'El valor de alícuota es Nulo (@alicuota_tmp)';

		THROW 51000,
			@errMsg,
			1;
	END;

	IF (@tipo_aplicacion IS NULL)
	BEGIN
		SET @errMsg = @nombreSP + ' - ' + 'El valor del tipo de aplicación es Nulo (@tipo_aplicacion)';

		THROW 51000,
			@errMsg,
			1;
	END;

	IF (@base_de_calculo IS NULL)
	BEGIN
		SET @errMsg = @nombreSP + ' - ' + 'El valor de la base de cálculo es Nulo (@base_de_calculo)';

		THROW 51000,
			@errMsg,
			1;
	END;

	--Evaluar si aplica acumulacion
	IF (@tipo_periodo = 'POR_CICLO')
	BEGIN --3
		--validar minimo imponible
		SELECT @cantidad_ac_tx = apo.cantidad_tx,
			@importe_total_ac_tx = apo.importe_total_tx,
			@fecha_desde = apo.fecha_desde,
			@fecha_hasta = apo.fecha_hasta,
			@flag_supera_tope = apo.flag_supera_tope
		FROM Configurations.dbo.Acumulador_Impuesto apo
		WHERE apo.id_cuenta = @LocationIdentification
			AND apo.id_impuesto = @IdImpuesto
			AND (CAST(apo.fecha_desde AS DATE) <= CAST(@CreateTimestamp AS DATE))
			AND (CAST(apo.fecha_hasta AS DATE) >= CAST(@CreateTimestamp AS DATE));

		SET @cantidad_ac_tx = ISNULL(@cantidad_ac_tx, 0);
		SET @importe_total_ac_tx = ISNULL(@importe_total_ac_tx, 0);

		--test
		--PRINT '@cantidad_ac_tx = ' + ISNULL(CAST(@cantidad_ac_tx AS VARCHAR(20)), 'NULL');
		--PRINT '@importe_total_ac_tx = ' + ISNULL(CAST(@importe_total_ac_tx AS VARCHAR(20)), 'NULL');
		--PRINT '@flag_supera_tope = ' + ISNULL(CAST(@flag_supera_tope AS VARCHAR(20)), 'NULL');
		--print ' '

		IF (
				@flag_supera_tope IS NULL
				OR @flag_supera_tope = 0
				)
			SET @estado_tope = 0;--no superado
		ELSE IF (@flag_supera_tope = 1)
			SET @estado_tope = - 1;--deshabilitado (ya se aplico anteriormente)	

		--tope alcanzado previamente / se aplica solo la 1ra vez
		IF (@estado_tope = - 1) --deshabilitado 
			SET @tipo_calculo = 1;--calcula solo impuesto
		ELSE IF (@estado_tope = 0) --no superado
		BEGIN
			--evaluar tope de exencion
			--si se inserta un nvo.reg.en el acumulador, solo se evalua Amount
			IF (
					(@importe_total_ac_tx + @Amount) >= @minimo_no_imponible
					AND (@cantidad_ac_tx + 1) >= @cantidad_no_imponible
					)
			BEGIN
				SET @estado_tope = 1;--superado
				SET @tipo_calculo = 1;--calcula solo impuesto
			END
			ELSE
				SET @tipo_calculo = 2;--tope no superado (calcula impuesto + retencion)
		END;
	END;--3

	--test
	--PRINT '@tipo_calculo = ' + ISNULL(CAST(@tipo_calculo AS VARCHAR(20)), 'NULL');
	--PRINT '@tipo_aplicacion = ' + ISNULL(CAST(@tipo_aplicacion AS VARCHAR(20)), 'NULL');
	--PRINT '@tipo_periodo = ' + ISNULL(CAST(@tipo_periodo AS VARCHAR(20)), 'NULL');
	IF (@tipo_calculo > 0) --impuesto / retencion
	BEGIN
		--Efectuar calculo
		IF (@tipo_aplicacion = 'AP_FIJO')
		BEGIN --2
			SET @monto_aplicado_impuesto = @alicuota_tmp;
		END --2
		ELSE IF (@tipo_aplicacion = 'AP_PORCENTAJE')
		BEGIN --2
			--calcular porcentaje exclusion - si excepcion NO esta vigente -> @porcentaje_exclusion_IIBB = 0 (no aplica)   
			SET @porcentaje_exclusion_IIBB = ISNULL(@porcentaje_exclusion_IIBB, 0);
			--SET @porcentaje_exclusion_IIBB = IIF(CAST(@fecha_hasta_exclusion_IIBB AS DATE) >= CAST(@CreateTimestamp AS DATE), @porcentaje_exclusion_IIBB, 0);
			SET @porcentaje_exclusion_IIBB = IIF(@fecha_hasta_exclusion_IIBB IS NULL
					OR (CAST(@fecha_hasta_exclusion_IIBB AS DATE) >= CAST(@CreateTimestamp AS DATE)), @porcentaje_exclusion_IIBB, 0);
			SET @alicuota_tmp = (100 - @porcentaje_exclusion_IIBB) * @alicuota_tmp / 100;

			IF (@tipo_base_de_calculo = 'MONTO_TX')
				SET @base_de_calculo = @Amount;
			ELSE IF (@tipo_base_de_calculo = 'MONTO_TX_SIN_CARGOS')
				SET @base_de_calculo = @Amount - @MontoTotalCargos;
			ELSE IF (@tipo_base_de_calculo = 'CARGOS')
				SET @base_de_calculo = @MontoTotalCargos;
			SET @monto_aplicado_impuesto = (@alicuota_tmp / 100) * @base_de_calculo;
				--SET @MontoCalculadoRetencion = IIF(@tipo_calculo = 2, @monto_aplicado_impuesto, 0);
				--test
				/*
   PRINT ' '
   PRINT 'Final del Batch_Liq_Calcular_IIBB'
   PRINT '@CreateTimestamp = ' + ISNULL(CAST(@CreateTimestamp AS VARCHAR(20)), 'NULL');
   PRINT '@fecha_hasta_exclusion_IIBB = ' + ISNULL(CAST(@fecha_hasta_exclusion_IIBB AS VARCHAR(20)), 'NULL');
   PRINT '@porcentaje_exclusion_IIBB = ' + ISNULL(CAST(@porcentaje_exclusion_IIBB AS VARCHAR(20)), 'NULL');
   PRINT '@tipo_base_de_calculo = ' + ISNULL(CAST(@tipo_base_de_calculo AS VARCHAR(20)), 'NULL');
   PRINT '@base_de_calculo = ' + ISNULL(CAST(@base_de_calculo AS VARCHAR(20)), 'NULL');
   PRINT '@alicuota_tmp = ' + ISNULL(CAST(@alicuota_tmp AS VARCHAR(20)), 'NULL');
   PRINT '@Amount = ' + ISNULL(CAST(@Amount AS VARCHAR(20)), 'NULL');
   PRINT '@monto_aplicado_impuesto = ' + ISNULL(CAST(@monto_aplicado_impuesto AS VARCHAR(20)), 'NULL');
   PRINT '@cantidad_no_imponible = ' + ISNULL(CAST(@cantidad_no_imponible AS VARCHAR(20)), 'NULL');
   PRINT '@minimo_no_imponible = ' + ISNULL(CAST(@minimo_no_imponible AS VARCHAR(20)), 'NULL');
   PRINT '@importe_total_ac_tx = ' + ISNULL(CAST(@importe_total_ac_tx AS VARCHAR(20)), 'NULL');
   PRINT '@cantidad_ac_tx = ' + ISNULL(CAST(@cantidad_ac_tx AS VARCHAR(20)), 'NULL');
   PRINT '@estado_tope = ' + ISNULL(CAST(@estado_tope AS VARCHAR(20)), 'NULL');
   PRINT '@id_tipo_condicion_IIBB = ' + ISNULL(CAST(@id_tipo_condicion_IIBB AS VARCHAR(20)), 'NULL');
   PRINT '@id_impuesto_tipo = ' + ISNULL(CAST(@id_impuesto_tipo AS VARCHAR(20)), 'NULL');
  */
		END;--2
	END;

	SET @Alicuota = @alicuota_tmp;
	SET @AplicaAcumulacion = IIF(@tipo_periodo = 'POR_CICLO', 1, 0);
	SET @EstadoTope = @estado_tope;
	SET @IdImpuestoTipo = @id_impuesto_tipo;
END TRY

BEGIN CATCH
	SET @ret_code = 0;

	PRINT @errMsg;
END CATCH;

RETURN @ret_code;

