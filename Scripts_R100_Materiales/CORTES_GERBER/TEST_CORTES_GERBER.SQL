
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

-- BASE 3798262

SELECT *  FROM ccjobhdr_sql 
WHERE datecreated < 20210111 
AND status = 'P'
AND machine LIKE 'T%'
AND INSTRUCT1 = ''
AND JOBNO IN (SELECT JOBNO FROM CCJOBLIN_SQL)
AND colourdesc NOT LIKE 'U%'
ORDER BY MACHINE, datecreated ASC
--jobno = '21928'

SELECT * FROM CCJOBLIN_SQL WHERE jobno = '85173 '
SELECT * FROM  RP_FOLIOS WHERE jobno = '21928'

SELECT * FROM RP_SC WHERE TAGNO IN (3805837, 3806017)

SELECT * FROM  RP_SC_FOLIO_STATUS_XX WHERE HIDE = '0092' and LOT = '105721'

SELECT  * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797941 or FOLIO_DESTINO = 3797941

SELECT * FROM COLORES_CONTROLADOS WHERE COLOR LIKE 'FG%'

SELECT * FROM  RP_FOLIOS WHERE TAG = 3798026

SELECT  TOP 100 * FROM cccuthst_sql WHERE JOBNO = '20880'  AND HIDENO IN ('0008', '0009', '0188', '0199', '0193', '0173', '0192')

SELECT '         ' + '1' + SUBSTRING(Ltrim(Rtrim('         067651')), 2, 6) 

SELECT * FROM RP_SC_TEMP WHERE TAGNO = 3803394

SELECT * FROM RP_SC WHERE	LTRIM(RTRIM(LOT)) IN ('750031') 
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND COLOUR = 'FYPATX7'
 ORDER BY COLOUR, HIDE asc


SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	LTRIM(RTRIM(PLOT)) IN ('401671')
--and HIDESLIN_SQL.fileno = '20210202170107'
--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) BETWEEN 141 AND 167
--AND PCOLOR = 'FYPATX7'
 ORDER BY HIDESLIN_SQL.HIDE ASC

SELECT * FROM  HIDESLIN_SQL WHERE FILENO IN ('20210202170107') --AND PRINTED = 1 
ORDER BY HIDE

SELECT * FROM HIDESHDR_SQL
WHERE FILENO IN ('20210202170107' )

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3799533 or FOLIO_DESTINO = 3799533

SELECT * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO =3799707 AND HIDE = '0099'

SELECT * FROM  RP_FOLIOS WHERE TAG = 3806452

SELECT * FROM RP_SC WHERE LOT = '' AND HIDE = '0064'

SELECT *  FROM ccjobhdr_sql WHERE jobno = '21666'

--SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         106771')), 2, 6)
 
SELECT * FROM RP_SC WHERE --LOT = '34062'              
--AND HIDE IN (552, 553)
--and 
TAGNO = 3808604  ORDER BY hide


SELECT *  FROM cccuthst_sql WHERE jobno = '21666' AND HIDENO = '0099'  AND LOTNO = '         067821' ORDER BY hideno

SELECT * FROM PEARL_LOG WHERE JOBNO = '22343'

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --FOLIO_ORIGEN = 3808604 OR FOLIO_DESTINO = 3808604 
--AND 
--K_USUARIO_ALTA = 136
--AND 
LOTE IN (401671)              
AND PIEL IN (99)
--and color = 'fwlcpt3'
--AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5)
--AND ORDEN_DESTIDO = '22873'
ORDER BY K_PIEL_LOG DESC


SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5031218, 5107455    ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5031218, 5107455 )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * 
from IMINVTRX_SQL 
where  item_no = 'FWLCPX7           '   /*and loc = 't13' */ and trx_dt>='20201023' --and doc_type = 'T' --AND SEQ_NO <> 0
and doc_ord_no = '19407'
--ord_no in ( '04855875')
order by trx_dt,trx_tm, ORD_NO desc
--order by ord_no asc


/*
SELECT * FROM cccuthst_sql WHERE JOBNO = '00000'  

--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '401451', 6) )
--DECLARE @VP_TURNO	VARCHAR(5) = '0'

--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
--										-- ===========================
--										'00000', '0000', '1', @VP_FECHA,
--										-- ===========================
--										@VP_HORA, @VP_FECHA, 0, 'FWLPAX7', 
--										-- ===========================
--										@VP_LOTE_CON_ESPACIO, '0090','009.7000',
--										-- ===========================
--										'00000', '', '00000', '00000',
--										'00000', '00000', '00000', '00000', '00000',
--										-- ===========================
--										0, 0, 0, 0,
--										-- ===========================
--																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'

*/

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
