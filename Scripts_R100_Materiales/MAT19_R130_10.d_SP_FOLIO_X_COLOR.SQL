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

USE [DATA_02Pruebas] 
GO


-- EXECUTE [dbo].[PG_SK_FOLIO_X_COLOUR] 0,0,  'FNLGPS4' 

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_FOLIO_X_COLOUR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_FOLIO_X_COLOUR]
GO


CREATE PROCEDURE [dbo].[PG_SK_FOLIO_X_COLOUR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_D_COLOR							VARCHAR(100)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	DISTINCT
			TAG,
			STATUS,
			MACHINE,
			JOBNO,
			COLOUR
	-- =====================
	FROM RP_Folios 
	INNER JOIN RP_SC on RP_Folios.TAG=RP_SC.TAGNO AND COLOUR = @PP_D_COLOR
	ORDER BY TAG
	-- =====================
	

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_D_COLOR, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_X_TAG_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_X_TAG_NO]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_X_TAG_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	DISTINCT
			LOT
	-- =====================
	FROM	RP_SC
	WHERE	tagno=@PP_TAG_NO 
	AND		type<>'D'
	-- =====================
	

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
