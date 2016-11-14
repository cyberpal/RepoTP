
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_Calcular_Ciclo_Facturacion] (
 @CreateTimestamp DATETIME
 ,@FechaDesde DATETIME OUTPUT
 ,@FechaHasta DATETIME OUTPUT
 ,@IdCicloFacturacion INT OUTPUT
 )
AS
DECLARE @ret_code INT;
DECLARE @days_in_month INT = DAY(EOMONTH(@CreateTimestamp));

BEGIN

  SELECT
	 @IdCicloFacturacion=cfo.id_ciclo_facturacion 
    ,@FechaDesde = (DATEADD(hour, 0, DATEADD(minute, 0, DATEADD(second, 0, CAST(DATEFROMPARTS(DATEPART(YYYY, @CreateTimestamp), DATEPART(MM, @CreateTimestamp), cfo.dia_inicio) AS DATETIME)))))
    ,@FechaHasta = (DATEADD(hour, 23, DATEADD(minute, 59, DATEADD(second, 59, CAST(DATEFROMPARTS(DATEPART(YYYY, @CreateTimestamp), DATEPART(MM, @CreateTimestamp), IIF(@days_in_month < cfo.dia_tope_incluido, @days_in_month, cfo.dia_tope_incluido)) AS DATETIME)))))
  FROM Configurations.dbo.Ciclo_Facturacion cfo
  WHERE DATEPART(DD, @CreateTimestamp) BETWEEN cfo.dia_inicio
    AND cfo.dia_tope_incluido;

 RETURN 1;

END

