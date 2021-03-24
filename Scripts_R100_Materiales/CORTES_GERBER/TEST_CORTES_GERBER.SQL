
-- ////////////////////////////////////////////////////////////// 
USE DATA_02Pruebas

/*
--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317
*/

/*
--DECLARE @VP_FOLIO_BASE INT = 0
--SELECT TOP 1 @VP_FOLIO_BASE = MAX(TAG) FROM RP_FOLIOS 

--SET @VP_FOLIO_BASE = @VP_FOLIO_BASE + 1

--EXECUTE [dbo].[PG_IN_RP_FOLIOS]		0, 0,
--									@VP_FOLIO_BASE, 'B', NULL, NULL, NULL


--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[YARDAS],[YLB],[PESO],[TYPE],[MOVEMENT],[K_CLASIFICACION]
--		)
--SELECT GETDATE(),[COLOUR],[LOT],[HIDE],[SQF],@VP_FOLIO_BASE,[YARDAS],[YLB],[PESO],[TYPE],'MHI',[K_CLASIFICACION]
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788336 AND HIDE = '0137'
*/

SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	LTRIM(RTRIM(PLOT)) IN ('34461')
--and HIDESLIN_SQL.fileno = '210310181706T1000002'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND PCOLOR = 'FNPJSA5'
 ORDER BY HIDESLIN_SQL.HIDE ASC

 SELECT * FROM HIDESHDR_SQL WHERE PLOT = '34461'

SELECT * FROM  HIDESLIN_SQL WHERE FILENO IN ('210311130104T1000002') --AND PRINTED = 1 
ORDER BY HIDE

--UPDATE  HIDESLIN_SQL 
--SET PRINTED = 0
--WHERE FILENO IN ('210311130104T1000002')

SELECT * --RIGHT('0000' + CONVERT(VARCHAR(4), CONVERT(INT, HIDE) + 215 ), 4) , SQF
FROM RP_SC
WHERE	LTRIM(RTRIM(LOT)) = ('34461')
--AND COLOUR = 'FWLNPX7'
--and convert(int, LTRIM(RTRIM(hide))) between 430 and 644
ORDER  BY HIDE

SELECT * FROM  CCJOBHDR_SQL WHERE jobno = ('25862') order by jobno desc

SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)  

SELECT * FROM cccuthst_sql WHERE jobno = '25736' order by hideno

SELECT * FROM cccuthst_sql WHERE jobno = '00000' AND hideno IN ('0119','0181','0375') ORDER BY hideno

--update cccuthst_sql 
--set lotno = '         ' + SUBSTRING(Ltrim(Rtrim(lotno)), 1, 5) + '1' 
--WHERE jobno = '00000' AND hideno IN ('0119','0181','0375')

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE (FOLIO_ORIGEN = 3809586 OR  FOLIO_DESTINO = 3809586 )
--(ORDEN_ORIGEN = 26245 OR  ORDEN_DESTIDO = 26245 )
--AND 
--K_USUARIO_ALTA = 136
--AND 
--LOTE IN (34411)              
AND PIEL   IN (SELECT  hideno FROM cccuthst_sql WHERE jobno = '23410' )
--PIEL   IN (8, 312, 311)
--AND PIEL_LOG.K_TIPO_PIEL_LOG IN (1)
ORDER BY k_piel_log desc

SELECT  * from RP_SC WHERE TAGNO = (3816975) ORDER BY HIDE

SELECT * FROM RP_FOLIOS WHERE TAG = 3816975

--update RP_FOLIOS 
--	set JOBNO = '23410',
--		MACHINE = 'Table 39',
--		STATUS = 'C1'
--WHERE TAG = 3809586

--SELECT * FROM RP_FOLIOS WHERE jobno = '23779'

SELECT *  FROM ccjobhdr_sql WHERE folio = 3816975

SELECT  * FROM cccuthst_sql WHERE jobno = '26718' ORDER BY LINENUM

--UPDATE ccjobhdr_sql 
--SET FOLIO = NULL
--WHERE FOLIO = 3816798

SELECT * FROM TIPO_PIEL_LOG

--	SELECT * FROM cccuthst_sql WHERE JOBNO = '00000'  

--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '34411', 6) )
--DECLARE @VP_TURNO	VARCHAR(5) = '0'

--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
--										-- ===========================
--										'00000', '0000', '1', @VP_FECHA,
--										-- ===========================
--										@VP_HORA, @VP_FECHA, 0, 'FWLNPX7', 
--										-- ===========================
--										@VP_LOTE_CON_ESPACIO, '0375','35.7500',
--										-- ===========================
--										'00000', '', '00000', '00000',
--										'00000', '00000', '00000', '00000', '00000',
--										-- ===========================
--										0, 0, 0, 0,
--										-- ===========================
--																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
