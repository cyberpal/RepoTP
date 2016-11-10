 CREATE PROCEDURE [dbo].[Batch_ABMCuentas_Parse]  
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
                                      
SET NOCOUNT ON;  
  
        SELECT TOP 1 @id_archivo_abm_cuenta = (ac.id_archivo_abm_cuenta),  
            @archivo_entrada = REPLACE(ac.nombre_archivo,'.txt','')  
       FROM Configurations.dbo.Archivo_ABM_Cuenta ac  
 INNER JOIN Configurations.dbo.Detalle_Archivo_ABM_Cuenta_Tmp da  
         ON ac.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta  
      WHERE ac.flag_procesado = 0  
        AND CAST(fecha_alta AS DATE) = CAST(GETDATE() AS DATE);  
       
       
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
  
    IF(@cant_trailer <> 1)  
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
    ELSE IF(@cant_detalles <> (@cant_tx_trailer - 2))  
      BEGIN   
     SET @motivo_rechazo = 'La cantidad de detalles informada en el archivo no coinciden';  
      END      
    ELSE  
      BEGIN    
     SET @resultado_proceso = 1;   
    
  SET @archivo_aceptado = @archivo_entrada+'_aceptadas';  
    
     SET @archivo_rechazado = @archivo_entrada+'_rechazadas';  
    
        INSERT INTO Configurations.dbo.Detalle_ABM_Cuenta  
             SELECT da.id_archivo_abm_cuenta, -- id_archivo_abm_cuenta  
                    RTRIM(SUBSTRING(da.detalle,27,1)), -- tipo_novedad  
                    t.id_tipo, -- id_tipo_cuenta  
                    CASE WHEN t.id_tipo = 29 THEN RTRIM(SUBSTRING(da.detalle,98,50)) ELSE NULL END, -- nombre de fantasía   
                    CASE WHEN t.id_tipo = 29 THEN RTRIM(SUBSTRING(da.detalle,148,50)) ELSE NULL END, -- razon social  
                    op.id_operador_celular, -- id_opcelular  
                    RTRIM(SUBSTRING(da.detalle,326,10)), -- nro_telefono_movil  
                    RTRIM(SUBSTRING(da.detalle,336,10)), -- nro_telefono_fijo  
                    t1.id_tipo, -- id_tipo_condicion_iva  
                    CASE WHEN t2.id_tipo IS NULL THEN NULL ELSE t2.id_tipo END, -- id_tipo_condicion_iibb  
                    RTRIM(SUBSTRING(da.detalle,386,4)), -- actividad  
                    RTRIM(SUBSTRING(da.detalle,390,11)), -- CUIT  
                    RTRIM(SUBSTRING(da.detalle,549,22)), -- cbu  
                    t3.id_tipo, -- ID_tipo_cashout  
                    CAST(SUBSTRING(da.detalle,591,10) AS INT), -- cantidad_Mpos  
                    1, -- id_modelo  
                    NULL, -- id cuenta  
                    GETDATE(), -- fecha_alta  
                    @usuario, -- usuario_alta  
                    NULL, -- fecha_modificacion  
                    NULL, -- usuario_modificacion  
                    NULL, -- fecha_baja  
                    NULL, -- usuario_baja  
                    0 -- version  
               FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da  
         INNER JOIN Configurations.dbo.Archivo_abm_cuenta aa  
                 ON aa.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta  
         INNER JOIN Configurations.dbo.Tipo t   
                 ON t.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,28,20)))  
         INNER JOIN Configurations.dbo.Tipo t1  
                 ON t1.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,346,20)))  
          AND t1.id_grupo_tipo = 1   
          LEFT JOIN Configurations.dbo.Tipo t2  
                 ON t2.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,366,20)))  
          AND t2.id_grupo_tipo = 2  
         INNER JOIN Configurations.dbo.Tipo t3   
                 ON t3.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,571,20)))   
                AND t3.id_grupo_tipo = 18  
         INNER JOIN Configurations.dbo.Operador_Celular op   
                 ON op.id_operador_celular = CAST(SUBSTRING(da.detalle,325,1) AS INT)  
              WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')  
             AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;    
          
          
          
        INSERT INTO Configurations.dbo.Persona_ABM_Cuenta  
             SELECT dac.id_detalle_abm_cuenta, -- id_detalle_abm_cuenta  
              RTRIM(SUBSTRING(da.detalle,198,50)), -- nombre de contacto  
              RTRIM(SUBSTRING(da.detalle,248,50)), -- apellido contacto  
                 RTRIM(SUBSTRING(da.detalle,48,50)), -- email   
                 RTRIM(SUBSTRING(da.detalle,298,1)), -- id_genero  
                 nac.id_nacionalidad, -- id_nacionalidad    
                 t.id_tipo, -- tipo_documento  
                 RTRIM(SUBSTRING(da.detalle,305,12)), -- numero_identificacion  
                 CAST(SUBSTRING(da.detalle,317,8) AS DATETIME), -- fecha_nacimiento  
                 GETDATE(), -- fecha_alta  
                 @usuario, -- usuario_alta  
                 NULL, -- fecha_modificacion  
                 NULL, -- usuario de modificaciond  
                 NULL, -- fecha_baja  
                 NULL, -- usuario_alta  
                 0 -- version  
            FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da  
         INNER JOIN Configurations.dbo.Detalle_ABM_Cuenta dac   
                 ON dac.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta  
         INNER JOIN Configurations.dbo.Nacionalidad nac   
                 ON nac.id_nacionalidad = CAST(SUBSTRING(da.detalle,299,3) AS INT)   
         INNER JOIN Configurations.dbo.Tipo t   
                 ON t.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,302,3)))  
         INNER JOIN Configurations.dbo.Tipo t1  
                 ON t1.codigo = UPPER(RTRIM(SUBSTRING(da.detalle,28,20)))  
           WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')  
                AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;       
          
             
       
        INSERT INTO Configurations.dbo.Domicilio_ABM_Cuenta  
          SELECT dac.id_detalle_abm_cuenta, -- id_detalle_abm_cuenta  
                    t.id_tipo, -- tipo_domicilio  
                    CASE WHEN t.id_tipo = 30 THEN RTRIM(SUBSTRING(da.detalle,401,30)) ELSE RTRIM(SUBSTRING(da.detalle,475,30)) END, -- calle  
                    CASE WHEN t.id_tipo = 30 THEN RTRIM(SUBSTRING(da.detalle,431,10)) ELSE RTRIM(SUBSTRING(da.detalle,505,10)) END, -- nro  
                    CASE WHEN t.id_tipo = 30 THEN RTRIM(SUBSTRING(da.detalle,451,10)) ELSE RTRIM(SUBSTRING(da.detalle,525,10)) END, -- depto  
                    CASE WHEN t.id_tipo = 30 THEN CAST(RTRIM(SUBSTRING(da.detalle,471,4))AS INT) ELSE CAST(RTRIM(SUBSTRING(da.detalle,545,4))AS INT) END, -- localidad  
                    CASE WHEN t.id_tipo = 30 THEN CAST(RTRIM(SUBSTRING(da.detalle,469,2))AS INT) ELSE CAST(RTRIM(SUBSTRING(da.detalle,543,2))AS INT) END,--provincia  
             CASE WHEN t.id_tipo = 30 THEN RTRIM(SUBSTRING(da.detalle,461,8)) ELSE RTRIM(SUBSTRING(da.detalle,535,8)) END, -- cod postal  
                    GETDATE(), -- fecha_alta  
                    'bpbatch', -- usuario_alta  
                    NULL, -- fecha_modificacion  
                    NULL, -- ususario_modificacion  
                    NULL, -- fecha_baja  
                    NULL, -- usuario_baja  
                    0 -- version  
               FROM Configurations.dbo.Detalle_archivo_abm_cuenta_tmp da  
         INNER JOIN Configurations.dbo.Detalle_ABM_Cuenta dac   
                 ON dac.id_archivo_abm_cuenta = da.id_archivo_abm_cuenta  
         INNER JOIN Configurations.dbo.Tipo t   
                 ON t.id_tipo  = 30 or t.id_tipo = 31       
              WHERE SUBSTRING(da.detalle,27,1) NOT IN ('H','T')   
          AND da.id_archivo_abm_cuenta = @id_archivo_abm_cuenta;  
       
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
