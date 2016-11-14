
CREATE PROCEDURE [dbo].[Batch_Fact_Calcular_Ciclo_Facturacion] (
	@FechaDesde DATETIME OUTPUT,
	@FechaHasta DATETIME OUTPUT,
	@CicloFacturacion INT OUTPUT
	)
AS

DECLARE @FechaInicioProceso DATETIME
DECLARE @FechaFinProceso DATETIME
DECLARE @IdCicloFacturacion INT

SET NOCOUNT ON;

BEGIN

		DECLARE @ultDiaMes int =
		DATEPART(dd,EOMONTH (
		CAST(
		DATEFROMPARTS(
		DATEPART(YYYY,DATEADD(MM, -1, GETDATE())),
		DATEPART(MM, DATEADD(MM, -1, GETDATE())),--mes anterior
		DATEPART(DD, DATEADD(MM, -1, GETDATE()))
		) AS DATETIME)
		));
		SELECT
		@FechaInicioProceso=
		CAST(
		DATEFROMPARTS(
		DATEPART(YYYY, DATEADD(MM, cfo.meses_desplazamiento, GETDATE())),
		DATEPART(MM, DATEADD(MM, cfo.meses_desplazamiento, GETDATE())),
		cfo.dia_inicio
		)
		AS DATETIME),
		@FechaFinProceso=
		DATEADD(SS, -1,
		DATEADD(DD, 1,
		CAST(
		DATEFROMPARTS(
		DATEPART(YYYY, DATEADD(MM, cfo.meses_desplazamiento, GETDATE())),
		DATEPART(MM, DATEADD(MM, cfo.meses_desplazamiento, GETDATE())),
		IIF(cfo.dia_tope_incluido>@ultDiaMes ,@ultDiaMes, cfo.dia_tope_incluido)
		)
		AS DATETIME)
		)
		),
		@IdCicloFacturacion=cfo.id_ciclo_Facturacion
		FROM Configurations.dbo.Ciclo_Facturacion cfo 
		WHERE cfo.dia_de_ejecucion = DATEPART(DD, GETDATE())

			
	SET @FechaDesde=@FechaInicioProceso;
	SET @FechaHasta=@FechaFinProceso;
	SET @CicloFacturacion=@IdCicloFacturacion;
	
	RETURN 1;

END


