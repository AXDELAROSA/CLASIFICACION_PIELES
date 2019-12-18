-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			
-- // OPERACION:		LIBERACION / DATOS
-- //////////////////////////////////////////////////////////////

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////
-- SELECT * FROM DATABASE_TAG

-- SELECT * FROM USUARIO

-- SELECT * FROM [SYS3_ACCESO_USR_X_UNO]
-- SELECT * FROM [SYS3_ACCESO_USR_X_RAS]
-- SELECT * FROM [SYS3_ACCESO_USR_X_ZON]


-- //////////////////////////////////////////////////////////////
-- K_SISTEMA | #0 DEFAULT | #10 ICS | #20 ERM | #40 PPT0
-- K_SISTEMA | #1001 PREMA | #2003 TRA19 | #2002 CYC19 | #2003 TRA19 | #2004 RHU19 | #2005 LIQ19 | #2006 ADG18 | #2003 GEO19

DECLARE @VP_K_SISTEMA INT

SET		@VP_K_SISTEMA =	2003		-- #2003 TRA19

-- //////////////////////////////////////////////////////////////


-- ===============================================
SET NOCOUNT ON
-- ===============================================


EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 027, 021, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 027, 003, 1		-- BIOGAS
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 027, 013, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 027, 018, 1		-- GAS CHAPULTEPEC



-- #022	A.SALGADO | #044 T.RUIZ 
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 022, 03, 1		-- BIOGAS
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 022, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 022, 18, 1		-- GAS CHAPULTEPEC

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 044, 03, 1		-- BIOGAS
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 044, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 044, 21, 1		-- GASOMATICO

-- #111	C.ZAMARRON | #169 H.GONZALEZ | #177 J.PEDROZA
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 03, 1		-- BIOGAS
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 21, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 18, 1		-- GAS CHAPULTEPEC
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 14, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 15, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 100, 16, 1		-- GAS CHAPULTEPEC

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 03, 1		-- BIOGAS
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 13, 1		-- UNIGAS MATRIZ
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 21, 1		-- GASOMATICO
EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 169, 18, 1		-- GAS CHAPULTEPEC

EXECUTE [dbo].[PG_CI_SYS3_ACCESO_USR_X_UNO] 0,0000,0, 0000, 177, 03, 1		-- BIOGAS



-- //////////////////////////////////////////////////////////////
-- SELECT * FROM [dbo].[SISTEMA] 
-- SELECT * FROM [dbo].[VALOR_PARAMETRO] 

UPDATE	VALOR_PARAMETRO 
SET		K_SISTEMA = @VP_K_SISTEMA


UPDATE	SYS3_ACCESO_USR_X_RAS 
SET		K_SISTEMA = @VP_K_SISTEMA
WHERE	K_SISTEMA=0

UPDATE	SYS3_ACCESO_USR_X_UNO 
SET		K_SISTEMA = @VP_K_SISTEMA
WHERE	K_SISTEMA=0

UPDATE	SYS3_ACCESO_USR_X_ZON 
SET		K_SISTEMA = @VP_K_SISTEMA
WHERE	K_SISTEMA=0



-- //////////////////////////////////////////////////////////////

DECLARE @VP_S_SISTEMA		VARCHAR(200)

SELECT	@VP_S_SISTEMA =		S_SISTEMA
							FROM	SISTEMA
							WHERE	K_SISTEMA=@VP_K_SISTEMA

IF @VP_S_SISTEMA IS NULL
	SET @VP_S_SISTEMA = '?????'


DECLARE @VP_D_TEXTO VARCHAR(200)
DECLARE @VP_C_TEXTO VARCHAR(200)

-- //////////////////////////////////////////////////////////////
-- SELECT * FROM DATABASE_TAG



-- ========================================================
-- LIBERACION // VERSION // BASE DE DATOS
SET @VP_D_TEXTO = @VP_S_SISTEMA+' > BD/RELEASE'
SET @VP_C_TEXTO = '01/ABR/2019'
SET @VP_C_TEXTO = 'BD/RELASE ['+ @VP_C_TEXTO +']'

EXECUTE [dbo].[PG_CI_DATABASE_TAG] 0,@VP_K_SISTEMA,	20190401.1,	@VP_D_TEXTO, 'BD.V0012', 1, @VP_C_TEXTO, 1


-- ========================================================
-- LIBERACION // VERSION // EJECUTABLE
SET @VP_D_TEXTO = @VP_S_SISTEMA+' > EXE/RELEASE'
SET @VP_C_TEXTO = '01/ABR/2019'
SET @VP_C_TEXTO = 'EXE/RELASE ['+ @VP_C_TEXTO +']'

EXECUTE [dbo].[PG_CI_DATABASE_TAG] 0, @VP_K_SISTEMA,	20190401.2,	@VP_D_TEXTO, 'EXE.V0001', 1, @VP_C_TEXTO, 1

-- ========================================================
-- EJECUCION SCRIPT
SET @VP_D_TEXTO = @VP_S_SISTEMA+' > EJECUCION SCRIPT'

SET @VP_C_TEXTO = GETDATE()
SET @VP_C_TEXTO = 'EJECUCION ['+ @VP_C_TEXTO +']'

EXECUTE [dbo].[PG_CI_DATABASE_TAG] 0,@VP_K_SISTEMA,	1000,	@VP_D_TEXTO, 'INIT/SQL', 1, @VP_C_TEXTO, 1


-- ========================================================

-- ========================================================
-- SELECT * FROM DATABASE_TAG




-- ===============================================
SET NOCOUNT OFF
-- ===============================================




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////