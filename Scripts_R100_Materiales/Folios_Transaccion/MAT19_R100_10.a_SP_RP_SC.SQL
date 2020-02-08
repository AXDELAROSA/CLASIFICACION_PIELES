-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RP_SC]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RP_SC]
GO

-- EXEC PG_LI_RP_SC_Y_RP_FOLIO 0 ,0, '32291', '0023' 

CREATE PROCEDURE [dbo].[PG_LI_RP_SC]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT,
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_PIEL					VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	SELECT TOP 1
			ISNULL(CDATE, '')		AS CDATE,
			ISNULL(COLOUR, '')		AS COLOUR,
			ISNULL(LOT, '')			AS LOT,
			ISNULL(HIDE, '')		AS HIDE,
			ISNULL(SQF, '')			AS SQF,
			ISNULL(TAGNO, 0)		AS TAGNO,
			ISNULL(YARDAS, '')		AS YARDAS,
			ISNULL(YLB, '')			AS YLB,
			ISNULL(PESO, '')		AS PESO,
			ISNULL(TYPE, '')		AS TYPE,
			ISNULL(MOVEMENT, '')	AS MOVEMENT
	FROM	RP_SC 
	-- =======================
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_FOLIO
	AND		LTRIM(RTRIM(COLOUR))=@PP_COLOR
	AND		LTRIM(RTRIM(LOT))=@PP_LOTE
	AND		LTRIM(RTRIM(HIDE))=@PP_PIEL	
	-- =======================
	ORDER BY CDATE DESC
          

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [dbo].[PG_SK_RP_SC_X_TAG_NO_GB_COLOR_LOTE] 0,0,  3777539
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_X_TAG_NO_GB_COLOR_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_X_TAG_NO_GB_COLOR_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_X_TAG_NO_GB_COLOR_LOTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	COLOUR	AS COLOUR,
			CONCAT('         ', RIGHT('000000' + Ltrim(Rtrim(LOT)), 6))		AS LOT,
			SUM(CAST(SQF AS DECIMAL(4,2)))	AS SQF
	-- =====================
	FROM	RP_SC
	-- =====================
	WHERE	TAGNO=@PP_TAG_NO 
	-- =====================
	GROUP BY	COLOUR, LOT
	-- =====================

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
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
	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_SK_RP_SC_X_TAG_NO] 0,0,  3777539
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
			COLOUR  AS COLOR,
			LOT		AS LOTE,
			HIDE	AS PIEL,
			SQF,
			ISNULL(MOVEMENT, '0') AS MOVEMENT
	-- =====================
	FROM	RP_SC
	WHERE	TAGNO=@PP_TAG_NO 
	AND		type<>'D'
	ORDER BY HIDE ASC
	-- =====================

	-----////////////////////////////////////////////////////////////////
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
			CONCAT('         ', RIGHT('000000' + Ltrim(Rtrim(LOT)), 6))		AS LOTE
			--LOT		AS LOTE
	-- =====================
	FROM	RP_SC
	WHERE	TAGNO=@PP_TAG_NO 
	AND		type<>'D'
	-- =====================
	

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO






-- EXECUTE [dbo].[PG_SK_RP_SC_COLOUR_X_TAG_NO] 0,0,  3777539
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_SC_COLOUR_X_TAG_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_SC_COLOUR_X_TAG_NO]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_SC_COLOUR_X_TAG_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	ISNULL(COLOUR, '')		AS COLOR,
			ISNULL(LOT, '')			AS LOTE,
			ISNULL(HIDE, '')		AS PIEL,
			ISNULL(SQF, '')			AS SQF,
			ISNULL(TYPE, '')		AS TIPO,
			ISNULL(MOVEMENT, '')	AS MOVIMIENTO	
	-- =====================
	FROM	RP_SC
	WHERE	TAGNO=@PP_TAG_NO 
	-- =====================

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
-- EXECUTE PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE 0,0,'104313'
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_RP_SC]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_RP_SC]
GO


CREATE PROCEDURE [dbo].[PG_IN_RP_SC]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_F_INGRESO				DATE,
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(10),
	@PP_PIEL					VARCHAR(10),
	@PP_SQF						VARCHAR(10),
	@PP_FOLIO					INT,
	@PP_YARDAS					VARCHAR(10),
	@PP_YLB						VARCHAR(10),
	@PP_PESO					VARCHAR(10),
	@PP_TIPO					VARCHAR(10),
	@PP_MOVIMIENTO				VARCHAR(10),
	@PP_K_CLASIFICACION			INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@VP_K_PIEL_CLASIFICADA,@PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	
			INSERT INTO RP_SC	
						(	[CDATE], 
							[COLOUR],						
							[LOT],				
							[HIDE],	
							[SQF],		
							[TAGNO],		
							[YARDAS],			
							[YLB],		
							[PESO],	
							[TYPE],
							[MOVEMENT],
							[K_CLASIFICACION]	
							)		
					VALUES	
						(	@PP_F_INGRESO, 
							@PP_COLOR,			
							@PP_LOTE,			
							@PP_PIEL,			
							@PP_SQF,				
							@PP_FOLIO,			
							@PP_YARDAS,			
							@PP_YLB,				
							@PP_PESO,				
							@PP_TIPO,						
							@PP_MOVIMIENTO,		
							@PP_K_CLASIFICACION	)	
		
		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[IN]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_LOTE, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', 'UP', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TAG_NO_ACTUAL			INT,
	@PP_MOVEMENT				VARCHAR(10),
	@PP_UP_TAGNO				INT

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	UPDATE RP_SC 
	SET		MOVEMENT	=	@PP_MOVEMENT,
			TAGNO		=	( CASE	WHEN @PP_UP_TAGNO = 1 THEN @PP_TAG_NO_ACTUAL 
														  ELSE TAGNO	END		)
	-- ===========================
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_MOVEMENT_X_FOLIO', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_TAGNO_Y_MOVEMENT_X_FOLIO_PIEL_LOTE_SQF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_Y_MOVEMENT_X_FOLIO_PIEL_LOTE_SQF]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_Y_MOVEMENT_X_FOLIO_PIEL_LOTE_SQF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_TAGNO_DESTINO			INT,
	@PP_HIDE					VARCHAR(15),
	@PP_LOT 					VARCHAR(15),
	@PP_SQF						VARCHAR(15),
	@PP_MOVIMIENTO				VARCHAR(20)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	UPDATE RP_SC 
	SET 
			TAGNO		= @PP_TAGNO_DESTINO,
			MOVEMENT	= @PP_MOVIMIENTO
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAGNO_ORIGEN
	AND		LTRIM(RTRIM(HIDE))=@PP_HIDE 
	AND		LTRIM(RTRIM(LOT))=@PP_LOT 
	AND		LTRIM(RTRIM(SQF))=@PP_SQF

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_TAGNO_Y_MOVEMENT_X_FOLIO_PIEL_LOTE_SQF', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END

	-- /////////////////////////////////////////////////////////////////////
	
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
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
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TIPO_ACTUAL				VARCHAR(10),
	@PP_TIPO_NUEVO				VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	UPDATE	RP_SC 
		SET	TYPE	= @PP_TIPO_NUEVO
		-- ===========================
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO 
	AND		LTRIM(RTRIM(TYPE))=@PP_TIPO_ACTUAL
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TIPO					VARCHAR(10),
	@PP_PIEL					VARCHAR(10),
	@PP_LOTE					VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	UPDATE	RP_SC 
		SET	TYPE	= @PP_TIPO
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO
	AND		LTRIM(RTRIM(HIDE))=@PP_PIEL
	AND		LTRIM(RTRIM(LOT))=@PP_LOTE 
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TOTAL_SQF				DECIMAL(13,2),
	@PP_TAG_NO					INT,
	@PP_LOTE					VARCHAR(10),
	@PP_PIEL					VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	UPDATE	RP_SC 
		SET	SQF	= CONVERT(VARCHAR(5), @PP_TOTAL_SQF) 
		-- ===========================
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO 
	AND		LTRIM(RTRIM(LOT))=@PP_LOTE
	AND		LTRIM(RTRIM(LOT))=@PP_PIEL
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- EXECUTE [dbo].[PG_SK_RP_SC_TRANSFERIR_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_TAGNO_DESTINO			INT,
	@PP_HIDE					VARCHAR(15),
	@PP_LOT 					VARCHAR(15),
	@PP_SQF						VARCHAR(15)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////

	UPDATE RP_SC 
	SET 
			TAGNO	=	@PP_TAGNO_DESTINO 
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAGNO_ORIGEN
	AND		LTRIM(RTRIM(HIDE))=@PP_HIDE 
	AND		LTRIM(RTRIM(LOT))=@PP_LOT 
	AND		LTRIM(RTRIM(SQF))=@PP_SQF

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
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
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]
GO


CREATE PROCEDURE [dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TIPO					VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	DELETE	RP_SC 
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO 
	AND		LTRIM(RTRIM(TYPE))=@PP_TIPO
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_DL_RP_SC_X_FOLIO_Y_TIPO', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // DELETE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_RP_SC_X_FOLIO_LOTE_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_RP_SC_X_FOLIO_LOTE_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_DL_RP_SC_X_FOLIO_LOTE_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_LOTE					VARCHAR(10),
	@PP_PIEL					VARCHAR(10)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	
	DELETE	RP_SC 
	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAG_NO 
	AND		LTRIM(RTRIM(LOT))=@PP_LOTE
	AND		LTRIM(RTRIM(HIDE))=@PP_PIEL
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_DL_RP_SC_X_FOLIO_LOTE_PIEL', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // DELETE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	
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
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
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
