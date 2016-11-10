
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Fecha_Cashout_old] (  
 @CreateTimestamp DATETIME,  
 @LocationIdentification INT,             
 @ProductIdentification INT,            
 @FacilitiesPayments INT,  
 @PaymentTimestamp DATETIME,  
 @CashoutTimestamp DATETIME OUTPUT        
)            
AS  
 DECLARE @tmp_codigo VARCHAR(20);  
 DECLARE @plazo_liberacion INT;  
 DECLARE @plazo_liberacion_cuotas INT;  
 DECLARE @plazo INT;  
 DECLARE @fecha_desde DATETIME;  
BEGIN            
 SET NOCOUNT ON;            
  
 BEGIN TRY  
  SELECT  
   @tmp_codigo = tmp.codigo,  
   @plazo_liberacion = pln.plazo_liberacion,  
   @plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas  
  FROM  
   Configurations.dbo.Plazo_Liberacion pln,  
   Configurations.dbo.Medio_De_Pago mdp,  
   Configurations.dbo.Tipo_Medio_Pago tmp  
  WHERE mdp.flag_habilitado > 0  
    AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago  
    AND tmp.id_tipo_medio_pago = pln.id_tipo_medio_pago  
    AND pln.id_cuenta = @LocationIdentification  
    AND mdp.id_medio_pago = @ProductIdentification  
    AND GETDATE() >= pln.fecha_alta  
    AND (  
   pln.fecha_baja IS NULL  
   OR  
   GETDATE() <= pln.fecha_baja  
    );  
  
  IF (@tmp_codigo IS NULL)  
   SELECT  
    @tmp_codigo = tmp.codigo,  
    @plazo_liberacion = pln.plazo_liberacion,  
    @plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas  
   FROM  
    Configurations.dbo.Cuenta cta,  
    Configurations.dbo.Actividad_Cuenta aca,  
    Configurations.dbo.Medio_De_Pago mdp,  
    Configurations.dbo.Tipo_Medio_Pago tmp,  
    Configurations.dbo.Plazo_Liberacion pln  
   WHERE cta.id_tipo_cuenta = pln.id_tipo_cuenta  
     AND cta.id_cuenta = aca.id_cuenta  
     AND aca.id_rubro = pln.id_rubro  
     AND mdp.flag_habilitado > 0  
     AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago  
     AND tmp.id_tipo_medio_pago = pln.id_tipo_medio_pago  
     AND cta.id_cuenta = @LocationIdentification  
     AND mdp.id_medio_pago = @ProductIdentification  
     AND GETDATE() >= pln.fecha_alta  
     AND (  
    pln.fecha_baja IS NULL  
    OR  
    GETDATE() <= pln.fecha_baja  
     );  
  
  IF (@tmp_codigo IS NULL)  
   SELECT  
    @tmp_codigo = tmp.codigo,  
    @plazo_liberacion = pln.plazo_liberacion,  
    @plazo_liberacion_cuotas = pln.plazo_liberacion_cuotas  
   FROM  
    Configurations.dbo.Cuenta cta,  
    Configurations.dbo.Medio_De_Pago mdp,  
    Configurations.dbo.Tipo_Medio_Pago tmp,  
    Configurations.dbo.Plazo_Liberacion pln  
   WHERE cta.id_tipo_cuenta = pln.id_tipo_cuenta  
     AND mdp.flag_habilitado > 0  
     AND mdp.id_tipo_medio_pago = tmp.id_tipo_medio_pago  
     AND tmp.id_tipo_medio_pago = pln.id_tipo_medio_pago  
     AND pln.id_cuenta IS NULL  
     AND cta.id_cuenta = @LocationIdentification  
     AND mdp.id_medio_pago = @ProductIdentification  
     AND GETDATE() >= pln.fecha_alta  
     AND (  
    pln.fecha_baja IS NULL  
    OR  
    GETDATE() <= pln.fecha_baja  
     );  
  
  
  IF (@FacilitiesPayments = 1)  
   SET @plazo = @plazo_liberacion;  
  ELSE  
   SET @plazo = @plazo_liberacion_cuotas;  
  
  IF (@tmp_codigo = 'EFECTIVO')  
   SET @fecha_desde = @PaymentTimestamp;  
  ELSE  
   SET @fecha_desde = @CreateTimestamp;  
  
  WITH Dias_Habiles(dia_habil, nro_fila) AS (  
   SELECT  
    CAST(fro.fecha AS DATE) AS dia_habil,  
    ROW_NUMBER() OVER (ORDER BY fro.fecha) AS nro_fila   
   FROM Configurations.dbo.Feriados fro  
   WHERE fro.esFeriado = 0  
     AND fro.habilitado = 1  
  )  
  SELECT   
   @CashoutTimestamp = DATETIMEFROMPARTS (  
    DATEPART(yyyy, dia_habil), DATEPART(mm, dia_habil), DATEPART(dd, dia_habil),  
    DATEPART(hh, @fecha_desde), DATEPART(mi, @fecha_desde), DATEPART(ss, @fecha_desde), DATEPART(ms, @fecha_desde)  
   )  
  FROM Dias_Habiles  
  WHERE nro_fila = (  
   SELECT TOP 1 nro_fila + @plazo  
   FROM Dias_Habiles  
   WHERE dia_habil <= CAST(@fecha_desde AS DATE)  
   ORDER BY dia_habil DESC  
  );  
  
  RETURN 1;          
 END TRY          
  
 BEGIN CATCH          
  RETURN 0;      
 END CATCH          
END
