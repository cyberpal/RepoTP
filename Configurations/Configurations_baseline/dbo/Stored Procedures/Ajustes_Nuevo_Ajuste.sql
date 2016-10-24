

CREATE PROCEDURE Ajustes_Nuevo_Ajuste (
	@id_cuenta INT,
	@id_motivo_ajuste INT,
	@importe_neto DECIMAL(12, 2),
	@observaciones VARCHAR(140),
	@usuario VARCHAR(20)
	)
AS
DECLARE @id_ajuste INT;

BEGIN

	SET NOCOUNT ON;
	EXEC Configurations.dbo.Ajustes_Nuevo_Ajuste_Pendiente @id_cuenta,
		@id_motivo_ajuste,
		@importe_neto,
		@observaciones,
		@usuario,
		@id_ajuste OUTPUT;

	EXEC Configurations.dbo.Ajustes_Procesar_Ajuste_Pendiente @id_ajuste,
		@usuario;
	RETURN 1;
END