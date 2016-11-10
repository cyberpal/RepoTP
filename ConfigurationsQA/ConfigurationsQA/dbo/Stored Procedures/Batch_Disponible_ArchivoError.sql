
CREATE PROCEDURE [dbo].[Batch_Disponible_ArchivoError]
AS
DECLARE @cant INT;
DECLARE @nombre_archivo VARCHAR(100);
DECLARE @TotalDisponibleAnterior DECIMAL(12,2);
DECLARE @TotalMontos DECIMAL(12,2);
DECLARE @TotalMontosMasAnterior DECIMAL(12,2);
DECLARE @TotalDisponibleActual DECIMAL(12,2);

BEGIN
	SET NOCOUNT ON;
  
	BEGIN TRY

	    TRUNCATE TABLE Configurations.dbo.Archivo_Disponible_tmp;
		
	
		SELECT @cant = COUNT(1)
	      FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp
	     WHERE flag_disponible_ok = 0;
		 
		 
		SET @nombre_archivo = 'control_actualizacion_disponible_' + FORMAT(GETDATE(),'yyyyMMddHHmmss');
		
		
		IF(@cant > 0)
		  BEGIN
		  
		    INSERT INTO Configurations.dbo.Archivo_Disponible_tmp
			VALUES (@nombre_archivo, (RIGHT(REPLICATE(' ',15)+'IDCuenta',15)+
			                          RIGHT(REPLICATE(' ',15)+'DisponibleAnterior',25)+
			                          RIGHT(REPLICATE(' ',21)+'Monto',25)+
									  RIGHT(REPLICATE(' ',15)+'AnteriorMasMonto',25)+
									  RIGHT(REPLICATE(' ',21)+'Actual',25)
									  ),
					1
					),
			       (@nombre_archivo, REPLICATE('-',120),1);
				   
				   
			INSERT INTO Configurations.dbo.Archivo_Disponible_tmp
			     SELECT @nombre_archivo,
				        (RIGHT(REPLICATE(' ',25)+REPLACE(CAST(id_cuenta AS VARCHAR(16)),'.',','),15)+
				         RIGHT(REPLICATE(' ',25)+REPLACE(CAST(disponible_anterior AS VARCHAR(16)),'.',','),25)+
				         RIGHT(REPLICATE(' ',25)+REPLACE(CAST(importe AS VARCHAR(16)),'.',','),25)+
						 RIGHT(REPLICATE(' ',25)+REPLACE(CAST((disponible_anterior+importe) AS VARCHAR(16)),'.',','),25)+
						 RIGHT(REPLICATE(' ',25)+REPLACE(CAST(disponible_actual AS VARCHAR(16)),'.',','),25)
						 ),
						 1
			       FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp
                  WHERE flag_disponible_ok = 0;		
				  	  
		    
		  END
	    ELSE
		  BEGIN
		    
			SELECT @TotalDisponibleAnterior = SUM(disponible_anterior),
				   @TotalMontos = SUM(importe),
				   @TotalMontosMasAnterior = SUM(disponible_anterior+importe),
				   @TotalDisponibleActual = SUM(disponible_actual)
			  FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp
	         WHERE flag_disponible_ok = 1;
			
			
		    INSERT INTO Configurations.dbo.Archivo_Disponible_tmp
			VALUES (@nombre_archivo, (RIGHT(REPLICATE(' ',15)+'TotalDisponibleAnterior',25)+
			                          RIGHT(REPLICATE(' ',20)+'TotalMontos',25)+
									  RIGHT(REPLICATE(' ',15)+'TotalMontosMasAnterior',25)+
									  RIGHT(REPLICATE(' ',15)+'TotalDisponibleActual',25)
									  ),
					0
					),
			       (@nombre_archivo, REPLICATE('-',110),0),
				   (@nombre_archivo, (RIGHT(REPLICATE(' ',25)+REPLACE(CAST(@TotalDisponibleAnterior AS VARCHAR(16)),'.',','),25)+
				                      RIGHT(REPLICATE(' ',25)+REPLACE(CAST(@TotalMontos AS VARCHAR(16)),'.',','),25)+
									  RIGHT(REPLICATE(' ',25)+REPLACE(CAST(@TotalMontosMasAnterior AS VARCHAR(16)),'.',','),25)+
									  RIGHT(REPLICATE(' ',25)+REPLACE(CAST(@TotalDisponibleActual AS VARCHAR(16)),'.',','),25)
				                     ),
					0
				    );
			
		  END
		  
		
		  
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;

		throw;

		RETURN 0;
	END CATCH;

	RETURN 1;
END;

