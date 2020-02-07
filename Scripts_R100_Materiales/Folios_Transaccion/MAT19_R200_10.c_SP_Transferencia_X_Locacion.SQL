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


-- EXECUTE [dbo].[PG_SK_FOLIO_X_COLOUR] 0,0,  'FCK2DX9' 

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

	SELECT	DISTINCT
			TAG,
			STATUS,
			MACHINE,
			JOBNO,
			COLOUR
	-- =====================
	FROM RP_Folios 
	INNER JOIN RP_SC ON RP_Folios.TAG=RP_SC.TAGNO 
						AND COLOUR = @PP_D_COLOR 
	WHERE  STATUS  <> 'XX'
	ORDER BY TAG
	-- =====================
	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_SK_RP_SC_TRANSFERIR_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_RP_SC_PRT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_RP_SC_PRT]
GO


CREATE PROCEDURE [dbo].[PG_IN_RP_SC_PRT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TYPE					INT
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	IF @VP_MENSAJE = ''
		BEGIN
			INSERT INTO RP_SC_PRT (
								TAG, TYPE	) 
					VALUES (	@PP_TAG_NO, @PP_TYPE)

			--IF @@ROWCOUNT = 0
			--	SET @VP_MENSAJE = 'ERROR: // INSERT RP_SC_PRT // '
		END
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO] en [RP_SC_PRT]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO AS CLAVE
	
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
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

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

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

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
		
			EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
													@PP_TAG_NO, 'A', NULL, NULL
		END
	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_TAG_NO_NUEVO		INT = 0
	EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'RP_SC', 'TAGNO',
												@OU_K_TABLA_DISPONIBLE = @VP_TAG_NO_NUEVO	OUTPUT
	-- =====================

	IF @VP_MENSAJE = ''
		BEGIN
			INSERT INTO RP_Folios (	
					TAG, STATUS, MACHINE, JOBNO	) 
			VALUES(
					@VP_TAG_NO_NUEVO, 'A', @VP_MACHINE, @PP_JOB_NO	)
			
			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT RP_Folios // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE = ''
		BEGIN
			EXECUTE [PG_IN_RP_SC_PRT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
										@VP_TAG_NO_NUEVO, 1
		END
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAG_NO_NUEVO)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @VP_TAG_NO_NUEVO AS CLAVE
	
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
													0, 0, @VP_TAG_NO_NUEVO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- EXECUTE [dbo].[PG_SK_RP_SC_TRANSFERIR_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO_NUEVO			INT,
	@PP_TAG_NO_ANTERIOR			INT,
	@PP_HIDE					VARCHAR(15),
	@PP_LOT 					VARCHAR(15),
	@PP_SQF						VARCHAR(15),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	EXECUTE	[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TAG_NO_ANTERIOR, @PP_TAG_NO_NUEVO, 
																@PP_HIDE, @PP_LOT, @PP_SQF
	
	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_DETAIL VARCHAR(100) = 'Transfer hide: ' + @PP_HIDE + ' to: ' + CONVERT(VARCHAR(20),@PP_TAG_NO_NUEVO) + ' Lot: ' + RIGHT('000000' + Ltrim(Rtrim(@PP_LOT)), 6)
	
	IF @VP_MENSAJE = ''
		BEGIN
			
			EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
												@PP_TAG_NO_ANTERIOR, 'Transfer Nuevo',
												@VP_DETAIL, @PP_HIDE

		END
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO_ANTERIOR)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO_ANTERIOR AS CLAVE
	
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





-- EXECUTE [dbo].[PG_SK_IMINVTRX_SQL_LOC_X_ORDER_NO] 0,0, 04244360
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
	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RP_SC_Y_RP_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RP_SC_Y_RP_FOLIO]
GO

-- EXEC PG_LI_RP_SC_Y_RP_FOLIO 0 ,0, '32701', '0486' 

CREATE PROCEDURE [dbo].[PG_LI_RP_SC_Y_RP_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(20),
	@PP_PIEL					VARCHAR(20)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
			
	SELECT  DISTINCT
			ISNULL(COLOUR, '')	AS COLOUR,
			ISNULL(LOT, '')		AS LOT,
			ISNULL(HIDE, '')	AS HIDE,
			ISNULL(SQF, '')		AS SQF,
			ISNULL(TAGNO, 0)	AS TAGNO,
			ISNULL(STATUS, '')	AS STATUS,
			ISNULL(MACHINE, '') AS MACHINE,
			ISNULL(JOBNO, '')	AS JOBNO 
	FROM	RP_SC 
	-- =======================
	INNER JOIN	RP_Folios ON RP_Folios.TAG=RP_SC.TAGNO 
				AND	LOT=@PP_LOTE
				AND	HIDE=@PP_PIEL	
	-- =======================
	--ORDER BY CDATE
          

	-----////////////////////////////////////////////////////////////////

	--EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'SELECT',
	--												'',
	--												-- ===========================================
	--												'[LI]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_LOTE, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_SK_RP_SC_TEMP_X_TAG_NO] 0,0,  '3783325'
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_TEMP_X_TAG_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_TEMP_X_TAG_NO]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_TEMP_X_TAG_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	*
	-- =====================
	FROM	RP_SC_TEMP
	WHERE	tagno=@PP_TAG_NO 
	ORDER BY HIDE ASC
	-- =====================
	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_JOB_NO					VARCHAR(50),
	@PP_LOCATION				VARCHAR(50),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////

	DECLARE @VP_COLOUR VARCHAR(15)
	DECLARE @VP_STATUS VARCHAR(5)

	SELECT	DISTINCT	
			@VP_COLOUR = COLOUR,
			@VP_STATUS = STATUS
	-- =====================
	FROM	RP_Folios 
	INNER	JOIN RP_SC ON RP_Folios.TAG=RP_SC.TAGNO
	AND		RP_Folios.TAG=@PP_TAG_NO 

	IF	@VP_COLOUR IS NULL
		SET @VP_COLOUR = ''

	IF	@VP_STATUS IS NULL
		SET @VP_STATUS = ''
	-- =====================

	DECLARE @VP_MACHINE VARCHAR(20)

	SELECT  @VP_MACHINE = MACHINE 
	FROM	CCJOBHDR_SQL 
	WHERE	JOBNO=@PP_JOB_NO
	
	IF	@VP_MACHINE IS NULL
		SET @VP_MACHINE = ''
		
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE = ''
		BEGIN
			UPDATE	CCJOBHDR_SQL 
				SET	STARTEDFLAG =	'C',
					FOLIO		=	@PP_TAG_NO
			WHERE	JOBNO=@PP_JOB_NO
			
			IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR SP: PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO', 16, 1 ) --MENSAJE - Severity -State.
					--SET @VP_MENSAJE = 'ERROR: // UPDATE CCJOBHDR_SQL // '
				END
		END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE = ''
		BEGIN
			UPDATE	RP_Folios 
				SET	STATUS	=	'C1',
					MACHINE	=	@VP_MACHINE,
					JOBNO	=	@PP_JOB_NO
			WHERE	TAG=@PP_TAG_NO

			IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR SP: PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO', 16, 1 ) --MENSAJE - Severity -State.
					--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_Folios // '
				END
		END
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_MENSAJE = ''
		BEGIN
		
			DECLARE @VP_DETAIL VARCHAR(100) = ' To: ' + @PP_LOCATION + ' order: ' + @PP_JOB_NO 
	
			EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION ,
												@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
												@PP_TAG_NO, 'Cargar Orden',
												@VP_DETAIL, ''
			
		END
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO AS CLAVE
	
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
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
