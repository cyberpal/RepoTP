
CREATE PROCEDURE [dbo].[Batch_ABMJsons]
AS

                                    
SET NOCOUNT ON;
          TRUNCATE TABLE Configurations.dbo.Jsons_ABM_tmp;
	

          INSERT INTO Configurations.dbo.Jsons_ABM_tmp
               SELECT  
                      dc.id_detalle_abm_cuenta,	
					  da.detalle,
                      REPLACE(aa.nombre_archivo,'.txt',''),					  
					  '{"tipoCuenta":"'+UPPER(RTRIM(SUBSTRING(da.detalle,28,20)))+
                      '","mail":"'+RTRIM(SUBSTRING(da.detalle,48,50))+
                      '","tipoDocumento":"'+UPPER(RTRIM(SUBSTRING(da.detalle,302,3)))+
                      '","nroDocumento":"'+RTRIM(SUBSTRING(da.detalle,305,12))+
                      '","genero":"'+RTRIM(SUBSTRING(da.detalle,298,1))+
                      '","nombre":"'+RTRIM(SUBSTRING(da.detalle,198,50))+
                      '","apellido":"'+RTRIM(SUBSTRING(da.detalle,248,50))+
                      '","fechaNacimiento":"'+SUBSTRING(da.detalle,317,8)+
                      '","nacionalidad":"'+RTRIM(SUBSTRING(da.detalle,299,3))+
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
					    ,"condicionIVA":"'+CAST(t2.id_tipo AS VARCHAR(3))+
                      '","condicionIIBB":"'+(CASE WHEN t3.id_tipo IS NULL THEN '' ELSE CAST(t3.id_tipo AS VARCHAR(3)) END)+
                      '","cuit":"'+(CASE WHEN UPPER(RTRIM(SUBSTRING(da.detalle,346,20))) = 'IVA_CONS_FINAL' THEN '' ELSE RTRIM(SUBSTRING(da.detalle,390,11)) END)+
                      '","actividad":"'+RTRIM(SUBSTRING(da.detalle,286,4))+
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
					  CASE WHEN CAST(SUBSTRING(da.detalle,591,10) AS INT)>0 THEN CAST(SUBSTRING(da.detalle,591,10) AS INT) - 1 ELSE CAST(SUBSTRING(da.detalle,591,10) AS INT) END, --cant Mpos
					  aa.id_solicitante_cuenta 
				 FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
           INNER JOIN Configurations.dbo.Archivo_abm_cuenta aa
                   ON aa.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta
           INNER JOIN Configurations.dbo.Tipo t2
                   ON t2.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,346,20)))
        		  AND t2.id_grupo_tipo = 1 
            LEFT JOIN Configurations.dbo.Tipo t3
                   ON t3.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,366,20)))
        		  AND t3.id_grupo_tipo = 2
           INNER JOIN Configurations.dbo.Operador_Celular op 
                   ON op.id_operador_celular = CAST(SUBSTRING(da.detalle,325,1) AS INT)
		   INNER JOIN Configurations.dbo.Detalle_ABM_Cuenta dc
                   ON dc.CUIT = RTRIM(SUBSTRING(da.detalle,390,11))					   
                WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
				  AND aa.flag_procesado = 1 
				  AND aa.resultado_proceso = 1 
				  AND CAST(aa.fecha_alta AS DATE) = CAST(GETDATE() AS DATE);
				 

 RETURN 1;
