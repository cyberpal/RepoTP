
CREATE PROCEDURE dbo.Update_ButtonConceptID_Robot
AS
		 
DECLARE @filas INT = 1;

WHILE @filas > 0
BEGIN
       DECLARE @trn TABLE (Id CHAR(36) PRIMARY KEY);

       INSERT INTO @trn
       SELECT TOP 1000 id
       FROM Transactions.dbo.transactions
       WHERE ButtonId = '3566'
             AND id_tipo_concepto_boton IS NULL;

       UPDATE T
       SET T.id_tipo_concepto_boton = '97'
       FROM Transactions.dbo.transactions T
       INNER JOIN @trn T1
             ON t.Id = T1.Id;

       SET @filas = @@ROWCOUNT;
END

SET NOCOUNT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	  -- Iniciar Log        
    

	COMMIT TRANSACTION;

	RETURN 1;
END TRY

BEGIN CATCH
	IF (@@TRANCOUNT > 0)
		ROLLBACK TRANSACTION;

	THROW;

	RETURN 0;
END CATCH;