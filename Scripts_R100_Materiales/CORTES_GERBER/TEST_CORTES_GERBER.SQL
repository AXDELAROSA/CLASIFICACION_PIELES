
-- ////////////////////////////////////////////////////////////// 
USE DATA_02Pruebas

/*
--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317
*/

SELECT * FROM IncInsp_sql ORDER BY ID DESC 

SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	--LTRIM(RTRIM(PLOT)) IN ('34441')
--and HIDESLIN_SQL.fileno = '210310181706T1000002'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
----AND
 PCOLOR = 'FCPRHL1'
 ORDER BY HIDESLIN_SQL.HIDE ASC

 SELECT * FROM COLORES_CONTROLADOS
 
	SELECT SUM (SQF)--* 
	FROM [TICKET_A_IMPORTAR] WHERE lote = 107962 AND FILE_NO = '210325171422T1000002'

 SELECT * FROM HIDESHDR_SQL WHERE PLOT = '107961' AND FILENO IN ('210322191702T1000002')

SELECT * --SUM(SQF) 
FROM  HIDESLIN_SQL WHERE FILENO IN ('210322191702T1000002') --AND PRINTED = 1 
--AND SQF = '36.90'
--ORDER BY HIDE

--UPDATE  HIDESLIN_SQL 
--SET PRINTED = 0
--WHERE FILENO IN ('210322191702T1000002')

SELECT *
FROM RP_SC
WHERE
LTRIM(RTRIM(LOT)) = ('107961')
and convert(int, LTRIM(RTRIM(hide))) between 1 and 133
--AND SQF = '36.90'
ORDER  BY HIDE DESC

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --(FOLIO_ORIGEN = 3818507 OR  FOLIO_DESTINO = 3818507 )
--(ORDEN_ORIGEN = 26245 OR  ORDEN_DESTIDO = 26245 )
--AND 
LOTE IN (402201)    
AND          
PIEL   IN (525, 526, 527, 528, 529, 530, 531, 532)
--PIEL  BETWEEN 0441 AND 479
AND PIEL_LOG.K_TIPO_PIEL_LOG IN (8)
ORDER BY k_piel_log DESC

--DELETE PIEL_LOG WHERE K_PIEL_LOG IN ( 1514964
--,1514963
--,1514962
--,1514961
--,1514960
--,1514959
--,1514958
--,1514957 )

SELECT *
FROM RP_SC
WHERE	TAGNO = 3812844
--and convert(int, LTRIM(RTRIM(hide))) between 189 and 196
ORDER  BY HIDE

SELECT * FROM RP_FOLIOS WHERE jobno  = '24954'

SELECT *  FROM ccjobhdr_sql WHERE jobno IN (24954, 25077)

SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)  

SELECT * FROM cccuthst_sql WHERE jobno = '20397' order by hideno


SELECT * FROM TIPO_PIEL_LOG

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
