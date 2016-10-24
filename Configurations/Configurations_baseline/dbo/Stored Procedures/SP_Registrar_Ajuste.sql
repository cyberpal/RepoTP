  
CREATE PROCEDURE [dbo].[SP_Registrar_Ajuste] (            
    @Id_cuenta INT=NULL,  
    @Monto decimal(12, 2)=NULL,  
    @Id_codigoOperacion INT=NULL,  
    @Id_MotivoAjuste INT=NULL,  
    @Id_TipoOrigenMovimiento INT=NULL,  
    @Id_TipoMovimiento INT=NULL,  
    @usuario VARCHAR(20)=NULL,  
    @Id_log_proceso INT=NULL,  
    @canal INT=NULL,
    @Msg VARCHAR(max) OUTPUT,  
    @CodRet VARCHAR(max) OUTPUT  
)  
  
AS   
   
  DECLARE @v_idAjuste INT;  
  DECLARE @Flag_OK_CV INT;  
  DECLARE @tipo_mov_cred INT;  
  DECLARE @tipo_mov_deb INT  
  DECLARE @cod_oper_AJN INT;  
  DECLARE @cod_oper_AJP INT  
  

BEGIN
     
SET NOCOUNT ON            
        
BEGIN TRANSACTION;

 BEGIN TRY   
     
	 --1. Establecer valores para salida correcta 
	 SET  @CodRet='00000'; 

	 SELECT @Msg = mensaje from Mensaje  
     WHERE codigo_mensaje = 0  
     
	 --2. Validaciones
     IF (@Id_cuenta IS NULL OR @Id_cuenta = 0 OR                
		 @Monto IS NULL OR @Monto = 0  OR          
		 @Id_codigoOperacion IS NULL OR @Id_codigoOperacion = 0 OR  @Id_codigoOperacion not in (4,5) or
		 @Id_MotivoAjuste IS NULL OR @Id_MotivoAjuste = 0 OR    
		 @Id_TipoOrigenMovimiento IS NULL OR @Id_TipoOrigenMovimiento = 0 OR   
		 @Id_TipoMovimiento IS NULL OR @Id_TipoMovimiento = 0 OR @Id_TipoMovimiento not in (57,58) or            
		 @usuario IS NULL OR @usuario = '' OR
		 @canal IS NULL)  
  
		 BEGIN  
  
		 SET @CodRet='2059'  
       
		 SELECT @Msg = mensaje from Mensaje  
		 WHERE codigo_mensaje = 2059  
  
		 END  
  
      ELSE  
  
		 BEGIN  
     
		  --3. Validacion de parametros (tipo movimiento y codigo de operacion)
		  SELECT @tipo_mov_cred=tpo_1.id_tipo, @tipo_mov_deb=tpo_2.id_tipo 
		  FROM configurations.dbo.Tipo tpo_1 , configurations.dbo.Tipo tpo_2
		  WHERE tpo_1.codigo = 'MOV_CRED' AND tpo_1.id_grupo_tipo = 16   
		  AND   tpo_2.codigo = 'MOV_DEB' AND tpo_2.id_grupo_tipo = 16

		  SELECT @cod_oper_AJN=Cod_1.id_codigo_operacion , @cod_oper_AJP=Cod_2.id_codigo_operacion
		  FROM Configurations.dbo.Codigo_Operacion Cod_1, Configurations.dbo.Codigo_Operacion Cod_2
		  WHERE Cod_1.codigo_operacion='AJN'  AND Cod_2.codigo_operacion='AJP'  
  
		  IF ((@Id_TipoMovimiento=@tipo_mov_cred and @monto<0) or (@Id_TipoMovimiento=@tipo_mov_deb and @monto>0)  
			  or (@Id_codigoOperacion=@cod_oper_AJN and @monto>0) or (@Id_codigoOperacion=@cod_oper_AJP and @monto<0))  
  
				  BEGIN
				  
				  SET @CodRet='2057'  
       
				  SELECT @Msg = mensaje from Mensaje WHERE codigo_mensaje = 2057;  
		    
				  END       
           ELSE  
           
			       BEGIN
				     
					 --4. Insertar en cuenta virtual
					 EXECUTE @Flag_OK_CV=Configurations.dbo.Actualizar_Cuenta_Virtual   
					   @Monto,   
					   null,   
					   @Monto,   
					   null,   
					   null,  
					   null,  
					   @Id_cuenta,  
					   @Usuario,   
					   @Id_TipoMovimiento, 
					   @Id_TipoOrigenMovimiento,   
					   @Id_log_proceso;  

					   --5. Generar ID para nuevo ajuste     
					   SET @v_idAjuste = (SELECT ISNULL(MAX(id_ajuste),0) + 1 FROM Configurations.dbo.Ajuste);  


						--6. Insertar en ajuste
					   INSERT INTO [dbo].[Ajuste](  
						  [id_ajuste],  
						  [id_codigo_operacion],  
						  [id_cuenta],  
						  [id_motivo_ajuste],  
						  [monto],  
						  [estado_ajuste],  
						  [fecha_alta],  
						  [usuario_alta],  
						  [version])  
						VALUES(@v_idAjuste,   
						  @Id_codigoOperacion, 
						  @Id_cuenta,  
						  @Id_MotivoAjuste,
						  @Monto,  
						  'TX_APROBADA',  
						  GETDATE(),  
						  @usuario,  
						  0);
					END	  
						
				END
     
	 COMMIT TRANSACTION;  
 
 END TRY  


  
 BEGIN CATCH   
 
	    
     IF (@@TRANCOUNT > 0)
   

		ROLLBACK TRANSACTION;     
    
		--7. Devolucion de mensaje y codigo para para deshacer cuenta virtual y ajuste en la operacion
		SET  @CodRet='2057' 
		SELECT @Msg = mensaje from configurations.dbo.Mensaje WHERE codigo_mensaje = 2057  
	
 END CATCH  
   
            
 END