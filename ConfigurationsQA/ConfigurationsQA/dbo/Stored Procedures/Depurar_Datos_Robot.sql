--============================================================================================================================================||
-- Author:		Alan Noboa																													  ||
-- Create date: 2016-05-11																													  ||
-- Description:	Store Procedure que depura las tablas NotificacionEnviada y Transactions del esquema Transactions							  ||
-- Parametros:  EXEC Depurar_Datos_Robot @idCuenta, @idNotificacion, @idSite, @estadoTransaccion, @cantidadRegistrosCommit, @esquema		  ||
--============================================================================================================================================||
CREATE PROCEDURE [dbo].[Depurar_Datos_Robot]
	@idCuenta INT,		
	@idNotificacion INT,
	@idSite VARCHAR(36),
	@estadoTransaccion VARCHAR(20),
	@cantidadRegistrosCommit INT,
	@esquema VARCHAR(15)
AS
BEGIN
	PRINT 'Inicia Ejecucion del Store';
	SET NOCOUNT ON;

	-- Validamos que hayan enviado el esquema.
	IF(@esquema is null or @esquema = '')
		THROW 50001, 'El esquema donde se va a ejecutar el store es obligatorio - Las opciones validas son Configurations/Transactions/Operations', 1;
		
	-- Validamos el parametro que indica cada cuanto se va a commitear.
	IF (@cantidadRegistrosCommit is null or @cantidadRegistrosCommit = 0 or @cantidadRegistrosCommit < 0)
		THROW 50001, 'El parametro para determinar cada cuantos registros se va a realizar el commit no debe ser vacio ni menor a 1', 1;
	
	-- Procedemos a ejecutar el switch para determinar que logica y en que esquema aplicarlo.
	IF (UPPER(@esquema) = 'CONFIGURATIONS')
		BEGIN
			-- Validamos que hayan enviado el parametro.
			IF (@idCuenta is null)
				THROW 50001, 'El ID de Cuenta no debe ser ni nulo ni vacio', 1;	
				
			IF (@idNotificacion is null)
				THROW 50001, 'El ID de Notificacion no debe ser ni nulo ni vacio', 1;	
				
			DECLARE @existeCuenta INT;
			SELECT @existeCuenta = id_cuenta from Configurations.dbo.Cuenta WITH(NOLOCK) where id_cuenta = @idCuenta;
			
			-- Validamos que la cuenta exista.
			IF (@existeCuenta is null)
				THROW 50001, 'La cuenta no existe', 1;
			
			-- Hacemos el declare de todos las variables que vamos a usar para controlar el commit cada 1000.
			DECLARE @ContadorNotificacion INT;
			SET @ContadorNotificacion = 1;
			DECLARE @UltimaNotificacion INT;
			SET @UltimaNotificacion = (SELECT TOP 1 ROW_NUMBER() OVER(order by id_notificacion_enviada desc) AS ultimo from Configurations.dbo.Notificacion_Enviada WITH(NOLOCK) where id_cuenta = @idCuenta and id_notificacion = @idNotificacion order by ultimo desc);

			-- Creamos la tabla temporal que vamos a usar.
			CREATE TABLE #DepurarNotificacionTemp(id int, orden int);
			
			-- Insertamos en la temporal los datos a borrar.
			INSERT INTO #DepurarNotificacionTemp(orden,id) SELECT ROW_NUMBER() OVER(order by id_notificacion_enviada desc) AS contador, id_notificacion_enviada from Configurations.dbo.Notificacion_Enviada WITH(NOLOCK) where id_cuenta = @idCuenta and id_notificacion = @idNotificacion order by contador asc;
			
			-- Logica para borrar registros de Notificacion Enviada
			DECLARE @notificacionContador INT;
			DECLARE @notificacionID INT;
			
			PRINT 'Empezamos a depurar las Notificaciones Enviadas';
			WHILE EXISTS (SELECT * FROM #DepurarNotificacionTemp)
			BEGIN
				SELECT TOP 1 @notificacionContador = orden,@notificacionID = id FROM #DepurarNotificacionTemp order by orden asc;
				IF(@ContadorNotificacion = 1)
				BEGIN
					PRINT 'Inicio Transaccion';
					BEGIN TRANSACTION
				END
					
				DELETE FROM Configurations.dbo.Notificacion_Enviada where id_notificacion_enviada = @notificacionID;
				DELETE FROM #DepurarNotificacionTemp where id = @notificacionID;
					
				IF(@ContadorNotificacion = @cantidadRegistrosCommit or @notificacionContador = @UltimaNotificacion)
				BEGIN
					PRINT 'Finalizo Transaccion'
					SET @ContadorNotificacion = 0;
					COMMIT TRANSACTION					
				END
				
				SET @ContadorNotificacion = @ContadorNotificacion + 1;				
			END
			
			-- Dropeamos la tabla temporal.
			DROP TABLE #DepurarNotificacionTemp;
			PRINT 'Notificaciones Depuradas';
			
		END
	ELSE IF (UPPER(@esquema) = 'TRANSACTIONS')
		BEGIN
			-- Validamos que hayan los parametros necesarios para realizar la depuracion.
			IF (@idSite is null or @idSite = '')
				THROW 50001, 'El ID Site no debe ser ni nulo ni vacio', 1;
				
			IF(@estadoTransaccion is null or @estadoTransaccion = '')
				THROW 50001, 'El estado de las TX a borrar no debe ser ni nulo ni vacio', 1;
			
			DECLARE @ContadorTXTransactionsVendedor INT;
			SET @ContadorTXTransactionsVendedor = 1;
			DECLARE @UltimaTXTransactionsVendedor INT;
			SET @UltimaTXTransactionsVendedor = (SELECT TOP 1 ROW_NUMBER() OVER(order by id desc) AS ultimo from Transactions.dbo.Transactions WITH(NOLOCK) where LocationIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by ultimo desc);
			
			DECLARE @ContadorTXTransactionsComprador INT;
			SET @ContadorTXTransactionsComprador = 1;
			DECLARE @UltimaTXTransactionsComprador INT;
			SET @UltimaTXTransactionsComprador = (SELECT TOP 1 ROW_NUMBER() OVER(order by id desc) AS ultimo from Transactions.dbo.Transactions WITH(NOLOCK) where BuyerAccountIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by ultimo desc);
			
			-- Creamos las tablas temporales que vamos a usar.
			CREATE TABLE #DepurarTXVentaTemp(id char(36), orden int);
			CREATE TABLE #DepurarTXCompraTemp(id char(36), orden int);
			
			-- Buscamos todos los ID de transacciones de venta del esquema transactions para la cuenta recibida por parametro.
			INSERT INTO #DepurarTXVentaTemp (orden, id)
			SELECT ROW_NUMBER() OVER(order by id desc) AS contador, id from Transactions.dbo.Transactions WITH(NOLOCK) where LocationIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by contador asc;

			-- Buscamos todos los ID de transacciones de compra del esquema transactions para la cuenta recibida por parametro.
			INSERT INTO #DepurarTXCompraTemp (orden, id)
			SELECT ROW_NUMBER() OVER(order by id desc) AS contador, id from Transactions.dbo.Transactions WITH(NOLOCK) where BuyerAccountIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by contador asc;
			
			-- Logica para borrar registros de TX Transactions Venta
			DECLARE @txTransactionsVendedorContador INT;
			DECLARE @txTransactionsVendedor CHAR(36);
			
			PRINT 'Empezamos a depurar las Transacciones de Transactions - Vendedor';
			WHILE EXISTS (SELECT * FROM #DepurarTXVentaTemp)
			BEGIN
				SELECT TOP 1 @txTransactionsVendedorContador = orden,@txTransactionsVendedor = id FROM #DepurarTXVentaTemp order by orden asc;
				
				IF(@ContadorTXTransactionsVendedor = 1)
				BEGIN
					PRINT 'Inicio Transaccion';
					BEGIN TRANSACTION
				END
				
				DELETE FROM Transactions.dbo.Transactions where id = @txTransactionsVendedor;
				DELETE FROM #DepurarTXVentaTemp where id = @txTransactionsVendedor;
										
				IF(@ContadorTXTransactionsVendedor = @cantidadRegistrosCommit or @txTransactionsVendedorContador = @UltimaTXTransactionsVendedor)
				BEGIN
					PRINT 'Finalizo Transaccion'
					SET @ContadorTXTransactionsVendedor = 0;
					COMMIT TRANSACTION					
				END
				
				SET @ContadorTXTransactionsVendedor = @ContadorTXTransactionsVendedor + 1;
			END
			-- Dropeamos la tabla temporal.
			DROP TABLE #DepurarTXVentaTemp;
			PRINT 'Transacciones de Vendedor Depuradas';
							
			-- Logica para borrar registros de TX Transactions Compra
			DECLARE @txTransactionsCompradorContador INT;
			DECLARE @txTransactionsComprador CHAR(36);
			
			PRINT 'Empezamos a depurar las Transacciones de Transactions - Comprador';
			WHILE EXISTS (SELECT * FROM #DepurarTXCompraTemp)
			BEGIN
				SELECT TOP 1 @txTransactionsCompradorContador = orden,@txTransactionsComprador = id FROM #DepurarTXCompraTemp order by orden asc;
				
				IF(@ContadorTXTransactionsComprador = 1)
				BEGIN
					PRINT 'Inicio Transaccion';
					BEGIN TRANSACTION
				END
				
				DELETE FROM Transactions.dbo.Transactions where id = @txTransactionsComprador;
				DELETE FROM #DepurarTXCompraTemp where id = @txTransactionsComprador;
										
				IF(@ContadorTXTransactionsComprador = @cantidadRegistrosCommit or @txTransactionsCompradorContador = @UltimaTXTransactionsComprador)
				BEGIN
					PRINT 'Finalizo Transaccion'
					SET @ContadorTXTransactionsComprador = 0;
					COMMIT TRANSACTION					
				END
				
				SET @ContadorTXTransactionsComprador = @ContadorTXTransactionsComprador + 1;
			END
			-- Dropeamos la tabla temporal.
			DROP TABLE #DepurarTXCompraTemp;
			PRINT 'Transacciones de Comprador Depuradas';
		END
		ELSE IF (UPPER(@esquema) = 'OPERATIONS')
			BEGIN				
				-- Validamos que hayan los parametros necesarios para realizar la depuracion.
				IF (@idSite is null or @idSite = '')
					THROW 50001, 'El ID Site no debe ser ni nulo ni vacio', 1;
					
				IF(@estadoTransaccion is null or @estadoTransaccion = '')
					THROW 50001, 'El estado de las TX a borrar no debe ser ni nulo ni vacio', 1;

				-- Hacemos el declare de todos las variables que vamos a usar para controlar el commit cada N.
				DECLARE @ContadorTXOperationsVendedor INT;
				SET @ContadorTXOperationsVendedor = 1;
				DECLARE @UltimaTXOperationsVendedor INT;
				SET @UltimaTXOperationsVendedor = (SELECT TOP 1 ROW_NUMBER() OVER(order by id desc) AS ultimo from Operations.dbo.Transactions WITH(NOLOCK) where LocationIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by ultimo desc);
				
				DECLARE @ContadorTXOperationsComprador INT;
				SET @ContadorTXOperationsComprador = 1;
				DECLARE @UltimaTXOperationsComprador INT;
				SET @UltimaTXOperationsComprador = (SELECT TOP 1 ROW_NUMBER() OVER(order by id desc) AS ultimo from Operations.dbo.Transactions WITH(NOLOCK) where BuyerAccountIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by ultimo desc);
				
				-- Creamos las tablas temporales que vamos a usar.
				CREATE TABLE #DepurarOPTXVentaTemp(id char(36), orden int);
				CREATE TABLE #DepurarOPTXCompraTemp(id char(36), orden int);
				
				-- Buscamos todos los ID de transacciones de venta del esquema transactions para la cuenta recibida por parametro.				
				INSERT INTO #DepurarOPTXVentaTemp (orden, id)
				SELECT ROW_NUMBER() OVER(order by id desc) AS contador, id from Operations.dbo.Transactions WITH(NOLOCK) where LocationIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by contador asc;

				-- Buscamos todos los ID de transacciones de compra del esquema transactions para la cuenta recibida por parametro.
				INSERT INTO #DepurarOPTXCompraTemp (orden, id)
				SELECT ROW_NUMBER() OVER(order by id desc) AS contador, id from Operations.dbo.Transactions WITH(NOLOCK) where BuyerAccountIdentification = @idCuenta and ProviderIdentification = @idSite and TransactionStatus = @estadoTransaccion order by contador asc;
				
				-- Logica para borrar registros de TX Transactions Venta
				DECLARE @txOperationsVendedorContador INT;
				DECLARE @txOperationsVendedor CHAR(36);
				
				PRINT 'Empezamos a depurar las Transacciones de Transactions - Vendedor';
				WHILE EXISTS (SELECT * FROM #DepurarOPTXVentaTemp)
				BEGIN
					SELECT TOP 1 @txOperationsVendedorContador = orden, @txOperationsVendedor = id FROM #DepurarOPTXVentaTemp order by orden asc;
					
					IF(@ContadorTXOperationsVendedor = 1)
					BEGIN
						PRINT 'Inicio Transaccion';
						BEGIN TRANSACTION
					END
					
					DELETE FROM Operations.dbo.Transactions where id = @txOperationsVendedor;
					DELETE FROM #DepurarOPTXVentaTemp where id = @txOperationsVendedor;
											
					IF(@ContadorTXOperationsVendedor = @cantidadRegistrosCommit or @txOperationsVendedorContador = @UltimaTXOperationsVendedor)
					BEGIN
						PRINT 'Finalizo Transaccion'
						SET @ContadorTXOperationsVendedor = 0;
						COMMIT TRANSACTION					
					END
					
					SET @ContadorTXOperationsVendedor = @ContadorTXOperationsVendedor + 1;
				END
				DROP TABLE #DepurarOPTXVentaTemp;
				PRINT 'Transacciones de Vendedor Depuradas';
								
				-- Logica para borrar registros de TX Transactions Compra
				DECLARE @txOperationsCompradorContador INT;
				DECLARE @txOperationsComprador CHAR(36);
				
				PRINT 'Empezamos a depurar las Transacciones de Transactions - Comprador';
				WHILE EXISTS (SELECT * FROM #DepurarOPTXCompraTemp)
				BEGIN
					SELECT TOP 1 @txOperationsCompradorContador = orden, @txOperationsComprador = id FROM #DepurarOPTXCompraTemp order by orden asc;
					
					IF(@ContadorTXOperationsComprador = 1)
					BEGIN
						PRINT 'Inicio Transaccion';
						BEGIN TRANSACTION
					END
					
					DELETE FROM Operations.dbo.Transactions where id = @txOperationsComprador;
					DELETE FROM #DepurarOPTXCompraTemp where id = @txOperationsComprador;
											
					IF(@ContadorTXOperationsComprador = @cantidadRegistrosCommit or @txOperationsCompradorContador = @UltimaTXOperationsComprador)
					BEGIN
						PRINT 'Finalizo Transaccion'
						SET @ContadorTXOperationsComprador = 0;
						COMMIT TRANSACTION					
					END
					
					SET @ContadorTXOperationsComprador = @ContadorTXOperationsComprador + 1;					
				END
				DROP TABLE #DepurarOPTXCompraTemp;
				PRINT 'Transacciones de Comprador Depuradas';
		END
	ELSE
		THROW 50001, 'Esquema Invalido', 1;
	
	PRINT 'Finaliza Ejecucion del Store';
END
