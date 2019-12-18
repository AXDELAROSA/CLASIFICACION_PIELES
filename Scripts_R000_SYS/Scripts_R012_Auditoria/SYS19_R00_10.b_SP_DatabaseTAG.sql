-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / 
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- //
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_BD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_BD]
GO



CREATE PROCEDURE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_BD]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================			
	@PP_K_SISTEMA			INT,
	@PP_VERSION_BD			VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300)
	
	SET		@VP_MENSAJE		= ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	

	DECLARE @VP_D_SISTEMA		VARCHAR(100)

	SELECT	@VP_D_SISTEMA =		D_SISTEMA
								FROM	SISTEMA
								WHERE	K_SISTEMA=@PP_K_SISTEMA
	-- ======================

	IF @VP_MENSAJE=''	
		IF @VP_D_SISTEMA  IS NULL
			SET	@VP_MENSAJE = 'El Sistema no se encuentra registrado.'

	-- ======================
	
	SET		@PP_VERSION_BD =  'BD.'+@PP_VERSION_BD

	DECLARE @VP_L_DATABASE_TAG		INT

	SELECT	@VP_L_DATABASE_TAG =	L_DATABASE_TAG
									FROM	DATABASE_TAG
									WHERE	K_SISTEMA=@PP_K_SISTEMA
									AND		S_DATABASE_TAG=@PP_VERSION_BD
	-- ======================
									
	IF @VP_MENSAJE=''	
		IF @VP_L_DATABASE_TAG  IS NULL
			SET	@VP_MENSAJE = 'La versión [#VER/'+CONVERT(VARCHAR(10),@PP_VERSION_BD)+'] no se encuentra registrada.'

	IF @VP_MENSAJE=''	
		IF @VP_L_DATABASE_TAG=0
			SET	@VP_MENSAJE = 'La versión [#VER/'+CONVERT(VARCHAR(10),@PP_VERSION_BD)+'] no es compatible con la base de datos.'
	
	-- ======================
		
	SET @OU_RESULTADO_VALIDACION = @VP_MENSAJE 

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_EXE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_EXE]
GO



CREATE PROCEDURE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_EXE]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================			
	@PP_K_SISTEMA			INT,
	@PP_VERSION_EXE			VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION			[VARCHAR] (200)		OUTPUT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300)
	
	SET		@VP_MENSAJE		= ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	

	DECLARE @VP_D_SISTEMA		VARCHAR(100)

	SELECT	@VP_D_SISTEMA =		D_SISTEMA
								FROM	SISTEMA
								WHERE	K_SISTEMA=@PP_K_SISTEMA
	-- ======================

	IF @VP_MENSAJE=''	
		IF @VP_D_SISTEMA  IS NULL
			SET	@VP_MENSAJE = 'El Sistema no se encuentra registrado.'

	-- ======================
	
	SET		@PP_VERSION_EXE =  'EXE.'+@PP_VERSION_EXE

	DECLARE @VP_L_DATABASE_TAG		INT

	SELECT	@VP_L_DATABASE_TAG =	L_DATABASE_TAG
									FROM	DATABASE_TAG
									WHERE	K_SISTEMA=@PP_K_SISTEMA
									AND		S_DATABASE_TAG=@PP_VERSION_EXE
	-- ======================
									
	IF @VP_MENSAJE=''	
		IF @VP_L_DATABASE_TAG  IS NULL
			SET	@VP_MENSAJE = 'La versión [#VER/'+CONVERT(VARCHAR(10),@PP_VERSION_EXE)+'] no se encuentra registrada.'

	IF @VP_MENSAJE=''	
		IF @VP_L_DATABASE_TAG=0
			SET	@VP_MENSAJE = 'La versión [#VER/'+CONVERT(VARCHAR(10),@PP_VERSION_EXE)+'] no es compatible con la base de datos.'
	
	-- ======================
		
	SET @OU_RESULTADO_VALIDACION = @VP_MENSAJE 

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- //
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SP_DATABASE_TAG_COMPATIBILIDAD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SP_DATABASE_TAG_COMPATIBILIDAD]
GO



CREATE PROCEDURE [dbo].[PG_SP_DATABASE_TAG_COMPATIBILIDAD]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT,
	-- ===========================			
	@PP_K_SISTEMA			INT,
	@PP_VERSION_EXE			VARCHAR(20),
	@PP_VERSION_BD			VARCHAR(20)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300)
	
	SET		@VP_MENSAJE		= ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_EXE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_K_SISTEMA, @PP_VERSION_EXE,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT		

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATABASE_TAG_COMPATIBILIDAD_BD]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_K_SISTEMA, @PP_VERSION_BD,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT		

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Operar] la [BD/EXE]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SYS.'+CONVERT(VARCHAR(10),@PP_K_SISTEMA)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_SISTEMA AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



/*


SELECT * FROM DATABASE_TAG


EXECUTE [PG_SP_DATABASE_TAG_COMPATIBILIDAD] 0,0,0,	9999,  'V0123', 'V0000'

EXECUTE [PG_SP_DATABASE_TAG_COMPATIBILIDAD] 0,0,0,	2006,  'V0123', 'V0000'

EXECUTE [PG_SP_DATABASE_TAG_COMPATIBILIDAD] 0,0,0,	2006,  'V0000', 'V0000'

EXECUTE [PG_SP_DATABASE_TAG_COMPATIBILIDAD] 0,0,0,	2006,  'V0100', 'V0106B'

BD.V0106B

EXE.V0000	1
BD.V0106B	1
EXE.V0100	1


*/




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
