
CREATE PROCEDURE [dbo].[Batch_Concil_Actualizar_distribucion](
@usuario varchar(50)

)
AS
SET NOCOUNT ON;

DECLARE @msg VARCHAR(max);
DECLARE @id_distribucion INT;
DECLARE @QUERY nvarchar(3501);
DECLARE @i int = 1;
DECLARE @count int = 0;
DECLARE @variable nvarchar(200);
DECLARE @variable_2 nvarchar(200);
DECLARE @id_medio_pago varchar(20);
DECLARE @codigoMedioPago varchar(50);
CREATE TABLE #MediosDePago (Id int identity(1,1), codigo varchar(50))


				BEGIN TRY
							-- Limpio la tabla temporal	
								TRUNCATE TABLE Distribucion_tmp;
							-- *** Cargo los medios de pago *** 

							INSERT INTO #MediosDePago (codigo)
							SELECT codigo FROM Configurations.dbo.Medio_de_pago
							WHERE flag_habilitado > 0


SET @count = ( SELECT count(*) FROM #MediosDePago );

BEGIN TRANSACTION;
								-- ** Ejecuto la query para cada medio encontrado **
	WHILE @i <= @count
BEGIN

		SET @codigoMedioPago = (SELECT codigo FROM #MediosDePago WHERE Id = @i )

		SELECT  @id_medio_pago = id_medio_pago 
		FROM    configurations.dbo.Medio_De_Pago  
		WHERE   codigo = @codigoMedioPago 

		

			if (@id_medio_pago = '500' OR @id_medio_pago = '501' )
		BEGIN
			SET @variable = ' AND 1 = 1';
			SET @variable_2 = ' AND 2 = 2';
		END
			else
		BEGIN
			SET @variable = ' AND ig.solo_impuestos = 1';
			SET @variable_2 = ' AND CAST(mpp.fecha_pago AS DATE) BETWEEN CAST(ig.fecha_pago_desde AS DATE) AND CAST(ig.fecha_pago_hasta AS DATE)';
		END

-- Obtengo los registros a distribuir.
	
SET @QUERY =	N'	INSERT INTO Configurations.dbo.Distribucion_tmp    
				   (id_transaccion, tipo, VACIO, PAGOS, id_cuenta, BCRA_cuenta, BCRA_emisor_tarjeta, signo_importe,
				   importe, cargo_marca, cargo_boton, impuesto_boton, fecha_liberacion_cashout,
				   flag_esperando_impuestos_generales_de_marca, id_impuesto_general, total_id_ig, id_medio_pago )	
		  		
					SELECT m.id_transaccion, m.tipo, 1, 0, m.id_cuenta, m.BCRA_cuenta, m.BCRA_emisor_tarjeta, m.signo_importe,
					CAST((CASE WHEN RTRIM(LTRIM(m.signo_importe)) = ''-'' THEN (m.importe * -1)ELSE m.importe END) AS DECIMAL(12,2)),
					CAST((CASE WHEN RTRIM(LTRIM(m.signo_cargo_marca)) = ''-'' THEN (m.cargo_marca * -1)ELSE m.cargo_marca END) AS DECIMAL(12,2)), 
					m.cargo_boton, m.impuesto_boton, m.fecha_liberacion_cashout, m.flag_esperando_impuestos_generales_de_marca,
					ig.id_impuesto_general,
				   (ig.percepciones+ig.retenciones+ig.cargos+ig.otros_impuestos) ,
				   ' + @id_medio_pago + '
   					FROM Configurations.dbo.Distribucion d 
					INNER JOIN Configurations.dbo.Movimientos_a_distribuir m ON d.id_transaccion = m.id_transaccion
					INNER JOIN dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = m.id_movimiento_mp
					INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago 
					LEFT JOIN dbo.Impuesto_General_MP ig  ON ig.id_medio_pago = mdp.id_medio_pago
					WHERE d.flag_procesado = 0 AND d.fecha_distribucion IS NULL AND ig.solo_impuestos = 1
					AND CAST(mpp.fecha_pago AS DATE) BETWEEN CAST(ig.fecha_pago_desde AS DATE) AND CAST(ig.fecha_pago_hasta AS DATE)
					AND mdp.id_medio_pago =  ' + @id_medio_pago + '
					UNION ALL
					SELECT md.id_transaccion, md.tipo, 1, 0, md.id_cuenta, md.BCRA_cuenta, md.BCRA_emisor_tarjeta, md.signo_importe,
					CAST((CASE WHEN RTRIM(LTRIM(md.signo_importe)) = ''-'' THEN (md.importe * -1)ELSE md.importe END) AS DECIMAL(12,2)),
					CAST((CASE WHEN RTRIM(LTRIM(md.signo_cargo_marca)) = ''-'' THEN (md.cargo_marca * -1)ELSE md.cargo_marca END) AS DECIMAL(12,2)), 
					md.cargo_boton, md.impuesto_boton, md.fecha_liberacion_cashout, md.flag_esperando_impuestos_generales_de_marca,
					ig.id_impuesto_general,
				   (ig.percepciones+ig.retenciones+ig.cargos+ig.otros_impuestos) ,
				   ' + @id_medio_pago + '
					FROM Configurations.dbo.Movimientos_a_distribuir md  
					INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp  ON mpp.id_movimiento_mp = md.id_movimiento_mp
					INNER JOIN Configurations.dbo.Medio_De_Pago mdp  ON mdp.id_medio_pago = mpp.id_medio_pago
					LEFT JOIN Configurations.dbo.Impuesto_General_MP ig  ON ig.id_medio_pago = mdp.id_medio_pago 
					WHERE md.flag_esperando_impuestos_generales_de_marca = 1
					AND mdp.id_medio_pago = ' + @id_medio_pago + @variable + @variable_2
					+ 'AND NOT EXISTS	(SELECT 1 FROM Configurations.dbo.Distribucion dis  
										WHERE md.id_transaccion = dis.id_transaccion
										AND CAST(md.fecha_alta AS DATE) = CAST(fecha_alta AS DATE))';

EXEC sp_executesql @QUERY


SET @i = @i + 1;

END

drop table #MediosDePago;
COMMIT TRANSACTION;

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT @msg = 'ERROR EN QUERY';

		THROW 51000,
			@Msg,
			1;
	END CATCH;

		
BEGIN TRANSACTION;

BEGIN TRY
		
		-- Actualizar la tabla Distribucion con los movimientos a distribuir.
		
		INSERT INTO Configurations.dbo.Distribucion    
		  ([id_transaccion]
           ,[fecha_alta]
           ,[usuario_alta]     
           ,[version]
           ,[flag_procesado]
           ,[fecha_distribucion]
           )
		SELECT id_transaccion, GETDATE(), @usuario, 0 as cero, 1 as flag_procesado, GETDATE()
		FROM dbo.Distribucion_tmp 
		WHERE id_transaccion IS NOT NULL
		
		
COMMIT TRANSACTION;


	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SELECT @msg = ERROR_MESSAGE();

		THROW 51000,
			@Msg,
			1;
	END CATCH;

	RETURN 1;

