-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:		TRA19_Transportadora
-- // MÓDULO:				ORGANIZACIÓN / COMBOS
-- // OPERACIÓN:			LIBERACIÓN / STORED PROCEDURES
-- ////////////////////////////////////////////////////////////// 
-- // Autor:				DANIEL PORTILLO ROMERO
-- // Modificador:			AX DE LA ROSA	|	Se realiza la adaptación para utilizar con el sistema de Transportadora
-- // Fecha modificación:	24/JUL/2019
-- //////////////////////////////////////////////////////////////  

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- ////////////////////////////////////////////////////////////////
-- // TRA19 // SP COMBO ESPECIAL PARA FACTURA_CXC
-- ////////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_FACTURA_CXC_Load]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_FACTURA_CXC_Load]
GO

CREATE PROCEDURE [dbo].[PG_CB_FACTURA_CXC_Load]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT
AS

	DECLARE @VP_INT_SHOW_K	INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
				(	TA_K_CATALOGO		INT,
					TA_O_CATALOGO		INT,
					-- =======================
					D_FACTURA_CXC		VARCHAR(200),
					D_CLIENTE_TRA		VARCHAR(200),
					D_PUNTO_ENTREGA		VARCHAR(200)	)
	
	-- ==========================================

	DECLARE @VP_O_FACTURA_CXC	INT = 0 
	
	INSERT INTO #VP_TA_CATALOGO 
			(	TA_K_CATALOGO,			TA_O_CATALOGO,
				-- =========================
				D_FACTURA_CXC,
				D_CLIENTE_TRA,			D_PUNTO_ENTREGA 			)
	SELECT		K_FACTURA_CXC,			@VP_O_FACTURA_CXC,
				-- =========================
				D_FACTURA_CXC,
				D_CLIENTE_TRA,			D_PUNTO_ENTREGA
	FROM	FACTURA_CXC
				INNER JOIN	PUNTO_ENTREGA				ON FACTURA_CXC.K_PUNTO_ENTREGA=PUNTO_ENTREGA.K_PUNTO_ENTREGA
				INNER JOIN	CLIENTE_TRA			ON FACTURA_CXC.K_CLIENTE_TRA=CLIENTE_TRA.K_CLIENTE_TRA
				-- =========================
--				INNER JOIN	SYS3_ACCESO_USR_X_RAS	ON CLIENTE_TRA.K_CLIENTE_TRA=SYS3_ACCESO_USR_X_RAS.K_CLIENTE_TRA
			-- ==============================
--	WHERE	SYS3_ACCESO_USR_X_RAS.K_USUARIO=@PP_K_USUARIO_ACCION
--	AND		SYS3_ACCESO_USR_X_RAS.K_SISTEMA=@PP_K_SISTEMA_EXE
--	AND		SYS3_ACCESO_USR_X_RAS.L_ACCESO=1
			-- ==============================
	WHERE	FACTURA_CXC.K_ESTATUS_FACTURA_CXC=1 -- 1. PREFACTURA
			-- ==============================
	AND		FACTURA_CXC.L_BORRADO=0
	--AND		(	@PP_K_UNIDAD_OPERATIVA=-1	OR	VI_UNO.VI_K_UNIDAD_OPERATIVA=@PP_K_UNIDAD_OPERATIVA )
	-- ==========================================

	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 0

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
				( '[#' + CONVERT(VARCHAR(100),TA_K_CATALOGO) + '] ' +
				D_CLIENTE_TRA + ' // ' + D_PUNTO_ENTREGA ) AS D_COMBOBOX
	FROM		#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				D_CLIENTE_TRA, D_PUNTO_ENTREGA

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO

-- //////////////////////////////////////////////////////////////


-- select * from tipo_SERIE

-- ////////////////////////////////////////////////////////////////
-- // TRA19 // SP COMBO ESPECIAL PARA SERIE
-- ////////////////////////////////////////////////////////////////
-- EXECUTE [dbo].[PG_CB_SERIE_Load] 0, 2003, 100, 1, -1,-1,1

-- EXECUTE [dbo].[PG_CB_SERIE_Load] 0,2003,100, 1, 13, 3, 2   , -1

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_SERIE_Load]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_SERIE_Load]
GO

CREATE PROCEDURE [dbo].[PG_CB_SERIE_Load]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- =========================
	@PP_L_CON_TODOS			INT,
	-- =========================
	@PP_K_CLIENTE_TRA		INT,
	@PP_K_PUNTO_ENTREGA		INT,
	-- =========================
	@PP_K_TIPO_SERIE		INT	
AS

	DECLARE @VP_INT_SHOW_K	INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
															@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
				(	TA_K_CATALOGO		INT,
					TA_O_CATALOGO		INT,
					-- =======================
					D_SERIE				VARCHAR(255),
					S_SERIE				VARCHAR(10),
					-- =======================
					D_TIPO_SERIE		VARCHAR(255),
					S_TIPO_SERIE		VARCHAR(10),
					-- =======================
					D_CLIENTE_TRA		VARCHAR(255),
					S_CLIENTE_TRA		VARCHAR(10),
					-- =======================
					D_PUNTO_ENTREGA	VARCHAR(255),
					S_PUNTO_ENTREGA	VARCHAR(10)		
				)
	
	-- ==========================================

	DECLARE @VP_O_SERIE	INT = 0 
	
	INSERT INTO #VP_TA_CATALOGO 
			(	TA_K_CATALOGO,		TA_O_CATALOGO,
				-- =========================
				D_SERIE,			S_SERIE,
				-- =========================
				D_TIPO_SERIE,		S_TIPO_SERIE,
				-- =========================
				D_CLIENTE_TRA,		S_CLIENTE_TRA,
				-- =========================
				D_PUNTO_ENTREGA,	S_PUNTO_ENTREGA
			)
	SELECT		K_SERIE,			@VP_O_SERIE,
				-- =========================
				D_SERIE,			S_SERIE,
				-- =========================
				D_TIPO_SERIE,		S_TIPO_SERIE,
				-- =========================
				D_CLIENTE_TRA,		S_CLIENTE_TRA,
				-- =========================
				D_PUNTO_ENTREGA,	S_PUNTO_ENTREGA
	FROM	SERIE
				INNER JOIN	CLIENTE_TRA								ON SERIE.K_CLIENTE_TRA=CLIENTE_TRA.K_CLIENTE_TRA
				INNER JOIN	PUNTO_ENTREGA							ON SERIE.K_PUNTO_ENTREGA=PUNTO_ENTREGA.K_PUNTO_ENTREGA
				-- =========================
				INNER JOIN	TIPO_SERIE								ON SERIE.K_TIPO_SERIE=TIPO_SERIE.K_TIPO_SERIE
--				INNER JOIN	CLASE_SERIE								ON TIPO_SERIE.K_CLASE_SERIE=CLASE_SERIE.K_CLASE_SERIE
				-- =========================
--				INNER JOIN	VI_UNIDAD_OPERATIVA_CATALOGOS AS VI_UNO	ON ( SERIE.K_UNIDAD_OPERATIVA=VI_UNO.VI_K_UNIDAD_OPERATIVA AND SERIE.K_RAZON_SOCIAL=VI_UNO.VI_K_RAZON_SOCIAL )
				-- =========================
--				INNER JOIN	SYS3_ACCESO_USR_X_UNO					ON VI_UNO.VI_K_UNIDAD_OPERATIVA=SYS3_ACCESO_USR_X_UNO.K_UNIDAD_OPERATIVA
			-- ==============================
--	WHERE	SYS3_ACCESO_USR_X_UNO.K_USUARIO=@PP_K_USUARIO_ACCION
--	AND		SYS3_ACCESO_USR_X_UNO.K_SISTEMA=@PP_K_SISTEMA_EXE
--	AND		SYS3_ACCESO_USR_X_UNO.L_ACCESO=1
			-- ==============================
	WHERE	SERIE.L_BORRADO=0
			-- ==============================
	AND		(	@PP_K_CLIENTE_TRA=-1		OR	CLIENTE_TRA.K_CLIENTE_TRA=@PP_K_CLIENTE_TRA )
	AND		(	@PP_K_PUNTO_ENTREGA=-1		OR	PUNTO_ENTREGA.K_PUNTO_ENTREGA=@PP_K_PUNTO_ENTREGA )
--	AND		(	@PP_K_UNIDAD_OPERATIVA=-1	OR	VI_UNO.VI_K_UNIDAD_OPERATIVA=@PP_K_UNIDAD_OPERATIVA )
				-- ==============================
	AND		(	@PP_K_TIPO_SERIE=-1		OR	TIPO_SERIE.K_TIPO_SERIE=@PP_K_TIPO_SERIE )
	

	-- ==========================================

	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 0

	-- ==========================================

	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,		TA_O_CATALOGO,	
					-- =========================
					D_SERIE,			S_SERIE,
					-- =========================
					D_TIPO_SERIE,		S_TIPO_SERIE,
					-- =========================
					D_CLIENTE_TRA,		S_CLIENTE_TRA,
					-- =========================
					D_PUNTO_ENTREGA,	S_PUNTO_ENTREGA	
				)
			VALUES
				(	-1,					-999,	
					-- =========================	 					
					'',					'(TODOS)',		
					-- =========================
					'',					'',
					-- =========================
					'',					'',
					-- =========================
					'',					''	  
				)

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT		TA_K_CATALOGO	AS K_COMBOBOX,
				( '[#' + CONVERT(VARCHAR(100),TA_K_CATALOGO) + '] ' +
				S_SERIE + 
				' // ' +	D_TIPO_SERIE	) AS D_COMBOBOX
	FROM		#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				S_SERIE

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO
-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////////////////////////////////////////////////////
