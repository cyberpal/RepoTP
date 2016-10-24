
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_CalcularAjuste] (          
	   @idCuenta INT,
	   @diferencia_ajuste decimal(18, 2),
	   @usuario VARCHAR(20)
)

AS 
 
		DECLARE @Msg varchar(20);
		DECLARE @v_idAjuste INT;
		DECLARE @v_idMotivoAjuste INT;
		DECLARE @v_codigoOperacion INT;
		DECLARE @RetCode INT



		 
BEGIN          
	
	SET NOCOUNT ON;          
	              
    BEGIN TRANSACTION 
	
	BEGIN TRY 
			
			IF (@diferencia_ajuste<>0)
								    
					--1.Solo realizara ajusteno cuando el valor sea positivo o negativo.
			BEGIN
					
					--2. Obtener el ID para tabla ajuste
					SET @v_idAjuste = (SELECT ISNULL(MAX(id_ajuste),0) + 1 FROM Configurations.dbo.Ajuste);

					
					--3.Obtener el codigo de operacion
					SET @v_codigoOperacion = (SELECT id_codigo_operacion AS q_codigoOperacion 
													FROM Configurations.dbo.Codigo_Operacion
													WHERE codigo_operacion=(case when @diferencia_ajuste > 0 then 'AJP' else 'AJN' end));

			
					--4.Obtener el motivo del ajuste
					SET @v_idMotivoAjuste = (SELECT id_motivo_ajuste FROM Configurations.dbo.Motivo_Ajuste WHERE codigo = 'DIF_FACT');
					
					--5.Insertar el registro en la tabla
					INSERT INTO [dbo].[Ajuste](
								[id_ajuste],
								--[id_codigo_operacion],
								[id_cuenta],
								[id_motivo_ajuste],
								[monto_neto],
								[estado_ajuste],
								[fecha_alta],
								[usuario_alta],
								[version])
						VALUES(@v_idAjuste, 
								--@v_codigoOperacion,
								@idCuenta,
								@v_idMotivoAjuste, 
								@diferencia_ajuste,
								'Aprobado',
								GETDATE(),
								@usuario,
								0);
						

			END	
			
			SET  @RetCode=1;
	
	END TRY        
  
		BEGIN CATCH  
		
			IF (@@TRANCOUNT > 0)  
				ROLLBACK TRANSACTION;  
				SET  @RetCode=0;
				RETURN @RetCode;
				
		
		END CATCH
	
	COMMIT TRANSACTION;
	
	RETURN @RetCode;
              
END
