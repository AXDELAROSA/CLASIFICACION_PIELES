-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANFERIR FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								
-- //////////////////////////////////////////////////////////////
-- EXEC [PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO] 0, 0, 3788882
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT,
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	-- ///////////////////////////////////////////

	DECLARE @VP_N_PIEL_SIN_CLASIFICAR		INT = 0

	SELECT TOP 1 @VP_N_PIEL_SIN_CLASIFICAR = COUNT(ID)
	FROM	RP_SC 
	WHERE	TAGNO = @PP_FOLIO
	AND		K_CLASIFICACION = 0

	IF @VP_N_PIEL_SIN_CLASIFICAR > 0
		SET @VP_RESULTADO = 'No se han clasificado todas las pieles del [FOLIO]: ' + CONVERT(VARCHAR(10), @PP_FOLIO)
		

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO
      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								
-- //////////////////////////////////////////////////////////////
-- EXEC [PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO] 0, 0, 3788882
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(20),
	@PP_FOLIO					INT,
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	-- ///////////////////////////////////////////

	DECLARE	@VP_N_PIEL_BUENA_X_FOLIO		INT = 0
	DECLARE	@VP_N_PIEL_REGULAR_X_FOLIO		INT = 0
	DECLARE	@VP_N_PIEL_MALA_X_FOLIO			INT = 0
	DECLARE @VP_PIEL_PORCENTAJE_BUENO		DECIMAL(19,4)
	DECLARE @VP_PIEL_PORCENTAJE_REGULAR		DECIMAL(19,4)
	DECLARE @VP_PIEL_PORCENTAJE_MALO		DECIMAL(19,4)
	DECLARE	@VP_N_PIEL_X_FOLIO				INT = 0
	-- ///////////////////////////////////////////

	SELECT	@VP_N_PIEL_X_FOLIO = COUNT(ID)
	FROM	RP_SC
	WHERE	RTRIM(LTRIM(COLOUR)) = @PP_COLOR
	AND		RTRIM(LTRIM(TAGNO)) = @PP_FOLIO

	IF @VP_N_PIEL_X_FOLIO IS NULL 
		SET @VP_N_PIEL_X_FOLIO = 0
	-- ///////////////////////////////////////////

	/*
	K_PIEL_CLASIFICADA
	#1 BUENA | #2 REGULAR | #3 MALA
	*/

	SELECT	@VP_N_PIEL_BUENA_X_FOLIO = COUNT(ID)
	FROM	RP_SC
	WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
	AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
	AND		K_CLASIFICACION=1 -- BUENA
			
	IF @VP_N_PIEL_BUENA_X_FOLIO IS NULL 
		SET @VP_N_PIEL_BUENA_X_FOLIO = 0
	-- ==================================

	SET @VP_PIEL_PORCENTAJE_BUENO =	ROUND(CAST(@VP_N_PIEL_BUENA_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100

	IF @VP_RESULTADO = ''
		BEGIN
			IF ( NOT @VP_PIEL_PORCENTAJE_BUENO BETWEEN 30 AND 35 )
				SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [BUENA] debe de estar entre el [30% y 35%]'
				
		END
	-- ///////////////////////////////////////////

	SELECT	@VP_N_PIEL_REGULAR_X_FOLIO = COUNT(ID)
	FROM	RP_SC
	WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
	AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
	AND		K_CLASIFICACION=2 -- REGULAR
	
	IF @VP_N_PIEL_REGULAR_X_FOLIO IS NULL 
		SET @VP_N_PIEL_REGULAR_X_FOLIO = 0
	-- ==================================

	SET @VP_PIEL_PORCENTAJE_REGULAR = ROUND(CAST(@VP_N_PIEL_REGULAR_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100

	IF @VP_RESULTADO = ''
		BEGIN
			IF ( NOT @VP_PIEL_PORCENTAJE_REGULAR BETWEEN 30 AND 35 )
				SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [REGULAR] debe de estar entre el [30% y 35%]'
				
		END
	-- ///////////////////////////////////////////

	SELECT	@VP_N_PIEL_MALA_X_FOLIO = COUNT(ID)
	FROM	RP_SC
	WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
	AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
	AND		K_CLASIFICACION=3 -- MALA
	
	IF @VP_N_PIEL_MALA_X_FOLIO IS NULL 
		SET @VP_N_PIEL_MALA_X_FOLIO = 0
	-- ==================================

	SET @VP_PIEL_PORCENTAJE_MALO = ROUND(CAST(@VP_N_PIEL_MALA_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100

	IF @VP_RESULTADO = ''
		BEGIN
			IF ( NOT @VP_PIEL_PORCENTAJE_MALO BETWEEN 30 AND 35 )
				SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [MALA] debe de estar entre el [30% y 35%]'
				
		END
	-- ///////////////////////////////////////////

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO
      
	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOCACION				VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_ITEM_NO		VARCHAR(20)
			
	SELECT	@VP_ITEM_NO	=	ITEM_NO
							FROM	IMLSMST_SQL
							WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION
							AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
							AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE
	-- ===========================


	IF @VP_RESULTADO=''
		IF ( @VP_ITEM_NO IS NULL )
			SET @VP_RESULTADO =  'El registro no existe.' 

	-- ===========================

	--IF @VP_RESULTADO=''
	--	IF @VP_L_BORRADO=1
	--		SET @VP_RESULTADO =  'la [PIEL CLASIFICADA] fue dado de baja.' 
		
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]
GO


CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOCACION				VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_CANTIDAD_PIEL_DISPONIBLE	DECIMAL(13,4)
			
	SELECT	@VP_CANTIDAD_PIEL_DISPONIBLE	=	qty_on_hand
											FROM	IMLSMST_SQL
											WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION
											AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
											AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE
	-- ===========================
	IF @VP_CANTIDAD_PIEL_DISPONIBLE IS NULL
		SET @VP_CANTIDAD_PIEL_DISPONIBLE = 0

	IF @VP_RESULTADO=''
		IF ( @PP_SQF > @VP_CANTIDAD_PIEL_DISPONIBLE )
			SET @VP_RESULTADO =  'Cantidad Insuficiente en inventario.' 

	-- ===========================

	--IF @VP_RESULTADO=''
	--	IF @VP_L_BORRADO=1
	--		SET @VP_RESULTADO =  'la [PIEL CLASIFICADA] fue dado de baja.' 
		
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION UPDATE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]
GO

CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_LOCACION					VARCHAR(10),			
	@PP_COLOR						VARCHAR(20),
	@PP_LOTE						VARCHAR(20),
	@PP_SQF							DECIMAL(13,4),
	-- ===========================		
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_UPDATE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--													11, -- @PP_K_DATA_SISTEMA,	
	--													@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
		
	-- ///////////////////////////////////////////
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION, @PP_COLOR, @PP_LOTE, 
																			@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
																			@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //UPD//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
