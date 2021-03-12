-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_Folios / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- EXECUTE [dbo].[PG_IN_RP_FOLIOS] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_TICKET_A_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_TICKET_A_IMPORTAR]
GO


CREATE PROCEDURE [dbo].[PG_IN_TICKET_A_IMPORTAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FILE_NO					VARCHAR(100),
	@PP_BUNDLE_NO				VARCHAR(10),
	@PP_FECHA_TICKET			VARCHAR(10),
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_D_COLOR					VARCHAR(50),
	@PP_CRUST_LOT				VARCHAR(50),
	@PP_LOTE					VARCHAR(10),
	@PP_TOTAL_PIEL				INT,
	@PP_AVG_AREA				VARCHAR(5),
	@PP_TOTAL_SQF				VARCHAR(10),
	@PP_CONSECUTIVO				INT,
	@PP_SQF						DECIMAL(13,2),
	@PP_UOM						VARCHAR(10)
	AS

	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--EXECUTE [dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]			@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@PP_FILE_NO, @PP_LOTE, @PP_PIEL,
	--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	DECLARE @VP_N_PIEL_EXISTE INT = 0
	SELECT @VP_N_PIEL_EXISTE = COUNT(K_TICKET_A_IMPORTAR)
	FROM [TICKET_A_IMPORTAR]
	WHERE FILE_NO = @PP_FILE_NO
	AND [CONSECUTIVO] = @PP_CONSECUTIVO
	AND [SQF] = @PP_SQF

	IF @VP_N_PIEL_EXISTE > 0
		SET @VP_MENSAJE = 'El ticket ya se cargo al sistema...'

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			
			INSERT INTO [TICKET_A_IMPORTAR]	
							(	[FILE_NO],						
								[BUNDLE_NO],				
								[FECHA_TICKET],				
								[CLIENTE],					
								[COLOR],						
								[D_COLOR],					
								[CRUST_LOT],					
								[LOTE],						
								[TOTAL_PIEL],				
								[AVG_AREA],					
								[TOTAL_SQF],					
								[CONSECUTIVO],				
								[SQF],		
								[UOM],
								-- ===========================
								[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
								[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
						VALUES	
							(	@PP_FILE_NO,		 
								@PP_BUNDLE_NO,	
								@PP_FECHA_TICKET,
								@PP_CLIENTE,		
								@PP_COLOR,			
								@PP_D_COLOR,					
								@PP_CRUST_LOT,	
								@PP_LOTE,		
								@PP_TOTAL_PIEL,		
								@PP_AVG_AREA,				
								@PP_TOTAL_SQF,	
								@PP_CONSECUTIVO,
								@PP_SQF,
								@PP_UOM,
								-- ===========================				
								@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
								0, NULL, NULL )	
				
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR SP: PG_IN_TICKET_A_IMPORTAR', 16, 1 ) --MENSAJE - Severity -State.
			END

			-- ///////////////////////////////////////////
		IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Leer el Ticket: ' + '[' + @PP_FILE_NO +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_CONSECUTIVO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'IN',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_FILE_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
