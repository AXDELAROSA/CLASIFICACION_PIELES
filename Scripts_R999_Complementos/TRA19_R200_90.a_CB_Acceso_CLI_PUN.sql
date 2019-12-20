-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_PUNTO_ENTREGA_x_AccesoLoad] 0,2006,169,  1,1,  28


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_PUNTO_ENTREGA_x_AccesoLoad]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_PUNTO_ENTREGA_x_AccesoLoad]
GO


CREATE PROCEDURE [dbo].[PG_CB_PUNTO_ENTREGA_x_AccesoLoad]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_CON_CLIENTE_TRA		INT,
--	@PP_K_ZONA_UO				INT,
	@PP_K_CLIENTE_TRA			INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
						-- =========================
						[D_PUNTO_ENTREGA]	VARCHAR(200),
--						[D_TIPO_UO]			VARCHAR(200),
--						[D_ZONA_UO]			VARCHAR(200),
--						[D_CLIENTE_TRA]		VARCHAR(200),
--						[D_REGION]			VARCHAR(200),
						[S_PUNTO_ENTREGA]	VARCHAR(200),
--						[S_TIPO_UO]			VARCHAR(200),
--						[S_ZONA_UO]			VARCHAR(200),
--						[S_CLIENTE_TRA]		VARCHAR(200),
--						[S_REGION]			VARCHAR(200)			
					)
	
	-- ==========================================
	
	INSERT INTO #VP_TA_CATALOGO 
		(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
				[D_PUNTO_ENTREGA],--, [D_TIPO_UO], [D_CLIENTE_TRA],
				[S_PUNTO_ENTREGA])--, [S_TIPO_UO], [S_CLIENTE_TRA]	)
--				[D_PUNTO_ENTREGA], [D_TIPO_UO], [D_ZONA_UO], [D_CLIENTE_TRA], [D_REGION],
--				[S_PUNTO_ENTREGA], [S_TIPO_UO], [S_ZONA_UO], [S_CLIENTE_TRA], [S_REGION])
		SELECT	PUNTO_ENTREGA.K_PUNTO_ENTREGA, O_PUNTO_ENTREGA,
				-- =========================
				PUNTO_ENTREGA.[D_PUNTO_ENTREGA], -- [D_TIPO_UO], [D_CLIENTE_TRA],
				PUNTO_ENTREGA.[S_PUNTO_ENTREGA] -- [S_TIPO_UO], [S_CLIENTE_TRA]
--				PUNTO_ENTREGA.[D_PUNTO_ENTREGA], [D_TIPO_UO], [D_ZONA_UO], [D_CLIENTE_TRA], [D_REGION],
--				PUNTO_ENTREGA.[S_PUNTO_ENTREGA], [S_TIPO_UO], [S_ZONA_UO], [S_CLIENTE_TRA], [S_REGION]
		FROM	PUNTO_ENTREGA, CLIENTE_TRA -- [VI_PUNTO_ENTREGA_CATALOGOS],
--				[SYS3_ACCESO_USR_X_UNO] AS SYS_ACCESO
--		WHERE	PUNTO_ENTREGA.K_PUNTO_ENTREGA=[VI_PUNTO_ENTREGA_CATALOGOS].VI_K_PUNTO_ENTREGA
		WHERE	PUNTO_ENTREGA.L_BORRADO=0
--		AND		SYS_ACCESO.L_ACCESO=1
--		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
--		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
				-- ================================
--		AND		( @PP_K_ZONA_UO=-1				OR		PUNTO_ENTREGA.K_ZONA_UO=@PP_K_ZONA_UO )
		AND		( @PP_K_CLIENTE_TRA=-1			OR		PUNTO_ENTREGA.K_CLIENTE_TRA=@PP_K_CLIENTE_TRA )
--		AND		( @PP_L_CON_CLIENTE_TRA=1		OR		PUNTO_ENTREGA.K_TIPO_UO<>50)
		-- =================================
--		AND		PUNTO_ENTREGA.K_PUNTO_ENTREGA=SYS_ACCESO.K_PUNTO_ENTREGA
		AND		PUNTO_ENTREGA.K_CLIENTE_TRA=CLIENTE_TRA.K_CLIENTE_TRA

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
					[D_PUNTO_ENTREGA],--, [D_TIPO_UO], [D_CLIENTE_TRA],
					[S_PUNTO_ENTREGA])--, [S_TIPO_UO], [S_CLIENTE_TRA]		)

--					[D_PUNTO_ENTREGA], [D_TIPO_UO], [D_ZONA_UO], [D_CLIENTE_TRA], [D_REGION],
--					[S_PUNTO_ENTREGA], [S_TIPO_UO], [S_ZONA_UO], [S_CLIENTE_TRA], [S_REGION]		)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)', --, '', '', '', '',		
					'(TODOS)') --, '', '', '', ''		  )

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_PUNTO_ENTREGA] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
--			+ ' ( '+[S_ZONA_UO]+' - '+[D_CLIENTE_TRA]+' )'
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	--[S_ZONA_UO], 
				TA_O_CATALOGO,
--				[D_CLIENTE_TRA], 
				[D_PUNTO_ENTREGA] 

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO




-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_CLIENTE_TRA_x_AccesoLoad] 0,2006,169,  1,1,  -1


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_CLIENTE_TRA_x_AccesoLoad]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_CLIENTE_TRA_x_AccesoLoad]
GO


CREATE PROCEDURE [dbo].[PG_CB_CLIENTE_TRA_x_AccesoLoad]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ======================================
	@PP_L_CON_TODOS				INT,
	@PP_L_CON_CLIENTE_TRA		INT,
	@PP_K_TIPO_CLIENTE_TRA		INT
AS

	DECLARE @VP_INT_SHOW_K		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
		
	CREATE TABLE	#VP_TA_CATALOGO	
					(	TA_K_CATALOGO		INT,
						TA_O_CATALOGO		INT,
						-- =========================
						[D_TIPO_CLIENTE_TRA]	VARCHAR(200),
						[D_CLIENTE_TRA]			VARCHAR(200),
						[S_TIPO_CLIENTE_TRA]	VARCHAR(200),
						[S_CLIENTE_TRA]			VARCHAR(200)		)
	
	-- ==========================================
	
	INSERT INTO #VP_TA_CATALOGO 
		(		TA_K_CATALOGO, TA_O_CATALOGO,
				-- =========================
				[D_TIPO_CLIENTE_TRA], [D_CLIENTE_TRA],
				[S_TIPO_CLIENTE_TRA], [S_CLIENTE_TRA]		)
				SELECT	DISTINCT
				PUNTO_ENTREGA.K_CLIENTE_TRA, PUNTO_ENTREGA.K_CLIENTE_TRA,
				-- =========================
				[D_TIPO_CLIENTE_TRA], CLIENTE_TRA.[D_CLIENTE_TRA],
				[S_TIPO_CLIENTE_TRA], CLIENTE_TRA.[S_CLIENTE_TRA]		
		FROM	CLIENTE_TRA, TIPO_CLIENTE_TRA,
				PUNTO_ENTREGA
--				, [VI_PUNTO_ENTREGA_CATALOGOS],
--				[SYS3_ACCESO_USR_X_RAS] AS SYS_ACCESO
--		WHERE	PUNTO_ENTREGA.K_PUNTO_ENTREGA=[VI_PUNTO_ENTREGA_CATALOGOS].VI_K_PUNTO_ENTREGA
		WHERE	PUNTO_ENTREGA.L_BORRADO=0
--		AND		SYS_ACCESO.L_ACCESO=1
--		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
--		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
				-- ================================
--		AND		( @PP_K_ZONA_UO=-1			OR		PUNTO_ENTREGA.K_ZONA_UO=@PP_K_ZONA_UO )
--		AND		( @PP_K_CLIENTE_TRA=-1		OR		PUNTO_ENTREGA.K_CLIENTE_TRA=@PP_K_CLIENTE_TRA )
--		AND		( @PP_L_CON_CLIENTE_TRA=1	OR		PUNTO_ENTREGA.K_TIPO_UO<>50)
		-- =================================
		AND		PUNTO_ENTREGA.K_CLIENTE_TRA=CLIENTE_TRA.K_CLIENTE_TRA
		AND		CLIENTE_TRA.K_TIPO_CLIENTE_TRA=TIPO_CLIENTE_TRA.K_TIPO_CLIENTE_TRA
--		AND		CLIENTE_TRA.K_TIPO_CLIENTE_TRA=TIPO_CLIENTE_TRA.K_TIPO_CLIENTE_TRA

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
					[D_TIPO_CLIENTE_TRA],	[D_CLIENTE_TRA],
					[S_TIPO_CLIENTE_TRA],	[S_CLIENTE_TRA]		)
			VALUES
				(	-1,				-999,		 					
					'(TODOS)', '', 		
					'(TODOS)', ''	)

	-- ==========================================
	
	SET @VP_INT_SHOW_K = 1

	SELECT	 
			TA_K_CATALOGO	AS K_COMBOBOX,
			[D_CLIENTE_TRA] 
			+ ( CASE WHEN @VP_INT_SHOW_K=1 
					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
					ELSE '' END )
			+ ' ( '+ ' - '+' )'
							AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	TA_O_CATALOGO,
				[D_CLIENTE_TRA]
				, TA_K_CATALOGO

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
GO




-- ////////////////////////////////////////////////////////////////
-- // 
-- ////////////////////////////////////////////////////////////////
-- SELECT * FROM [VI_PUNTO_ENTREGA_CATALOGOS]

-- SELECT * FROM USUARIO

-- EXECUTE [PG_CB_CLIENTE_TRA_x_AccesoLoad] 0,2006,169,  1,1,  -1, -1


--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_ZONA_UO_x_AccesoLoad]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_CB_ZONA_UO_x_AccesoLoad]
--GO


--CREATE PROCEDURE [dbo].[PG_CB_ZONA_UO_x_AccesoLoad]
--	@PP_L_DEBUG					INT,
--	@PP_K_SISTEMA_EXE			INT,
--	@PP_K_USUARIO_ACCION		INT,
--	-- ======================================
--	@PP_L_CON_TODOS				INT,
--	@PP_L_CON_CLIENTE_TRA		INT
--AS

--	DECLARE @VP_INT_SHOW_K		INT

--	EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
--																@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
--	-- ==========================================
		
--	CREATE TABLE	#VP_TA_CATALOGO	
--					(	TA_K_CATALOGO		INT,
--						TA_O_CATALOGO		INT,
--						-- =========================
--						[D_ZONA_UO]				VARCHAR(200),
--						[S_ZONA_UO]				VARCHAR(200)		)
	
--	-- ==========================================
	
--	INSERT INTO #VP_TA_CATALOGO 
--		(		TA_K_CATALOGO, TA_O_CATALOGO,
--				-- =========================
--				[D_ZONA_UO],
--				[S_ZONA_UO]		)
--		SELECT	DISTINCT
--				VI_K_ZONA_UO, VI_K_ZONA_UO,
--				-- =========================
--				[D_ZONA_UO], 
--				[S_ZONA_UO] 
--		FROM	[VI_PUNTO_ENTREGA_CATALOGOS],
--				[SYS3_ACCESO_USR_X_UNO] AS SYS_ACCESO
--		WHERE	SYS_ACCESO.L_ACCESO=1
--		AND		SYS_ACCESO.K_SISTEMA=@PP_K_SISTEMA_EXE			
--		AND		SYS_ACCESO.K_USUARIO=@PP_K_USUARIO_ACCION		
--				-- ================================
----		AND		( @PP_K_ZONA_UO=-1				OR		PUNTO_ENTREGA.K_ZONA_UO=@PP_K_ZONA_UO )
----		AND		( @PP_K_CLIENTE_TRA=-1			OR		PUNTO_ENTREGA.K_CLIENTE_TRA=@PP_K_CLIENTE_TRA )
----		AND		( @PP_L_CON_CLIENTE_TRA=1		OR		PUNTO_ENTREGA.K_TIPO_UO<>50)
--		-- =================================
--		AND		VI_K_PUNTO_ENTREGA=SYS_ACCESO.K_PUNTO_ENTREGA


--	-- ==========================================

--	UPDATE	#VP_TA_CATALOGO
--	SET		TA_O_CATALOGO = 0


--	UPDATE	#VP_TA_CATALOGO
--	SET		TA_O_CATALOGO = 99999
--	WHERE	TA_K_CATALOGO>999

--	-- ==========================================

--	IF @PP_L_CON_TODOS=1
--		INSERT INTO #VP_TA_CATALOGO
--				(	TA_K_CATALOGO,	TA_O_CATALOGO,	
--					-- =========================
--					[D_ZONA_UO], 
--					[S_ZONA_UO]			)
--			VALUES
--				(	-1,				-999,		 					
--					'(TODOS)', 	
--					'(TODOS)'		  )

--	-- ==========================================
	
--	SET @VP_INT_SHOW_K = 1

--	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
--			[D_ZONA_UO] 
--			+ ( CASE WHEN @VP_INT_SHOW_K=1 
--					THEN (' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') 
--					ELSE '' END )
--			+ ' ( '+[S_ZONA_UO]+' - '+ ' )'
--							AS D_COMBOBOX
--	FROM	#VP_TA_CATALOGO
--	ORDER BY	[S_ZONA_UO], 
--				TA_O_CATALOGO

--	-- ==========================================

--	DROP TABLE #VP_TA_CATALOGO

--	-- ==========================================
--GO



-- ///////////////////////////////////////////////////////////


/*

EXECUTE [PG_CB_PUNTO_ENTREGA_x_AccesoLoad]	0,2006,169,  1,1,  -1, -1

EXECUTE [PG_CB_CLIENTE_TRA_x_AccesoLoad]		0,2006,169,  1,1,  -1

EXECUTE [PG_CB_ZONA_UO_x_AccesoLoad]			0,2006,169,  1,1

*/


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
