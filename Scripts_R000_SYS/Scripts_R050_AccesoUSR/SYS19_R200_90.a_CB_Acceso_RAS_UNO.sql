-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_UNIDAD_OPERATIVA_x_AccesoLoad] 0,2006,169,  1,1,  -1, -1


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_UNIDAD_OPERATIVA_x_AccesoLoad]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_UNIDAD_OPERATIVA_x_AccesoLoad]
GO


CREATE PROCEDURE [dbo].[PG_CB_UNIDAD_OPERATIVA_x_AccesoLoad]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_CON_RAZON_SOCIAL		INT,
	@PP_K_ZONA_UO				INT,
	@PP_K_RAZON_SOCIAL			INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
						-- =========================
						[D_UNIDAD_OPERATIVA]	VARCHAR(200),
						[D_TIPO_UO]				VARCHAR(200),
						[D_ZONA_UO]				VARCHAR(200),
						[D_RAZON_SOCIAL]		VARCHAR(200),
						[D_REGION]				VARCHAR(200),
						[S_UNIDAD_OPERATIVA]	VARCHAR(200),
						[S_TIPO_UO]				VARCHAR(200),
						[S_ZONA_UO]				VARCHAR(200),
						[S_RAZON_SOCIAL]		VARCHAR(200),
						[S_REGION]				VARCHAR(200)			)
	
	-- ==========================================
	
	INSERT INTO #VP_TA_CATALOGO 
		(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
				[D_UNIDAD_OPERATIVA], [D_TIPO_UO], [D_ZONA_UO], [D_RAZON_SOCIAL], [D_REGION],
				[S_UNIDAD_OPERATIVA], [S_TIPO_UO], [S_ZONA_UO], [S_RAZON_SOCIAL], [S_REGION]		)
		SELECT	UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA, O_UNIDAD_OPERATIVA,
				-- =========================
				UNIDAD_OPERATIVA.[D_UNIDAD_OPERATIVA], [D_TIPO_UO], [D_ZONA_UO], [D_RAZON_SOCIAL], [D_REGION],
				UNIDAD_OPERATIVA.[S_UNIDAD_OPERATIVA], [S_TIPO_UO], [S_ZONA_UO], [S_RAZON_SOCIAL], [S_REGION]
		FROM	UNIDAD_OPERATIVA, [VI_UNIDAD_OPERATIVA_CATALOGOS],
				[SYS3_ACCESO_USR_X_UNO] AS SYS_ACCESO
		WHERE	UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA=[VI_UNIDAD_OPERATIVA_CATALOGOS].VI_K_UNIDAD_OPERATIVA
		AND		UNIDAD_OPERATIVA.L_BORRADO=0
		AND		SYS_ACCESO.L_ACCESO=1
		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
				-- ================================
		AND		( @PP_K_ZONA_UO=-1				OR		UNIDAD_OPERATIVA.K_ZONA_UO=@PP_K_ZONA_UO )
		AND		( @PP_K_RAZON_SOCIAL=-1			OR		UNIDAD_OPERATIVA.K_RAZON_SOCIAL=@PP_K_RAZON_SOCIAL )
		AND		( @PP_L_CON_RAZON_SOCIAL=1		OR		UNIDAD_OPERATIVA.K_TIPO_UO<>50)
		-- =================================
		AND		UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA=SYS_ACCESO.K_UNIDAD_OPERATIVA

	-- ==========================================

	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 0


	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 99999
	WHERE	TA_K_CATALOGO>999

	-- ==========================================

	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,	TA_O_CATALOGO,	
					-- =========================
					[D_UNIDAD_OPERATIVA], [D_TIPO_UO], [D_ZONA_UO], [D_RAZON_SOCIAL], [D_REGION],
					[S_UNIDAD_OPERATIVA], [S_TIPO_UO], [S_ZONA_UO], [S_RAZON_SOCIAL], [S_REGION]		)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)', '', '', '', '',		
					'(TODOS)', '', '', '', ''		  )

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_UNIDAD_OPERATIVA] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
			+ ' ( '+[S_ZONA_UO]+' - '+[D_RAZON_SOCIAL]+' )'
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	[S_ZONA_UO], 
				TA_O_CATALOGO,
				[D_RAZON_SOCIAL], [D_UNIDAD_OPERATIVA] 

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO




-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_RAZON_SOCIAL_x_AccesoLoad] 0,2006,169,  1,1,  -1


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_RAZON_SOCIAL_x_AccesoLoad]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_RAZON_SOCIAL_x_AccesoLoad]
GO


CREATE PROCEDURE [dbo].[PG_CB_RAZON_SOCIAL_x_AccesoLoad]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_CON_RAZON_SOCIAL		INT,
	@PP_K_TIPO_RAZON_SOCIAL		INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
						-- =========================
						[D_TIPO_RAZON_SOCIAL]	VARCHAR(200),
						[D_RAZON_SOCIAL]		VARCHAR(200),
						[S_TIPO_RAZON_SOCIAL]	VARCHAR(200),
						[S_RAZON_SOCIAL]		VARCHAR(200)		)
	
	-- ==========================================
	
	INSERT INTO #VP_TA_CATALOGO 
		(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
				[D_TIPO_RAZON_SOCIAL], [D_RAZON_SOCIAL],
				[S_TIPO_RAZON_SOCIAL], [S_RAZON_SOCIAL]		)
		SELECT	DISTINCT 
				UNIDAD_OPERATIVA.K_RAZON_SOCIAL, UNIDAD_OPERATIVA.K_RAZON_SOCIAL,
				-- =========================
				[D_TIPO_RAZON_SOCIAL], RAZON_SOCIAL.[D_RAZON_SOCIAL],
				[S_TIPO_RAZON_SOCIAL], RAZON_SOCIAL.[S_RAZON_SOCIAL]		
		FROM	RAZON_SOCIAL, TIPO_RAZON_SOCIAL,
				UNIDAD_OPERATIVA, [VI_UNIDAD_OPERATIVA_CATALOGOS],
				[SYS3_ACCESO_USR_X_RAS] AS SYS_ACCESO
		WHERE	UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA=[VI_UNIDAD_OPERATIVA_CATALOGOS].VI_K_UNIDAD_OPERATIVA
		AND		UNIDAD_OPERATIVA.L_BORRADO=0
		AND		SYS_ACCESO.L_ACCESO=1
		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
				-- ================================
	--	AND		( @PP_K_ZONA_UO=-1			OR		UNIDAD_OPERATIVA.K_ZONA_UO=@PP_K_ZONA_UO )
	--	AND		( @PP_K_RAZON_SOCIAL=-1		OR		UNIDAD_OPERATIVA.K_RAZON_SOCIAL=@PP_K_RAZON_SOCIAL )
		AND		( @PP_L_CON_RAZON_SOCIAL=1	OR		UNIDAD_OPERATIVA.K_TIPO_UO<>50)
		-- =================================
		AND		UNIDAD_OPERATIVA.K_RAZON_SOCIAL=RAZON_SOCIAL.K_RAZON_SOCIAL
		AND		RAZON_SOCIAL.K_TIPO_RAZON_SOCIAL=TIPO_RAZON_SOCIAL.K_TIPO_RAZON_SOCIAL
		AND		RAZON_SOCIAL.K_RAZON_SOCIAL=SYS_ACCESO.K_RAZON_SOCIAL

	-- ==========================================

	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 0


	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 99999
	WHERE	TA_K_CATALOGO>999

	-- ==========================================

	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,	TA_O_CATALOGO,	
					-- =========================
					[D_TIPO_RAZON_SOCIAL],	[D_RAZON_SOCIAL],
					[S_TIPO_RAZON_SOCIAL],	[S_RAZON_SOCIAL]		)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)', '', 		
					'(TODOS)', ''	)

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	 
			TA_K_CATALOGO	AS K_COMBOBOX,
			[D_RAZON_SOCIAL] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
			+ ' ( '+ ' - '+' )'
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				[D_RAZON_SOCIAL]
				, TA_K_CATALOGO

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO




-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM [VI_UNIDAD_OPERATIVA_CATALOGOS]

-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_RAZON_SOCIAL_x_AccesoLoad] 0,2006,169,  1,1,  -1, -1


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ZONA_UO_x_AccesoLoad]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_ZONA_UO_x_AccesoLoad]
GO


CREATE PROCEDURE [dbo].[PG_CB_ZONA_UO_x_AccesoLoad]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_CON_RAZON_SOCIAL		INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
						-- =========================
						[D_ZONA_UO]				VARCHAR(200),
						[S_ZONA_UO]				VARCHAR(200)		)
	
	-- ==========================================
	
	INSERT INTO #VP_TA_CATALOGO 
		(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
				[D_ZONA_UO],
				[S_ZONA_UO]		)
		SELECT	DISTINCT
				VI_K_ZONA_UO, VI_K_ZONA_UO,
				-- =========================
				[D_ZONA_UO], 
				[S_ZONA_UO] 
		FROM	[VI_UNIDAD_OPERATIVA_CATALOGOS],
				[SYS3_ACCESO_USR_X_UNO] AS SYS_ACCESO
		WHERE	SYS_ACCESO.L_ACCESO=1
		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
				-- ================================
--		AND		( @PP_K_ZONA_UO=-1				OR		UNIDAD_OPERATIVA.K_ZONA_UO=@PP_K_ZONA_UO )
--		AND		( @PP_K_RAZON_SOCIAL=-1			OR		UNIDAD_OPERATIVA.K_RAZON_SOCIAL=@PP_K_RAZON_SOCIAL )
--		AND		( @PP_L_CON_RAZON_SOCIAL=1		OR		UNIDAD_OPERATIVA.K_TIPO_UO<>50)
		-- =================================
		AND		VI_K_UNIDAD_OPERATIVA=SYS_ACCESO.K_UNIDAD_OPERATIVA


	-- ==========================================

	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 0


	UPDATE	#VP_TA_CATALOGO
	SET		TA_O_CATALOGO = 99999
	WHERE	TA_K_CATALOGO>999

	-- ==========================================

	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,	TA_O_CATALOGO,	
					-- =========================
					[D_ZONA_UO], 
					[S_ZONA_UO]			)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)', 	
					'(TODOS)'		  )

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_ZONA_UO] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
			+ ' ( '+[S_ZONA_UO]+' - '+ ' )'
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	[S_ZONA_UO], 
				TA_O_CATALOGO

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO



-- ///////////////////////////////////////////////////////////


/*

EXECUTE [PG_CB_UNIDAD_OPERATIVA_x_AccesoLoad]	0,2006,169,  1,1,  -1, -1

EXECUTE [PG_CB_RAZON_SOCIAL_x_AccesoLoad]		0,2006,169,  1,1,  -1

EXECUTE [PG_CB_ZONA_UO_x_AccesoLoad]			0,2006,169,  1,1

*/


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
