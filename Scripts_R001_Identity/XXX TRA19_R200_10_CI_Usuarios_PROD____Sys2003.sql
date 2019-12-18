-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION // STORED PROCEDURE
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // PASO 1 > PURGAR TABLAS [#PROD]
-- // PASO 2 > CARGA INICIAL [USUARIO#PROD]
-- // PASO 3 > CARGA INICIAL [ACCESO/UNO#PROD]
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO


-- SELECT * FROM [SYS3_ACCESO_USR_X_UNO] WHERE K_USUARIO>999
-- SELECT * FROM [SYS3_ACCESO_USR_X_RAS] WHERE K_USUARIO>999
-- SELECT * FROM [SYS3_ACCESO_USR_X_ZON] WHERE K_USUARIO>999



-- ===============================================
SET NOCOUNT ON
-- ===============================================


-- //////////////////////////////////////////////////////////////
-- // PASO 1 > PURGAR TABLAS [#PROD]
-- //////////////////////////////////////////////////////////////
 
DELETE 
FROM	[SYS3_ACCESO_USR_X_UNO]
WHERE	K_USUARIO>999
AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

DELETE 
FROM	[SYS3_ACCESO_USR_X_RAS]
WHERE	K_USUARIO>999
AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

DELETE 
FROM	[SYS3_ACCESO_USR_X_ZON]
WHERE	K_USUARIO>999
AND		K_SISTEMA=2003		-- K_SISTEMA = #2003 TRA19

DELETE 
FROM	[USUARIO] 
WHERE	K_USUARIO>999
GO



-- //////////////////////////////////////////////////////////////
-- // PASO 2 > CARGA INICIAL [USUARIO#PROD]
-- //////////////////////////////////////////////////////////////
-- SELECT * FROM USUARIO

EXECUTE [dbo].[PG_CI_USUARIO]	0,2003,0, 1401, 'TRA19/GERENTE#PROD',		'GERENTE',		'GER', 150, 1, 'ger.LIQ@tomza.com',	'GER', '123', '04/MAR/2019',	1, 1, NULL
EXECUTE [dbo].[PG_CI_USUARIO]	0,2003,0, 1402, 'TRA19/CORDINADOR#PROD',	'CORDINADOR',	'COR', 160, 1, 'cor.LIQ@tomza.com',	'COR', '234', '04/MAR/2019',	1, 1, NULL
EXECUTE [dbo].[PG_CI_USUARIO]	0,2003,0, 1403, 'TRA19/ANALISTA#PROD',		'ANALISTA',		'ANA', 170, 1, 'ana.LIQ@tomza.com', 'ANA', '345', '04/MAR/2019',	1, 1, NULL
GO

-- ==============================





-- //////////////////////////////////////////////////////////////
-- // PASO 3 > CARGA INICIAL [ACCESO/UNO#PROD]
-- //////////////////////////////////////////////////////////////




EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1401, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1402, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1403, 13, 1		-- UNIGAS MATRIZ
GO

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1402, 14, 1		-- 
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1403, 14, 1		-- 
GO

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,2003,0, 2003, 1403, 15, 1		-- 
GO


-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- /////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////
-- /////////////////////////////////////////////////////////////////////////////////////
