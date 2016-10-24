
CREATE PROCEDURE [dbo].[Obtener_Ciclo_Facturacion] (
	@ciclos_desplazamiento INT = 0,
	@fecha_base DATETIME,
	@id_ciclo_facturacion INT OUTPUT,
	@dia_de_ejecucion INT OUTPUT,
	@fecha_desde DATETIME OUTPUT,
	@fecha_hasta DATETIME OUTPUT
	)
AS
DECLARE @ultimo_dia_del_mes INT;

BEGIN
	SET NOCOUNT ON;

	-- Si no se indicó Fecha Base, asumir la de hoy.
	IF (@fecha_base IS NULL)
		SET @fecha_base = getdate();
	-- Obtener el último día del mes de la Fecha Base
	SET @ultimo_dia_del_mes = day(eomonth(@fecha_base));

	-- Determinar el Ciclo correspondiente a la Fecha Base
	SELECT @id_ciclo_facturacion = id_ciclo_facturacion,
		@dia_de_ejecucion = dia_de_ejecucion,
		@fecha_desde = datefromparts(year(@fecha_base), month(@fecha_base), dia_inicio),
		@fecha_hasta = datefromparts(year(@fecha_base), month(@fecha_base), iif(@ultimo_dia_del_mes < dia_tope_incluido, @ultimo_dia_del_mes, dia_tope_incluido))
	FROM Configurations.dbo.Ciclo_Facturacion
	WHERE day(@fecha_base) BETWEEN dia_inicio
			AND dia_tope_incluido;

	-- Incluir hora 23:59:59 en la fecha final del rango
	SET @fecha_hasta = dateadd(s, - 1, dateadd(day, 1, @fecha_hasta));

	-- Si hay que desplazarse en Ciclos, reclacular la Fecha Base y reparametrizar el SP
	IF (@ciclos_desplazamiento <> 0)
	BEGIN
		-- Fecha Base:
		-- + Para desplazamiento negativo, obtener un día antes de la fecha inicial del ciclo
		-- + Para desplazamiento positivo, obtener un día despues de la fecha final del ciclo
		SET @fecha_base = dateadd(day, @ciclos_desplazamiento, iif(@ciclos_desplazamiento < 0, @fecha_desde, @fecha_hasta));
		-- Restar un ciclo de desplazamiento
		SET @ciclos_desplazamiento += iif(@ciclos_desplazamiento > 0, - 1, 1);

		EXEC Configurations.dbo.Obtener_Ciclo_Facturacion @ciclos_desplazamiento,
			@fecha_base,
			@id_ciclo_facturacion OUTPUT,
			@dia_de_ejecucion OUTPUT,
			@fecha_desde OUTPUT,
			@fecha_hasta OUTPUT;
	END;

	RETURN 1;
END;
