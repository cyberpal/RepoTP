

CREATE PROCEDURE [dbo].[Batch_Liq_PC_Main] (@Usuario VARCHAR(20))
AS
DECLARE @id_proceso INT = 25;--actualizar id_proceso generado por Aldana
DECLARE @fecha_proceso DATETIME;
DECLARE @fecha_ult_proceso DATETIME;
DECLARE @ret_code INT = 1;
DECLARE @id_pr1 INT;--id_promocion 1
DECLARE @id_tipo_ap_pr1 INT;--id_tipo_aplicacion 1

DECLARE @id_log_proceso INT;
declare @ret_log_paso_tablas INT;
declare @id_log_paso INT;
DECLARE @flag_ok INT;
declaRE @Registros_Procesados INT;
declare @Total_Medios_Pago_Validos int = 0;
declare @Total_Cuentas_a_Bonificar Int
declare @Total_Cuentas_Bonificadas int
declare @cant_Mails_A_Enviar Int

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
 
	begin transaction

	EXEC @id_log_proceso = Configurations.dbo.Iniciar_Log_Proceso @id_proceso,null,NULL,@Usuario;
	
	SET @fecha_proceso = DATEADD(day, - 1, GETDATE());

	SELECT @fecha_ult_proceso = MAX(fecha_fin_ejecucion)
	FROM Configurations.dbo.Log_Proceso lpo
	WHERE id_proceso = @id_proceso;

	EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
    1,
    'Selección de Promociones Vigentes',
    NULL,
    @Usuario,
    @id_log_paso OUTPUT;

	EXEC @flag_ok =  Configurations.dbo.Batch_Liq_PC_Obtener_Promos_Vigentes @fecha_proceso,@fecha_ult_proceso,
	@id_pr1 output,@id_tipo_ap_pr1 output,@Registros_Procesados output
	--Obtener promociones vigentes en una fila

	--PRINT '@Registros_Procesados = ' + ISNULL(CAST(@Registros_Procesados AS VARCHAR(20)), 'NULL');
	
	EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso,null, null,@flag_ok, null,@Registros_Procesados
	,null,null,null,null,null,null,null,@Usuario


	IF(@id_pr1 <> -1 and @flag_ok = 1)
	BEGIN
		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
		2,
		'Evaluación de Promociones',
		NULL,
		@Usuario,
		@id_log_paso OUTPUT;
	  --aplica promo 1

	  EXEC @flag_ok =  Configurations.dbo.Batch_Liq_PC_Proc_Primera_Adhesion @id_pr1, @id_tipo_ap_pr1, @fecha_ult_proceso,@Usuario,
	  @Total_Medios_Pago_Validos OUTPUT

	  EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso,null, null,@flag_ok, null,@Total_Medios_Pago_Validos
	  ,null,null,null,null,null,null,null,@Usuario
	END;



	--IF(@id_pr2 <> -1)
	--BEGIN
	  --aplica promo 2
	--EXEC Configurations.dbo.Batch_Liq_PC_Proc_2 @id_pr2, @id_tipo_ap_pr2;
	--END;

	if ( @id_pr1 <> -1 and @flag_ok = 1)
	BEGIN

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
		3,
		'Afectación de Saldo en Cuenta',
		NULL,
		@Usuario,
		@id_log_paso OUTPUT;

		EXEC @flag_ok = Configurations.dbo.Batch_Liq_PC_Afectacion_Saldo_Cuenta @fecha_proceso,@Usuario,@id_log_proceso,
		@Total_Cuentas_a_Bonificar OUTPUT

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso,null, null,@flag_ok, null,
		@Total_Cuentas_a_Bonificar,null,null,null,null,null,null,null,@Usuario

		IF (@flag_ok = 0)
		BEGIN
			PRINT '@id_pr1= ' + @id_pr1;
			PRINT 'Batch_Liq_PC_Main - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
		END;
	END;
			
	------------

	if ( @id_pr1 <> -1 and @flag_ok = 1)
	BEGIN

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
		4,
		'Control Bonificación Disponible',
		NULL,
		@Usuario,
		@id_log_paso OUTPUT;

		EXEC @flag_ok = Configurations.dbo.Batch_Liq_PC_Control_Bonificacion_Disponible @fecha_proceso,@Usuario,@id_log_proceso,
		@Total_Cuentas_Bonificadas OUTPUT

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso,null, null,@flag_ok, null,
		@Total_Cuentas_Bonificadas,null,null,null,null,null,null,null,@Usuario

		IF (@flag_ok = 0)
		BEGIN
			PRINT '@id_pr1= ' + @id_pr1;
			PRINT 'Batch_Liq_PC_Main - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
		END;
	END;
	------------

	
	--if ( @id_pr1 <> -1 and @flag_ok = 1)
	BEGIN

	
		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Iniciar_Paso @id_log_proceso,
		5,
		'Carga de Promociones en Tabla Temporal',
		NULL,
		@Usuario,
		@id_log_paso OUTPUT;
		

		EXEC @flag_ok = Configurations.dbo. Batch_Liq_PC_ObtenerRegistros_Bonificaciones @id_log_proceso,@Usuario,
		@cant_Mails_A_Enviar OUTPUT

		EXEC @ret_log_paso_tablas = Configurations.dbo.Batch_Log_Finalizar_Paso @id_log_paso,null, null,@flag_ok, null,
		@cant_Mails_A_Enviar,null,null,null,null,null,null,null,@Usuario
		

		IF (@flag_ok = 0)
		BEGIN
			--PRINT '@id_pr1= ' + @id_pr1;
			PRINT 'Batch_Liq_PC_Main - @flag_ok: ' + cast(@flag_ok AS CHAR(1));
		END;
	END;
	

	EXEC @ret_log_paso_tablas = Configurations.dbo.Finalizar_Log_Proceso @id_log_proceso,@Total_Cuentas_a_Bonificar,@usuario




  --SET @ret_code = 1;
  commit
 END TRY

 BEGIN CATCH
		PRINT ERROR_MESSAGE();

		IF (@@TRANCOUNT > 0)
			ROLLBACK TRANSACTION;
 END CATCH

 RETURN @ret_code;
END
