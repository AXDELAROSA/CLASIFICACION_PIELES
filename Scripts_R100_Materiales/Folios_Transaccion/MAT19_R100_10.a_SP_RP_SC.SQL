-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
-- EXECUTE PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE 0,0,'104313'
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_RP_SC]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_RP_SC]
GO


CREATE PROCEDURE [dbo].[PG_IN_RP_SC]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INGRESO				DATE,
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(10),
	@PP_PIEL					VARCHAR(10),
	@PP_SQF						VARCHAR(10),
	@PP_FOLIO					INT,
	@PP_YARDAS					VARCHAR(10),
	@PP_YLB						VARCHAR(10),
	@PP_PESO					VARCHAR(10),
	@PP_TIPO					VARCHAR(10),
	@PP_MOVIMIENTO				VARCHAR(10),
	@PP_K_CLASIFICACION			INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@VP_K_PIEL_CLASIFICADA,@PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	
			IF NOT EXISTS(SELECT TAGNO FROM RP_SC WHERE TAGNO = @PP_FOLIO )
				BEGIN
					INSERT INTO RP_SC	
								(	[CDATE], 
									[COLOUR],						
									[LOT],				
									[HIDE],	
									[SQF],		
									[TAGNO],		
									[YARDAS],			
									[YLB],		
									[PESO],	
									[TYPE],
									[MOVEMENT],
									[K_CLASIFICACION]	
									)		
							VALUES	
								(	@PP_F_INGRESO, 
									@PP_COLOR,			
									@PP_LOTE,			
									@PP_PIEL,			
									@PP_SQF,				
									@PP_FOLIO,			
									@PP_YARDAS,			
									@PP_YLB,				
									@PP_PESO,				
									@PP_TIPO,						
									@PP_MOVIMIENTO,		
									@PP_K_CLASIFICACION	)	
				END
			ELSE
				BEGIN
					RAISERROR ('Error raised in TRY block.', 16, 1 ) --MENSAJE - Severity -State.
				END
		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[IN]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_LOTE, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', 'UP', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
