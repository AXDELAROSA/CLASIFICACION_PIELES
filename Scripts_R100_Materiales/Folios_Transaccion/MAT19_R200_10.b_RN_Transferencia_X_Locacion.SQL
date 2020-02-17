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

-- //////////////////////////////////////////////////////////////




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
