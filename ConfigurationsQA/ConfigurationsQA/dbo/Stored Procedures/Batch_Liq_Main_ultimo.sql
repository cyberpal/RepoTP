
CREATE PROCEDURE [dbo].[Batch_Liq_Main_ultimo] (@Usuario VARCHAR(20))
AS
DECLARE @id_log_proceso INT;
DECLARE @id_tipo_movimiento INT;
DECLARE @id_tipo_origen_movimiento INT;
DECLARE @tx_count INT;
DECLARE @tx_i INT = 1;
DECLARE @Id CHAR(36);
DECLARE @CreateTimestamp DATETIME;
DECLARE @LocationIdentification INT;
DECLARE @ProductIdentification INT;
DECLARE @OperationName VARCHAR(128);
DECLARE @Amount DECIMAL(12, 2);
DECLARE @FeeAmount DECIMAL(12, 2);
DECLARE @TaxAmount DECIMAL(12, 2);
DECLARE @CashoutTimestamp DATETIME;
DECLARE @FilingDeadline DATETIME;
DECLARE @PaymentTimestamp DATETIME;
DECLARE @FacilitiesPayments INT;
DECLARE @LiquidationStatus INT;
DECLARE @LiquidationTimestamp DATETIME;
DECLARE @PromotionIdentification INT;
DECLARE @ButtonCode VARCHAR(20);
DECLARE @flag_ok INT;
DECLARE @saldo DECIMAL(12, 2);
DECLARE @fecha_base_de_cashout DATE;
DECLARE @fecha_de_cashout DATE;
DECLARE @id_codigo_operacion INT;
DECLARE @registros_afectados INT;
DECLARE @TransactionStatus VARCHAR(20);

BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		-- Iniciar Log  
		EXEC @id_log_proceso = Configurations.dbo.Iniciar_Log_Proceso 1,
			NULL,
			NULL,
			@Usuario;

		-- Obtener ID de tipo de movimiento
		SELECT @id_tipo_movimiento = tpo.id_tipo
		FROM dbo.Tipo tpo
		WHERE tpo.codigo = 'MOV_CRED'
			AND tpo.id_grupo_tipo = 16;

		-- Obtener ID de origen de movimiento
		SELECT @id_tipo_origen_movimiento = tpo.id_tipo
		FROM dbo.Tipo tpo
		WHERE tpo.codigo = 'ORIG_PROCESO'
			AND tpo.id_grupo_tipo = 17;

		-- Obtener Transacciones a Liquidar  
		EXEC @tx_count = Configurations.dbo.Batch_Liq_Obtener_Transacciones;

		-- Para cada transacción
		WHILE (@tx_i <= @tx_count)
		BEGIN
			BEGIN TRY
				-- Leer Transacción
				SELECT @Id = tmp.Id,
					@CreateTimestamp = tmp.CreateTimestamp,
					@LocationIdentification = tmp.LocationIdentification,
					@ProductIdentification = tmp.ProductIdentification,
					@OperationName = tmp.OperationName,
					@Amount = tmp.Amount,
					@FeeAmount = tmp.FeeAmount,
					@TaxAmount = tmp.TaxAmount,
					@CashoutTimestamp = tmp.CashoutTimestamp,
					@FilingDeadline = tmp.FilingDeadline,
					@PaymentTimestamp = tmp.PaymentTimestamp,
					@FacilitiesPayments = tmp.FacilitiesPayments,
					@LiquidationStatus = tmp.LiquidationStatus,
					@LiquidationTimestamp = tmp.LiquidationTimestamp,
					@PromotionIdentification = tmp.PromotionIdentification,
					@ButtonCode = tmp.ButtonCode,
					@TransactionStatus = tmp.TransactionStatus
				FROM Configurations.dbo.Liquidacion_Tmp tmp
				WHERE tmp.i = @tx_i;

				IF (@Id IS NOT NULL)
				BEGIN
					BEGIN TRANSACTION;

					SET @flag_ok = 1;
				END
				ELSE
					SET @flag_ok = 0;

				-- Si no hay error y es una Compra, calcular Cargos
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Cargos @Id,
						@CreateTimestamp,
						@LocationIdentification,
						@ProductIdentification,
						@Amount,
						@PromotionIdentification,
						@FacilitiesPayments,
						@ButtonCode,
						@Usuario,
						@FeeAmount OUTPUT;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Calcular_Cargos - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si es una Devolución detallar los Cargos calculados
				IF (
						@flag_ok = 1
						AND (
							UPPER(@OperationName) = 'DEVOLUCION'
							AND @FeeAmount IS NOT NULL
							)
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Detallar_Cargos_Devolucion @Id,
						@FeeAmount,
						@Usuario;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Detallar_Cargos_Devolucion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error y es una Compra, Acumular en Promociones                    
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						AND @PromotionIdentification IS NOT NULL
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Actualizar_Acumulador_Promociones @CreateTimestamp,
						@LocationIdentification,
						@Amount,
						@PromotionIdentification;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Actualizar_Acumulador_Promociones - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error calcular Impuestos                    
				IF (
						@flag_ok = 1
						AND
						-- Si es una Compra           
						UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Impuestos @Id,
						@CreateTimestamp,
						@LocationIdentification,
						@Usuario,
						@TaxAmount OUTPUT;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Calcular_Impuestos - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si es una Devolución                    
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) = 'DEVOLUCION'
						AND @TaxAmount IS NOT NULL
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Detallar_Impuestos_Devolucion @Id,
						@TaxAmount,
						@Usuario;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Detallar_Impuestos_Devolucion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error y es Compra, calcular Fecha de Cashout                    
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Fecha_Cashout @CreateTimestamp,
						@LocationIdentification,
						@ProductIdentification,
						@FacilitiesPayments,
						@PaymentTimestamp,
						@CashoutTimestamp OUTPUT;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Calcular_Fecha_Cashout - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error calcular Fecha Tope de Presentación                    
				IF (@flag_ok = 1)
				BEGIN
					EXEC @flag_ok = Configurations.dbo.Batch_Liq_Calcular_Fecha_Tope_Presentacion @ProductIdentification,
						@CreateTimestamp,
						@FilingDeadline OUTPUT;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Liq_Calcular_Fecha_Tope_Presentacion - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error actualizar la Transaccion en la tabla temporal                    
				IF (@flag_ok = 1)
				BEGIN
					-- Si es una Compra                    
					IF (
							UPPER(@OperationName) IN (
								'COMPRA_OFFLINE',
								'COMPRA_ONLINE'
								)
							)
					BEGIN
						UPDATE Configurations.dbo.Liquidacion_Tmp
						SET FeeAmount = @FeeAmount,
							TaxAmount = @TaxAmount,
							CashoutTimestamp = @CashoutTimestamp,
							FilingDeadline = @FilingDeadline,
							Flag_Ok = 1
						WHERE i = @tx_i;
					END;

					-- Si es una Devolución                    
					IF (UPPER(@OperationName) = 'DEVOLUCION')
					BEGIN
						UPDATE Configurations.dbo.Liquidacion_Tmp
						SET FilingDeadline = @FilingDeadline,
							Flag_Ok = 1
						WHERE i = @tx_i;
					END;
				END
				ELSE IF (@flag_ok = 0)
				BEGIN
					-- Si hay error, marcar la Transaccion en la tabla temporal                    
					UPDATE Configurations.dbo.Liquidacion_Tmp
					SET Flag_Ok = 0
					WHERE i = @tx_i;
				END;

				-- Si no hay error Actualizar Cuenta Virtual
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						)
				BEGIN
					SET @saldo = @Amount - @FeeAmount - @TaxAmount;

					EXEC @flag_ok = Configurations.dbo.Actualizar_Cuenta_Virtual NULL,
						NULL,
						@saldo,
						NULL,
						NULL,
						NULL,
						@LocationIdentification,
						@Usuario,
						@id_tipo_movimiento,
						@id_tipo_origen_movimiento,
						@id_log_proceso;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Actualizar_Cuenta_Virtual - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error Actualizar el Control de Disponible
				IF (
						@flag_ok = 1
						AND UPPER(@OperationName) IN (
							'COMPRA_OFFLINE',
							'COMPRA_ONLINE'
							)
						)
				BEGIN
					-- Obtener fechas y codigo de operación
					SELECT @fecha_base_de_cashout = CAST((
								CASE 
									WHEN tmp.codigo = 'EFECTIVO'
										THEN ltp.PaymentTimestamp
									ELSE ltp.CreateTimestamp
									END
								) AS DATE),
						@fecha_de_cashout = CAST(ltp.CashoutTimestamp AS DATE),
						@id_codigo_operacion = cop.id_codigo_operacion
					FROM Configurations.dbo.Liquidacion_Tmp ltp
					INNER JOIN Configurations.dbo.Medio_De_Pago mdp
						ON ltp.ProductIdentification = mdp.id_medio_pago
					INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp
						ON mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago
					INNER JOIN Configurations.dbo.Codigo_Operacion cop
						ON cop.codigo_operacion = (
								CASE 
									WHEN ltp.OperationName = 'devolucion'
										THEN 'DEV'
									ELSE 'COM'
									END
								)
					WHERE ltp.i = @tx_i;

					-- Actualizar
					EXEC @flag_ok = Configurations.dbo.Batch_Actualizar_Control_Liquidacion_Disponible @id_log_proceso,
						@Id,
						@fecha_base_de_cashout,
						@fecha_de_cashout,
						@LocationIdentification,
						@id_codigo_operacion,
						@saldo;

					IF (@flag_ok = 0)
					BEGIN
						PRINT 'id= ' + @Id;
						PRINT 'Batch_Actualizar_Control_Liquidacion_Disponible - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
					END;
				END;

				-- Si no hay error Actualizar transaccion
				IF (@flag_ok = 1)
				BEGIN
					UPDATE Transactions.dbo.transactions
					SET Transactions.dbo.transactions.FeeAmount = @FeeAmount,
						Transactions.dbo.transactions.TaxAmount = @TaxAmount,
						Transactions.dbo.transactions.CashoutTimestamp = @CashoutTimestamp,
						Transactions.dbo.transactions.FilingDeadline = @FilingDeadline,
						Transactions.dbo.transactions.LiquidationStatus = - 1,
						Transactions.dbo.transactions.LiquidationTimestamp = GETDATE(),
						Transactions.dbo.transactions.TransactionStatus = (
							CASE 
								WHEN UPPER(@OperationName) IN (
										'COMPRA_OFFLINE',
										'COMPRA_ONLINE'
										)
									THEN 'TX_APROBADA'
								WHEN UPPER(@OperationName) = 'DEVOLUCION'
									THEN @TransactionStatus
								END
							),
						Transactions.dbo.transactions.SyncStatus = 0
					WHERE Id = @Id;
				END;

				-- SI HAY ERROR, lanzar excepción para deshacer las modificaciones
				IF (@flag_ok = 0)
				BEGIN
					THROW 51000,
						'Error procesando la Transacción',
						1;
				END;

				COMMIT TRANSACTION;
			END TRY

			BEGIN CATCH
				PRINT ERROR_MESSAGE();

				-- Deshacer las modificaciones
				ROLLBACK TRANSACTION;

				BEGIN TRANSACTION;

				-- Marcar la Transacción como procesada con error.
				UPDATE Transactions.dbo.transactions
				SET Transactions.dbo.transactions.LiquidationStatus = Transactions.dbo.transactions.LiquidationStatus + 1,
					Transactions.dbo.transactions.SyncStatus = 0
				WHERE Id = @Id;

				COMMIT TRANSACTION;
			END CATCH;

			-- Siguiente Transacción
			SET @tx_i += 1;
		END;

		-- Contar registros afectados
		SELECT @registros_afectados = COUNT(1)
		FROM Configurations.dbo.Liquidacion_Tmp
		WHERE Flag_Ok = 1;

		-- Completar Log de Proceso
		EXEC @flag_ok = Configurations.dbo.Finalizar_Log_Proceso @id_log_proceso,
			@registros_afectados,
			@Usuario;

		RETURN 1;
	END TRY

	BEGIN CATCH
		PRINT ERROR_MESSAGE();

		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		RETURN 0;
	END CATCH
END

