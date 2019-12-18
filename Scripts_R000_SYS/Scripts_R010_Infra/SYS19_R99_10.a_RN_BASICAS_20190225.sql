-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / REGLAS DE NEGOCIO
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0]  
GO

-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_REGISTRO_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_REGISTRO_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_REGISTRO_EXISTE]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_K_REGISTRO					VARCHAR(100),
	@PP_S_DATO						VARCHAR(100),
	-- ===========================		
	@PP_RESULTADO_ACTUAL			VARCHAR(300), 
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 

	IF @PP_RESULTADO_ACTUAL<>''
		SET @VP_RESULTADO = @PP_RESULTADO_ACTUAL 
	
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF ( @PP_K_REGISTRO IS NULL )
			SET @VP_RESULTADO =  'El registro ['+@PP_S_DATO+'] no existe.' 
			
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_REGISTRO_BORRADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_REGISTRO_BORRADO]
GO


CREATE PROCEDURE [dbo].[PG_RN_REGISTRO_BORRADO]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_L_BORRADO					INT,
	@PP_S_DATO						VARCHAR(100),
	-- ===========================		
	@PP_RESULTADO_ACTUAL			VARCHAR(300), 
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 
	
	IF @PP_RESULTADO_ACTUAL<>''
		SET @VP_RESULTADO = @PP_RESULTADO_ACTUAL 

	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF @PP_L_BORRADO=1
			SET @VP_RESULTADO =  'El registro ['+@PP_S_DATO+'] fue dado de baja.' 
			
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_REGISTRO_ESTATUS_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_SQL]
GO


CREATE PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_SQL]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_TA_DATO						VARCHAR(100),
	@PP_TA_ESTATUS					VARCHAR(100),
	@PP_K_DATO						INT,
	-- ===========================		
	@OU_K_ESTATUS_SQL				VARCHAR(100)	OUTPUT,
	@OU_D_ESTATUS_SQL				VARCHAR(100)	OUTPUT
AS
	-- /////////////////////////////////////////////////////

	DECLARE @VP_SQL		NVARCHAR(MAX)

	SET		@VP_SQL =	'SELECT ' 
	SET		@VP_SQL =	@VP_SQL + '@OU_K_ESTATUS_SQL = '+@PP_TA_ESTATUS+'.K_'+@PP_TA_ESTATUS+', '
	SET		@VP_SQL =	@VP_SQL + '@OU_D_ESTATUS_SQL = '+@PP_TA_ESTATUS+'.D_'+@PP_TA_ESTATUS+' '
	SET		@VP_SQL =	@VP_SQL + ' '
	SET		@VP_SQL =	@VP_SQL + 'FROM '  + @PP_TA_DATO + ', ' + @PP_TA_ESTATUS+' '
	SET		@VP_SQL =	@VP_SQL + 'WHERE ' + @PP_TA_DATO+'.K_'+@PP_TA_ESTATUS+'='+@PP_TA_ESTATUS+'.K_'+@PP_TA_ESTATUS	+' '									
	SET		@VP_SQL =	@VP_SQL + 'AND	'+'K_'+@PP_TA_DATO+'='+CONVERT(VARCHAR(50),@PP_K_DATO)+' '

	-- ===============================

	DECLARE @VP_DEFINICION_PARAMETROS		NVARCHAR(500)
	
	SET		@VP_DEFINICION_PARAMETROS =		N'@OU_K_ESTATUS_SQL VARCHAR(100) OUTPUT, @OU_D_ESTATUS_SQL VARCHAR(100) OUTPUT'

	-- ===============================

	IF @PP_L_DEBUG>0
		PRINT @VP_SQL

	-- =====================================
	DECLARE @VP_K_ESTATUS_SQL	VARCHAR(100)
	DECLARE @VP_D_ESTATUS_SQL	VARCHAR(100)

	EXECUTE sp_executesql	@VP_SQL, @VP_DEFINICION_PARAMETROS, 
							@OU_K_ESTATUS_SQL = @VP_K_ESTATUS_SQL		OUTPUT,
							@OU_D_ESTATUS_SQL = @VP_D_ESTATUS_SQL		OUTPUT

	IF @PP_L_DEBUG>0
		BEGIN
		PRINT @VP_K_ESTATUS_SQL
		PRINT @VP_D_ESTATUS_SQL
		END

	-- ===============================
	
	SET @OU_K_ESTATUS_SQL = @VP_K_ESTATUS_SQL
	SET @OU_D_ESTATUS_SQL = @VP_D_ESTATUS_SQL

	-- /////////////////////////////////////////////////////
GO


/*
	
	EXECUTE [dbo].[PG_RN_REGISTRO_ESTATUS_VALIDOS]	1,0,0,
													'MATRIZ_ALMACEN', 'ESTATUS_MATRIZ_ALMACEN',
													5,
													'.1.2.3.4.5.', ''

	EXECUTE [dbo].[PG_RN_REGISTRO_ESTATUS_NO_VALIDOS]	1,0,0,
														'MATRIZ_ALMACEN', 'ESTATUS_MATRIZ_ALMACEN',
														5,
														'.0.', ''


	EXECUTE [dbo].[PG_RN_REGISTRO_ESTATUS_VALIDOS]	1,0,0,
													'MATRIZ_ALMACEN', 'ESTATUS_MATRIZ_ALMACEN',
													6,
													'.1.2.3.4.5.', ''

*/


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_REGISTRO_ESTATUS_VALIDOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_VALIDOS]
GO


CREATE PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_VALIDOS]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_TA_DATO						VARCHAR(100),
	@PP_TA_ESTATUS					VARCHAR(100),
	@PP_K_DATO						INT,
	@PP_K_ESTATUS_VALIDOS			VARCHAR(100),
	-- ===========================		
	@PP_RESULTADO_ACTUAL			VARCHAR(300),
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT 
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 
	
	IF @PP_RESULTADO_ACTUAL<>''
		SET @VP_RESULTADO = @PP_RESULTADO_ACTUAL 

	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_ESTATUS_SQL	VARCHAR(100)
	DECLARE @VP_D_ESTATUS_SQL	VARCHAR(100)

	IF @VP_RESULTADO=''
		BEGIN

		EXECUTE	[dbo].[PG_RN_REGISTRO_ESTATUS_SQL]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_TA_DATO, @PP_TA_ESTATUS,
														@PP_K_DATO,
														@OU_K_ESTATUS_SQL = @VP_K_ESTATUS_SQL			OUTPUT,
														@OU_D_ESTATUS_SQL = @VP_D_ESTATUS_SQL			OUTPUT
		-- ===============================
		END			

	-- /////////////////////////////////////////////////////

	EXECUTE	[dbo].[PG_RN_REGISTRO_EXISTE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@VP_K_ESTATUS_SQL, @PP_TA_DATO,
											@VP_RESULTADO, 
											@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		BEGIN
		SET @VP_K_ESTATUS_SQL = '.'+@VP_K_ESTATUS_SQL+'.'

		IF @PP_L_DEBUG>0
			BEGIN
			PRINT	@VP_K_ESTATUS_SQL
			PRINT	@PP_K_ESTATUS_VALIDOS
			END

		IF NOT ( @PP_K_ESTATUS_VALIDOS LIKE '%'+@VP_K_ESTATUS_SQL+'%' )
			SET @VP_RESULTADO =  'El [Estatus#'+CONVERT(VARCHAR(10),@VP_K_ESTATUS_SQL)+'-'+@VP_D_ESTATUS_SQL+'] no lo permite.'

		END

	-- /////////////////////////////////////////////////////
	
	IF @PP_L_DEBUG>0
		PRINT @VP_RESULTADO

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_REGISTRO_ESTATUS_NO_VALIDOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_NO_VALIDOS]
GO


CREATE PROCEDURE [dbo].[PG_RN_REGISTRO_ESTATUS_NO_VALIDOS]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_TA_DATO						VARCHAR(100),
	@PP_TA_ESTATUS					VARCHAR(100),
	@PP_K_DATO						INT,
	@PP_K_ESTATUS_NO_VALIDOS		VARCHAR(100),
	-- ===========================		
	@PP_RESULTADO_ACTUAL			VARCHAR(300),
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT 
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 
	
	IF @PP_RESULTADO_ACTUAL<>''
		SET @VP_RESULTADO = @PP_RESULTADO_ACTUAL 

	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_ESTATUS_SQL	VARCHAR(100)
	DECLARE @VP_D_ESTATUS_SQL	VARCHAR(100)

	IF @VP_RESULTADO=''
		BEGIN

		EXECUTE	[dbo].[PG_RN_REGISTRO_ESTATUS_SQL]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_TA_DATO, @PP_TA_ESTATUS,
														@PP_K_DATO,
														@OU_K_ESTATUS_SQL = @VP_K_ESTATUS_SQL			OUTPUT,
														@OU_D_ESTATUS_SQL = @VP_D_ESTATUS_SQL			OUTPUT
		-- ===============================
		END			

	-- /////////////////////////////////////////////////////

	EXECUTE	[dbo].[PG_RN_REGISTRO_EXISTE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@VP_K_ESTATUS_SQL, @PP_TA_DATO,
											@VP_RESULTADO, 
											@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		BEGIN
		SET @VP_K_ESTATUS_SQL = '.'+@VP_K_ESTATUS_SQL+'.'

		IF @PP_L_DEBUG>0
			BEGIN
			PRINT	@VP_K_ESTATUS_SQL
			PRINT	@PP_K_ESTATUS_NO_VALIDOS
			END

		IF ( @PP_K_ESTATUS_NO_VALIDOS LIKE '%'+@VP_K_ESTATUS_SQL+'%' )
			SET @VP_RESULTADO =  'El [Estatus#'+CONVERT(VARCHAR(10),@VP_K_ESTATUS_SQL)+'-'+@VP_D_ESTATUS_SQL+'] no lo permite.'

		END

	-- /////////////////////////////////////////////////////
	
	IF @PP_L_DEBUG>0
		PRINT @VP_RESULTADO

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- ////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////


