
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Ajuste_ObtenerRegistros] (
	@fecha_fin_proceso DATETIME = NULL,
	@Usuario VARCHAR(20),
	@cant_items_ajuste INT OUTPUT
	)
AS
SET NOCOUNT ON;

DECLARE @I INT;

BEGIN
	INSERT INTO [dbo].[Facturacion_Items_Ajuste_tmp] (
		[I],
		[id_ajuste],
		[id_cuenta],
		[id_motivo_ajuste],
		[estado_ajuste],
		[signo],
		[monto_neto],
		[monto_impuesto],
		[fecha_alta],
		[usuario_alta]
		)
	SELECT ROW_NUMBER() OVER (
			ORDER BY id_cuenta
			) AS I,
		f.[id_ajuste],
		f.[id_cuenta],
		f.[id_motivo_ajuste],
		f.[estado_ajuste],
		f.[signo],
		f.[monto_neto],
		f.[monto_impuesto],
		f.[fecha_alta],
		f.[usuario_alta]
	FROM (
		SELECT aj.id_ajuste,
			aj.id_cuenta,
			aj.id_motivo_ajuste,
			aj.estado_ajuste,
			CASE 
				WHEN maj.signo = '+'
					THEN 'C'
				ELSE 'F'
				END AS signo,
			aj.monto_neto,
			aj.monto_impuesto,
			getdate() AS fecha_alta,
			@Usuario AS usuario_alta
		FROM configurations.dbo.Ajuste aj
		INNER JOIN Configurations.dbo.Motivo_Ajuste maj
			ON maj.id_motivo_ajuste = aj.id_motivo_ajuste
				AND maj.facturable = 1
		INNER JOIN Configurations.dbo.Estado e
			ON e.id_estado = aj.estado_ajuste
				AND e.Codigo = 'AJUSTE_PROCESADO'
		WHERE aj.fecha_alta <= @fecha_fin_proceso
			AND (
				aj.facturacion_estado = 0
				OR aj.facturacion_estado IS NULL
				)
		) f;

	SET @cant_items_ajuste = @@ROWCOUNT

	RETURN 1;
END
