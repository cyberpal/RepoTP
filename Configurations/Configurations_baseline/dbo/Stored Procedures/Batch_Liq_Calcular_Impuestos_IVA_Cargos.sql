
CREATE PROCEDURE [dbo].[Batch_Liq_Calcular_Impuestos_IVA_Cargos] (
 @IdCargo INT
 ,@CreateTimestamp DATETIME
 ,@idTipoCondicionIVA INT
 ,@MontoCalculadoCargo DECIMAL(12, 2)
 ,@monto_aplicado_impuesto DECIMAL(12, 2) OUTPUT
 ,@Alicuota DECIMAL(12, 2) OUTPUT
 )
AS
DECLARE @alicuota_tmp DECIMAL(12, 2) = 0;
DECLARE @msg VARCHAR(255) = NULL;
DECLARE @ret_code INT = 1;--sin errores

SET NOCOUNT ON;

BEGIN TRY
 --Obtener datos para el calculo
 SELECT @alicuota_tmp = ipt.alicuota
 FROM Configurations.dbo.Impuesto AS ipo
  ,Configurations.dbo.Impuesto_Por_Tipo AS ipt
  ,Configurations.dbo.Cargo AS cgo
  ,Configurations.dbo.Tipo_Cargo AS tgo
 WHERE cgo.id_cargo = @IdCargo
  AND cgo.id_tipo_cargo = tgo.id_tipo_cargo
  AND tgo.flag_aplica_iva = 1
  AND ipo.codigo = 'IVA'
  AND ipo.id_impuesto = ipt.id_impuesto
  AND ipt.id_tipo = @idTipoCondicionIVA
  AND ipt.flag_estado = 1
  AND CAST(ipt.fecha_vigencia_inicio AS DATE) <= CAST(@CreateTimestamp AS DATE)
  AND (
   ipt.fecha_vigencia_fin IS NULL
   OR CAST(ipt.fecha_vigencia_fin AS DATE) >= CAST(@CreateTimestamp AS DATE)
   );

 IF (@alicuota_tmp IS NULL) THROW 51000
  ,'El valor de alícuota es Nulo'
  ,1;
  SET @monto_aplicado_impuesto = (@alicuota_tmp / 100) * @MontoCalculadoCargo;
 SET @Alicuota = @alicuota_tmp;
END TRY

BEGIN CATCH
 SET @ret_code = 0;
END CATCH;

RETURN @ret_code;

