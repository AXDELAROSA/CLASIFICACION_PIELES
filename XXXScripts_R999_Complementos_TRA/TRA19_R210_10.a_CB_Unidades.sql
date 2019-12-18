-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	
-- // MODULO:			ORGANIZACION / COMBOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- ////////////////////////////////////////////////////////////// 
-- // Autor:			AX DE LA ROSA
-- // Fecha creación:	22/FEB/2019
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0]
GO

-- //////////////////////////////////////////////////////////////







-- ////////////////////////////////////////////////////////////////
-- // 
-- // 
-- ////////////////////////////////////////////////////////////////

-- EXECUTE [PG_CB_UNIDAD_Load] 0,0,300,  1,-1

-- EXECUTE [PG_CB_UNIDAD_Load] 0,0,300,  0, 1

-- EXECUTE [PG_CB_UNIDAD_Load] 0,0,300,  0, 2


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_UNIDAD_Load]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_UNIDAD_Load]
GO


CREATE PROCEDURE [dbo].[PG_CB_UNIDAD_Load]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_K_TIPO_UNIDAD			INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
	
	CREATE TABLE	#VP_TA_CATALOGO		
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
					-- =========================
						D_UNIDAD			VARCHAR(200)
					)

	-- ==========================================

	IF @PP_L_K_TIPO_UNIDAD=1
		INSERT INTO #VP_TA_CATALOGO 
			(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
					[D_UNIDAD]
			)
			SELECT	K_TRACTOCAMION, 10,
				-- =========================
					TRACTOCAMION.[D_TRACTOCAMION]
			FROM	TRACTOCAMION
			WHERE	TRACTOCAMION.L_BORRADO=0

	-- ==========================================

	IF @PP_L_K_TIPO_UNIDAD=2
		INSERT INTO #VP_TA_CATALOGO 
			(		TA_K_CATALOGO, TA_O_CATALOGO,
					-- =========================
					[D_UNIDAD]
			)
			SELECT	K_REMOLQUE, 10,
				-- =========================
					REMOLQUE.[D_REMOLQUE]
			FROM	REMOLQUE
			WHERE	REMOLQUE.L_BORRADO=0


	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,	TA_O_CATALOGO,	
					-- =========================
					[D_UNIDAD]
				)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)'
				)

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_UNIDAD] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				[D_UNIDAD] 

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO



-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
