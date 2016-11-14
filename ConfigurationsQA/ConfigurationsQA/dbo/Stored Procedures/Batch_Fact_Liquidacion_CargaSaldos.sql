
/****** Object:  StoredProcedure [dbo].[Batch_Fact_Liquidacion_CompletaItems]    Script Date: 31/07/2015 11:48:04 ******/

CREATE PROCEDURE [dbo].[Batch_Fact_Liquidacion_CargaSaldos] (
	@fecha_desde DATETIME = NULL,
	@fecha_hasta DATETIME = NULL,
	@v_suma_cargos_aurus DECIMAL(18, 2) = NULL,
	@v_total_liquidado DECIMAL(18, 2) = NULL,
	@Usuario VARCHAR(20),
	@Mes INT = NULL,
	@Anio INT = NULL,
	@IdCicloFacturacion INT = NULL
	)
AS
--Variables del proceso          
DECLARE @v_numero_cuit VARCHAR(11);
DECLARE @v_eMail VARCHAR(50);
DECLARE @v_saldo_pendiente DECIMAL(18, 2);
DECLARE @v_saldo_revision DECIMAL(18, 2);
DECLARE @v_saldo_disponible DECIMAL(18, 2);
DECLARE @v_posee_diferencia BIT;

BEGIN
	
	SET NOCOUNT ON;

	--Seter Valores en 0 para como inicializacion de tabla
	UPDATE Configurations.dbo.Control_Liquidacion_Facturacion
	SET
	saldo_pendiente=0,
	saldo_revision=0,
	saldo_disponible=0,
	id_ciclo_facturacion = @IdCicloFacturacion,
	mes = @Mes,
	anio = @anio
		
	UPDATE clf
	SET 
	numero_CUIT=(CASE 
					WHEN ltrim(rtrim(tpo.codigo)) = 'CTA_PROFESIONAL'
						AND ltrim(rtrim(tpo.codigo)) <> 'IVA_CONS_FINAL'
						THEN isnull(cta.numero_CUIT, '0')
					WHEN ltrim(rtrim(tpo.codigo)) = 'CTA_EMPRESA'
						THEN isnull(sfc.numero_CUIT, 0)
					ELSE isnull(cta.numero_identificacion, '0')
					END
				),
	eMail=uscta.eMail
	FROM Configurations.dbo.Control_Liquidacion_Facturacion clf
	INNER JOIN Configurations.dbo.Cuenta cta on clf.id_cuenta=cta.id_cuenta
	INNER JOIN Configurations.dbo.Situacion_Fiscal_Cuenta sfc
			ON sfc.id_cuenta = cta.id_cuenta
		INNER JOIN Configurations.dbo.Tipo tpo
			ON cta.id_tipo_cuenta = tpo.id_tipo
		INNER JOIN Configurations.dbo.Usuario_Cuenta uscta
			ON uscta.id_cuenta = cta.id_cuenta
	    INNER JOIN Configurations.dbo.Log_Movimiento_Cuenta_Virtual lm
	        ON lm.id_cuenta=clf.id_cuenta
		WHERE sfc.flag_vigente = 1
			AND uscta.fecha_baja IS NULL
			AND uscta.usuario_baja IS NULL
		
	UPDATE clfMov
	SET 
	saldo_pendiente = isnull(lmcv.saldo_cuenta_actual,0),
	saldo_revision = isnull(lmcv.saldo_revision_actual,0),
	saldo_disponible = isnull(lmcv.disponible_actual,0),
	id_ciclo_facturacion = @IdCicloFacturacion,
	mes = @Mes,
	anio = @anio
	--posee_diferencia = (
				--CASE 
					--WHEN (isnull(suma_cargos_aurus,0)<>isnull(total_liquidado,0)) THEN 1
					--ELSE 0
					--END
				--)
	FROM Configurations.dbo.Control_Liquidacion_Facturacion clfmov
    INNER JOIN Configurations.dbo.Log_Movimiento_Cuenta_Virtual lmcv on clfmov.id_cuenta=lmcv.id_cuenta 
    WHERE cast(lmcv.fecha_alta AS DATE) BETWEEN cast(@fecha_desde AS DATE) AND cast(@fecha_hasta AS DATE)
	AND lmcv.fecha_alta=(SELECT MAX(t2.fecha_alta) FROM Configurations.dbo.Log_Movimiento_Cuenta_Virtual t2
	                     WHERE t2.id_cuenta=clfmov.id_cuenta
	                     GROUP BY t2.id_cuenta)

	UPDATE Configurations.dbo.Control_Liquidacion_Facturacion
	SET
	posee_diferencia=1,
	fecha_modificacion=getdate(),
	usuario_modificacion=@Usuario
	WHERE isnull(suma_cargos_aurus,0)<>isnull(total_liquidado,0)
	AND posee_diferencia is null
		
	RETURN 1
	
END

