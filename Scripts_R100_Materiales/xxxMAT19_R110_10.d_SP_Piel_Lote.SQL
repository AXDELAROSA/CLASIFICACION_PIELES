-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	TRA19
-- // MODULO:			CENTRO_EMBARQUE
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			AX DE LA ROSA
-- // Fecha creación:	17/ENE/2019
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////


--EXECUTE [dbo].[PG_LI_CENTRO_EMBARQUE] 0,0,0,'',-1,-1,-1,-1

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_CENTRO_EMBARQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_CENTRO_EMBARQUE]
GO


CREATE PROCEDURE [dbo].[PG_LI_CENTRO_EMBARQUE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ==============================================
	@PP_BUSCAR							VARCHAR(200),
	-- ==============================================
	@PP_K_ESTATUS_CENTRO_EMBARQUE		INT,
	@PP_K_TIPO_CENTRO_EMBARQUE			INT,
	@PP_K_PUNTO							INT,
	@PP_K_TERMINAL						INT
AS

	DECLARE @VP_MENSAJE					VARCHAR(300) = ''
	DECLARE @VP_L_APLICAR_MAX_ROWS		INT = 0
	
	-- ///////////////////////////////////////////

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_SELECT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													11, -- @PP_K_DATA_SISTEMA,	
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS	INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_LISTADO_MAX_ROWS_PESADO_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
																		@VP_L_APLICAR_MAX_ROWS,		
																		@OU_MAXROWS = @VP_LI_N_REGISTROS		OUTPUT	
	-- =========================================		

	DECLARE @VP_K_FOLIO		INT

	EXECUTE [dbo].[PG_RN_OBTENER_ID_X_REFERENCIA]		@PP_BUSCAR, 
														@OU_K_ELEMENTO = @VP_K_FOLIO	OUTPUT
	-- =========================================
	
	DECLARE @VP_L_VER_BORRADOS		INT		
	
	EXECUTE [dbo].[PG_RN_DATA_VER_BORRADOS]			@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@OU_L_VER_BORRADOS = @VP_L_VER_BORRADOS			OUTPUT
	-- =========================================

	IF @VP_MENSAJE<>''
		SET @VP_LI_N_REGISTROS = 0

	-- =========================================
		
	SELECT	TOP (@VP_LI_N_REGISTROS)
				CENTRO_EMBARQUE.*,
				USUARIO.D_USUARIO AS D_USUARIO_CAMBIO,		
			-- =====================
				TERMINAL.D_CENTRO_EMBARQUE AS D_TERMINAL,TERMINAL.S_CENTRO_EMBARQUE AS S_TERMINAL,
			-- =====================
				D_ESTATUS_CENTRO_EMBARQUE, D_TIPO_CENTRO_EMBARQUE, D_PUNTO, D_FILTRO_SI_NO AS D_ES_TERMINAL,
				S_ESTATUS_CENTRO_EMBARQUE, S_TIPO_CENTRO_EMBARQUE, S_PUNTO, S_FILTRO_SI_NO AS S_ES_TERMINAL
			-- =====================
	FROM		CENTRO_EMBARQUE, USUARIO,
				CENTRO_EMBARQUE AS TERMINAL,
				ESTATUS_CENTRO_EMBARQUE,
				TIPO_CENTRO_EMBARQUE,
				PUNTO, FILTRO_SI_NO
			-- =====================
	WHERE		CENTRO_EMBARQUE.K_USUARIO_CAMBIO=USUARIO.K_USUARIO
			-- =====================
	AND			CENTRO_EMBARQUE.K_TERMINAL=TERMINAL.K_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_ESTATUS_CENTRO_EMBARQUE=ESTATUS_CENTRO_EMBARQUE.K_ESTATUS_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_TIPO_CENTRO_EMBARQUE=TIPO_CENTRO_EMBARQUE.K_TIPO_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_PUNTO=PUNTO.K_PUNTO
	AND			CENTRO_EMBARQUE.L_TERMINAL=FILTRO_SI_NO.K_FILTRO_SI_NO
			-- =====================
	AND		(		CENTRO_EMBARQUE.D_CENTRO_EMBARQUE				LIKE '%'+@PP_BUSCAR+'%' 
				OR	CENTRO_EMBARQUE.C_CENTRO_EMBARQUE				LIKE '%'+@PP_BUSCAR+'%' 
				OR	TERMINAL.D_CENTRO_EMBARQUE						LIKE '%'+@PP_BUSCAR+'%'
				OR	CENTRO_EMBARQUE.K_CENTRO_EMBARQUE=@VP_K_FOLIO 
			)	
			-- =====================
	AND		( @PP_K_TERMINAL=-1						OR	CENTRO_EMBARQUE.K_TERMINAL=@PP_K_TERMINAL )
	AND		( @PP_K_ESTATUS_CENTRO_EMBARQUE=-1		OR	CENTRO_EMBARQUE.K_ESTATUS_CENTRO_EMBARQUE=@PP_K_ESTATUS_CENTRO_EMBARQUE )
	AND		( @PP_K_TIPO_CENTRO_EMBARQUE=-1			OR	CENTRO_EMBARQUE.K_TIPO_CENTRO_EMBARQUE=@PP_K_TIPO_CENTRO_EMBARQUE )
	AND		( @PP_K_PUNTO=-1						OR	CENTRO_EMBARQUE.K_PUNTO=@PP_K_PUNTO )
			-- =====================
	AND		( CENTRO_EMBARQUE.L_BORRADO=0		OR	@VP_L_VER_BORRADOS=1 )	
			-- =====================		
	AND		( CENTRO_EMBARQUE.K_CENTRO_EMBARQUE>0 )
	ORDER BY S_TERMINAL, S_TIPO_CENTRO_EMBARQUE, D_CENTRO_EMBARQUE 

			
	-- /////////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_LI_CENTRO_EMBARQUE]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_BUSCAR, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- /////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_SK_CENTRO_EMBARQUE] 0,0,0, 8

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_CENTRO_EMBARQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_CENTRO_EMBARQUE]
GO


CREATE PROCEDURE [dbo].[PG_SK_CENTRO_EMBARQUE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_CENTRO_EMBARQUE				INT
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_SEEK]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													11, -- @PP_K_DATA_SISTEMA,	
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- ///////////////////////////////////////////
	
	DECLARE @VP_L_VER_BORRADOS		INT		
	
	EXECUTE [dbo].[PG_RN_DATA_VER_BORRADOS]			@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@OU_L_VER_BORRADOS = @VP_L_VER_BORRADOS			OUTPUT
	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 100

	IF @VP_MENSAJE<>''
		SET @VP_LI_N_REGISTROS = 0

	-- =========================================
		
	SELECT	TOP (@VP_LI_N_REGISTROS)
				CENTRO_EMBARQUE.*,
				USUARIO.D_USUARIO AS D_USUARIO_CAMBIO,		
			-- =====================
				TERMINAL.D_CENTRO_EMBARQUE AS D_TERMINAL,TERMINAL.S_CENTRO_EMBARQUE AS S_TERMINAL,
			-- =====================
				D_ESTATUS_CENTRO_EMBARQUE, D_TIPO_CENTRO_EMBARQUE, D_PUNTO, D_FILTRO_SI_NO AS D_ES_TERMINAL,
				S_ESTATUS_CENTRO_EMBARQUE, S_TIPO_CENTRO_EMBARQUE, S_PUNTO, S_FILTRO_SI_NO AS S_ES_TERMINAL
			-- =====================
	FROM		CENTRO_EMBARQUE, USUARIO,
				CENTRO_EMBARQUE AS TERMINAL,
				ESTATUS_CENTRO_EMBARQUE,
				TIPO_CENTRO_EMBARQUE,
				PUNTO, FILTRO_SI_NO
			-- =====================
	WHERE		CENTRO_EMBARQUE.K_USUARIO_CAMBIO=USUARIO.K_USUARIO
			-- =====================
	AND			CENTRO_EMBARQUE.K_TERMINAL=TERMINAL.K_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_ESTATUS_CENTRO_EMBARQUE=ESTATUS_CENTRO_EMBARQUE.K_ESTATUS_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_TIPO_CENTRO_EMBARQUE=TIPO_CENTRO_EMBARQUE.K_TIPO_CENTRO_EMBARQUE
	AND			CENTRO_EMBARQUE.K_PUNTO=PUNTO.K_PUNTO
	AND			CENTRO_EMBARQUE.L_TERMINAL=FILTRO_SI_NO.K_FILTRO_SI_NO
			-- =====================
	AND			CENTRO_EMBARQUE.K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE
			-- =====================
		
	-----////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SEEK',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_SK_CENTRO_EMBARQUE]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_CENTRO_EMBARQUE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_CENTRO_EMBARQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_CENTRO_EMBARQUE]
GO


CREATE PROCEDURE [dbo].[PG_IN_CENTRO_EMBARQUE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_D_CENTRO_EMBARQUE				VARCHAR(100),
	@PP_C_CENTRO_EMBARQUE				VARCHAR(255),
	@PP_S_CENTRO_EMBARQUE				VARCHAR(10),
	-- ===========================
	@PP_K_ESTATUS_CENTRO_EMBARQUE		INT,
	@PP_K_TIPO_CENTRO_EMBARQUE			INT,
	@PP_K_PUNTO							INT,
	@PP_K_TERMINAL						INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_K_CENTRO_EMBARQUE		INT = 0
	
	EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
												'CENTRO_EMBARQUE', 
												@OU_K_TABLA_DISPONIBLE = @VP_K_CENTRO_EMBARQUE			OUTPUT
	-- ==================================

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_K_CENTRO_EMBARQUE,@PP_D_CENTRO_EMBARQUE,
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	
		--DECLARE @VP_S_CENTRO_EMBARQUE VARCHAR(10) = LEFT(@PP_D_CENTRO_EMBARQUE,5)		
		INSERT INTO [CENTRO_EMBARQUE]	
			(	[K_CENTRO_EMBARQUE], [D_CENTRO_EMBARQUE],
				[S_CENTRO_EMBARQUE], [C_CENTRO_EMBARQUE], 
				[K_ESTATUS_CENTRO_EMBARQUE],
				[K_TIPO_CENTRO_EMBARQUE],
				[K_PUNTO], [K_TERMINAL],
			-- ============================================
				[K_USUARIO_ALTA], [F_ALTA], 
				[K_USUARIO_CAMBIO], [F_CAMBIO],
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )		
		VALUES	
			(	@VP_K_CENTRO_EMBARQUE, @PP_D_CENTRO_EMBARQUE,
				@PP_S_CENTRO_EMBARQUE, @PP_C_CENTRO_EMBARQUE,
				@PP_K_ESTATUS_CENTRO_EMBARQUE,
				@PP_K_TIPO_CENTRO_EMBARQUE,
				@PP_K_PUNTO, @PP_K_TERMINAL,		
			-- ============================================
				@PP_K_USUARIO_ACCION, GETDATE(), 
				@PP_K_USUARIO_ACCION, GETDATE(),
				0, NULL, NULL )				
		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [Centro Embarque]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#CEm.'+CONVERT(VARCHAR(10),@VP_K_CENTRO_EMBARQUE)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_CENTRO_EMBARQUE AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													3,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'INSERT',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_IN_CENTRO_EMBARQUE]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@VP_K_CENTRO_EMBARQUE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													--0, 0, @PP_C_CENTRO_EMBARQUE, '', 0.00, 0.00,
													0, 0, '', '', 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_CENTRO_EMBARQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_CENTRO_EMBARQUE]
GO

CREATE PROCEDURE [dbo].[PG_UP_CENTRO_EMBARQUE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ========================================
	@PP_K_CENTRO_EMBARQUE				INT,			
	@PP_D_CENTRO_EMBARQUE				VARCHAR(100),
	@PP_C_CENTRO_EMBARQUE				VARCHAR(255),
	@PP_S_CENTRO_EMBARQUE				VARCHAR(10),
	-- ===========================
	@PP_K_ESTATUS_CENTRO_EMBARQUE		INT,
	@PP_K_TIPO_CENTRO_EMBARQUE			INT,
	@PP_K_PUNTO							INT,
	@PP_K_TERMINAL						INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_UPDATE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_CENTRO_EMBARQUE, @PP_D_CENTRO_EMBARQUE,
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
		--DECLARE @VP_S_CENTRO_EMBARQUE VARCHAR(10) = LEFT(@PP_D_CENTRO_EMBARQUE,5)		
		-- ==================================

		UPDATE	CENTRO_EMBARQUE
		SET		
				[D_CENTRO_EMBARQUE]					= @PP_D_CENTRO_EMBARQUE,					
				[S_CENTRO_EMBARQUE]					= @PP_S_CENTRO_EMBARQUE,					
				[C_CENTRO_EMBARQUE]					= @PP_C_CENTRO_EMBARQUE,		
				[K_ESTATUS_CENTRO_EMBARQUE]			= @PP_K_ESTATUS_CENTRO_EMBARQUE,
				[K_TIPO_CENTRO_EMBARQUE]			= @PP_K_TIPO_CENTRO_EMBARQUE,
				[K_PUNTO]							= @PP_K_PUNTO,
				[K_TERMINAL]						= @PP_K_TERMINAL,
			-- ===========================
				[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION, 
				[F_CAMBIO]							= GETDATE() 
		WHERE	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [Centro Embarque]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#CEm.'+CONVERT(VARCHAR(10),@PP_K_CENTRO_EMBARQUE)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_CENTRO_EMBARQUE AS CLAVE

	-- //////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													3,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_UP_CENTRO_EMBARQUE]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_CENTRO_EMBARQUE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													--0, 0, @PP_C_CENTRO_EMBARQUE, '', 0.00, 0.00,
													0, 0, '', '', 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_CENTRO_EMBARQUE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_CENTRO_EMBARQUE]
GO


CREATE PROCEDURE [dbo].[PG_DL_CENTRO_EMBARQUE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_CENTRO_EMBARQUE						INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- //////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CENTRO_EMBARQUE_DELETE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_CENTRO_EMBARQUE, 
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- //////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN

		UPDATE	CENTRO_EMBARQUE
		SET		
				[L_BORRADO]				= 1,
				-- ====================
				[F_BAJA]				= GETDATE(), 
				[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
		WHERE	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible borrar el [Centro Embarque]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#CEm.'+CONVERT(VARCHAR(10),@PP_K_CENTRO_EMBARQUE)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_CENTRO_EMBARQUE AS CLAVE

	-- /////////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													5,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'DELETE',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_DL_CENTRO_EMBARQUE]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_CENTRO_EMBARQUE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- /////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
