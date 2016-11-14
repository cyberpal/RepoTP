
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Ajuste_Detalle] @fecha_comienzo_proceso DATETIME,
	@id_cuenta INT,
	@Usuario VARCHAR(20)
AS
SET NOCOUNT ON;

BEGIN
	INSERT INTO Configurations.dbo.Detalle_Ajuste_Facturacion (
		[id_item_facturacion],
		[id_ajuste],
		[fecha_alta],
		[usuario_alta],
		[version]
		)
	SELECT itf.id_item_facturacion,
		iaj.id_ajuste,
		getdate(),
		@Usuario,
		0
	FROM Configurations.dbo.Facturacion_Items_Ajuste_tmp iaj
	INNER JOIN Configurations.dbo.Item_Facturacion itf
		ON iaj.id_cuenta = itf.id_cuenta
	WHERE iaj.signo = itf.tipo_comprobante
		AND iaj.id_cuenta = @id_cuenta
		AND itf.vuelta_facturacion = 'Pendiente'
		AND itf.fecha_alta >= @fecha_comienzo_proceso

	UPDATE Configurations.dbo.ajuste
	SET facturacion_estado = - 1,
		facturacion_fecha = getdate(),
		fecha_modificacion = getdate(),
		usuario_modificacion = @Usuario
	FROM Configurations.dbo.Ajuste aj
	INNER JOIN Configurations.dbo.Facturacion_Items_Ajuste_tmp tmp
		ON tmp.id_ajuste = aj.id_ajuste
	WHERE aj.id_cuenta = @id_cuenta

	RETURN 1;
END

