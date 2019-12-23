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
	@PP_D_COLOR					VARCHAR(100)
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
	--AND MOVEMENT <> 0 -- QUITAR SOLO PARA PRUEBA
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



-- EXECUTE [dbo].[PG_SK_RP_SC_X_TAG_NO] 0,0,  807969
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
			LOT		AS LOTE,
			HIDE	AS PIEL,
			SQF,
			MOVEMENT
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





-- EXECUTE [dbo].[PG_SK_RP_SC_LOTE_X_TAG_NO] 0,0,  1524141
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_LOTE_X_TAG_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_LOTE_X_TAG_NO]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_LOTE_X_TAG_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	DISTINCT
			LOT		AS LOTE
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




-- EXECUTE [dbo].[PG_SK_RP_SC_TRANSFERIR_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_RP_FOLIO_TRANSFERIR_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_RP_FOLIO_TRANSFERIR_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_IN_RP_FOLIO_TRANSFERIR_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_JOB_NO					VARCHAR(50),
	@PP_SELECT_TODOS			INT
AS

	DECLARE @VP_MENSAJE VARCHAR(50) = ''

	-- ///////////////////////////////////////////

	DECLARE @VP_COLOUR VARCHAR(50)

	SELECT	TOP 1 @VP_COLOUR = COLOUR
	-- =====================
	FROM	RP_SC
	WHERE	TAGNO=@PP_TAG_NO 

	IF	@VP_COLOUR IS NULL
		SET @VP_COLOUR = ''
	-- =====================

	DECLARE @VP_MACHINE VARCHAR(50)

	SELECT  TOP 1 @VP_MACHINE = MACHINE 
	FROM	RP_Folios 
	WHERE	TAG=@PP_TAG_NO
	
	IF	@VP_MACHINE IS NULL
		SET @VP_MACHINE = ''
	-- =====================

	DECLARE @VP_JOBNO VARCHAR(10)

	SELECT DISTINCT @VP_JOBNO = JOBNO
	FROM	RP_Folios 
	INNER JOIN	RP_SC ON RP_Folios.TAG=RP_SC.TAGNO
	AND			RP_Folios.TAG=@PP_TAG_NO
	GROUP BY	TAG, STATUS, MACHINE, COLOUR , JOBNO

	IF @VP_JOBNO IS NULL
		SET @VP_JOBNO = ''

	-- /////////////////////////////////////////////////////////////////////

	IF	@PP_SELECT_TODOS = 1
		BEGIN
			UPDATE RP_Folios 
			SET
				STATUS='A',
				JOBNO=NULL,
				MACHINE=NULL 
			WHERE TAG=@PP_TAG_NO

			IF @@ROWCOUNT = 0
			SET @VP_MENSAJE = 'ERROR: // UPDATE RP_Folios  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_TAG_NO		INT = 0
	EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'RP_SC', 'TAGNO',
												@OU_K_TABLA_DISPONIBLE = @VP_TAG_NO	OUTPUT
	-- =====================

	INSERT INTO RP_Folios (	
			TAG, STATUS, MACHINE, JOBNO	) 
	VALUES(
			@VP_TAG_NO, 'A', @VP_MACHINE, @PP_JOB_NO	)
	
	IF @@ROWCOUNT = 0
		SET @VP_MENSAJE = 'ERROR: // INSERT RP_Folio // '

	-- /////////////////////////////////////////////////////////////////////
	

	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAG_NO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_TAG_NO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'INSERT',
													'',
													-- ===========================================
													'[IN]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @VP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_SK_RP_SC_TRANSFERIR_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO_NUEVO			INT,
	@PP_TAG_NO_ANTERIOR			INT,
	@VP_HIDE					VARCHAR(15),
	@VP_LOT 					VARCHAR(15),
	@VP_SQF						VARCHAR(15)

AS

	DECLARE @VP_MENSAJE VARCHAR(50) = ''

	-- ///////////////////////////////////////////

	UPDATE RP_SC 
	SET 
			TAGNO=@PP_TAG_NO_NUEVO 
	WHERE	TAGNO=@PP_TAG_NO_ANTERIOR
	AND		HIDE=@VP_HIDE 
	AND		LOT=@VP_LOT 
	AND		SQF=@VP_SQF

	IF @@ROWCOUNT = 0
	SET @VP_MENSAJE = 'ERROR: // UPDATE RP_Folios  // '

	-- /////////////////////////////////////////////////////////////////////
	

	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO_ANTERIOR)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO_ANTERIOR AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO_ANTERIOR, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- EXECUTE [dbo].[PG_SK_IMINVTRX_SQL_LOC_X_ORDER_NO] 0,0, 02564860
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_IMINVTRX_SQL_LOC_X_ORDER_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_IMINVTRX_SQL_LOC_X_ORDER_NO]
GO


CREATE PROCEDURE [dbo].[PG_SK_IMINVTRX_SQL_LOC_X_ORDER_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDER_NO				INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	IMLSTRX_SQL.Source, IMLSTRX_SQL.Ord_No, IMLSTRX_SQL.Ctl_No, 
			IMINVTRX_SQL.Quantity, IMLSTRX_SQL.Line_No, IMLSTRX_SQL.Lev_No, 
			IMLSTRX_SQL.Seq_No, IMLSTRX_SQL.Ser_Lot_No, IMLSTRX_SQL.Trx_Dt, 
			IMLSTRX_SQL.Trx_Qty, IMLSTRX_SQL.Item_No, IMINVTRX_SQL.Loc, 
			IMINVTRX_SQL.Doc_Dt, IMINVTRX_SQL.Doc_Type, IMINVTRX_SQL.Doc_Ord_No, 
			IMINVTRX_SQL.Doc_Source, IMINVTRX_SQL.User_Name, IMLSTRX_SQL.Trx_Tm, 
			IMINVTRX_SQL.Comment
			-- ===================== 
	FROM	IMLSTRX_SQL, IMINVTRX_SQL 
			-- =====================
	WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
	AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
	AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
	AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
	AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
	AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
	AND		IMINVTRX_SQL.ord_no	= @PP_ORDER_NO
	-- =====================
	AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
			OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
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
													0, 0, @PP_ORDER_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_SK_RP_FOLIO_X_TAG] 0,0,  'FNLGPS4' 

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_FOLIO_X_TAG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_FOLIO_X_TAG]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_FOLIO_X_TAG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG						INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	ID,
			ISNULL(TAG, 0)		AS ID,
			ISNULL(STATUS,'')	AS STATUS,
			ISNULL(MACHINE,'')	AS MACHINE,
			ISNULL(JOBNO,'')	AS JOBNO,
			ISNULL(JOBNO2,'')	AS JOBNO2
	-- =====================
	FROM	RP_Folios 
	WHERE	TAG = @PP_TAG
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
													0, 0, @PP_TAG, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_SK_RP_FOLIO_X_TAG] 0,0,  'FNLGPS4' 

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_X_RP_FOLIO_STATUS_B]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_X_RP_FOLIO_STATUS_B]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_X_RP_FOLIO_STATUS_B]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_STATUS					VARCHAR(50)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	
	SELECT	TAGNO, 
			COLOUR, 
			COUNT(TAGNO) AS PIELES, 
			SUM(CAST(SQF AS DECIMAL(4,2))) AS SQF 
	-- =====================
	FROM	RP_SC 
	-- =====================
	WHERE	TAGNO IN (	SELECT	TAG 
						FROM	RP_Folios 
						WHERE	STATUS=@PP_STATUS )
	-- =====================
	GROUP BY TAGNO, COLOUR

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
													0, 0, @PP_STATUS, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
