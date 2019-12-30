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

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////


--EXECUTE [dbo].[PG_LI_PIEL_CLASIFICADA] 0,0,0,'',-1,-1,-1,-1

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_LI_PIEL_CLASIFICADA]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ==============================================
	@PP_BUSCAR							VARCHAR(200),
	-- ==============================================
	@PP_K_PIEL_LOTE						INT,
	@PP_K_ESTATUS_PIEL_CLASIFICADA		INT,
	@PP_K_TIPO_PIEL_CLASIFICADA			INT
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
	
	DECLARE @VP_L_VER_BORRADOS		INT		
	
	EXECUTE [dbo].[PG_RN_DATA_VER_BORRADOS]			@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@OU_L_VER_BORRADOS = @VP_L_VER_BORRADOS			OUTPUT
	-- =========================================

	IF @VP_MENSAJE<>''
		SET @VP_LI_N_REGISTROS = 0

	-- =========================================
		
	SELECT	TOP (@VP_LI_N_REGISTROS)
				PIEL_CLASIFICADA.*,
				USUARIO.D_USUARIO AS D_USUARIO_CAMBIO,		
			-- =====================
				PIEL_LOTE.D_PIEL_LOTE,PIEL_LOTE.S_PIEL_LOTE,
			-- =====================
				D_ESTATUS_PIEL_CLASIFICADA, D_TIPO_PIEL_CLASIFICADA, 
				S_ESTATUS_PIEL_CLASIFICADA, S_TIPO_PIEL_CLASIFICADA 
			-- =====================
	FROM		PIEL_CLASIFICADA, USUARIO,
				ESTATUS_PIEL_CLASIFICADA,
				TIPO_PIEL_CLASIFICADA,
				PIEL_LOTE
			-- =====================
	WHERE		PIEL_CLASIFICADA.K_USUARIO_CAMBIO=USUARIO.K_USUARIO
			-- =====================
	AND			PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA=ESTATUS_PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA=TIPO_PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_PIEL_LOTE=PIEL_LOTE.K_PIEL_LOTE
			-- =====================
	AND		(		PIEL_CLASIFICADA.D_PIEL_CLASIFICADA			LIKE '%'+@PP_BUSCAR+'%' 
				OR	PIEL_CLASIFICADA.C_PIEL_CLASIFICADA			LIKE '%'+@PP_BUSCAR+'%' 
				OR	PIEL_LOTE.D_PIEL_LOTE						LIKE '%'+@PP_BUSCAR+'%'
				OR	D_ESTATUS_PIEL_CLASIFICADA					LIKE '%'+@PP_BUSCAR+'%' 
				OR	D_TIPO_PIEL_CLASIFICADA						LIKE '%'+@PP_BUSCAR+'%'
			)	
			-- =====================
	AND		( @PP_K_PIEL_LOTE=-1					OR	PIEL_CLASIFICADA.K_PIEL_LOTE=@PP_K_PIEL_LOTE )
	AND		( @PP_K_ESTATUS_PIEL_CLASIFICADA=-1		OR	PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA=@PP_K_ESTATUS_PIEL_CLASIFICADA )
	AND		( @PP_K_TIPO_PIEL_CLASIFICADA=-1		OR	PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA=@PP_K_TIPO_PIEL_CLASIFICADA )
			-- =====================
	AND		( PIEL_CLASIFICADA.L_BORRADO=0			OR	@VP_L_VER_BORRADOS=1 )	
			-- =====================		
	AND		( PIEL_CLASIFICADA.K_PIEL_CLASIFICADA>0 )
	ORDER BY D_PIEL_LOTE, S_ESTATUS_PIEL_CLASIFICADA, S_TIPO_PIEL_CLASIFICADA, D_PIEL_CLASIFICADA 

			
	-- /////////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_LI_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_BUSCAR, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- /////////////////////////////////////////////////////////////////////
GO



-- EXECUTE [dbo].[PG_SK_PIEL_CLASIFICADA] 0,0,0, 8

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_CLASIFICADA				INT
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
				PIEL_CLASIFICADA.*,
				USUARIO.D_USUARIO AS D_USUARIO_CAMBIO,		
			-- =====================
				PIEL_LOTE.D_PIEL_LOTE,PIEL_LOTE.S_PIEL_LOTE,
			-- =====================
				D_ESTATUS_PIEL_CLASIFICADA, D_TIPO_PIEL_CLASIFICADA, 
				S_ESTATUS_PIEL_CLASIFICADA, S_TIPO_PIEL_CLASIFICADA 
			-- =====================
	FROM		PIEL_CLASIFICADA, USUARIO,
				ESTATUS_PIEL_CLASIFICADA,
				TIPO_PIEL_CLASIFICADA,
				PIEL_LOTE
			-- =====================
	WHERE		PIEL_CLASIFICADA.K_USUARIO_CAMBIO=USUARIO.K_USUARIO
			-- =====================
	AND			PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA=ESTATUS_PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA=TIPO_PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_PIEL_LOTE=PIEL_LOTE.K_PIEL_LOTE
			-- =====================
	AND			PIEL_CLASIFICADA.K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA
			-- =====================
		
	-----////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SEEK',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_SK_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_CLASIFICADA, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_SK_PIEL_CLASIFICADA_X_K_PIEL_LOTE] 0,0,0, 2

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_CLASIFICADA_X_K_PIEL_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_X_K_PIEL_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_X_K_PIEL_LOTE]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_LOTE						INT
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
				PIEL_CLASIFICADA.*,
				USUARIO.D_USUARIO AS D_USUARIO_CAMBIO,		
			-- =====================
				PIEL_LOTE.D_PIEL_LOTE,PIEL_LOTE.S_PIEL_LOTE,
				PIEL_LOTE_CANTIDAD,
				(	SELECT ISNULL(COUNT(K_PIEL_CLASIFICADA),0) 
					FROM PIEL_CLASIFICADA 
					WHERE K_PIEL_LOTE=@PP_K_PIEL_LOTE	) AS PIEL_LOTE_CANTIDAD_CLASIFICADA,
			-- =====================
				D_ESTATUS_PIEL_CLASIFICADA, D_TIPO_PIEL_CLASIFICADA, 
				S_ESTATUS_PIEL_CLASIFICADA, S_TIPO_PIEL_CLASIFICADA 
			-- =====================
	FROM		PIEL_CLASIFICADA, USUARIO,
				ESTATUS_PIEL_CLASIFICADA,
				TIPO_PIEL_CLASIFICADA,
				PIEL_LOTE
			-- =====================
	WHERE		PIEL_CLASIFICADA.K_USUARIO_CAMBIO=USUARIO.K_USUARIO
			-- =====================
	AND			PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA=ESTATUS_PIEL_CLASIFICADA.K_ESTATUS_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA=TIPO_PIEL_CLASIFICADA.K_TIPO_PIEL_CLASIFICADA
	AND			PIEL_CLASIFICADA.K_PIEL_LOTE=PIEL_LOTE.K_PIEL_LOTE
			-- =====================
	AND			PIEL_CLASIFICADA.K_PIEL_LOTE=@PP_K_PIEL_LOTE
			-- =====================
		
	-----////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SEEK',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_SK_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_LOTE, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_IN_PIEL_CLASIFICADA] 0,0,0, '123A','',1,1,5

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_IN_PIEL_CLASIFICADA]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_D_PIEL_CLASIFICADA				VARCHAR(100),
	@PP_C_PIEL_CLASIFICADA				VARCHAR(255),
	-- ===========================
	@PP_K_ESTATUS_PIEL_CLASIFICADA		INT,
	@PP_K_TIPO_PIEL_CLASIFICADA			INT,
	@PP_K_PIEL_LOTE						INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_K_PIEL_CLASIFICADA		INT = 0
	
	EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, 
												'PIEL_CLASIFICADA', 
												@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_CLASIFICADA			OUTPUT
	-- ==================================

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_K_PIEL_LOTE, @PP_D_PIEL_CLASIFICADA,
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	
			BEGIN TRANSACTION 
			BEGIN TRY

			DECLARE @VP_S_PIEL_CLASIFICADA VARCHAR(10) = LEFT(@PP_D_PIEL_CLASIFICADA,5)		
			INSERT INTO [PIEL_CLASIFICADA]	
				(	[K_PIEL_CLASIFICADA], [D_PIEL_CLASIFICADA],
					[S_PIEL_CLASIFICADA], [C_PIEL_CLASIFICADA], 
					[K_PIEL_LOTE],
					[K_ESTATUS_PIEL_CLASIFICADA],
					[K_TIPO_PIEL_CLASIFICADA],
				-- ============================================
					[K_USUARIO_ALTA], [F_ALTA], 
					[K_USUARIO_CAMBIO], [F_CAMBIO],
					[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )		
			VALUES	
				(	@VP_K_PIEL_CLASIFICADA, @PP_D_PIEL_CLASIFICADA,
					@VP_S_PIEL_CLASIFICADA, @PP_C_PIEL_CLASIFICADA,
					@PP_K_PIEL_LOTE,
					@PP_K_ESTATUS_PIEL_CLASIFICADA,
					@PP_K_TIPO_PIEL_CLASIFICADA,		
				-- ============================================
					@PP_K_USUARIO_ACCION, GETDATE(), 
					@PP_K_USUARIO_ACCION, GETDATE(),
					0, NULL, NULL )	
			-- ==================================	
			IF @@ROWCOUNT=0
				BEGIN
					SET @VP_MENSAJE = 'ERROR ROWCOUNT: NO SE EJECUTO LA ACCION'
				END
			ELSE
				BEGIN
					EXECUTE	[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_K_PIEL_LOTE
				END
			/* Confirmamos la transaccion*/
			COMMIT TRANSACTION 
			
			END TRY
			
			BEGIN CATCH
			
			/* Ocurrió un error, deshacemos los cambios*/ 
			ROLLBACK TRANSACTION
			PRINT 'Ha ocurrido un error!'
			
			END CATCH
		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar la [Piel]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.' + @PP_D_PIEL_CLASIFICADA +']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.'+CONVERT(VARCHAR(10),@VP_K_PIEL_CLASIFICADA)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_K_PIEL_CLASIFICADA AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													3,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'INSERT',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_IN_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@VP_K_PIEL_CLASIFICADA, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													--0, 0, @PP_C_PIEL_CLASIFICADA, '', 0.00, 0.00,
													0, 0, '', '', 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_PIEL_CLASIFICADA]
GO

CREATE PROCEDURE [dbo].[PG_UP_PIEL_CLASIFICADA]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_CLASIFICADA				INT,	
	-- ===========================		
	@PP_D_PIEL_CLASIFICADA				VARCHAR(100),
	@PP_C_PIEL_CLASIFICADA				VARCHAR(255),
	-- ===========================
	@PP_K_ESTATUS_PIEL_CLASIFICADA		INT,
	@PP_K_TIPO_PIEL_CLASIFICADA			INT,
	@PP_K_PIEL_LOTE						INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_UPDATE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@PP_K_PIEL_CLASIFICADA, @PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_S_PIEL_CLASIFICADA VARCHAR(10) = LEFT(@PP_D_PIEL_CLASIFICADA,5)		
			-- ==================================

			UPDATE	PIEL_CLASIFICADA
			SET		
					[D_PIEL_CLASIFICADA]				= @PP_D_PIEL_CLASIFICADA,					
					[S_PIEL_CLASIFICADA]				= @VP_S_PIEL_CLASIFICADA,					
					[C_PIEL_CLASIFICADA]				= @PP_C_PIEL_CLASIFICADA,	
					[K_PIEL_LOTE]						= @PP_K_PIEL_LOTE,	
					[K_ESTATUS_PIEL_CLASIFICADA]		= @PP_K_ESTATUS_PIEL_CLASIFICADA,
					[K_TIPO_PIEL_CLASIFICADA]			= @PP_K_TIPO_PIEL_CLASIFICADA,
					-- ===========================
					[K_USUARIO_CAMBIO]					= @PP_K_USUARIO_ACCION, 
					[F_CAMBIO]							= GETDATE() 
			WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA
			-- ==================================

			EXECUTE	[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
															@PP_K_PIEL_LOTE
		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar la [Piel]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.' + @PP_D_PIEL_CLASIFICADA +']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.'+CONVERT(VARCHAR(10),@PP_K_PIEL_CLASIFICADA)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PIEL_CLASIFICADA AS CLAVE

	-- //////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													3,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_UP_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_CLASIFICADA, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													--0, 0, @PP_C_PIEL_CLASIFICADA, '', 0.00, 0.00,
													0, 0, '', '', 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_PIEL_CLASIFICADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_PIEL_CLASIFICADA]
GO


CREATE PROCEDURE [dbo].[PG_DL_PIEL_CLASIFICADA]
	@PP_L_DEBUG							INT,
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_CLASIFICADA				INT
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- //////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_DELETE]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@PP_K_PIEL_CLASIFICADA, 
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- //////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN

		--UPDATE	PIEL_CLASIFICADA
		--SET		
		--		[L_BORRADO]				= 1,
		--		-- ====================
		--		[F_BAJA]				= GETDATE(), 
		--		[K_USUARIO_BAJA]		= @PP_K_USUARIO_ACCION
		--WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA

		DECLARE @VP_K_PIEL_LOTE	INT = 0

		SELECT	@VP_K_PIEL_LOTE = K_PIEL_LOTE
		FROM	PIEL_CLASIFICADA
		WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA
		-- ====================

		DELETE	PIEL_CLASIFICADA
		WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA
		-- ====================

		EXECUTE	[PG_IN_UP_PIEL_PORCENTAJE_X_ESTATUS]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
														@VP_K_PIEL_LOTE
		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		DECLARE @VP_D_PIEL_CLASIFICADA VARCHAR(100)
		-- ========================

		SELECT	@VP_D_PIEL_CLASIFICADA = D_PIEL_CLASIFICADA
		FROM	PIEL_CLASIFICADA
		WHERE	K_PIEL_CLASIFICADA=@PP_K_PIEL_CLASIFICADA

		SET		@VP_MENSAJE = 'No es posible borrar la [Piel]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.' + @VP_D_PIEL_CLASIFICADA +']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.'+CONVERT(VARCHAR(10),@PP_K_PIEL_CLASIFICADA)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'

		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PIEL_CLASIFICADA AS CLAVE

	-- /////////////////////////////////////////////////////////////////////

	EXECUTE [dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													5,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'DELETE',
													@VP_MENSAJE,
													-- ===========================================
													'[PG_DL_PIEL_CLASIFICADA]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													@PP_K_PIEL_CLASIFICADA, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, '', '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- /////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
