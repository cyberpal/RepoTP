
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Fecha_Cashout] (
	@CreateTimestamp DATETIME,
	@LocationIdentification INT,
	@ProductIdentification INT,
	@FacilitiesPayments INT,
	@PaymentTimestamp DATETIME,
	@CashoutTimestamp DATETIME OUTPUT
	)
AS
DECLARE @tmp_codigo VARCHAR(20);
DECLARE @plazo_liberacion INT;
DECLARE @plazo_liberacion_cuotas INT;
DECLARE @plazo INT;
DECLARE @fecha_desde DATETIME;

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Obtener Plazo de Liberación por Cuenta y Tipo de Medio de Pago
		SELECT @tmp_codigo = tmp.codigo,
			@plazo_liberacion = pln.plazo_liberacion,
			@plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas
		FROM Configurations.dbo.Plazo_Liberacion pln
		INNER JOIN Configurations.dbo.Medio_De_Pago mdp
			ON pln.id_tipo_medio_pago = mdp.id_tipo_medio_pago
		INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp
			ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
		WHERE mdp.flag_habilitado > 0
			AND pln.id_cuenta = @LocationIdentification
			AND mdp.id_medio_pago = @ProductIdentification
			AND pln.fecha_alta <= @CreateTimestamp
			AND (
				pln.fecha_baja >= @CreateTimestamp
				OR pln.fecha_baja IS NULL
				);

		-- Si no se encontró, obtener Plazo de Liberación por Tipo y Grupo de Rubro de la Cuenta y Tipo de Medio de Pago
		IF (@tmp_codigo IS NULL)
			SELECT @tmp_codigo = tmp.codigo,
				@plazo_liberacion = pln.plazo_liberacion,
				@plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas
			FROM Configurations.dbo.Cuenta cta
			INNER JOIN Configurations.dbo.Actividad_Cuenta AS aca
				ON cta.id_cuenta = aca.id_cuenta
			INNER JOIN Configurations.dbo.Rubro_GrupoRubro AS rgo
				ON aca.id_rubro = rgo.id_rubro
			INNER JOIN Configurations.dbo.Plazo_Liberacion AS pln
				ON pln.id_tipo_cuenta = cta.id_tipo_cuenta
					AND pln.id_grupo_rubro = rgo.id_grupo_rubro
			INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp
				ON tmp.id_tipo_medio_pago = pln.id_tipo_medio_pago
			INNER JOIN Configurations.dbo.Medio_De_Pago AS mdp
				ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
			WHERE cta.id_cuenta = @LocationIdentification
				AND aca.flag_vigente = 1
				AND mdp.id_medio_pago = @ProductIdentification
				AND mdp.flag_habilitado > 0
				AND pln.fecha_alta <= @CreateTimestamp
				AND (
					pln.fecha_baja >= @CreateTimestamp
					OR pln.fecha_baja IS NULL
					);

		-- Si no se encontró, obtener Plazo de Liberación por Tipo de Cuenta y Tipo de Medio de Pago
		IF (@tmp_codigo IS NULL)
			SELECT @tmp_codigo = tmp.codigo,
				@plazo_liberacion = pln.plazo_liberacion,
				@plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas
			FROM Configurations.dbo.Plazo_Liberacion pln
			INNER JOIN Configurations.dbo.Medio_De_Pago mdp
				ON pln.id_tipo_medio_pago = mdp.id_tipo_medio_pago
			INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp
				ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
			INNER JOIN Configurations.dbo.Cuenta cta
				ON pln.id_tipo_cuenta = cta.id_tipo_cuenta
			WHERE mdp.flag_habilitado > 0
				AND cta.id_cuenta = @LocationIdentification
				AND mdp.id_medio_pago = @ProductIdentification
				AND pln.fecha_alta <= @CreateTimestamp
				AND (
					pln.fecha_baja >= @CreateTimestamp
					OR pln.fecha_baja IS NULL
					);

		IF (@FacilitiesPayments = 1)
			SET @plazo = @plazo_liberacion;
		ELSE
			SET @plazo = @plazo_liberacion_cuotas;

		IF (@tmp_codigo = 'EFECTIVO')
			SET @fecha_desde = @PaymentTimestamp;
		ELSE
			SET @fecha_desde = @CreateTimestamp;

		WITH Dias_Habiles (
			dia_habil,
			nro_fila
			)
		AS (
			SELECT CAST(fro.fecha AS DATE) AS dia_habil,
				ROW_NUMBER() OVER (
					ORDER BY fro.fecha
					) AS nro_fila
			FROM Configurations.dbo.Feriados fro
			WHERE fro.esFeriado = 0
				AND fro.habilitado = 1
			)
		SELECT @CashoutTimestamp = DATETIMEFROMPARTS(DATEPART(yyyy, dia_habil), DATEPART(mm, dia_habil), DATEPART(dd, dia_habil), DATEPART(hh, @fecha_desde), DATEPART(mi, @fecha_desde), DATEPART(ss, @fecha_desde), DATEPART(ms, @fecha_desde))
		FROM Dias_Habiles
		WHERE nro_fila = (
				SELECT TOP 1 nro_fila + @plazo
				FROM Dias_Habiles
				WHERE dia_habil <= CAST(@fecha_desde AS DATE)
				ORDER BY dia_habil DESC
				);

		RETURN 1;
	END TRY

	BEGIN CATCH
		RETURN 0;
	END CATCH
END
