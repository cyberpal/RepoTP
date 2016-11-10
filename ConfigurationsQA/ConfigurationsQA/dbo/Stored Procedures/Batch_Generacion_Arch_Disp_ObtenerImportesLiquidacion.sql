
CREATE  PROCEDURE [dbo].[Batch_Generacion_Arch_Disp_ObtenerImportesLiquidacion] (          
	@fecha_cashout DATE,
	@cantidad INT = NULL OUTPUT
)

AS 

	DECLARE @Msg VARCHAR(80);

BEGIN          
	
	SET NOCOUNT ON;          
	
	BEGIN TRANSACTION 
	
	BEGIN TRY


		   MERGE Configurations.dbo.Disponible_control_tmp AS trg
           USING (SELECT id_cuenta,
		                 fecha_de_cashout,
                         SUM(importe) AS imporTOTAL
                  FROM Configurations.dbo.Control_Liquidacion_Disponible
                  WHERE fecha_de_cashout = @fecha_cashout 
				  GROUP BY id_cuenta,
				           fecha_de_cashout) AS src 
           ON (trg.id_cuenta = src.id_cuenta)
           WHEN MATCHED THEN 
                UPDATE SET trg.Importe_Liquidado = src.imporTOTAL
           WHEN NOT MATCHED BY TARGET THEN 
                INSERT (id_cuenta, fecha_de_cashout, Importe_Liquidado) 
	            VALUES (src.id_cuenta, fecha_de_cashout, src.imporTOTAL);

           
		   UPDATE Configurations.dbo.Disponible_control_tmp 
		   SET flag_control = 1
		   WHERE (Importe_Cashout_Actual - Importe_Liquidado ) <> 0;


		   UPDATE Configurations.dbo.Disponible_control_tmp 
           SET denominacion = (CASE WHEN c.id_tipo_cuenta = 29 
		                            THEN  c.denominacion1 
									ELSE c.denominacion2+' '+c.denominacion1 
							   END)
           FROM  Configurations.dbo.Disponible_control_tmp DCtmp 
           INNER JOIN Configurations.dbo.cuenta c
           ON c.id_cuenta = DCtmp.id_cuenta;


		   SET @cantidad = (SELECT COUNT(*) 
		                    FROM Configurations.dbo.Disponible_control_tmp
						    WHERE flag_control = 1
					       )

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
END;
