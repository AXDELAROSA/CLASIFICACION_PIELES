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




/*
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_CLAVE_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PIEL_CLASIFICADA_CLAVE_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_CLAVE_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_CLAVE_EXISTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_PIEL_CLASIFICADA		INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO='' 
		BEGIN

		DECLARE @VP_EXISTE_CLAVE	INT

		SELECT	@VP_EXISTE_CLAVE =	COUNT(K_PIEL_CLASIFICADA)
									FROM	PIEL_CLASIFICADA 
									WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA
										
		IF @VP_EXISTE_CLAVE>0
			SET @VP_RESULTADO =  'El folio/identificador no está disponible.' 

		END	
		
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_DESCRIPCION_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PIEL_CLASIFICADA_DESCRIPCION_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_DESCRIPCION_EXISTE]
GO

CREATE PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_DESCRIPCION_EXISTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================			
	@PP_D_PIEL_CLASIFICADA		VARCHAR (100),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR (300)		OUTPUT
AS	
	DECLARE @VP_RESULTADO		VARCHAR(300)= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO='' 
		BEGIN
			DECLARE @VP_EXISTE_DESC		INT
			SELECT @VP_EXISTE_DESC =	COUNT(D_PIEL_CLASIFICADA )
										FROM PIEL_CLASIFICADA  
										WHERE D_PIEL_CLASIFICADA =	@PP_D_PIEL_CLASIFICADA
			IF @VP_EXISTE_DESC > 0
				SET	@VP_RESULTADO = @VP_RESULTADO +CHAR(13)+CHAR(10) + 'El Numeero de Piel ya existe'
		END	
		
	-- ///////////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DESC//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_DESCRIPCION_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PIEL_CLASIFICADA_VALIDA_CANTIDAD_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_VALIDA_CANTIDAD_PIEL]
GO

CREATE PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_VALIDA_CANTIDAD_PIEL]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================			
	@PP_K_PIEL_LOTE				INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR (300)		OUTPUT
AS	
	DECLARE @VP_RESULTADO		VARCHAR(300)= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO='' 
		BEGIN
			DECLARE	@VP_PIEL_LOTE_CANTIDAD		INT = 0
			DECLARE	@VP_D_PIEL_LOTE_CANTIDAD	VARCHAR(100)
			SELECT	@VP_D_PIEL_LOTE_CANTIDAD	= D_PIEL_LOTE,
					@VP_PIEL_LOTE_CANTIDAD		= PIEL_LOTE_CANTIDAD
												FROM PIEL_LOTE  
												WHERE K_PIEL_LOTE=@PP_K_PIEL_LOTE

			IF @VP_PIEL_LOTE_CANTIDAD IS NULL
				SET @VP_PIEL_LOTE_CANTIDAD = 0

			DECLARE	@VP_PIEL_CLASIFICADA_CANTIDAD		INT
			SELECT	@VP_PIEL_CLASIFICADA_CANTIDAD =	COUNT(K_PIEL_CLASIFICADA )
										FROM PIEL_CLASIFICADA  
										WHERE K_PIEL_LOTE =	@PP_K_PIEL_LOTE

			IF @VP_PIEL_CLASIFICADA_CANTIDAD IS NULL
				SET @VP_PIEL_CLASIFICADA_CANTIDAD = 0

			IF @VP_PIEL_LOTE_CANTIDAD = @VP_PIEL_CLASIFICADA_CANTIDAD
				SET	@VP_RESULTADO = @VP_RESULTADO +CHAR(13)+CHAR(10) + 'Ya se han clasificado todas las Pieles para este ' + '[#LOTE:' + @VP_D_PIEL_LOTE_CANTIDAD + ']'
		END	
		
	-- ///////////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DESC//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- ===========================================================================================
-- ===========================================================================================
-- == REGLAS DE NEGOCIO BASICAS (INSERT / UPDATE / DELETE)
-- ===========================================================================================
-- ===========================================================================================


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]
GO


CREATE PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_PIEL_LOTE				INT,
	@PP_D_PIEL_CLASIFICADA		VARCHAR(100),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_INSERT]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
														1, -- @PP_K_DATA_SISTEMA,	
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- //////////////////////////////////////
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_VALIDA_CANTIDAD_PIEL]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_K_PIEL_LOTE,
																		@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_DESCRIPCION_EXISTE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_D_PIEL_CLASIFICADA,
																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- //////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //INS//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO

*/


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


/*
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION DELETE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PIEL_CLASIFICADA_DELETE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_DELETE]
GO


CREATE PROCEDURE [dbo].[PG_RN_PIEL_CLASIFICADA_DELETE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_K_PIEL_CLASIFICADA			INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_DELETE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
														1, -- @PP_K_DATA_SISTEMA,	
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_EXISTE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_PIEL_CLASIFICADA, 
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////




	-- ///////////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DEL//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO

*/




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
