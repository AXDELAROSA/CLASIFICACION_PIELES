-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		MAT19
-- // MODULE:			
-- // OPERATION:		
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			FEG			
-- // CREATION DATE:	20191219
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////


/* CARGA COMBO DE COLORES */
-- EXECUTE [PG_CB_COLOUR] 001,144, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_COLOUR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_COLOUR]
GO


CREATE PROCEDURE [dbo].[PG_CB_COLOUR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS
	--DECLARE @VP_TA_CATALOGO	AS TABLE
	--			(	TA_K_CATALOGO		INT,
	--				TA_D_CATALOGO		VARCHAR(50))
	
	--INSERT INTO @VP_TA_CATALOGO 
	SELECT	ID				AS K_COMBOBOX,
			LTRIM(RTRIM(COLOR))		AS D_COMBOBOX	
	FROM	COLORS 
	WHERE	COLOR LIKE 'F%'


	--IF @PP_L_CON_TODOS=1
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO	)
	--		VALUES
	--			( -1,				'( TODOS )'	)

	--SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
	--			TA_D_CATALOGO	AS D_COMBOBOX 
	--	FROM	@VP_TA_CATALOGO
	--	ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO



/* CARGA COMBO DE LOCACIONES */
-- EXECUTE [PG_CB_IMLOCFIL_SQL] 001,144, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_IMLOCFIL_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_IMLOCFIL_SQL]
GO


CREATE PROCEDURE [dbo].[PG_CB_IMLOCFIL_SQL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
						(	TA_K_CATALOGO		INT IDENTITY(1,1) NOT NULL,
							TA_D_CATALOGO		VARCHAR(50))

	IF @PP_L_CON_TODOS=1
		BEGIN	
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	LTRIM(RTRIM(alt1_loc))		AS D_COMBOBOX	
			FROM	imlocfil_sql 
		END
	ELSE
		BEGIN
			INSERT INTO @VP_TA_CATALOGO 
			SELECT	LTRIM(RTRIM(alt1_loc))		AS D_COMBOBOX	
			FROM	imlocfil_sql 
			WHERE	SUBSTRING(LTRIM(RTRIM(alt1_loc)),1,1) = 'T'
			UNION
			SELECT	LTRIM(RTRIM(alt1_loc))		AS D_COMBOBOX	
			FROM	imlocfil_sql 
			WHERE	 LTRIM(RTRIM(alt1_loc)) = 'MHI'
		END
	
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
	FROM	@VP_TA_CATALOGO
	ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO


/* CARGA COMBO DE ORDENES */

-- EXECUTE [PG_CB_JOBNO_SQL] 001,144, 0, 'Table 01'      
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_JOBNO_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_JOBNO_SQL]
GO


CREATE PROCEDURE [dbo].[PG_CB_JOBNO_SQL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_L_CON_TODOS				INT,
	@PP_MACHINE					VARCHAR(15)
AS
	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT IDENTITY(1,1) NOT NULL,
					TA_D_CATALOGO		VARCHAR(50))
	
	INSERT INTO @VP_TA_CATALOGO 

	SELECT	LTRIM(RTRIM(jobno))		AS D_COMBOBOX	
	FROM	ccjobhdr_sql 
	WHERE	status='P'
	AND		machine=@PP_MACHINE
	
	--IF @PP_L_CON_TODOS=1
	--	INSERT INTO @VP_TA_CATALOGO
	--			( TA_K_CATALOGO,	TA_D_CATALOGO	)
	--		VALUES
	--			( -1,				'( TODOS )'	)

	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
	FROM	@VP_TA_CATALOGO
	ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO



-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////