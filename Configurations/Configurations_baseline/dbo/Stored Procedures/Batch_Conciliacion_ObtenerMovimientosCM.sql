
CREATE PROCEDURE dbo.Batch_Conciliacion_ObtenerMovimientosCM
AS
DECLARE @cant INT;

BEGIN
 SET NOCOUNT ON;
    
	
	INSERT INTO
	          Movimientos_conciliados_manual_tmp
	     SELECT 
               cm.id_conciliacion_manual,
               cm.id_transaccion, 
               cm.id_movimiento_mp,
	           cm.flag_aceptada_marca, 
               cm.flag_contracargo,
			   tmp.codigo
          FROM Configurations.dbo.Conciliacion_Manual cm
    INNER JOIN Configurations.dbo.Movimiento_Presentado_MP mpp
	        ON mpp.id_movimiento_mp = cm.id_movimiento_mp
    INNER JOIN Configurations.dbo.Medio_De_Pago mdp 
    		ON mpp.id_medio_pago = mdp.id_medio_pago
    INNER JOIN Configurations.dbo.Tipo_Medio_Pago tmp 
    		ON tmp.id_tipo_medio_pago = mdp.id_tipo_medio_pago
         WHERE flag_conciliado_manual = 1 
           AND flag_procesado = 0 
           AND NOT EXISTS (SELECT 1 
		                   FROM Configurations.dbo.Conciliacion c 
			               WHERE cm.id_conciliacion_manual = c.id_conciliacion_manual
				         )
	 
    SELECT @cant = COUNT(1) FROM Configurations.dbo.Movimientos_conciliados_manual_tmp;		

 RETURN @cant;
END