
USE DATA_02Pruebas
SELECT * FROM [PIEL_A_TRANSFERIR]
SELECT * FROM PIEL_A_TRANSFERIR_TRANSACCION

SELECT D_TIPO_PIEL_LOG,usuario,PIEL_LOG.*  
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG=TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
/*
USE DATA_02Pruebas
TRUNCATE TABLE [PIEL_A_TRANSFERIR]

DELETE	PIEL_A_TRANSFERIR_TRANSACCION
WHERE	K_PIEL_A_TRANSFERIR_TRANSACCION = 2

*/


select * from HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '33012' 
 AND LTRIM(RTRIM(HIDE)) IN   ('0002')

--SELECT * FROM CCJOBHDR_SQL WHERE  LTRIM(RTRIM(jobno)) IN ('11111' ,'11002' )

SELECT  * FROM cccuthst_sql 
WHERE LTRIM(RTRIM(COLOUR)) = 'FMCKTX7'  
AND	LTRIM(RTRIM(lotno)) = '033012' 
 AND LTRIM(RTRIM(hideno))   IN ('0600','0601','0602','0603','0604','0605','0606')
ORDER BY HIDENO ASC

SELECT  * FROM RP_SC
WHERE	LTRIM(RTRIM(COLOUR)) = 'FMCKTX7' 
AND	LTRIM(RTRIM(LOT)) = '32782' 
AND LTRIM(RTRIM(HIDE)) IN   ('0631')




/*
USE DATA_02Pruebas
UPDATE cccuthst_sql 
	SET hidesqm = '15.10'
WHERE LTRIM(RTRIM(COLOUR)) = 'FMCKTX7'  
AND	LTRIM(RTRIM(lotno)) = '033012' 
AND LTRIM(RTRIM(hideno))   IN ('0599')
*/



 --USE DATA_02Pruebas
 --IF (	SELECT COUNT(*) FROM sys.table_types
	--						WHERE name = 'TVPParamtest' AND schema_id = 1	) = 0
	--						CREATE TYPE dbo.TVPParamtest AS TABLE(	COLOR		VARCHAR(20),
	--															LOTE		VARCHAR(20),
	--															SQF			VARCHAR(20)	)
				
select * from test
 USE DATA_02Pruebas
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TEST_TABLA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TEST_TABLA]
GO
-- EXECUTE   [dbo].[PG_PM_TEST_TABLA] 0,0, 'B' , 'FCMKDX9' 
CREATE PROCEDURE [dbo].[PG_PM_TEST_TABLA]
	--@PP_K_SISTEMA_EXE			INT,
	--@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@TBL_TOTAL_SQF_X_LOTE		TVPParamtest READONLY
	-- ===========================
AS
	-- ///////////////////////////////////////////

	select * into test
	from @TBL_TOTAL_SQF_X_LOTE
	-- ////////////////////////////////////////////////////////////////////


	-- ////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////

GO

