-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	
-- // MODULO:			ORGANIZACION / COMBOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- ////////////////////////////////////////////////////////////// 
-- // Autor:			FEG
-- // Fecha creación:	21/NOV/2019
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0]
GO

-- //////////////////////////////////////////////////////////////







-- ////////////////////////////////////////////////////////////////
-- // 
-- // 
-- ////////////////////////////////////////////////////////////////

-- EXECUTE [PG_CB_PROVEEDOR_Load] 0,0,300,  1



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_PROVEEDOR_Load]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_PROVEEDOR_Load]
GO


CREATE PROCEDURE [dbo].[PG_CB_PROVEEDOR_Load]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
	
	CREATE TABLE	#VP_TA_CATALOGO		
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
					-- =========================
						D_PROVEEDOR			VARCHAR(200)
					)

	-- ==========================================

		INSERT INTO #VP_TA_CATALOGO 
			(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
					[D_PROVEEDOR]
			)
			SELECT	K_PROVEEDOR, O_PROVEEDOR,
				-- =========================
					D_PROVEEDOR
			FROM	PROVEEDOR
			WHERE	PROVEEDOR.L_BORRADO=0
			AND		K_PROVEEDOR<>0

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_PROVEEDOR] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				[D_PROVEEDOR] 

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO



-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
