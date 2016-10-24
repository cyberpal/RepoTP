
CREATE PROCEDURE [dbo].[Batch_Fact_NovedadesCtas] (
	@fecha_inicio_proceso DATETIME = NULL,
	@fecha_fin_proceso DATETIME = NULL
	)

AS

SET NOCOUNT ON;


	BEGIN

	-- particular o profesional - alta de cuentas
		
		INSERT INTO [dbo].[Facturacion_NovedadesCtas_tmp] (
		    [I],
			[Empr],
			[id_cuenta],
			[RazonSocial],
			[Calle],
			[Nro],
			[Piso],
			[Dto],
			[Localidad],
			[Pais], 
			[ProvCodigo],
			[Cp],
			[TEFijo],
			[Fantasia],
			[Mail],
			[CUIT],
			[Cod_IVA],
			[id_tipo_condicion_IIBB],
			[DNI],
			[Tipo_Novedad]
			)
			SELECT ROW_NUMBER() OVER (
			ORDER BY id_cuenta
			) AS I,
			f.[Empr],
			f.[id_cuenta],
			f.[RazonSocial],
			f.[Calle],
			f.[Nro],
			f.[Piso],
			f.[Dpto],
			f.[Localidad],
			f.[Pais], 
			f.[ProvCodigo],
			f.[Cp],
			f.[TEFijo],
			f.[Fantasia],
			f.[Mail],
			f.[CUIT],
			f.[Cod_IVA],
			f.[IIBB],
			f.[DNI],
			f.[Tipo_Novedad]
			FROM
			(
		   	select    
			convert(varchar,'6') as Empr,																	--Empresa
			(cta.id_cuenta + 1000000) as id_cuenta,											                --Codigo cliente boton de pago
       
			case 
			when ltrim(rtrim(tpo2.codigo))='CTA_EMPRESA' then left(ltrim(rtrim(cta.denominacion2)),50)
			else left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)),50) 
			end as RazonSocial,                                                                            --Razon Social
		
			dcta.calle as Calle,																			--Calle
			dcta.numero as Nro,																				--Numero de calle
			dcta.piso as Piso,	 															                --Piso
			isnull(dcta.departamento,0) as Dpto,															--Departamento
			loc.nombre as Localidad,																		--Localidad
			1  as Pais,        										                                        --Pais de origen
			prov.codigo_aurus as ProvCodigo,																--Provincia o Estado
			isnull(dcta.codigo_postal,0) as Cp,																--Codigo Postal
			isnull(cta.telefono_fijo,0) as TEFijo,															--Telefono
		
			case when ltrim(rtrim(tpo2.codigo)) = 'CTA_EMPRESA' 
            then left(ltrim(rtrim(cta.denominacion1)),50)                                                            --Nombre de fantasia 
			else
			left(ltrim(rtrim(cta.denominacion1)) + ' ' + ltrim(rtrim(cta.denominacion2)),50) end 
			as Fantasia,

			uscta.eMail as Mail,																			--Direccion de mail

			case 
			when ltrim(rtrim(tpo2.codigo))='CTA_PROFESIONAL' AND ltrim(rtrim(tpo.codigo))<>'IVA_CONS_FINAL' 
			then isnull(cta.numero_CUIT,'0')
			when ltrim(rtrim(tpo2.codigo))='CTA_EMPRESA' then isnull(sfc.numero_CUIT,0)
			else '0' end as CUIT,                                                                           --CUIT 
		
			isnull(tfac.codigo_facturacion,0) as Cod_IVA,	 												--Codigo de IVA
			isnull(sfc.id_tipo_condicion_IIBB,0) as IIBB,													--Numero de Ingresos Brutos
		
			case when ltrim(rtrim(tpo2.codigo))='CTA_PROFESIONAL' AND ltrim(rtrim(tpo.codigo))='IVA_CONS_FINAL' 
			then isnull(cta.numero_identificacion,'0')
			when ltrim(rtrim(tpo2.codigo))='CTA_PARTICULAR' then isnull(cta.numero_identificacion,'0')
			else '0' end as DNI,                                                                            --DNI
			
			case 
			when cta.flag_informado_a_facturacion=1 
			then 'Modificacion' else 'Alta' end as Tipo_Novedad
			from Configurations.dbo.Cuenta cta
			inner join Configurations.dbo.Estado e on cta.id_estado_cuenta=e.id_estado and e.id_grupo_estado=1 and e.codigo not in ('CTA_CREADA','CTA_VENCIDA','CTA_RECHAZADA')
			inner join Configurations.dbo.Situacion_Fiscal_Cuenta sfc on sfc.id_cuenta=cta.id_cuenta and sfc.flag_vigente=1 
			inner join Configurations.dbo.Domicilio_Cuenta dcta on dcta.id_domicilio=sfc.id_domicilio_facturacion --and dcta.flag_vigente=1
			inner join Configurations.dbo.Localidad loc on loc.id_localidad=dcta.id_localidad
			inner join Configurations.dbo.Provincia prov on prov.id_provincia=dcta.id_provincia
			inner join Configurations.dbo.Usuario_Cuenta uscta on uscta.id_cuenta=cta.id_cuenta and uscta.fecha_baja is null and uscta.usuario_baja is null
			inner join Configurations.dbo.Tipo tpo on tpo.id_tipo=sfc.id_tipo_condicion_IVA and tpo.id_grupo_tipo=1
			inner join Configurations.dbo.tipo_facturacion tfac on tfac.id_tipo=tpo.id_tipo
			inner join Configurations.dbo.Tipo tpo2 on tpo2.id_tipo=cta.id_tipo_cuenta and tpo2.id_grupo_tipo=5
			where 
			(uscta.id_perfil=3 and uscta.id_tipo_usuario=110)
			and
			((cta.flag_informado_a_facturacion=1 
			and 
			(cta.fecha_modificacion>=@fecha_inicio_proceso and cta.fecha_modificacion<=@fecha_fin_proceso or
			e.fecha_modificacion>=@fecha_inicio_proceso and e.fecha_modificacion<=@fecha_fin_proceso or
			sfc.fecha_modificacion>=@fecha_inicio_proceso and sfc.fecha_modificacion<=@fecha_fin_proceso or 
		    dcta.fecha_modificacion>=@fecha_inicio_proceso and dcta.fecha_modificacion<=@fecha_fin_proceso or
		    loc.fecha_modificacion>=@fecha_inicio_proceso and loc.fecha_modificacion<=@fecha_fin_proceso or
		    prov.fecha_modificacion>=@fecha_inicio_proceso and prov.fecha_modificacion<=@fecha_fin_proceso or
		    uscta.fecha_modificacion>=@fecha_inicio_proceso and uscta.fecha_modificacion<=@fecha_fin_proceso or
		    tpo.fecha_modificacion>=@fecha_inicio_proceso and tpo.fecha_modificacion<=@fecha_fin_proceso or
		    tfac.fecha_modificacion>=@fecha_inicio_proceso and tfac.fecha_modificacion<=@fecha_fin_proceso))
			or
		    ((cta.flag_informado_a_facturacion=0 or cta.flag_informado_a_facturacion is NULL) and
			cta.fecha_alta<=@fecha_fin_proceso))
			)f;
		

RETURN 1;

END
