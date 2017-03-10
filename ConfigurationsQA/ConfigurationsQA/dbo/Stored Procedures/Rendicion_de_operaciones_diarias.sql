
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- Projecto:		TodoPago
-- Objeto:		PROCEDURE dbo.Rendicion_de_operaciones_diarias
-- Autor:		Alberto Martins
-- Descripcion:	
--				SP para crear un reporte de  “Rendiciones de operaciones (transacciones)” 
--				con las siguientes características:

--				1.	La información del reporte será tomada de la BD transactions.
--				2.	Por cada comercio se generará un reporte de operaciones diario.
--				3.	El reporte se ejecutará de manera automática (batch) 
--					únicamente si se activó la opcion en el panel de Todo Pago, para ese comercio
--				4.  Se ejecutara de Lunes a Viernes excepto que sea feriado
--				5.  Incluirá las operaciones desde el ultimo dia habil anterior a la fecha de proceso
--					hasta el dia anterior a la fecha de proceso 
--	Historial de cambios:
--
--  21-02-2017  Version 1.2	Se agrega el campo “IVA del Precio del Servicio”
--  15-02-2017	Version 1.0
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


CREATE PROCEDURE dbo.Rendicion_de_operaciones_diarias
	 @fecha datetime = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @fechaDesde datetime;
	DECLARE @fechaHasta datetime;
	DECLARE @ayer		datetime;
	DECLARE @fechaUltimaEjecucion datetime;
	DECLARE @FechaProceso datetime;
	DECLARE @diaSemana  int;
	DECLARE @nroDia		int;
	DECLARE @esFeriado	bit;
	DECLARE @id_log_proceso INT;
	DECLARE @id_proceso INT;
	DECLARE @flag_ok INT = 1;
	DECLARE @rowCount INT;
	DECLARE @ayerCorrio BIT;
	DECLARE @id_impuestoIVA INT = (SELECT id_impuesto FROM dbo.Impuesto WHERE codigo ='IVA');
	DECLARE @Dias_Habiles TABLE (fecha datetime, diaSemana int, esFeriado bit, nro_fila int);
	DECLARE @transac TABLE 
	(
		[Id] [char](36) NOT NULL,
		[CreateTimestamp] [datetime] NULL,
		[LocationIdentification] [int] NULL,
		[OperationName] [varchar](128) NULL,
		[ProductIdentification] [int] NULL,
		[FacilitiesPayments] [int] NULL,
		[CredentialHolderName] [varchar](48) NULL,
		[SaleConcept] [varchar](255) NULL,
		[ProviderTransactionID] [varchar](64) NULL,
		[Amount] [decimal](12, 2) NULL,
		[FeeAmount] [decimal](12, 2) NULL,
		[TaxAmount] [decimal](12, 2) NULL,
		[ProviderAuthorizationCode] [varchar](8) NULL,
		[CredentialMask] [varchar](20) NULL,
		[CredentialEmailAddress] [varchar](64) NULL,
		[CashoutTimestamp] [datetime] NULL,
		[TransactionStatus] [varchar](20) NULL,
		[AmountBuyer] [decimal](12, 2) NULL,
		[OriginalAmount] [decimal](12, 2) NULL,
		PRIMARY KEY CLUSTERED (	[Id] ASC )
	)
	
	SELECT @id_proceso = id_proceso FROM dbo.Proceso WHERE nombre = 'Reporte de Operaciones Diarias'

	IF @fecha IS NULL
		SET @fecha = cast(cast(GETDATE() as date) as datetime);
	ELSE
		SET @fecha = cast(cast(@fecha as date) as datetime);

	INSERT INTO @Dias_Habiles 
			SELECT	fecha, diaSemana, esFeriado,
					ROW_NUMBER() OVER (ORDER BY fecha) AS nro_fila
			FROM	dbo.Feriados (NOLOCK) 
			WHERE	habilitado = 1
			  AND   fecha > CAST(CAST(DATEADD(month,-1,GETDATE()) as DATE) as DATETIME);
			
		-- @fechaDesde = ultimo dia habil anterior a @fecha
		-- si es lunes, toma viernes sabado y domingo
		SELECT	@nroDia		= ISNULL(nro_fila,0),
				@fechaDesde	= fecha,
				@diaSemana	= diaSemana,
				@esFeriado	= esFeriado
		FROM	@Dias_Habiles 
		WHERE	fecha = @fecha;

		IF @esFeriado = 1 -- Si @fecha es feriado no hace nada
			BEGIN
			PRINT CONCAT (CONVERT(char(10),GETDATE(), 103), '  es feriado.') 
			RETURN 0;
		END

		-- Procesa hasta ayer
		SET @ayer = DATEADD(day,-1,@fecha)

		-- @fechaDesde = @ayer o el ultimo dia habil anterior a @ayer
		-- si @fecha es lunes, toma viernes sabado y domingo
		SELECT	@nroDia		= ISNULL(nro_fila,0),
				@fechaDesde	= fecha,
				@diaSemana	= diaSemana,
				@esFeriado	= esFeriado
		FROM	@Dias_Habiles 
		WHERE	fecha = @ayer;

		WHILE 1=1 BEGIN
			--Si ayer fue feriado , bajo un dia
			IF @esFeriado = 0  
				BEGIN
					IF @fechaDesde IN (SELECT	CAST(CAST(ISNULL(fecha_fin_ejecucion, @fechaDesde) as DATE) as DATETIME)
										FROM	dbo.Log_Proceso
									   WHERE	id_proceso = @id_proceso)

						BREAK;
				END;

			SET @nroDia = @nroDia -1;
			SELECT	
					@fechaDesde	= fecha,
					@diaSemana	= diaSemana,
					@esFeriado	= esFeriado
			FROM	@Dias_Habiles 
			WHERE	nro_fila = @nroDia;
			IF @@ROWCOUNT < 1 BREAK;
		END;

		-- Iniciar Log        
		EXEC @id_log_proceso = dbo.Iniciar_Log_Proceso
				@id_proceso  = @id_proceso,
				@fecha_desde_proceso = @fechaDesde,
				@fecha_hasta_proceso = @ayer,
				@usuario = 'RSBatch';

TRUNCATE TABLE dbo.Operaciones_Diarias_tmp;

--Subconjunto de transacciones filtradas por fecha y estado
INSERT INTO @transac
			SELECT 
					[Id],
					[CreateTimestamp],
					[LocationIdentification],
					[OperationName],
					[ProductIdentification],
					[FacilitiesPayments],
					[CredentialHolderName],
					[SaleConcept],
					[ProviderTransactionID],
					[Amount],
					[FeeAmount],
					[TaxAmount],
					[ProviderAuthorizationCode],
					[CredentialMask],
					[CredentialEmailAddress],
					[CashoutTimestamp],
					[TransactionStatus],
					[AmountBuyer],
					[OriginalAmount] 
			  FROM 
					Transactions.dbo.transactions
			 WHERE 
					TransactionStatus = 'TX_APROBADA'
				--TransactionStatus IN	('TX_APROBADA', 'TX_PENDIENTE')
				AND	CreateTimestamp >= @fechaDesde
				AND CreateTimestamp <  @ayer +1;

		SELECT @rowCount = COUNT(*) FROM @transac;

		IF @rowCount < 1 BEGIN
			PRINT 'No hay transacciones para procesar.';
			SET @flag_ok = 0;
			GOTO Fin
		END;


;WITH Impuestos as (	
		SELECT	I.Id_Transaccion, 
				ISNULL(SUM(I.monto_calculado), 0.00) as Calculado,
				ISNULL(SUM(I.monto_aplicado), 0.00) as Aplicado
		FROM	dbo.Impuesto_Por_Transaccion I
				INNER JOIN @transac T ON T.Id = I.id_transaccion
		WHERE	I.Id_Impuesto = @id_impuestoIVA
		GROUP BY I.Id_Transaccion )

,Retenciones as (	
		SELECT	I.Id_Transaccion, 
				ISNULL(SUM(I.monto_calculado), 0.00) as Calculado,
				ISNULL(SUM(I.monto_aplicado), 0.00) as Aplicado
		FROM	dbo.Impuesto_Por_Transaccion I
				INNER JOIN @transac T ON T.Id = I.id_transaccion
		WHERE	I.Id_Impuesto <> @id_impuestoIVA
		GROUP BY I.Id_Transaccion )

, Cargos as (
		SELECT	C.Id_Transaccion, 
				ISNULL(SUM(C.monto_calculado), 0.00) as Calculado,
				ISNULL(SUM(C.valor_aplicado), 0.00) as Aplicado
		FROM	dbo.Cargos_Por_Transaccion C
				INNER JOIN @transac T ON T.Id = C.id_transaccion
		GROUP BY C.Id_Transaccion	)


		INSERT INTO dbo.Operaciones_Diarias_tmp

		SELECT	filename = CAST(CONCAT('Operaciones_'
						, CAST(T.LocationIdentification as VARCHAR(10)), '_'
						, REPLACE(REPLACE(REPLACE(CONVERT(char(19),GETDATE(), 121),'-',''),':',''),' ','_')
						, '.csv') as VARCHAR(50))
			,	Desde					  = convert(VARCHAR(10),@fechaDesde,103)
			,	Hasta					  = convert(VARCHAR(10),@ayer,103)
			,	Cuenta					  = CAST(T.LocationIdentification as VARCHAR(10))
			,	Fecha_de_cobro			=   CAST(ISNULL(convert(VARCHAR(10),T.CreateTimestamp,103),'') as VARCHAR(10))
			,	Fecha_para_cashout 		=	CAST(ISNULL(convert(VARCHAR(10),T.CashoutTimestamp,103),'') as VARCHAR(10))
			,	ID_de_operacion			=	CAST(T.ProviderTransactionID as VARCHAR(10))
			,	Tipo_de_movimiento 		=	CAST(T.OperationName as VARCHAR(18))	--(solo cobros)
			,	Concepto				 =	CAST(T.SaleConcept as VARCHAR(50))
			,	Cliente_email			 =	CAST(ISNULL(T.CredentialEmailAddress,'') as VARCHAR(50))
			,	Cliente_nombre_completo =	CAST(T.CredentialHolderName as VARCHAR(50))
			,	Estado 					=	CAST(T.TransactionStatus as VARCHAR(18)) 
			,	Monto_Bruto 			 =	CAST(T.Amount as VARCHAR(18))	--(+ / -)
			,	Monto_Neto 				=	CAST(T.Amount - T.FeeAmount - T.TaxAmount	as VARCHAR(18)) --(+ / -)
			,	Precio_del_servicio		=	CAST(ISNULL(C.Calculado,0.00)	 as VARCHAR(18))
			,	IVA_Precio_del_Servicio	=	CAST(ISNULL(I.Aplicado,0.00)	 as VARCHAR(18))
			,	Retenciones				=	CAST(ISNULL(R.Aplicado,0.00)	 as VARCHAR(18))	
			,	Monto_Cliente 			 =	CAST(ISNULL(T.AmountBuyer,0.00) as VARCHAR(10))
			,	Cantidad_de_cuotas		 =	CAST(T.FacilitiesPayments as VARCHAR(3))
			,	Medio_de_pago			 =	CAST(ISNULL(M.codigo,'') as VARCHAR(20))
			,	Nro_de_tarjeta 			=	CAST(CONCAT('...', right(T.CredentialMask,4)) as VARCHAR(7))	--(los últimos 4 dígitos) 
			,	Nro_de_autorizacion 	 =	CAST(ISNULL(T.ProviderAuthorizationCode,0) as VARCHAR(10))

		FROM @transac T
				LEFT JOIN Cargos					as C	ON T.Id = C.Id_Transaccion
				LEFT JOIN Impuestos					as I	ON T.Id = I.Id_Transaccion
				LEFT JOIN Retenciones				as R	ON T.Id = R.Id_Transaccion
				LEFT JOIN dbo.Medio_De_Pago			as M	ON T.ProductIdentification = M.id_medio_pago
		ORDER BY T.LocationIdentification ;

		/*-- Exportacion de archivos -----------------------------------------------------------
			El reporte se deberá almacenar en el VNET del comercio 
			con el nombre Operaciones_cuenta_aaaammdd_hhmmss.csv,  
			donde:

				aaaa : Año de generación del archivo
				mm : Mes de generación del archivo
				dd : Día de generación del archivo
				hh : Hora de generación del archivo
				mm : Minutos de generación del archivo
				ss : Segundos de generación del archivo
		*/

Fin:
		-- Completar Log de Proceso      
		EXEC  dbo.Finalizar_Log_Proceso
			 @id_log_proceso = @id_log_proceso,
			 @registros_afectados = @rowCount,
			 @usuario = 'RSBatch'

		select * FROM dbo.Operaciones_Diarias_tmp ORDER BY Cuenta;

		RETURN @flag_ok;
END;