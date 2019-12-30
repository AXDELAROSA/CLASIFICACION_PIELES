-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	TRA19
-- // MODULO:			CENTRO_EMBARQUE
-- // OPERACION:		LIBERACION / REGLAS NEGOCIO
-- //////////////////////////////////////////////////////////////
-- // Autor:			AX DE LA ROSA
-- // Fecha creación:	17/ENE/2019
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_EXISTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE		INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_CENTRO_EMBARQUE		INT
	DECLARE @VP_L_BORRADO				INT
			
	SELECT	@VP_K_CENTRO_EMBARQUE	=	K_CENTRO_EMBARQUE,
			@VP_L_BORRADO		=	CENTRO_EMBARQUE.L_BORRADO
									FROM	CENTRO_EMBARQUE
									WHERE	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_K_CENTRO_EMBARQUE IS NULL )
			SET @VP_RESULTADO =  'El registro para el [Centro Embarque] no existe.' 

	-- ===========================

	IF @VP_RESULTADO=''
		IF @VP_L_BORRADO=1
			SET @VP_RESULTADO =  'El [Centro Embarque] fue dado de baja.' 
		
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_CLAVE_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_CLAVE_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_CLAVE_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_CLAVE_EXISTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE		INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO='' 
		BEGIN

		DECLARE @VP_EXISTE_CLAVE	INT

		SELECT	@VP_EXISTE_CLAVE =	COUNT(K_CENTRO_EMBARQUE)
									FROM	CENTRO_EMBARQUE 
									WHERE	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE
										
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_DESCRIPCION_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_DESCRIPCION_EXISTE]
GO

CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_DESCRIPCION_EXISTE]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE		INT,	
	@PP_D_CENTRO_EMBARQUE		VARCHAR (100),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR (300)		OUTPUT
AS	
	--DECLARE @VP_RESULTADO		VARCHAR(300)= ''
		
	---- ///////////////////////////////////////////

	--IF @VP_RESULTADO='' 
	--	BEGIN
	--		DECLARE @VP_EXISTE_DESC		INT
	--		SELECT @VP_EXISTE_DESC =	COUNT(D_CENTRO_EMBARQUE )
	--									FROM CENTRO_EMBARQUE  
	--									WHERE D_CENTRO_EMBARQUE =	@PP_D_CENTRO_EMBARQUE
	--									AND K_CENTRO_EMBARQUE <>@PP_K_CENTRO_EMBARQUE
	--		IF @VP_EXISTE_DESC > 0
	--			SET	@VP_RESULTADO = @VP_RESULTADO +CHAR(13)+CHAR(10) + 'La descripción ya existe'
	--	END	
		
	---- ///////////////////////////////////////////
	
	--IF	@VP_RESULTADO<>''
	--	SET	@VP_RESULTADO = @VP_RESULTADO + ' //DESC//'
	
	---- ///////////////////////////////////////////
		
	--SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

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


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_INSERT]
GO


CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_INSERT]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE		INT,
	@PP_D_CENTRO_EMBARQUE		VARCHAR(100),
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
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_DESCRIPCION_EXISTE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_CENTRO_EMBARQUE, @PP_D_CENTRO_EMBARQUE,
																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- //////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //INS//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION UPDATE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_UPDATE]
GO

CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_UPDATE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE				INT,
	@PP_D_CENTRO_EMBARQUE				VARCHAR(100),	
	-- ===========================		
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_UPDATE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
														11, -- @PP_K_DATA_SISTEMA,	
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
		
	-- ///////////////////////////////////////////
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_EXISTE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_CENTRO_EMBARQUE,	 
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_DESCRIPCION_EXISTE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_CENTRO_EMBARQUE, @PP_D_CENTRO_EMBARQUE,
																	@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- //////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //UPD//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION DELETE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CENTRO_EMBARQUE_DELETE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_DELETE]
GO


CREATE PROCEDURE [dbo].[PG_RN_CENTRO_EMBARQUE_DELETE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_K_CENTRO_EMBARQUE			INT,
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
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_EXISTE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_CENTRO_EMBARQUE, 
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////




	-- ///////////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DEL//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
