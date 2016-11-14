
CREATE PROCEDURE [dbo].[Batch_Liq_PC_Obtener_Promos_Vigentes] (
  @fecha_proceso DATETIME
 ,@fecha_ult_proceso DATETIME
 ,@id_pr1 int output
 ,@id_tipo_ap_pr1 int output
 ,@Registros_Procesados int = 0 output
 )
AS
DECLARE @ret_code INT;



BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
 SELECT
	-- Antes PRO_COM_PRI PRO_COM_AMP
	   @id_pr1 = MAX((CASE WHEN Q1.codigo = 'PRO_COM_AMP' THEN Q1.id_promocion_comprador ELSE -1 END))
	  ,@id_tipo_ap_pr1 = MAX((CASE WHEN Q1.codigo = 'PRO_COM_AMP' THEN Q1.id_tipo_aplicacion ELSE -1 END))
	  --ej.promo2
	  --,@id_pr2 = MAX( (CASE WHEN Q1.codigo = 'PRO_COM_2' THEN Q1.id_promocion_comprador ELSE -1 END))
	  --,@id_tipo_ap_pr2 = MAX( (CASE WHEN Q1.codigo = 'PRO_COM_2' THEN Q1.id_tipo_aplicacion ELSE -1 END))
	FROM
	(
	  SELECT
	    pcr.id_promocion_comprador,
	    pcr.id_tipo_aplicacion,  
	    tpo.codigo
	  FROM Configurations.dbo.Promocion_Comprador pcr
	    INNER JOIN Configurations.dbo.Tipo tpo ON tpo.id_tipo = pcr.id_tipo_promocion
	  WHERE 
	    @fecha_ult_proceso >= pcr.fecha_inicio AND (pcr.fecha_fin IS NULL OR @fecha_ult_proceso <= pcr.fecha_fin)
	    OR @fecha_proceso >= pcr.fecha_inicio AND (pcr.fecha_fin IS NULL OR @fecha_proceso <= pcr.fecha_fin)
	)Q1;

	set @Registros_Procesados = @@ROWCOUNT

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END

