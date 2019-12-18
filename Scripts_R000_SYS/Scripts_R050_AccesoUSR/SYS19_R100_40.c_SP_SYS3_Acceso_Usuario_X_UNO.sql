-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			SITIO 
-- // OPERACION:		LIBERACION / STORED PROCEDURES 
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM SYS3_ACCESO_USR_X_UNO

-- DELETE FROM SYS3_ACCESO_USR_X_UNO

-- EXECUTE [PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- EXECUTE [PG_LI_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- SELECT * FROM SYS3_ACCESO_USR_X_UNO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
GO


CREATE PROCEDURE [dbo].[PG_LI_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_K_USUARIO				INT
	-- ============================		
AS	
	DECLARE @VP_MENSAJE		VARCHAR(300)

	SET		@VP_MENSAJE		= ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_DATA_ACCESO_SELECT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													1, -- @PP_K_DATA_SISTEMA,	
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT	

	-- ///////////////////////////////////////////
		
	DECLARE @VP_L_APLICAR_MAX_ROWS	INT=1
	DECLARE @VP_LI_N_REGISTROS		INT

	EXECUTE [dbo].[PG_SK_CONFIGURACION_LI_N_REGISTROS_GET]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
															@VP_L_APLICAR_MAX_ROWS,
															@OU_LI_N_REGISTROS = @VP_LI_N_REGISTROS		OUTPUT		
	-- =========================================	

	IF @VP_MENSAJE<>''
		SET @VP_LI_N_REGISTROS = 0
	
	-- =========================================		

	--DECLARE @VP_K_FOLIO		INT

	--EXECUTE [dbo].[PG_RN_OBTENER_ID_X_REFERENCIA]	@PP_BUSCAR, 
	--												@OU_K_ELEMENTO = @VP_K_FOLIO	OUTPUT
	-- =========================================
	
	DECLARE @VP_L_VER_BORRADOS		[INT]		
	
	EXECUTE [dbo].[PG_RN_DATA_VER_BORRADOS]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@OU_L_VER_BORRADOS = @VP_L_VER_BORRADOS			OUTPUT

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	-- SELECT * FROM USUARIO
	SELECT	TOP ( @VP_LI_N_REGISTROS )
			SYS3_ACCESO_USR_X_UNO.*,
			-- ==============================
			D_UNIDAD_OPERATIVA, S_UNIDAD_OPERATIVA,
			-- ==============================
			(SELECT D_USUARIO AS D_USUARIO FROM USUARIO WHERE USUARIO.K_USUARIO= SYS3_ACCESO_USR_X_UNO.K_USUARIO),
			(SELECT D_USUARIO AS D_USUARIO_CAMBIO FROM USUARIO WHERE USUARIO.K_USUARIO= SYS3_ACCESO_USR_X_UNO.K_USUARIO_CAMBIO)
			-- ==============================
	FROM	SYS3_ACCESO_USR_X_UNO,
			UNIDAD_OPERATIVA, USUARIO
			-- ==============================
	WHERE	SYS3_ACCESO_USR_X_UNO.K_UNIDAD_OPERATIVA=UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA
	--AND		SYS3_ACCESO_USR_X_UNO.K_USUARIO=USUARIO.K_USUARIO
	--OR		SYS3_ACCESO_USR_X_UNO.K_USUARIO_CAMBIO=USUARIO.K_USUARIO_CAMBIO
	AND		(	@PP_K_USUARIO=-1			OR  SYS3_ACCESO_USR_X_UNO.K_USUARIO=@PP_K_USUARIO )
			-- ==============================
	ORDER BY K_UNIDAD_OPERATIVA ASC

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM SYS3_ACCESO_USR_X_UNO

-- DELETE FROM SYS3_ACCESO_USR_X_UNO

-- EXECUTE [PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- SELECT * FROM SYS3_ACCESO_USR_X_UNO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
GO


CREATE PROCEDURE [dbo].[PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_K_SISTEMA				INT,
	@PP_K_USUARIO				INT
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	/*
	IF @VP_MENSAJE=''	
		EXECUTE [dbo].[PG_RN_SYS3_ACCESO_USR_X_UNO_INSERT]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_K_USUARIO, @PP_K_UNIDAD_OPERATIVA,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
*/
	
	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
		
		INSERT INTO [SYS3_ACCESO_USR_X_UNO]
				(	[K_USUARIO],
					[K_UNIDAD_OPERATIVA],
					-- ===========================
					[L_ACCESO],
					-- ===========================
					[K_USUARIO_ALTA], [F_ALTA], 
					[K_USUARIO_CAMBIO], [F_CAMBIO],
					[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )
			SELECT	@PP_K_USUARIO,		
					UNO.K_UNIDAD_OPERATIVA,
					-- ===========================
					0,		-- @PP_L_ACCESO,
					-- ===========================
					@PP_K_USUARIO_ACCION, GETDATE(), 
					@PP_K_USUARIO_ACCION, GETDATE(),
					0, NULL, NULL 
			FROM	UNIDAD_OPERATIVA AS UNO
			WHERE	NOT (	UNO.K_UNIDAD_OPERATIVA IN	(	SELECT	UNO2.K_UNIDAD_OPERATIVA 
															FROM	[SYS3_ACCESO_USR_X_UNO] AS UNO2
															WHERE	UNO2.K_USUARIO=@PP_K_USUARIO	)	)
			-- ===================================
	
			EXECUTE	[dbo].[PG_PR_SYS3_ACCESO_USR_X_ZON_Init_X_K_USUARIO]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_K_SISTEMA, @PP_K_USUARIO
			-- ============================		

			EXECUTE	[dbo].[PG_PR_SYS3_ACCESO_USR_X_RAS_Init_X_K_USUARIO]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_K_SISTEMA, @PP_K_USUARIO
			-- ////////////////////////////////////////
		END


	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [Sitio_Usuario_UNO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SIT_USU_UNO.'+CONVERT(VARCHAR(10),@PP_K_USUARIO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_USUARIO AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM SYS3_ACCESO_USR_X_UNO

-- DELETE FROM SYS3_ACCESO_USR_X_UNO

-- EXECUTE [PG_DL_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- SELECT * FROM SYS3_ACCESO_USR_X_UNO


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
GO


CREATE PROCEDURE [dbo].[PG_DL_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_K_USUARIO				INT
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	/*
	IF @VP_MENSAJE=''	
		EXECUTE [dbo].[PG_RN_SYS3_ACCESO_USR_X_UNO_INSERT]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_K_USUARIO, @PP_K_UNIDAD_OPERATIVA,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
*/
	
	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
		
		DELETE
		FROM	[SYS3_ACCESO_USR_X_UNO]
		WHERE	K_USUARIO=@PP_K_USUARIO
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [Sitio_Usuario_UNO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SIT_USU_UNO.'+CONVERT(VARCHAR(10),@PP_K_USUARIO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_USUARIO AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM SYS3_ACCESO_USR_X_UNO

-- DELETE FROM SYS3_ACCESO_USR_X_UNO

-- EXECUTE [PG_IN_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- EXECUTE [PG_DL_SYS3_ACCESO_USR_X_UNO_X_K_USUARIO] 0,0,0, 69

-- SELECT * FROM SYS3_ACCESO_USR_X_UNO

-- EXECUTE [PG_UP_SYS3_ACCESO_USR_X_UNO] 0,0,0, 69, 10, 0


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_SYS3_ACCESO_USR_X_UNO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_SYS3_ACCESO_USR_X_UNO]
GO


CREATE PROCEDURE [dbo].[PG_UP_SYS3_ACCESO_USR_X_UNO]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_K_USUARIO				INT,
	@PP_K_UNIDAD_OPERATIVA		INT,
	@PP_L_ACCESO				INT
	-- ============================		
AS			

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	
	/*
	IF @VP_MENSAJE=''	
		EXECUTE [dbo].[PG_RN_SYS3_ACCESO_USR_X_UNO_INSERT]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_K_USUARIO, @PP_K_UNIDAD_OPERATIVA,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
*/
	
	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR
	
	IF @VP_MENSAJE=''
		BEGIN
		
		UPDATE	[SYS3_ACCESO_USR_X_UNO]
		SET		L_ACCESO=@PP_L_ACCESO
		WHERE	K_USUARIO=@PP_K_USUARIO
		AND		K_UNIDAD_OPERATIVA=@PP_K_UNIDAD_OPERATIVA
		
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [Crear] el [Sitio_Usuario_UNO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#SIT_USU_UNO.'+CONVERT(VARCHAR(10),@PP_K_USUARIO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_USUARIO AS CLAVE

	-- //////////////////////////////////////////////////////////////

GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////