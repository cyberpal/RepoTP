
CREATE  PROCEDURE [dbo].[Batch_Generacion_Arch_Disp_ObtenerCuentas] (          
	@usuario VARCHAR(20),
	@fecha_actual DATE = NULL OUTPUT,
	@fecha_hasta DATE = NULL OUTPUT
)

AS 

	DECLARE @dias INT;
	DECLARE @id_proceso INT;
	DECLARE @Msg VARCHAR(80);
	DECLARE @fecha_desde DATE;
	DECLARE @MergeTable TABLE (id_bonificacion INT);

BEGIN          
	
	SET NOCOUNT ON;          
	
	BEGIN TRANSACTION 
	
	BEGIN TRY

	        TRUNCATE TABLE Configurations.dbo.Disponible_control_tmp;

			SELECT 
			@id_proceso = lpo.id_proceso
			FROM Configurations.dbo.Proceso lpo
			WHERE lpo.nombre LIKE 'Generacion%archivo%disponible';

		
			SELECT 
			@dias = CAST(pmo.valor AS INT),
            @fecha_actual =  CAST(GETDATE() AS DATE)
            FROM dbo.Parametro pmo 
            WHERE pmo.codigo = 'CONC_PLAZO_DISP';


			WITH Dias_Habiles(dia_habil, dia_habil_anterior, nro_fila) AS 
			    (
	             SELECT
		         CAST(fro.fecha AS DATE) AS dia_habil,
				 LAG(CAST(fro.fecha AS DATE), 1) OVER (ORDER BY CAST(fro.fecha AS DATE)) AS dia_habil_anterior,
		         ROW_NUMBER() OVER (ORDER BY fro.fecha) AS nro_fila 
	             FROM Configurations.dbo.Feriados fro
	             WHERE fro.esFeriado = 0
		         AND fro.habilitado = 1
                 )
            SELECT
			@fecha_desde = dia_habil_anterior,
	        @fecha_hasta = dia_habil
            FROM Dias_Habiles
            WHERE nro_fila = (
	        SELECT nro_fila + @dias
	        FROM Dias_Habiles
	        WHERE dia_habil = @fecha_actual
            );


			EXEC Configurations.dbo.Iniciar_Log_Proceso 
				 @id_proceso, 
				 @fecha_desde, 
				 @fecha_hasta, 
				 @Usuario;


			INSERT INTO Configurations.dbo.Disponible_control_tmp
            (Id_cuenta,
			 fecha_de_cashout, 
             Importe_Cashout_Actual
             )
            SELECT
            trn.LocationIdentification,
			@fecha_hasta,
            SUM(CASE WHEN UPPER(trn.OperationName) = 'DEVOLUCION' 
                THEN ((ISNULL(trn.Amount, 0) - ISNULL(trn.FeeAmount, 0) - ISNULL(trn.TaxAmount, 0))* -1)
	            ELSE(ISNULL(trn.Amount, 0) - ISNULL(trn.FeeAmount, 0) - ISNULL(trn.TaxAmount, 0)) 
	            END)
            FROM Transactions.dbo.transactions trn
            WHERE CAST(trn.CashoutTimestamp AS DATE) > @fecha_desde
            AND CAST(trn.CashoutTimestamp AS DATE) <= @fecha_hasta
            AND (trn.CashoutReleaseStatus <> -1  
                 OR
                 trn.CashoutReleaseStatus IS NULL)
			AND trn.LiquidationTimestamp IS NOT NULL
			AND trn.liquidationstatus = - 1
			AND trn.AvailableTimestamp IS NULL
			AND (
				trn.availablestatus <> - 1
				OR trn.availablestatus IS NULL
				)
			AND trn.TransactionStatus = 'TX_APROBADA'
			AND trn.LocationIdentification IS NOT NULL
           GROUP BY trn.LocationIdentification;


		   MERGE Configurations.dbo.Disponible_control_tmp AS trg
           USING (SELECT
                  LocationIdentification,
                  SUM(CASE WHEN UPPER(OperationName) = 'DEVOLUCION' 
                      THEN ((ISNULL(Amount, 0) - ISNULL(FeeAmount, 0) - ISNULL(TaxAmount, 0))* -1)
	                  ELSE(ISNULL(Amount, 0) - ISNULL(FeeAmount, 0) - ISNULL(TaxAmount, 0)) 
	                  END) AS importe
           FROM Transactions.dbo.transactions 
           WHERE CAST(CashoutTimestamp AS DATE) <= @fecha_desde
                 AND (CashoutReleaseStatus <> -1  
                      OR
                      CashoutReleaseStatus IS NULL)
							AND LiquidationTimestamp IS NOT NULL
			     AND liquidationstatus = - 1
			     AND AvailableTimestamp IS NULL
			     AND (
				      availablestatus <> - 1
				      OR 
					  availablestatus IS NULL
				     )
			     AND TransactionStatus = 'TX_APROBADA'
			     AND LocationIdentification IS NOT NULL
           GROUP BY LocationIdentification) AS src 
           ON (trg.id_cuenta = src.LocationIdentification)
           WHEN MATCHED THEN 
                UPDATE SET trg.Importe_Pendiente = src.importe,
				           trg.Importe_Disponibilizado = src.importe + trg.Importe_Cashout_actual
           WHEN NOT MATCHED BY TARGET THEN 
                INSERT (id_cuenta, fecha_de_cashout, Importe_Disponibilizado, Importe_Pendiente) 
	            VALUES (src.LocationIdentification, @fecha_hasta, src.importe, src.importe)
		   WHEN NOT MATCHED BY SOURCE THEN 
                UPDATE SET trg.Importe_Disponibilizado = trg.Importe_Cashout_actual;

				
			MERGE Configurations.dbo.Disponible_control_tmp AS trg	
			USING (SELECT id_bonificacion, 
                          id_cuenta, 
	                      importe_bonificacion 
					 FROM Configurations.dbo.Bonificacion
                    WHERE flag_afectacion_fondeo = 0
                      AND fecha_liberacion <= @fecha_hasta) AS src 
           ON (trg.id_cuenta = src.id_cuenta)	
		   WHEN MATCHED THEN 
                UPDATE SET trg.Importe_Disponibilizado = src.importe_bonificacion + trg.Importe_Disponibilizado
		   WHEN NOT MATCHED BY TARGET THEN 
                INSERT (id_cuenta, fecha_de_cashout, Importe_Disponibilizado) 
	            VALUES (src.id_cuenta, @fecha_hasta, src.importe_bonificacion)
		   OUTPUT src.id_bonificacion
	         INTO @MergeTable;
			 
			
           UPDATE b
	          SET b.flag_afectacion_fondeo = 1,
		          b.fecha_afectacion_fondeo = GETDATE()
	         FROM Configurations.dbo.Bonificacion b
	   INNER JOIN @MergeTable MgTrn
		       ON b.id_bonificacion = MgTrn.id_bonificacion;	
			   
			   
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



          
