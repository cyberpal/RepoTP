
CREATE PROCEDURE dbo.Batch_ABMCuentas_Parse
AS
DECLARE @archivo_entrada  VARCHAR(100) = NULL;
DECLARE @id INT;
DECLARE @cant INT;

                                     
SET NOCOUNT ON;
	

	SELECT TOP 1 @id = (ac.id),
	             @archivo_entrada = REPLACE(ac.nombre_archivo,'.txt','') 
	      FROM Configurations.dbo.Archivo_abm_cuenta ac
	INNER JOIN Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
	        ON ac.id = da.id_archivo
	     WHERE ac.flag_procesado = 0
	       AND CAST(fecha AS DATE)=CAST(GETDATE() AS DATE);
	

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO Configurations.dbo.Info_archivo_abm_cuenta_Tmp
         SELECT da.id_detalle,--id detalle
	            da.detalle,-- detalle
	            @archivo_entrada,--nombre archivo alta
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,1,20)) ELSE NULL END,--codigo solicitante
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,21,6)AS INT) ELSE NULL END,--Nro solicitud
                RTRIM(SUBSTRING(da.detalle,27,1)),--tipo novedad
	            CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,28,20)) ELSE NULL END,--tipo cuenta 
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,48,50)) ELSE NULL END,--email
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,98,50)) ELSE NULL END,--nombre de fantasía
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,148,50)) ELSE NULL END,--razon social
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,198,50)) ELSE NULL END,--Nombre / contacto de la empresa
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,248,50)) ELSE NULL END,--Apellido / Contacto Empresa
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,298,1)) ELSE NULL END,--genero
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,299,3)AS INT) ELSE NULL END,--nacionalidad
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,302,3)) ELSE NULL END,--id tipo doc
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,305,12)) ELSE NULL END,--nro_doc
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN SUBSTRING(da.detalle,317,8) ELSE NULL END,--fechanac
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,325,1) AS INT) ELSE NULL END,--opcelu
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,326,10)) ELSE NULL END,--nro_celu
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,336,10)) ELSE NULL END,--nro_tel
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,346,20)) ELSE NULL END,--cond_iva
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,366,20)) ELSE NULL END,--cond_iibb
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,386,4)) ELSE NULL END,--actividad
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN SUBSTRING(da.detalle,390,11) ELSE NULL END,--CUIT
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,401,30)) ELSE NULL END,--callelegal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,431,10)) ELSE NULL END,--nro_legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,441,10)) ELSE NULL END,--piso_legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,451,10)) ELSE NULL END,--depto_legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,461,8)) ELSE NULL END,--cod postal legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,469,2) AS INT) ELSE NULL END,--id prov legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,471,4)) ELSE NULL END,--loc_legal
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,475,30)) ELSE NULL END,--calle facturacion
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,505,10)) ELSE NULL END,--nro_dom_facturacion
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,515,10)) ELSE NULL END,--piso_fac
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,525,10)) ELSE NULL END,--depto_fac
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,535,8)) ELSE NULL END,--cod_post_fact
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,543,2) AS INT) ELSE NULL END,--id_prov_fac
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,545,4)) ELSE NULL END,--loc_fact
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,549,22)) ELSE NULL END,--cbu
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,571,20)) ELSE NULL END,--tipo cashout
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN CAST(SUBSTRING(da.detalle,591,10) AS INT) ELSE NULL END,--cant_Mpos
                CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN RTRIM(SUBSTRING(da.detalle,601,20)) ELSE NULL END,--costo_Mpos
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN 9 ELSE NULL END,
		        CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN 'S' ELSE NULL END
           FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da 
          WHERE da.id_archivo = @id;
                   
				   
	SELECT @cant = COUNT(1) FROM Configurations.dbo.Info_archivo_abm_cuenta_Tmp WHERE Tipo_Novedad NOT IN ('H','T');

	UPDATE Configurations.dbo.Archivo_abm_cuenta
	   SET cantidad_registros = @cant,
	       archivo_alta_aceptados = @archivo_entrada+'_aceptadas',
		   archivo_alta_rechazados = @archivo_entrada+'_rechazadas',
		   flag_procesado = 1
	 WHERE id = @id;
	
    COMMIT TRANSACTION;

    RETURN 1;

END TRY

BEGIN CATCH

    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;