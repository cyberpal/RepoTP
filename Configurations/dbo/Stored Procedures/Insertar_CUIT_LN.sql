/*
=============================================

Author:		 Mariela Romero
Create date: 09/09/2015
Description: Inserta CUITs en Lista negra validando longitud, formato y que no se encuentre en la tabla de LN
Origen:		 TPAGO-1145

Casos de prueba:

-- formato inválido
exec Insertar_CUIT_LN '987654gdg32100'
GO
-- longitud mayor
exec Insertar_CUIT_LN '98765432555100'	
GO
-- longitud menor
exec Insertar_CUIT_LN '987654300'	
GO
-- ok
exec Insertar_CUIT_LN '98765432102'	
GO
-- duplicado
exec Insertar_CUIT_LN '98765432102'	
GO

=============================================
*/
CREATE PROCEDURE [dbo].[Insertar_CUIT_LN] (
	@cuit varchar(20) 
)
AS
BEGIN

declare @mensaje varchar(100)

-- verifica no sea null
IF (@cuit is null)
 begin
	set @mensaje = 'ERROR: CUIT Nulo'
    ;THROW 51000, @mensaje, 1;
 end

-- verifica formato
BEGIN TRY
	 declare @big bigint
	 set @big = cast(@cuit as bigint)
END TRY
BEGIN CATCH
	set @mensaje = 'ERROR: CUIT ' + @CUIT + ' tiene formato inválido'
    ;THROW 51000, @mensaje, 1;
END CATCH

-- verifica longitud
IF (len(@cuit) <> 11)
 begin
	set @mensaje = 'ERROR: CUIT ' + @CUIT + ' tiene una longitud inválida'
    ;THROW 51000, @mensaje, 1;
 end

-- verifica unicidad
IF NOT EXISTS (
	SELECT * FROM Lista_Negra_CUIT where CUIT = @cuit and Usuario_Baja IS NULL
)
 begin
	INSERT INTO Lista_Negra_CUIT (CUIT, fecha_alta, usuario_alta)
	VALUES (@cuit, getdate(), 'Script')
	
	print 'OK: CUIT ' + @CUIT + ' Insertado'
 end
else 
 begin
	set @mensaje = 'ERROR: CUIT ' + @CUIT + ' ya se encuentra en la Lista Negra de CUITs'
    ;THROW 51000, @mensaje, 1;
 end

END
