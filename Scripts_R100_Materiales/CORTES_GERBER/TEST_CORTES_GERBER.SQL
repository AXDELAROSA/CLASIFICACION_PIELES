
-- ////////////////////////////////////////////////////////////// 
USE DATA_02Pruebas

/*
--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317
*/



SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	LTRIM(RTRIM(PLOT)) IN ('108011')
--and HIDESLIN_SQL.fileno = '210310181706T1000002'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
----AND
 --PCOLOR = 'FCPRHL1'
 ORDER BY HIDESLIN_SQL.HIDE ASC

SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '108021'  AND FILE_NO = '210402193455T1000001'

--UPDATE [TICKET_A_IMPORTAR] 
--SET LOTE = '108021'
--WHERE lote = '10802/2'  AND FILE_NO = '210402193455T1000001'

SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) = '108011' ORDER BY ID DESC 

 SELECT * FROM HIDESHDR_SQL WHERE PLOT = '34341' --AND status = 'MIT'

SELECT * --SUM(SQF) 
FROM  HIDESLIN_SQL WHERE FILENO IN ('210401065016T1000001') --AND PRINTED = 1 

--UPDATE  HIDESLIN_SQL 
--SET PRINTED = 0
--WHERE FILENO IN ('210401065016T1000001')

SELECT *
FROM RP_SC
WHERE
LTRIM(RTRIM(LOT)) = ('34591')
--AND convert(int, LTRIM(RTRIM(hide))) IN (1105, 67, 192, 1438, 1402, 1180, 952, 945, 32)
and convert(int, LTRIM(RTRIM(hide))) between 557 and 659
--AND SQF = '36.90'
ORDER  BY HIDE asc

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --(FOLIO_ORIGEN = 3795010 OR  FOLIO_DESTINO = 3795010 )
--(ORDEN_ORIGEN = 26245 OR  ORDEN_DESTIDO = 26245 )
--AND 
LOTE IN (750121)    
AND          
PIEL   IN (223, 234)
--PIEL  BETWEEN 557 and 659
AND PIEL_LOG.K_TIPO_PIEL_LOG IN (8)
--AND USUARIO = 'alondrah'
ORDER BY k_piel_log DESC

--DELETE PIEL_LOG WHERE K_PIEL_LOG IN (1360325
--,1360323)

SELECT * FROM cccuthst_sql WHERE LTRIM(RTRIM(LOTNO)) = '034441' 
AND hideno = '0763' order by hideno

SELECT * FROM RP_SC WHERE LOT = '34441' --AND CONVERT(DATE,CDATE) = CONVERT(DATE, GETDATE())
ORDER BY HIDE
SELECT * FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788982

SELECT *
FROM RP_SC
WHERE	TAGNO IN (3818527, 3818664)
--and convert(int, LTRIM(RTRIM(hide))) between 189 and 196
ORDER  BY HIDE

SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('106771')), 2, 6)  

SELECT * FROM RP_FOLIOS WHERE jobno  = '24503'

SELECT *  FROM ccjobhdr_sql WHERE JOBNO = '27504'

--UPDATE ccjobhdr_sql 
--SET folio = 3818527
--WHERE jobno = (27431)

--SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)  

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
