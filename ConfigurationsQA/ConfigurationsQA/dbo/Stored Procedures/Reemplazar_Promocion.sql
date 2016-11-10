
CREATE PROCEDURE [dbo].[Reemplazar_Promocion] (
  @id_promocion          INT,
  @id_cuenta             INT,
  @fecha_inicio_vigencia DATE,
  @fecha_fin_vigencia    DATE,
  @usuario               VARCHAR(20),
  @id_promocion_clon     INT OUTPUT
)
AS
BEGIN

  SET NOCOUNT ON;
  EXEC [Configurations].[dbo].[Borrar_Promociones]  @id_promocion,
                                                    @id_cuenta,
                                                    @fecha_inicio_vigencia,
                                                    @fecha_fin_vigencia,
                                                    @usuario;

  EXEC [Configurations].[dbo].[Clonar_Promocion]  @id_promocion,
                                                  @id_cuenta,
                                                  @fecha_inicio_vigencia,
                                                  @fecha_fin_vigencia,
                                                  @usuario,
                                                  @id_promocion_clon OUTPUT;
  RETURN @id_promocion_clon;


END;

