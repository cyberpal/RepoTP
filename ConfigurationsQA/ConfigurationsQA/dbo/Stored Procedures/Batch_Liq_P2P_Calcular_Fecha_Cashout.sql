
CREATE PROCEDURE [dbo].[Batch_Liq_P2P_Calcular_Fecha_Cashout] (
 @plazo INT
 ,@FechaDesde DATETIME
 ,@CashoutTimestamp DATETIME OUTPUT
 )
AS
BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  WITH Dias_Habiles (
   dia_habil
   ,nro_fila
   )
  AS (
   SELECT CAST(fro.fecha AS DATE) AS dia_habil
    ,ROW_NUMBER() OVER (
     ORDER BY fro.fecha
     ) AS nro_fila
   FROM Configurations.dbo.Feriados fro
   WHERE fro.esFeriado = 0
    AND fro.habilitado = 1
   )
  SELECT @CashoutTimestamp = DATETIMEFROMPARTS(DATEPART(yyyy, dia_habil), DATEPART(mm, dia_habil), DATEPART(dd, dia_habil), DATEPART(hh, @FechaDesde), DATEPART(mi, @FechaDesde), DATEPART(ss, @FechaDesde), DATEPART(ms, @FechaDesde))
  FROM Dias_Habiles
  WHERE nro_fila = (
    SELECT TOP 1 nro_fila + @plazo
    FROM Dias_Habiles
    WHERE dia_habil <= CAST(@FechaDesde AS DATE)
    ORDER BY dia_habil DESC
    );

  RETURN 1;
 END TRY

 BEGIN CATCH
  RETURN 0;
 END CATCH
END

