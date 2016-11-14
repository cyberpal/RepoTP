CREATE PROCEDURE [dbo].[Batch_VencMediosDePago_ObtenerRegistros] (            
  @Usuario VARCHAR(20)        
        
)        
        
AS          
  DECLARE @rows INT;          
  DECLARE @I INT;                
          
        
BEGIN                    
 SET NOCOUNT ON;              
              
 BEGIN TRY              
          
  TRUNCATE TABLE Configurations.dbo.VencMediosDePago_tmp;              
                
  BEGIN TRANSACTION;              
               
  INSERT INTO [dbo].[VencMediosDePago_tmp] (        
   [I],        
   [id_medio_pago_cuenta],        
   [id_cuenta],        
   [codigo],        
   [denominacion1],        
   [denominacion2],        
   [mascara_numero_tarjeta],        
   [eMail],        
   [fecha_vencimiento],        
   [flag_tipo_de_medio]             
   )        
  SELECT ROW_NUMBER() OVER (        
    ORDER BY id_cuenta        
    ) AS I,        
   f.[id_medio_pago_cuenta],        
   f.[id_cuenta],        
   f.[codigo],        
   f.[denominacion1],        
   f.[denominacion2],        
   f.[mascara_numero_tarjeta],        
   f.[eMail],        
   f.[fecha_vencimiento],        
   f.[flag_tipo_de_medio]           
  FROM (        
   SELECT          
    mpc.id_medio_pago_cuenta,        
    mpc.id_cuenta,        
    mp.codigo,         
    cta.denominacion1,        
    cta.denominacion2,        
    mpc.mascara_numero_tarjeta,        
    ucta.eMail,        
    mpc.fecha_vencimiento,        
    'Vencidos' as flag_tipo_de_medio            
    FROM Configurations.dbo.Medio_Pago_Cuenta mpc        
    INNER JOIN configurations.dbo.Cuenta cta ON mpc.id_cuenta = cta.id_cuenta        
    INNER JOIN configurations.dbo.Usuario_Cuenta ucta ON mpc.id_cuenta = ucta.id_cuenta        
    INNER JOIN configurations.dbo.Medio_de_Pago mp ON mpc.id_medio_pago = mp.id_medio_pago        
    INNER JOIN Configurations.dbo.Estado est ON mpc.id_estado_medio_pago = est.id_estado        
    WHERE est.Codigo = 'MP_HABILITADO'        
    AND (RIGHT(mpc.fecha_vencimiento, 4) + LEFT(mpc.fecha_vencimiento, 2)) < (cast(year(getdate()) AS VARCHAR)) + RIGHT ('00' + CAST (MONTH(GETDATE()) AS VARCHAR),2)        
   UNION ALL        
   SELECT         
    mpc.id_medio_pago_cuenta,        
    mpc.id_cuenta,         
    mp.codigo,         
    cta.denominacion1,         
    cta.denominacion2,        
    mpc.mascara_numero_tarjeta,        
    utca.eMail,         
    mpc.fecha_vencimiento,         
    'AVencer' as flag_tipo_de_medio         
    FROM configurations.dbo.medio_pago_cuenta mpc        
    INNER JOIN configurations.dbo.Cuenta cta ON mpc.id_cuenta = cta.id_cuenta        
    INNER JOIN configurations.dbo.Usuario_Cuenta utca ON mpc.id_cuenta = utca.id_cuenta   
    INNER JOIN configurations.dbo.Medio_de_Pago mp ON mpc.id_medio_pago = mp.id_medio_pago        
    INNER JOIN Configurations.dbo.Estado est ON mpc.id_estado_medio_pago = est.id_estado        
    WHERE est.Codigo in ('MP_HABILITADO','MP_PEND_HABILITAR')        
    AND (RIGHT(mpc.fecha_vencimiento, 4) + LEFT(mpc.fecha_vencimiento, 2)) = (cast(year(getdate()) AS VARCHAR)) + RIGHT ('00' + CAST (MONTH(GETDATE()) AS VARCHAR),2)        
    AND mpc.medio_notificado  = 0         
   )f;        
        
           
 SET @rows = @@ROWCOUNT;          
   COMMIT TRANSACTION;              
      RETURN @rows;          
 END TRY                  
              
 BEGIN CATCH                  
   ROLLBACK TRANSACTION;                    
   RETURN 0;          
 END CATCH                  
        
END   
  
  
  
  
  
  


----------------------------------

