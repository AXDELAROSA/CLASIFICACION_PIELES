
-- ////////////////////////////////////////////////////////////// 
USE DATA_02

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
SELECT * FROM  RP_FOLIOS WHERE TAG = 3798340

SELECT * FROM  RP_SC_FOLIO_STATUS_XX WHERE HIDE = '0092' and LOT = '105721'

SELECT  * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797941 or FOLIO_DESTINO = 3797941

SELECT * FROM COLORES_CONTROLADOS WHERE COLOR LIKE 'FG%'

SELECT * FROM  RP_FOLIOS WHERE TAG = 3798340

SELECT * FROM  RP_FOLIOS WHERE jobno = '18123'

SELECT * FROM ccjobhdr_sql WHERE jobno = '18137'

SELECT * FROM RP_SC WHERE TAGNO = 3798607 ORDER BY HIDE

SELECT  TOP 100 * FROM cccuthst_sql WHERE JOBNO = '18123'  ORDER BY HIDENO

SELECT * FROM HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '67211' 
 --AND LTRIM(RTRIM(HIDE))  IN ('0200')
 --AND PCOLOR = 'FMCKVT9'
 --AND HIDESHDR_SQL.FILENO IN ( '20201027172310', '20201027192801')
 ORDER BY HIDE ASC
 	
select tagno,colour,( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOT)),2, 10) ELSE LTRIM(RTRIM(LOT)) END ) AS LOT,count(*) as count 
from rp_sc_temp where tagno <> 1
group by tagno,COLOuR,( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOT)),2, 10) ELSE LTRIM(RTRIM(LOT)) END ) 
--order by tagno,colour,( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOT)),2, 10) ELSE LTRIM(RTRIM(LOT)) END ) 

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797972 or FOLIO_DESTINO = 3797972

SELECT * FROM TIPO_PIEL_LOG

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
--WHERE -- FOLIO_ORIGEN = 3798443 OR FOLIO_DESTINO = 3798443 
--AND 
--LOTE = 33411 
-- AND PIEL = 206
ORDER BY K_PIEL_LOG DESC

SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (04991858, 4991859   ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (04991858, 4991859   )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * 
from IMINVTRX_SQL 
where  item_no = 'FMCKTX7           '   and loc = 'T17' and trx_dt>='20201103' and doc_type = 'T' --AND SEQ_NO <> 0
and doc_ord_no = '18032'
--ord_no in ( '04855875')
order by trx_dt,trx_tm, ORD_NO desc
--order by ord_no asc

/*
--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '106221', 6) )
--DECLARE @VP_TURNO	VARCHAR(5) = '0'

--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
--										-- ===========================
--										'17343', '0000', '1', @VP_FECHA,
--										-- ===========================
--										@VP_HORA, @VP_FECHA, 0, 'FCNPJRR', 
--										-- ===========================
--										@VP_LOTE_CON_ESPACIO, '0023','39.00',
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
