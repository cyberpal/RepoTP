
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Fecha_Tope_Presentacion] (
 @ProductIdentification INT
 ,@CreateTimestamp DATETIME
 ,@FilingDeadline DATETIME OUTPUT
 )
AS
DECLARE @plazo_pago_marca INT;
DECLARE @margen_espera_pago_marca INT;
DECLARE @dias INT;

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  SELECT @plazo_pago_marca = mdp.plazo_pago_marca
   ,@margen_espera_pago_marca = mdp.margen_espera_pago_marca
  FROM Configurations.dbo.Medio_De_Pago mdp
  WHERE mdp.flag_habilitado > 0
   AND mdp.id_medio_pago = @ProductIdentification;

  SET @dias = ISNULL(@plazo_pago_marca, 0) + ISNULL(@margen_espera_pago_marca, 0);
  SET @FilingDeadline = DATEADD(dd, @dias, @CreateTimestamp);

  RETURN 1;
 END TRY

 BEGIN CATCH
  RETURN 0;
 END CATCH
END

