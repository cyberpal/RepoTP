
CREATE PROCEDURE dbo.[Batch_ABMCuentas_Parse]
AS
DECLARE @resultado_proceso BIT = 0;
DECLARE @id_proceso INT = 26;
DECLARE @id_log_proceso INT;
DECLARE @cant INT;
DECLARE @archivo_entrada VARCHAR(100) = NULL;
DECLARE @archivo_aceptado VARCHAR(100) = NULL;
DECLARE @archivo_rechazado VARCHAR(100) = NULL;
DECLARE @id_nivel_detalle_global INT;
DECLARE @usuario VARCHAR(7) = 'bpbatch';
DECLARE @id_archivo_abm_cuenta INT;
DECLARE @cant_trailer INT;
DECLARE @cant_header INT;
DECLARE @cant_detalles INT = 0;
DECLARE @cant_tx_trailer INT;
DECLARE @motivo_rechazo VARCHAR(100) = NULL;
DECLARE @id_detalle INT;
DECLARE @fecha_archivo DATETIME = NULL;
CREATE TABLE #info(id_detalle_abm_cuenta INT, id_archivo_abm_cuenta INT);
                                    
SET NOCOUNT ON;
	   

       SELECT TOP 1 @id_archivo_abm_cuenta = (ac.id_archivo_abm_cuenta),
                  @archivo_entrada = REPLACE(ac.nombre_archivo,'.txt','')
             FROM Configurations.dbo.Archivo_ABM_Cuenta ac
       INNER JOIN Configurations.dbo.Detalle_Archivo_ABM_Cuenta_Tmp da
               ON ac.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta
            WHERE ac.flag_procesado = 0
              AND CAST(fecha_alta AS DATE) = CAST(GETDATE() AS DATE);
		
		
		   SELECT TOP 1
                  @fecha_archivo = fecha_archivo
             FROM Configurations.dbo.Archivo_ABM_Cuenta
            WHERE nombre_archivo = @archivo_entrada+'.txt' 
              AND resultado_proceso = 1;
                   
                
           SELECT @cant_trailer = SUM(CASE WHEN SUBSTRING(da.detalle,27,1) = 'T' THEN 1 ELSE 0 END),
                  @cant_header = SUM(CASE WHEN SUBSTRING(da.detalle,27,1) = 'H' THEN 1 ELSE 0 END),
                  @cant_detalles = SUM(CASE WHEN SUBSTRING(da.detalle,27,1) NOT IN ('H','T') THEN 1 ELSE 0 END)
             FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da 
            WHERE da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;
             
              
           SELECT @cant_tx_trailer = CAST(SUBSTRING(da.detalle,86,12) AS INT)
             FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da 
            WHERE SUBSTRING(da.detalle,27,1) = 'T'
              AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;

BEGIN TRY
    BEGIN TRANSACTION;     


    IF(@fecha_archivo IS NOT NULL)
	  BEGIN
	   SET @motivo_rechazo = 'El archivo fue procesado anteriormente';
	  END
    ELSE IF(@cant_trailer <> 1)
      BEGIN
       SET @motivo_rechazo = 'Debe existir un solo trailer en el archivo';
      END
    ELSE IF(@cant_header <> 1)
      BEGIN
       SET @motivo_rechazo = 'Debe existir un solo header en el archivo';
      END  
    ELSE IF(@cant_detalles < 1)
      BEGIN 
       SET @motivo_rechazo = 'Debe existir al menos un detalle en el archivo';
      END
	ELSE IF(@cant_tx_trailer <= 0)
      BEGIN 
       SET @motivo_rechazo = 'La cantidad informada en el trailer tiene que ser mayo a 0';
      END  
    ELSE IF(@cant_detalles <> (@cant_tx_trailer - 2))
      BEGIN 
       SET @motivo_rechazo = 'La cantidad de detalles informada en el archivo no coinciden';
      END       
    ELSE
      BEGIN 
           SET @resultado_proceso = 1; 
             
           SET @archivo_aceptado = @archivo_entrada+'_aceptadas_'+FORMAT(GETDATE(),'yyyyMMddHHmmss');
             
           SET @archivo_rechazado = @archivo_entrada+'_rechazadas_'+FORMAT(GETDATE(),'yyyyMMddHHmmss');


        INSERT INTO Configurations.dbo.Detalle_ABM_Cuenta
             OUTPUT INSERTED.id_detalle_abm_cuenta,
			        INSERTED.id_archivo_abm_cuenta
              INTO  #info       
             SELECT aa.id_archivo_abm_cuenta, -- id_archivo_abm_cuenta
                    RTRIM(SUBSTRING(da.detalle,27,1)), -- tipo_novedad
                    CASE WHEN t.id_tipo IS NULL THEN NULL ELSE t.id_tipo END,  --id_tipo_cuenta
                    CASE WHEN t.id_tipo = 29 THEN RTRIM(SUBSTRING(da.detalle,98,50)) ELSE NULL END, -- nombre_fantASia
                    CASE WHEN t.id_tipo = 29 THEN RTRIM(SUBSTRING(da.detalle,148,50)) ELSE NULL END, -- razon_social
                    CASE WHEN op.id_operador_celular IS NULL THEN NULL ELSE op.id_operador_celular END, -- id_operador_celular
                    RTRIM(SUBSTRING(da.detalle,326,10)), -- telefono_movil
                    RTRIM(SUBSTRING(da.detalle,336,10)), -- telefono_fijo
                    CASE WHEN t1.id_tipo IS NULL THEN NULL ELSE t1.id_tipo END, -- id_tipo_condicion_IVA
                    CASE WHEN t2.id_tipo IS NULL THEN NULL ELSE t2.id_tipo END, -- id_tipo_condicion_IIBB
                    RTRIM(SUBSTRING(da.detalle,386,4)), -- actividad
                    RTRIM(SUBSTRING(da.detalle,390,11)), -- CUIT
                    RTRIM(SUBSTRING(da.detalle,549,22)), -- CBU
                    CASE WHEN t3.id_tipo IS NULL THEN NULL ELSE t3.id_tipo END, -- id_tipo_cAShout
                    CAST(SUBSTRING(da.detalle,591,10) AS INT), -- cantidad_mpos
					1, -- id_modelo_dispositivo_mpos
                    NULL, -- id_cuenta
                    GETDATE(), -- fecha_alta
                    @usuario, -- usuario_alta
                    NULL, -- fecha_modificacion
                    NULL, -- usuario_modificacion
                    NULL, -- fecha_baja,
                    NULL, -- usuario_baja
                    0 -- version
               FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
         INNER JOIN Configurations.dbo.Archivo_abm_cuenta aa
                 ON aa.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta
          LEFT JOIN Configurations.dbo.Tipo t 
                 ON t.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,28,20)))
          LEFT JOIN Configurations.dbo.Tipo t1
                 ON t1.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,346,20)))
                AND t1.id_grupo_tipo = 1 
          LEFT JOIN Configurations.dbo.Tipo t2
                 ON t2.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,366,20)))
                AND t2.id_grupo_tipo = 2
          LEFT JOIN Configurations.dbo.Tipo t3 
                 ON t3.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,571,20))) 
                AND t3.id_grupo_tipo = 18
          LEFT JOIN Configurations.dbo.Operador_Celular op 
                 ON op.id_operador_celular = CAST(SUBSTRING(da.detalle,325,1) AS INT)
              WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
                AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;


		     SELECT @id_detalle = ISNULL(MAX(id_detalle_abm_cuenta),0) FROM Configurations.dbo.Persona_ABM_Cuenta;
				
				
        INSERT INTO Configurations.dbo.Persona_ABM_Cuenta(
		            id_detalle_abm_cuenta,
                    nombre,
                    apellido,
                    email,
                    id_genero,
                    id_nacionalidad,
                    id_tipo_identificacion,
                    numero_identificacion,
                    fecha_nacimiento,
                    fecha_alta,
                    usuario_alta,
                    version)
             SELECT
                    Q1.id_detalle_abm_cuenta,
                    Q1.nombre,
                    Q1.apellido,
                    Q1.email,
                    Q1.id_genero,
                    Q1.id_nacionalidad,
                    Q1.id_tipo_identificacion,
                    Q1.numero_identificacion,
                    Q1.fecha_nacimiento,
                    GETDATE(),
                    @usuario,
                    0
               FROM
                    (SELECT 
			                ROW_NUMBER() OVER(ORDER BY aa.id_archivo_abm_cuenta) + @id_detalle AS id_detalle_abm_cuenta,
                            RTRIM(SUBSTRING(da.detalle,198,50)) AS nombre, -- nombre de contacto
                            RTRIM(SUBSTRING(da.detalle,248,50)) AS apellido , -- apellido contacto
                            RTRIM(SUBSTRING(da.detalle,48,50)) AS email, -- email 
                            RTRIM(SUBSTRING(da.detalle,298,1)) AS id_genero, -- id_genero
                            CASE WHEN nac.id_nacionalidad IS NULL THEN NULL ELSE nac.id_nacionalidad END AS id_nacionalidad, -- id_nacionalidad  
                            CASE WHEN t.id_tipo IS NULL THEN NULL ELSE t.id_tipo END AS id_tipo_identificacion, -- tipo_documento
                            RTRIM(SUBSTRING(da.detalle,305,12)) AS numero_identificacion, -- numero_identificacion
                            CAST(SUBSTRING(da.detalle,317,8) AS DATETIME) AS fecha_nacimiento -- fecha_nacimiento
                       FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
		         INNER JOIN Configurations.dbo.Archivo_ABM_Cuenta aa
		                 ON da.id_archivo_abm_cuenta = aa.id_archivo_abm_cuenta
                  LEFT JOIN Configurations.dbo.Nacionalidad nac 
                         ON nac.codigo = CAST(SUBSTRING(da.detalle,299,3) AS INT) 
                  LEFT JOIN Configurations.dbo.Tipo t 
                         ON t.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,302,3)))
                      WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
                        AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta
                    )Q1
         INNER JOIN
                    (SELECT 
					        id_detalle_abm_cuenta,
			                id_archivo_abm_cuenta
			           FROM #info
                    )Q2 
                 ON Q1.id_detalle_abm_cuenta = Q2.id_detalle_abm_cuenta;
               
                      
        INSERT INTO Configurations.dbo.Domicilio_ABM_Cuenta(
		            id_detalle_abm_cuenta,
                    id_tipo_domicilio,
                    calle,
                    numero,
                    departamento,
                    id_localidad,
                    id_provincia,
                    codigo_postal,
                    fecha_alta,
                    usuario_alta,
                    version)
             SELECT
                    Q1.id_detalle_abm_cuenta,
                    Q1.id_tipo_domicilio,
                    Q1.calle,
                    Q1.numero,
                    Q1.departamento,
                    Q1.id_localidad,
                    Q1.id_provincia,
                    Q1.codigo_postal,
                    GETDATE(),
                    @usuario,
                    0
               FROM
                    (SELECT 
					        ROW_NUMBER() OVER(ORDER BY aa.id_archivo_abm_cuenta) + @id_detalle AS id_detalle_abm_cuenta, -- id_detalle_abm_cuenta
                            t.id_tipo AS id_tipo_domicilio, -- tipo_domicilio
                            RTRIM(SUBSTRING(da.detalle,401,30)) AS calle, -- calle
                            RTRIM(SUBSTRING(da.detalle,431,10)) AS numero, -- nro
                            RTRIM(SUBSTRING(da.detalle,451,10)) AS departamento, -- depto
                            CAST(RTRIM(SUBSTRING(da.detalle,471,4))AS INT) AS id_localidad, -- localidad
                            CAST(RTRIM(SUBSTRING(da.detalle,469,2))AS INT) AS id_provincia,--provincia
                            RTRIM(SUBSTRING(da.detalle,461,8)) AS codigo_postal-- cod postal
                       FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
		         INNER JOIN Configurations.dbo.Archivo_ABM_Cuenta aa
		                 ON da.id_archivo_abm_cuenta = aa.id_archivo_abm_cuenta
                 INNER JOIN Configurations.dbo.Tipo t 
                         ON t.id_tipo = 30 
		              WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
                        AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta
						
					UNION 
					
					SELECT 
					        ROW_NUMBER() OVER(ORDER BY aa.id_archivo_abm_cuenta) + @id_detalle AS id_detalle_abm_cuenta, -- id_detalle_abm_cuenta
                            t.id_tipo AS id_tipo_domicilio, -- tipo_domicilio
                            RTRIM(SUBSTRING(da.detalle,475,30)) AS calle, -- calle
                            RTRIM(SUBSTRING(da.detalle,505,10)) AS numero, -- nro
                            RTRIM(SUBSTRING(da.detalle,525,10)) AS departamento, -- depto
                            CAST(RTRIM(SUBSTRING(da.detalle,545,4))AS INT) AS id_localidad, -- localidad
                            CAST(RTRIM(SUBSTRING(da.detalle,543,2))AS INT) AS id_provincia,--provincia
                            RTRIM(SUBSTRING(da.detalle,535,8)) AS codigo_postal-- cod postal
                       FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da
		         INNER JOIN Configurations.dbo.Archivo_ABM_Cuenta aa
		                 ON da.id_archivo_abm_cuenta = aa.id_archivo_abm_cuenta
                 INNER JOIN Configurations.dbo.Tipo t 
                         ON t.id_tipo = 31 
		              WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')
                        AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta
                    )Q1
         INNER JOIN
                    (SELECT 
					        id_detalle_abm_cuenta,
			                id_archivo_abm_cuenta
			           FROM #info
                    )Q2 
                 ON Q1.id_detalle_abm_cuenta = Q2.id_detalle_abm_cuenta;    
     
      END                    

    UPDATE Configurations.dbo.Archivo_abm_cuenta
       SET cantidad_registros = @cant_detalles,
           archivo_alta_aceptados = @archivo_aceptado,
           archivo_alta_rechazados = @archivo_rechazado,
           flag_procesado = 1,
           resultado_proceso = @resultado_proceso,
           motivo_rechazo = @motivo_rechazo
     WHERE id_archivo_abm_cuenta = @id_archivo_abm_cuenta;
       
    COMMIT TRANSACTION;

    RETURN 1;

END TRY

BEGIN CATCH

    IF (@@TRANCOUNT > 0)
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
