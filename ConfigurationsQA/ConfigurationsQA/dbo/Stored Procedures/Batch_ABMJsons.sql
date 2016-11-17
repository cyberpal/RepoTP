
CREATE PROCEDURE dbo.Batch_ABMJsons
AS
DECLARE @min_id INT;
                                    
SET NOCOUNT ON;
          TRUNCATE TABLE Configurations.dbo.Jsons_ABM_tmp;


		       SELECT @min_id = MIN(dc.id_detalle_abm_cuenta) - 1
			     FROM Configurations.dbo.Archivo_ABM_Cuenta aa
           INNER JOIN Configurations.dbo.Detalle_ABM_Cuenta dc
                   ON aa.id_archivo_abm_cuenta = dc.id_archivo_abm_cuenta
                WHERE aa.flag_procesado = 1 
				  AND aa.resultado_proceso = 1 
				  AND CAST(aa.fecha_alta AS DATE) = CAST(GETDATE() AS DATE)
	

          INSERT INTO Configurations.dbo.Jsons_ABM_tmp
               SELECT
			          ROW_NUMBER() OVER(ORDER BY aa.id_archivo_abm_cuenta) + @min_id AS id_detalle_abm_cuenta,
					  da.detalle,
                      aa.nombre_archivo,
					  aa.archivo_alta_aceptados,
					  aa.archivo_alta_rechazados,				  
					  '{"tipoCuenta":"'+UPPER(RTRIM(SUBSTRING(da.detalle,28,20)))+
                      '","mail":"'+RTRIM(SUBSTRING(da.detalle,48,50))+
                      '","tipoDocumento":"'+UPPER(RTRIM(SUBSTRING(da.detalle,302,3)))+
                      '","nroDocumento":"'+RTRIM(SUBSTRING(da.detalle,305,12))+
                      '","genero":"'+RTRIM(SUBSTRING(da.detalle,298,1))+
                      '","nombre":"'+RTRIM(SUBSTRING(da.detalle,198,50))+
                      '","apellido":"'+RTRIM(SUBSTRING(da.detalle,248,50))+
                      '","fechaNacimiento":"'+SUBSTRING(da.detalle,317,8)+
                      '","nacionalidad":"'+(CASE WHEN nac.id_nacionalidad IS NULL THEN '' ELSE CAST(nac.id_nacionalidad AS VARCHAR(10)) END)+
                      '","domicilioLegal":{"calle":"'+RTRIM(SUBSTRING(da.detalle,401,30))+
                                          '","numeroCalle":"'+RTRIM(SUBSTRING(da.detalle,431,10))+
                                          '","piso":"'+RTRIM(SUBSTRING(da.detalle,441,10))+
                                          '","departamento":"'+RTRIM(SUBSTRING(da.detalle,451,10))+
                                          '","localidad":"'+RTRIM(SUBSTRING(da.detalle,471,4))+
                                          '","provincia":"'+RTRIM(SUBSTRING(da.detalle,469,2))+
                                          '","codigoPostal":"'+RTRIM(SUBSTRING(da.detalle,461,8))+
                      '"},"domicilioFacturacion":{"calle":"'+RTRIM(SUBSTRING(da.detalle,475,30))+
                                                '","numeroCalle":"'+RTRIM(SUBSTRING(da.detalle,505,10))+
                                                '","piso":"'+RTRIM(SUBSTRING(da.detalle,515,10))+
                                                '","departamento":"'+RTRIM(SUBSTRING(da.detalle,525,10))+
                                                '","localidad":"'+RTRIM(SUBSTRING(da.detalle,545,4))+
                                                '","provincia":"'+RTRIM(SUBSTRING(da.detalle,543,2))+
                                                '","codigoPostal":"'+RTRIM(SUBSTRING(da.detalle,535,8))+
                      '"},'+
                      '"telefonoFijo":"'+RTRIM(SUBSTRING(da.detalle,336,10))+
                      '","operadorCelular":"'+RTRIM(SUBSTRING(da.detalle,325,1))+
                      '","numeroCelular":"'+RTRIM(SUBSTRING(da.detalle,326,10))+
                      '","aceptaTyC":"S"
					    ,"condicionIVA":"'+(CASE WHEN t2.id_tipo IS NULL THEN '' ELSE CAST(t2.id_tipo AS VARCHAR(4)) END)+
                      '","condicionIIBB":"'+(CASE WHEN t3.id_tipo IS NULL THEN '' ELSE CAST(t3.id_tipo AS VARCHAR(4)) END)+
                      '","cuit":'+(CASE WHEN UPPER(RTRIM(SUBSTRING(da.detalle,28,20))) = 'CTA_PARTICULAR' AND LEN(RTRIM(SUBSTRING(da.detalle,549,22))) = 0 THEN 'null' ELSE '"'+RTRIM(SUBSTRING(da.detalle,390,11))+'"' END)+
                      ',"actividad":"'+RTRIM(SUBSTRING(da.detalle,386,4))+
                      '","nombreFantasia":"'+RTRIM(SUBSTRING(da.detalle,98,50))+
                      '","razonSocial":"'+RTRIM(SUBSTRING(da.detalle,148,50))+
                      '","canal":"9"
					    ,"usuarioAlta":"bpbatch"}',-- JSON alta
					  '","banco":null
					    ,"canal":"9"
					    ,"cbus":[{"cbu":"'+RTRIM(SUBSTRING(da.detalle,549,22))+
					  '","tipoCuenta":null
					    ,"nroCuenta":null
						,"cuit":"'+RTRIM(SUBSTRING(da.detalle,390,11))+
					  '","usuarioAlta":"bpbatch"
					    ,"monedaCuenta":null
						,"codBanco":null
						,"tipo_Novedad":"R"}]
					    ,"tipo_acreditacion":"'+RTRIM(SUBSTRING(da.detalle,571,20))+'"}', --JSON CBU
					  CASE WHEN CAST(SUBSTRING(da.detalle,591,10) AS INT)>1 THEN CAST(SUBSTRING(da.detalle,591,10) AS INT) - 1 ELSE CAST(SUBSTRING(da.detalle,591,10) AS INT) END, --cant Mpos
					  aa.id_solicitante_cuenta 
				 FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
           INNER JOIN Configurations.dbo.Archivo_abm_cuenta aa
                   ON aa.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta
            LEFT JOIN Configurations.dbo.Tipo t2
                   ON t2.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,346,20)))
        		  AND t2.id_grupo_tipo = 1 
            LEFT JOIN Configurations.dbo.Tipo t3
                   ON t3.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,366,20)))
        		  AND t3.id_grupo_tipo = 2
			LEFT JOIN Configurations.dbo.Nacionalidad nac 
                   ON nac.codigo = CAST(SUBSTRING(da.detalle,299,3) AS INT)				   
                WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
				  AND aa.flag_procesado = 1 
				  AND aa.resultado_proceso = 1 
				  AND CAST(aa.fecha_alta AS DATE) = CAST(GETDATE() AS DATE);
				 



 RETURN 1;
