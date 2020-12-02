
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
SELECT * FROM  RP_FOLIOS WHERE TAG = 37997215

SELECT * FROM  RP_SC_FOLIO_STATUS_XX WHERE HIDE = '0092' and LOT = '105721'

SELECT  * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797941 or FOLIO_DESTINO = 3797941

SELECT * FROM COLORES_CONTROLADOS WHERE COLOR LIKE 'FG%'

SELECT * FROM  RP_FOLIOS WHERE TAG = 3798026

SELECT  TOP 100 * FROM cccuthst_sql WHERE JOBNO = '18523'  

SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         105731')), 2, 6) 

SELECT * FROM RP_SC WHERE COLOUR = 'FCNPWU9' AND LOT = '105731' AND HIDE IN ('0035', '0038', '0019', '0086', '0025', '0081') ORDER BY HIDE

SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
WHERE	LTRIM(RTRIM(PLOT)) IN ('33851') --, '033711')
AND  HIDESLIN_SQL.HIDE IN ('0792')
 --AND PCOLOR = 'FMCKTX7'
 --AND HIDESHDR_SQL.FILENO IN ( '20201027172310', '20201027192801')
 ORDER BY HIDESLIN_SQL.HIDE ASC

SELECT * FROM  HIDESLIN_SQL WHERE FILENO = '201111102344T1000001' AND PRINTED = 0 ORDER BY HIDE ASC

SELECT * FROM HIDESHDR_SQL
WHERE FILENO IN ('20201105082615' )

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3799533 or FOLIO_DESTINO = 3799533

SELECT * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM TIPO_PIEL_LOG

SELECT * FROM RP_SC WHERE LEN(LTRIM(RTRIM(SQF))) < 4
AND COLOUR IN (SELECT COLOR FROM COLORES_CONTROLADOS)

SELECT * FROM  RP_FOLIOS WHERE JOBNO = '19157'

SELECT * FROM RP_SC WHERE LOT = '33901' AND HIDE = '0516'

SELECT *  FROM ccjobhdr_sql WHERE jobno = '19157'

SELECT * FROM cccuthst_sql WHERE jobno = '19157' --and hideno = '0647' order by linenum asc

SELECT top 100  * FROM cccuthst_sql order by colkey asc


SELECT * FROM RP_SC WHERE LOT IN ('401501','33901') AND HIDE IN ( '0516', '0494', '0068' )

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --FOLIO_ORIGEN = 3800663 OR FOLIO_DESTINO = 3800663 
--AND 
LOTE = 700151         
AND PIEL IN (282)
--and color = 'FMCKTX7'
--AND D_TIPO_PIEL_LOG = 'DEVOLUCION'
ORDER BY  K_PIEL_LOG ASC

SELECT TOP 100 * FROM pearl_log WHERE JOBNO = '3800386' --HIDENO = '0089' 
ORDER BY  cdate DESC

SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5026175   ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (5026175 )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * 
from IMINVTRX_SQL 
where  item_no = 'fDnpdx9           '   /*and loc = 't13' */ and trx_dt>='20201123' --and doc_type = 'T' --AND SEQ_NO <> 0
--and doc_ord_no = '19037'
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
