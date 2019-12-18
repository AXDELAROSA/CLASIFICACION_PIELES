-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			USUARIO_X_ZON
-- // OPERACION:		LIBERACION / TABLAS 
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////

   




-- //////////////////////////////////////////////////////////////
-- //
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_SYS3_ACCESO_USR_X_ZON_Init_X_K_USUARIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_SYS3_ACCESO_USR_X_ZON_Init_X_K_USUARIO]
GO


CREATE PROCEDURE [dbo].[PG_PR_SYS3_ACCESO_USR_X_ZON_Init_X_K_USUARIO]
	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_K_SISTEMA				INT,
	@PP_K_USUARIO				INT
	-- ============================		
AS	

	DELETE 
	FROM	[SYS3_ACCESO_USR_X_ZON]
	WHERE	K_USUARIO=@PP_K_USUARIO
	AND		K_SISTEMA=@PP_K_SISTEMA

	-- ==================================

	INSERT INTO [SYS3_ACCESO_USR_X_ZON]
		(		[K_SISTEMA], [K_USUARIO], [K_ZONA_UO], 
				[L_ACCESO], 
				[K_USUARIO_ALTA], [F_ALTA], 
				[K_USUARIO_CAMBIO], [F_CAMBIO], 
				[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]		)
		SELECT	DISTINCT 
				SYS3.[K_SISTEMA], SYS3.[K_USUARIO], ZONA_UO.[K_ZONA_UO], 
				SYS3.[L_ACCESO], 
				0, GETDATE(), 
				0, GETDATE(), 
				0, 0, NULL
		FROM	SYS3_ACCESO_USR_X_UNO AS SYS3, 
				UNIDAD_OPERATIVA, ZONA_UO
		WHERE	UNIDAD_OPERATIVA.K_ZONA_UO=ZONA_UO.K_ZONA_UO
		AND		SYS3.K_UNIDAD_OPERATIVA=UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA
		AND		SYS3.K_USUARIO=@PP_K_USUARIO
		AND		SYS3.K_SISTEMA=@PP_K_SISTEMA

	-- ==================================
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
