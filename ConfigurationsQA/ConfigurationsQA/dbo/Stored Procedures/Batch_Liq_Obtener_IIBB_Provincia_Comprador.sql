

CREATE PROCEDURE [dbo].[Batch_Liq_Obtener_IIBB_Provincia_Comprador] (
 @Id CHAR(36)
 ,@IdProvincia INT OUTPUT
 )
AS
DECLARE @LocationIdentification INT;
DECLARE @BuyerAccountIdentification INT;
DECLARE @FlagExcepcionCyberSource BIT;
DECLARE @ret_code INT;
DECLARE @CredentialDocumentType VARCHAR(36);
DECLARE @CredentialDocumentNumber VARCHAR(24);
DECLARE @CredentialMask VARCHAR(20);
DECLARE @LikeCredentialMask VARCHAR(20);

BEGIN
 SET NOCOUNT ON;

 BEGIN TRY
  SELECT @BuyerAccountIdentification = trn.BuyerAccountIdentification
   ,@LocationIdentification = trn.LocationIdentification
  -- ,@CredentialDocumentType = trn.CredentialDocumentType
  -- ,@CredentialDocumentNumber = trn.CredentialDocumentNumber
  -- ,@CredentialMask = trn.CredentialMask
  FROM Configurations.dbo.Liquidacion_Tmp trn
  WHERE trn.Id = @Id;

  IF (@BuyerAccountIdentification IS NOT NULL)
  BEGIN
   PRINT '**CON BILLETERA**';

   /*
   SELECT @IdProvincia = dca.id_provincia
   FROM Configurations.dbo.Domicilio_Cuenta dca
    ,Configurations.dbo.Tipo tpo
   WHERE tpo.codigo = 'DOM_LEGAL'
    AND tpo.id_tipo = dca.id_tipo_domicilio
    AND dca.id_cuenta = @BuyerAccountIdentification;

	*/

	   SELECT @IdProvincia = dca.id_provincia
   FROM Configurations.dbo.Domicilio_Cuenta dca
   inner join Configurations.dbo.Tipo tpo
   on tpo.id_tipo = dca.id_tipo_domicilio
   WHERE tpo.codigo = 'DOM_LEGAL'
    AND dca.id_cuenta = @BuyerAccountIdentification
	and  dca.flag_vigente = 1;

  END
  ELSE
   --TX SIN BILLETERA
  BEGIN
   PRINT '**SIN BILLETERA**';

   /*
   --Obtener provincia por CyberSource
   SELECT @IdProvincia = pva.id_provincia
   FROM Configurations.dbo.Provincia pva
    ,Configurations.dbo.Liquidacion_Tmp trn
   WHERE trn.AdditionalData IS NOT NULL
    AND pva.codigo_aurus = trn.AdditionalData.value('(/CS_Data/CSBTSTATE)[1]', 'CHAR')
    AND trn.Id = @Id
	*/

	   --Obtener provincia por CyberSource
   SELECT @IdProvincia = pva.id_provincia
   FROM Configurations.dbo.Provincia pva
    inner join Configurations.dbo.Liquidacion_Tmp trn
	on pva.codigo_aurus = trn.AdditionalData.value('(/CS_Data/CSBTSTATE)[1]', 'CHAR')
   WHERE trn.AdditionalData IS NOT NULL
    AND trn.Id = @Id
    /*
   IF (@IdProvincia IS NULL)
   BEGIN
    --Obtener prov.por cliente unico
    -- Armar patrón de búsqueda reemplazando todas las X de la máscara por un solo %
    SET @LikeCredentialMask = left(@CredentialMask, charindex('X', @CredentialMask) - 1) + '%' + right(@CredentialMask, charindex('X', reverse(@CredentialMask)) - 1);

    -- Buscar la provincia en Cliente Unico por tipo de documento, numero de documento y patron de tarjeta para obtener la provincia
    SELECT @IdProvincia = cuo.id_provincia
    FROM Configurations.dbo.Cliente_Unico cuo
    WHERE cuo.tipo_identificacion = @CredentialDocumentType
     AND cuo.numero_identificacion = @CredentialDocumentNumber
     AND cuo.numero_tarjeta LIKE @LikeCredentialMask;
   END;
   */
  END;--else

  SET @ret_code = 1;
 END TRY

 BEGIN CATCH
  SET @ret_code = 0;

  PRINT ERROR_MESSAGE();
 END CATCH

 RETURN @ret_code;
END


