
-- ////////////////////////////////////////////////////////////// 
USE DATA_02

--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317

SELECT  * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797941 or FOLIO_DESTINO = 3797941

SELECT * FROM COLORES_CONTROLADOS

SELECT * FROM RP_SC WHERE TAGNO  = 3797972 ORDER BY HIDE

SELECT * FROM RP_SC WHERE LOT= '33641'  AND HIDE IN ('0767', '0755', '0753', '0763', '0754', '0762', '0781', '0757', '0759', '0575'  ) ORDER BY HIDE

 SELECT * FROM ccjobhdr_sql WHERE jobno = '17342'

select * from HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '105922' 
 AND LTRIM(RTRIM(HIDE))  IN ('0018')
 --AND PCOLOR = 'FYPATX7'
 ORDER BY HIDE ASC
 															
SELECT  * FROM cccuthst_sql 
WHERE --JOBNO = '17733'
 LTRIM(RTRIM(LOTNO)) = '105922'
AND LTRIM(RTRIM(HIDENO)) IN ('0018')
ORDER BY hideno

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION] where folio_origen = 3797972 or FOLIO_DESTINO = 3797972

SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --FOLIO_ORIGEN = 3797972 OR FOLIO_DESTINO = 3797972 
--AND 
LOTE = 33641
 AND PIEL = 0575
ORDER BY K_PIEL_LOG asc


SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (4877021,4877022 ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN (4877021,4877022 )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * 
from IMINVTRX_SQL 
where  item_no = 'FMCKTX7           '   and loc = 'T17' and trx_dt>='20201020' --and doc_type = 'T' AND SEQ_NO <> 0
--and doc_ord_no = '17084'
--ord_no in ( '04855875')
order by trx_dt,trx_tm, ORD_NO desc
--order by ord_no asc


/*
DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '401031', 6) )
DECLARE @VP_TURNO	VARCHAR(5) = '0'

EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
										-- ===========================
										'00000', '0000', '1', @VP_FECHA,
										-- ===========================
										@VP_HORA, @VP_FECHA, 0, 'FWLNPX7', 
										-- ===========================
										@VP_LOTE_CON_ESPACIO, '0128','14.4000',
										-- ===========================
										'00000', '', '00000', '00000',
										'00000', '00000', '00000', '00000', '00000',
										-- ===========================
										0, 0, 0, 0,
										-- ===========================
																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'
*/


/* PIELES BORRADAS POR ERROR 
SELECT * FROM RP_SC WHERE HIDE IN ( SELECT HIDE FROM RP_SC WHERE TAGNO = 3796551)
AND COLOUR = 'FWLPAX7' AND LOT = '401251'
ORDER BY HIDE 

*/
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
