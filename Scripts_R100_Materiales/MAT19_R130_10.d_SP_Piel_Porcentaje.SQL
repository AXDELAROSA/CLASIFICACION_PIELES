-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_CLASIFICADA
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO


-- EXECUTE [dbo].[PG_SK_PIEL_PORCENTAJE_X_ESTATUS_X_K_PIEL_LOTE] 0,0,0, 2

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_PORCENTAJE_X_ESTATUS_X_K_PIEL_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_PORCENTAJE_X_ESTATUS_X_K_PIEL_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_SK_PIEL_PORCENTAJE_X_ESTATUS_X_K_PIEL_LOTE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_LOTE						INT
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_SEEK]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													11, -- @PP_K_DATA_SISTEMA,	
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- ///////////////////////////////////////////
	
	DECLARE @VP_L_VER_BORRADOS		INT		
	
	EXECUTE [dbo].[PG_RN_DATA_VER_BORRADOS]			@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@OU_L_VER_BORRADOS = @VP_L_VER_BORRADOS			OUTPUT
	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 100

	IF @VP_MENSAJE<>''
		SET @VP_LI_N_REGISTROS = 0

	-- =========================================
		
	SELECT	TOP (@VP_LI_N_REGISTROS)
				PIEL_PORCENTAJE_X_ESTATUS.*,	
			-- =====================
				PIEL_LOTE.PIEL_LOTE_CANTIDAD,
				(	SELECT ISNULL(COUNT(K_PIEL_CLASIFICADA), 0) 
					FROM PIEL_CLASIFICADA 
					WHERE K_PIEL_LOTE=@PP_K_PIEL_LOTE	) AS PIEL_LOTE_CANTIDAD_CLASIFICADA,
				PIEL_LOTE.D_PIEL_LOTE,PIEL_LOTE.S_PIEL_LOTE
			-- =====================
	FROM		PIEL_PORCENTAJE_X_ESTATUS,
				PIEL_LOTE
			-- =====================
	WHERE		PIEL_PORCENTAJE_X_ESTATUS.K_PIEL_LOTE=PIEL_LOTE.K_PIEL_LOTE
			-- =====================
	AND			PIEL_PORCENTAJE_X_ESTATUS.K_PIEL_LOTE=@PP_K_PIEL_LOTE
			-- =====================
		
	-----////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SEEK',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_SK_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_LOTE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_LOTE						INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_K_PIEL_PORCENTAJE_X_ESTATUS		INT = 0
	
	EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
												'PIEL_PORCENTAJE_X_ESTATUS', 
												@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_PORCENTAJE_X_ESTATUS			OUTPUT
	-- ==================================

	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@VP_K_PIEL_CLASIFICADA,@PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	

		DECLARE @VP_N_K_PIEL_LOTE INT = 0

		SELECT	@VP_N_K_PIEL_LOTE = COUNT(K_PIEL_PORCENTAJE_X_ESTATUS)
		FROM	PIEL_PORCENTAJE_X_ESTATUS
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE

		IF @VP_N_K_PIEL_LOTE IS NULL 
			SET @VP_N_K_PIEL_LOTE = 0
		-- ==================================

		DECLARE	@VP_PIEL_LOTE_CANTIDAD			INT = 0

		SELECT	@VP_PIEL_LOTE_CANTIDAD = PIEL_LOTE_CANTIDAD
		FROM	PIEL_LOTE
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE

		IF @VP_PIEL_LOTE_CANTIDAD IS NULL 
			SET @VP_PIEL_LOTE_CANTIDAD = 0
		-- ==================================

		DECLARE	@VP_PIEL_LOTE_CANTIDAD_BUENO	INT = 0
		DECLARE	@VP_PIEL_LOTE_CANTIDAD_REGULAR	INT = 0
		DECLARE	@VP_PIEL_LOTE_CANTIDAD_MALO		INT = 0
		/*
		K_ESTATUS_PIEL_CLASIFICADA
		#1 BUENA | #2 REGULAR | #3 MALA
		*/

		SELECT	@VP_PIEL_LOTE_CANTIDAD_BUENO = COUNT(K_PIEL_CLASIFICADA)
		FROM	PIEL_CLASIFICADA
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE
		AND		K_ESTATUS_PIEL_CLASIFICADA=1 -- BUENA
				
		IF @VP_PIEL_LOTE_CANTIDAD_BUENO IS NULL 
			SET @VP_PIEL_LOTE_CANTIDAD_BUENO = 0
		-- ==================================

		SELECT	@VP_PIEL_LOTE_CANTIDAD_REGULAR = COUNT(K_PIEL_CLASIFICADA)
		FROM	PIEL_CLASIFICADA
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE
		AND		K_ESTATUS_PIEL_CLASIFICADA=2 -- REGULAR
		
		IF @VP_PIEL_LOTE_CANTIDAD_REGULAR IS NULL 
			SET @VP_PIEL_LOTE_CANTIDAD_REGULAR = 0
		-- ==================================

		SELECT	@VP_PIEL_LOTE_CANTIDAD_MALO = COUNT(K_PIEL_CLASIFICADA)
		FROM	PIEL_CLASIFICADA
		WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE
		AND		K_ESTATUS_PIEL_CLASIFICADA=3 -- MALA
		
		IF @VP_PIEL_LOTE_CANTIDAD_MALO IS NULL 
			SET @VP_PIEL_LOTE_CANTIDAD_MALO = 0
		-- ==================================

		DECLARE @VP_PIEL_PORCENTAJE_BUENO		DECIMAL(19,4)
		DECLARE @VP_PIEL_PORCENTAJE_REGULAR		DECIMAL(19,4)
		DECLARE @VP_PIEL_PORCENTAJE_MALO		DECIMAL(19,4)

		SET @VP_PIEL_PORCENTAJE_BUENO =	ROUND(CAST(@VP_PIEL_LOTE_CANTIDAD_BUENO AS FLOAT) / CAST(@VP_PIEL_LOTE_CANTIDAD AS FLOAT),3) * 100
	
		SET @VP_PIEL_PORCENTAJE_REGULAR = ROUND(CAST(@VP_PIEL_LOTE_CANTIDAD_REGULAR AS FLOAT) / CAST(@VP_PIEL_LOTE_CANTIDAD AS FLOAT),3) * 100

		SET @VP_PIEL_PORCENTAJE_MALO = ROUND(CAST(@VP_PIEL_LOTE_CANTIDAD_MALO AS FLOAT) / CAST(@VP_PIEL_LOTE_CANTIDAD AS FLOAT),3) * 100
		-- ==================================

		IF @VP_N_K_PIEL_LOTE = 0
			BEGIN
				INSERT INTO [PIEL_PORCENTAJE_X_ESTATUS]	
					(	[K_PIEL_PORCENTAJE_X_ESTATUS], 
						[K_PIEL_LOTE],
						[PIEL_LOTE_CANTIDAD],
						[PIEL_PORCENTAJE_BUENO],
						[PIEL_PORCENTAJE_REGULAR],
						[PIEL_PORCENTAJE_MALO]		)		
				VALUES	
					(	@VP_K_PIEL_PORCENTAJE_X_ESTATUS, 
						@PP_K_PIEL_LOTE,
						@VP_PIEL_LOTE_CANTIDAD,
						@VP_PIEL_PORCENTAJE_BUENO,
						@VP_PIEL_PORCENTAJE_REGULAR,		
						@VP_PIEL_PORCENTAJE_MALO	)				
			END
		ELSE
			BEGIN
				UPDATE	PIEL_PORCENTAJE_X_ESTATUS
				SET		
					[PIEL_LOTE_CANTIDAD]		= @VP_PIEL_LOTE_CANTIDAD,
					[PIEL_PORCENTAJE_BUENO]		= @VP_PIEL_PORCENTAJE_BUENO,	
					[PIEL_PORCENTAJE_REGULAR]	= @VP_PIEL_PORCENTAJE_REGULAR,			
					[PIEL_PORCENTAJE_MALO]		= @VP_PIEL_PORCENTAJE_MALO	
					
				WHERE	K_PIEL_LOTE=@PP_K_PIEL_LOTE
			END

		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													3,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'INSERT',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_LOTE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													--0, 0, @PP_C_PIEL_CLASIFICADA, '', 0.00, 0.00,
													0, 0, '', '', 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
