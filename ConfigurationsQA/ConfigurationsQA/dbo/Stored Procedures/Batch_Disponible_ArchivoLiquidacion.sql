
CREATE PROCEDURE [dbo].[Batch_Disponible_ArchivoLiquidacion]
AS
DECLARE @cant INT;
DECLARE @nombre_archivo VARCHAR(100);

BEGIN
	SET NOCOUNT ON;
  
	BEGIN TRY

	    TRUNCATE TABLE Configurations.dbo.Archivo_DisponibleLiquidacion_tmp;
		
	
		SELECT @cant = COUNT(1)
	      FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp
	     WHERE flag_liquidacion_ok = 0;
		 
		 
		SET @nombre_archivo = 'control_generacion_liquidacion_' + FORMAT(GETDATE(),'yyyyMMddHHmmss');
		
		
		IF(@cant > 0)
		  BEGIN
		  
		    INSERT INTO Configurations.dbo.Archivo_DisponibleLiquidacion_tmp
			VALUES (@nombre_archivo, (RIGHT(REPLICATE(' ',11)+'IDCuenta',11)+
			                          RIGHT(REPLICATE(' ',44)+'Denominacion',44)+
			                          RIGHT(REPLICATE(' ',18)+'FechaDeCashOut',18)+
									  RIGHT(REPLICATE(' ',21)+'Importe_Liquidado',21)+
									  RIGHT(REPLICATE(' ',28)+'Importe_Disponibilizado',28)+
									  RIGHT(REPLICATE(' ',28)+'PorCashOut_Actual',28)+
									  RIGHT(REPLICATE(' ',30)+'PorCashOut_Pendiente',30)
									  )
					),
			       (@nombre_archivo, REPLICATE('-',180));
				   
				   
			INSERT INTO Configurations.dbo.Archivo_DisponibleLiquidacion_tmp
			     SELECT @nombre_archivo,
				        (RIGHT(REPLICATE(' ',11)+CAST(id_cuenta AS VARCHAR(16)),11)+
						 RIGHT(REPLICATE(' ',44)+denominacion,44)+
						 RIGHT(REPLICATE(' ',18)+CONVERT(VARCHAR(10),GETDATE(),126),18)+
				         RIGHT(REPLICATE(' ',21)+REPLACE(CAST(ISNULL(importe_liquidado,0) AS VARCHAR(16)),'.',','),21)+
				         RIGHT(REPLICATE(' ',28)+REPLACE(CAST(disponible_actual AS VARCHAR(16)),'.',','),28)+
						 RIGHT(REPLICATE(' ',28)+REPLACE(CAST(importe_cashout_actual AS VARCHAR(16)),'.',','),28)+
						 RIGHT(REPLICATE(' ',30)+REPLACE(CAST(importe_cashout_pendiente AS VARCHAR(16)),'.',','),30)
						 )
			       FROM Configurations.dbo.Disponible_Por_Cuenta_Tmp
                  WHERE flag_liquidacion_ok = 0;		
				  	  
		    
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
