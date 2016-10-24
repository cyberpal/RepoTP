--exec sp_helptext 'dbo.Actualizar_Cuenta_Virtual_Control'    
    
      
CREATE PROCEDURE [dbo].[Actualizar_Cuenta_Virtual_Control_Barrido] (       
             @importe decimal (12,2) = NULL,  
			 @id_cuenta int,
			 @usuario_alta varchar (20) = NULL,        
			 @id_log_proceso int = NULL,
			 @anteriorMasImporte decimal (12,2) = NULL
			 
)                  
AS       

	declare @monto_disponible_cv      decimal (12,2)   --pertenece a cuenta virtual 
	declare @monto_disponible_lmcv    decimal (12,2)   --pertenece a log mov cuenta virtual
	declare @disponible_anterior_lmcv decimal (12,2)      
	declare @disponible_actual_lmcv   decimal (12,2)      
	declare @v_maximoIDProceso        int
	declare @v_id_control             int      
	declare @Msg                      VARCHAR(255)      
      
BEGIN

	SET NOCOUNT ON;      
      
	BEGIN TRANSACTION      
      
	BEGIN TRY      
        
      
	IF (@id_cuenta IS NULL OR @id_cuenta = 0 OR @id_log_proceso IS NULL)      
		THROW 51000, 'Se han recibido valores nulos o cero para variables Cuenta, Proceso o Usuario', 1;
	
	IF (@importe IS NULL)      
		THROW 51000, 'Se ha recibido un valor nulo correspondiente al importe', 1;
	
	IF (@anteriorMasImporte IS NULL)      
		THROW 51000, 'Se ha recibido un valor nulo correspondiente al importe', 1;
	
	IF (@usuario_alta IS NULL OR @usuario_alta = '')      
		THROW 51000, 'Se han recibido valores nulos o cero para variables Cuenta, Proceso o Usuario', 1;          
        
  	
	BEGIN
			--Se realiza captura de valores en log movimiento cuenta virtual,
			--para una cuenta, un proceso y en la fecha actual.

			SELECT
			@monto_disponible_lmcv=monto_disponible,
			@disponible_anterior_lmcv=disponible_anterior,
			@disponible_actual_lmcv=disponible_actual
				FROM Configurations.DBO.Log_Movimiento_Cuenta_Virtual lmcv
				WHERE datediff(dd,cast(lmcv.fecha_alta as date),cast(getdate() as date))=0
				AND lmcv.id_log_proceso=@id_log_proceso
				AND lmcv.id_cuenta=@id_cuenta     
			
			--Selecciono el disponible para esa cuenta de cuenta virtual

			SELECT @monto_disponible_cv=disponible 
			from Configurations.dbo.Cuenta_Virtual where id_cuenta=@id_cuenta
			
			--Si detecta anomalias hace un insert en tabla control cuenta virtual
			--Estas anomalias pueden ser:
			--El disponible actual de log movimiento cuenta virtual es distinto de 
			--disponibleanterior+monto generado en el paso previo.
			
			--El disponible actual de log movimiento cuenta virtual es distinto de
			--el disponible de cuenta virtual. Ambos montos deben coincidir
			
			--El importe que se actualizo+monto anterior en log cuenta virtual es distinto
			--anterior mas monto, pero del paso anterior. Con 
			--Con esto se aseguran todos los campos


			IF (@disponible_actual_lmcv<>@anteriorMasImporte 
			or @disponible_actual_lmcv<>@monto_disponible_cv 
			or (@monto_disponible_lmcv+@disponible_anterior_lmcv)<>@anteriorMasImporte)       
			        
				BEGIN      
      
					SELECT      
					@v_id_control = ISNULL(MAX(id_control), 0) + 1      
					FROM Configurations.dbo.Control_Cuenta_Virtual      
      
					INSERT INTO Configurations.dbo.Control_Cuenta_Virtual      
					(      
					[id_control],      
					[id_cuenta],      
					[id_log_proceso],      
					[disponible_anterior],      
					[monto_disponible],      
					[disponible_anteriorMASmonto_disponible],      
					[disponible_actual],       
					[fecha_alta],      
					[usuario_alta]      
					)VALUES(      
					@v_id_control,      
					@id_cuenta,      
					@id_log_proceso,      
					@disponible_anterior_lmcv,      
					@importe,      
					@anteriorMasImporte,      
					@disponible_actual_lmcv,      
					getdate(),      
					@usuario_alta);    
           
				END      
      	  
     	    END
      
	END TRY      
	BEGIN CATCH      
		ROLLBACK TRANSACTION       
		SELECT @Msg  = ERROR_MESSAGE();      
		THROW  51000, @Msg , 1;      
	END CATCH      
      
	COMMIT TRANSACTION       
    
	RETURN 1;

END;