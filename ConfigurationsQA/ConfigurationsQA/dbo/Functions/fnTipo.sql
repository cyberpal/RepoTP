CREATE FUNCTION dbo.fnTipo (@id_grupo int=null,@nombre varchar(50)=null) RETURNS Table
AS
RETURN
(
	SELECT	 Tipo.Id_tipo
			,Tipo.Codigo
			,Tipo.Descripcion
			,Tipo.Id_grupo_tipo
			,Grupo_Tipo.Nombre
	FROM Tipo
			INNER JOIN Grupo_Tipo
				ON Tipo.Id_grupo_tipo = Grupo_Tipo.Id_grupo_tipo
	WHERE	Grupo_Tipo.Id_grupo_tipo	= ISNULL(@id_grupo,Grupo_Tipo.Id_grupo_tipo) AND
			Grupo_Tipo.Nombre			= ISNULL(@nombre,Grupo_Tipo.Nombre)
);