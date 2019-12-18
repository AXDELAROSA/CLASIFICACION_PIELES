-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			USUARIO_X_UNO 
-- // OPERACION:		LIBERACION / TABLAS 
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////

   
   
-- //////////////////////////////////////////////////////////////
--	SELECT *	FROM [dbo].[SYS3_ACCESO_USR_X_UNO]


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SYS3_ACCESO_USR_X_UNO]') AND type in (N'U'))
	BEGIN
	
	DELETE	
	FROM	[dbo].[SYS3_ACCESO_USR_X_UNO]
	WHERE	K_USUARIO<=999
	AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

	DELETE	
	FROM	[dbo].[SYS3_ACCESO_USR_X_RAS]
	WHERE	K_USUARIO<=999
	AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

	DELETE	FROM [dbo].[SYS3_ACCESO_USR_X_ZON]
	WHERE	K_USUARIO<=999
	AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

	END
GO





-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////



-- ===============================================
SET NOCOUNT ON
-- ===============================================
-- SELECT * FROM [SYS3_ACCESO_USR_X_UNO]

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 013, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 099, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 111, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 169, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 177, 13, 1		-- UNIGAS MATRIZ

/*

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 099, 21, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 099, 18, 1		-- GAS CHAPULTEPEC

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 21, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 18, 1		-- GAS CHAPULTEPEC
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 14, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 15, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 16, 1		-- GAS CHAPULTEPEC

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 34, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 35, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 36, 1		-- GAS CHAPULTEPEC
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 37, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 38, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 39, 1		-- GAS CHAPULTEPEC
GO
*/

-- ===============================================
SET NOCOUNT OFF
-- ===============================================



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
