-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	14/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- EXECUTE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_K_PIEL_LOTE] 0,0,0, 2

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]
GO
-- EXECUTE PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE 0,0,'FCPRDX9,104313-0215*37.50'

CREATE PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10)
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////OBTENER VALORES DE LA ETIQUETA PIEL////////////////////////////////////////////
	

	-- =========================================
	
	IF EXISTS( SELECT LOTE FROM PIEL_CLASIFICADA_PORCENTAJE WHERE LOTE=@PP_LOTE)
		BEGIN
			SELECT		PIEL_CLASIFICADA_PORCENTAJE.*,
						CAST(PIEL_PORCENTAJE_BUENO AS DECIMAL(13,2))	AS PORCENTAJE_BUENO,
						CAST(PIEL_PORCENTAJE_REGULAR AS DECIMAL(13,2))	AS PORCENTAJE_REGULAR,
						CAST(PIEL_PORCENTAJE_MALO AS DECIMAL(13,2))		AS PORCENTAJE_MALO,
						(PIEL_TOTAL - PIEL_TOTAL_CLASIFICADA)			AS PIEL_X_CLASIFICAR
					-- =====================
			FROM		PIEL_CLASIFICADA_PORCENTAJE
					-- =====================
			WHERE		LOTE=@PP_LOTE
					-- =====================
		END
	--ELSE
	--	BEGIN

	--		SELECT	@PP_K_PIEL_LOTE AS PIEL_LOTE_CANTIDAD,
	--				(SELECT ISNULL(COUNT(K_PIEL_CLASIFICADA), 0) 
	--				FROM PIEL_CLASIFICADA 
	--				WHERE K_PIEL_LOTE=@PP_K_PIEL_LOTE) AS PIEL_LOTE_CANTIDAD_CLASIFICADA,
	--				0 AS PIEL_PORCENTAJE_BUENO,
	--				0 AS PIEL_PORCENTAJE_REGULAR,
	--				0 AS PIEL_PORCENTAJE_MALO
	--	END

	-----////////////////////////////////////////////////////////////////

	--EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'SEEK',
	--												@VP_MENSAJE,
	--												-- ===========================================
	--												'[PG_SK_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												@PP_K_PIEL_LOTE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, '', '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
-- EXECUTE PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE 0,0,'104313'
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_LOTE							VARCHAR(10)
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_K_PIEL_CLASIFICADA_PORCENTAJE		INT = 0

		EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'PIEL_CLASIFICADA_PORCENTAJE', 'K_PIEL_CLASIFICADA_PORCENTAJE',
													@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_CLASIFICADA_PORCENTAJE	OUTPUT
	-- ==================================

	--IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@VP_K_PIEL_CLASIFICADA,@PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	

			DECLARE	@VP_N_PIEL_X_LOTE			INT = 0

			SELECT	@VP_N_PIEL_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	LTRIM(RTRIM(LOT))=@PP_LOTE

			IF @VP_N_PIEL_X_LOTE IS NULL 
				SET @VP_N_PIEL_X_LOTE = 0
			-- ==================================

			DECLARE	@VP_N_PIEL_BUENA_X_LOTE		INT = 0
			DECLARE	@VP_N_PIEL_REGULAR_X_LOTE	INT = 0
			DECLARE	@VP_N_PIEL_MALA_X_LOTE		INT = 0

			/*
			K_PIEL_CLASIFICADA
			#1 BUENA | #2 REGULAR | #3 MALA
			*/

			SELECT	@VP_N_PIEL_BUENA_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	LTRIM(RTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=1 -- BUENA
					
			IF @VP_N_PIEL_BUENA_X_LOTE IS NULL 
				SET @VP_N_PIEL_BUENA_X_LOTE = 0
			-- ==================================

			SELECT	@VP_N_PIEL_REGULAR_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	LTRIM(RTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=2 -- REGULAR
			
			IF @VP_N_PIEL_REGULAR_X_LOTE IS NULL 
				SET @VP_N_PIEL_REGULAR_X_LOTE = 0
			-- ==================================

			SELECT	@VP_N_PIEL_MALA_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	LTRIM(RTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=3 -- MALA
			
			IF @VP_N_PIEL_MALA_X_LOTE IS NULL 
				SET @VP_N_PIEL_MALA_X_LOTE = 0
			-- ==================================

			DECLARE @VP_PIEL_PORCENTAJE_BUENO		DECIMAL(19,4)
			DECLARE @VP_PIEL_PORCENTAJE_REGULAR		DECIMAL(19,4)
			DECLARE @VP_PIEL_PORCENTAJE_MALO		DECIMAL(19,4)

			SET @VP_PIEL_PORCENTAJE_BUENO =	ROUND(CAST(@VP_N_PIEL_BUENA_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100
	
			SET @VP_PIEL_PORCENTAJE_REGULAR = ROUND(CAST(@VP_N_PIEL_REGULAR_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100

			SET @VP_PIEL_PORCENTAJE_MALO = ROUND(CAST(@VP_N_PIEL_MALA_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100
			-- ==================================

			DECLARE @VP_PIEL_TOTAL_CLASIFICADA INT = (@VP_N_PIEL_BUENA_X_LOTE	+  @VP_N_PIEL_REGULAR_X_LOTE + @VP_N_PIEL_MALA_X_LOTE)		


			IF NOT EXISTS(SELECT LOTE FROM PIEL_CLASIFICADA_PORCENTAJE WHERE LOTE = @PP_LOTE)
				BEGIN
					
					INSERT INTO [PIEL_CLASIFICADA_PORCENTAJE]	
						(	[K_PIEL_CLASIFICADA_PORCENTAJE], 
							[LOTE],						
							[PIEL_TOTAL],				
							[PIEL_TOTAL_CLASIFICADA],	
							[PIEL_TOTAL_BUENO],		
							[PIEL_TOTAL_REGULAR],		
							[PIEL_TOTAL_MALO],			
							[PIEL_PORCENTAJE_BUENO],		
							[PIEL_PORCENTAJE_REGULAR],	
							[PIEL_PORCENTAJE_MALO]	
							)		
					VALUES	
						(	@VP_K_PIEL_CLASIFICADA_PORCENTAJE, 
							@PP_LOTE,
							@VP_N_PIEL_X_LOTE,
							@VP_PIEL_TOTAL_CLASIFICADA,
							@VP_N_PIEL_BUENA_X_LOTE,
							@VP_N_PIEL_REGULAR_X_LOTE,
							@VP_N_PIEL_MALA_X_LOTE,
							@VP_PIEL_PORCENTAJE_BUENO,
							@VP_PIEL_PORCENTAJE_REGULAR,		
							@VP_PIEL_PORCENTAJE_MALO	)				
				END
			ELSE
				BEGIN
					UPDATE	PIEL_CLASIFICADA_PORCENTAJE
					SET		
						[PIEL_TOTAL_CLASIFICADA]	= @VP_PIEL_TOTAL_CLASIFICADA,
						[PIEL_TOTAL_BUENO]			= @VP_N_PIEL_BUENA_X_LOTE,		
						[PIEL_TOTAL_REGULAR]		= @VP_N_PIEL_REGULAR_X_LOTE,	
						[PIEL_TOTAL_MALO]			= @VP_N_PIEL_MALA_X_LOTE,		
						[PIEL_PORCENTAJE_BUENO]		= @VP_PIEL_PORCENTAJE_BUENO,	
						[PIEL_PORCENTAJE_REGULAR]	= @VP_PIEL_PORCENTAJE_REGULAR,			
						[PIEL_PORCENTAJE_MALO]		= @VP_PIEL_PORCENTAJE_MALO	
						
					WHERE	LOTE=@PP_LOTE
				END

		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

	--EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'UPDATE',
	--												'',
	--												-- ===========================================
	--												'[IN/UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_LOTE, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', 'UP', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
