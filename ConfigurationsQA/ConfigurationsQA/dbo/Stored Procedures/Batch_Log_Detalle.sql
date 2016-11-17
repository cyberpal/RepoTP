--sp_helptext 'Batch_Log_Detalle'

CREATE PROCEDURE [dbo].[Batch_Log_Detalle] (  
 @id_nivel_detalle_global INT,  
 @id_log_proceso INT,  
 @nombre_sp VARCHAR(50),  
 @id_nivel_detalle_lp INT,  
 @detalle VARCHAR(200)  
 )  
AS  
BEGIN  
 SET NOCOUNT ON; 
 
 print 'Id_nivel_detalle_global';  print @id_nivel_detalle_global;
 print 'Id_log_proceso'; print @id_log_proceso; 
 print 'Nombre Sp'; print @nombre_sp;
 print 'Id_nivel_detalle_lp'; print @id_nivel_detalle_lp; 
 print 'Detalle: '+@detalle ;
  
 BEGIN TRANSACTION;  
  
 IF (@id_nivel_detalle_lp <= @id_nivel_detalle_global)  
 BEGIN  
  INSERT Configurations.dbo.Detalle_Log_Proceso  
  VALUES (  
   @id_log_proceso,  
   @nombre_sp,  
   @id_nivel_detalle_lp,  
   GETDATE(),  
   @detalle  
   );  
 END;  
  
 COMMIT TRANSACTION;  
  
 RETURN 1;  
END;

