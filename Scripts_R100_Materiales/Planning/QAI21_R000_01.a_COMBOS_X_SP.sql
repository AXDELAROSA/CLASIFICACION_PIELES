-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			EMBARQUES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/11/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_COLOR_X_CLIENTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_COLOR_X_CLIENTE]
GO

/*
	EXEC	[dbo].[PG_CB_COLOR_X_CLIENTE] 0,0,	 'MAGN03'
*/
CREATE PROCEDURE [dbo].[PG_CB_COLOR_X_CLIENTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_CLIENTE					VARCHAR(50)
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT IDENTITY(1,1),
					TA_D_CATALOGO		VARCHAR(50))

	INSERT INTO @VP_TA_CATALOGO 
	SELECT	DISTINCT
			LTRIM(RTRIM(COLOUR))	AS TA_D_CATALOGO
	FROM [DATA_02].[dbo].COLORES_ACTIVOS 
	WHERE cus_no = @PP_CLIENTE

	-- ///////////////////////////////////////////////////
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
				TA_D_CATALOGO	AS D_COMBOBOX 
		FROM	@VP_TA_CATALOGO
		ORDER BY  TA_D_CATALOGO 

	-- ==========================================
		
	-- ////////////////////////////////////////////////////
GO




IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_LOCACION_X_CLIENTE_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_LOCACION_X_CLIENTE_COLOR]
GO

/*
	EXEC	[dbo].PG_CB_LOCACION_X_CLIENTE_COLOR 0,0,	 'MAGN03', 'FCNPJRR'
*/
CREATE PROCEDURE [dbo].PG_CB_LOCACION_X_CLIENTE_COLOR
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO				INT,
	--============================
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50)
AS

	DECLARE @VP_TA_CATALOGO	AS TABLE
				(	TA_K_CATALOGO		INT IDENTITY(1,1),
					TA_D_CATALOGO		VARCHAR(50))

	INSERT INTO @VP_TA_CATALOGO 
	SELECT DISTINCT LTRIM(RTRIM(MACHINE))
	FROM ccjobhdr_sql 
	WHERE CUSTOMER =  @PP_CLIENTE
	AND CONCAT('F', LTRIM(RTRIM(COLOUR))) = @PP_COLOR
	AND STATUS = 'P'

	INSERT INTO @VP_TA_CATALOGO (TA_D_CATALOGO)
	VALUES ( '( TODOS )'	)

	-- ///////////////////////////////////////////////////
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