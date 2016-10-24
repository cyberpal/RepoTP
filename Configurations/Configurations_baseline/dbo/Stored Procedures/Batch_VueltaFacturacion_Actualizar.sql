/****** Object:  StoredProcedure [dbo].[Batch_VueltaFacturacion_ObtenerRegistros]    Script Date: 31/07/2015 11:48:04 ******/  
  
CREATE PROCEDURE [dbo].[Batch_VueltaFacturacion_Actualizar] (      
  @Usuario VARCHAR(20),  
  @id_log_paso INT,  
  @Cuenta INT,  
  @vuelta_facturacion varchar(15),  
  @identificador_carga_dwh INT,  
  @impuestos_reales [decimal](18, 2),   
  @tipo_comprobante char(1),  
  @numero_comprobante INT,  
  @fecha_comprobante datetime,  
  @id_item_facturacion INT,  
  @punto_venta char(1),
  @letra_comprobante char(1)  
)  
  
AS    
    
     
  
BEGIN              
   
 SET NOCOUNT ON;        
        
 BEGIN TRY        
     
          
     BEGIN TRANSACTION;        
     
   IF (@vuelta_facturacion<>LTRIM(RTRIM('Procesado')))  
  
    BEGIN  
  
    UPDATE Configurations.dbo.Item_Facturacion   
    SET  
      vuelta_facturacion=@vuelta_facturacion,  
      id_log_vuelta_facturacion=@id_log_paso,  
      identificador_carga_dwh=@identificador_carga_dwh,  
      impuestos_reales=@impuestos_reales,  
      nro_comprobante=@numero_comprobante,  
      fecha_comprobante=@fecha_comprobante,  
      fecha_modificacion=GETDATE(),  
      usuario_modificacion=@Usuario,  
      punto_venta=@punto_venta,
      letra_comprobante=@letra_comprobante  
    WHERE   id_cuenta=@Cuenta  
    AND     vuelta_facturacion=LTRIM(RTRIM('Pendiente'))  
     
      
  
    UPDATE Transactions.dbo.transactions                      
     SET                      
     BillingTimestamp=null,                      
     BillingStatus=0,  
     SyncStatus=0  
     WHERE id in                      
     (       
      select id_transaccion   
      from Configurations.dbo.Detalle_Facturacion dt  
      inner join Configurations.dbo.Item_Facturacion_tmp   
      tmp on dt.id_item_facturacion=@id_item_facturacion and tmp.id_cuenta=@Cuenta                 
     )  
     and BillingTimestamp is not null  
     and BillingStatus=-1  
      
   END  
  
   ELSE  
  
   BEGIN  
  
    UPDATE Configurations.dbo.Item_Facturacion   
    SET  
      vuelta_facturacion=@vuelta_facturacion,  
      id_log_vuelta_facturacion=@id_log_paso,  
      identificador_carga_dwh=@identificador_carga_dwh,  
      impuestos_reales=@impuestos_reales,  
      nro_comprobante=@numero_comprobante,  
      fecha_comprobante=@fecha_comprobante,  
      fecha_modificacion=GETDATE(),  
      usuario_modificacion=@Usuario,  
      punto_venta=@punto_venta,
      letra_comprobante=@letra_comprobante  
    WHERE   id_cuenta=@Cuenta  
    AND     vuelta_facturacion=LTRIM(RTRIM('Pendiente'))  
    AND     tipo_comprobante=@tipo_comprobante  
  
   END  
  
  
   COMMIT TRANSACTION;        
      RETURN 1;    
   
 END TRY            
        
 BEGIN CATCH            
   
   ROLLBACK TRANSACTION;              
   RETURN 0;    
   
 END CATCH            
  
END  