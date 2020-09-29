
-- ////////////////////////////////////////////////////////////// 
USE DATA_02

--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
--		)
--SELECT TOP 1 GETDATE(),'FWLCPX7','401131','0037','45.10',3793137,'C','MHI'
--FROM RP_SC WHERE TAGNO = 3794204 AND HIDE  = '0065'


SELECT * FROM IMITMIDX_SQL WHERE LTRIM(RTRIM(item_no)) = 'FMCKTX7'

SELECT * FROM ARCUSFIL_SQL WHERE LTRIM(RTRIM(cus_no)) = 'FMCKTX7'

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION]
where FOLIO_ORIGEN = 3794204
order by [K_PIEL_A_TRANSFERIR_TRANSACCION] desc

SELECT  COUNT(K_PIEL_A_TRANSFERIR) 
					FROM [PIEL_A_TRANSFERIR]
					WHERE [K_PIEL_A_TRANSFERIR_TRANSACCION] = 958
					AND CONVERT(DECIMAL(13,2),SQF_ENVIAR) = CONVERT(DECIMAL(13,2),SQF_RECIBIR) 

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION]

SELECT * FROM RP_SC WHERE MOVEMENT LIKE 'G%' ORDER BY TAGNO ASC


SELECT * FROM RP_SC WHERE COLOUR IN (	SELECT COLOR FROM COLORES_CONTROLADOS) AND TYPE = 'D' 

SELECT * FROM RP_SC WHERE TAGNO = 3795978

--LTRIM(RTRIM(COLOUR))= 'FWLCPX7'
--AND 
--LTRIM(RTRIM(LOT)) = '401131'
--AND LTRIM(RTRIM(HIDE)) = '0063'

--SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE --TAGNO = 3794061
----LTRIM(RTRIM(COLOUR))= 'FWLCPX7'
----AND 
--LTRIM(RTRIM(LOT)) = '401131'
--AND LTRIM(RTRIM(HIDE)) = '0063'

select * from HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '401121' 
 AND LTRIM(RTRIM(HIDE))  IN ('0045')
 AND PCOLOR = 'FWLNPA5'
 															
SELECT  * FROM cccuthst_sql 
WHERE LTRIM(RTRIM(LOTNO)) = '033441'
AND LTRIM(RTRIM(HIDENO)) = '0442'


SELECT * FROM RP_FOLIOS WHERE TAG IN (3795852)

SELECT * FROM RP_SC 
WHERE LTRIM(RTRIM(COLOUR)) = 'FWSCPX7' AND LTRIM(RTRIM(LOT)) = '501031' AND
LTRIM(RTRIM(HIDE)) IN (SELECT HIDE FROM RP_SC WHERE  LTRIM(RTRIM(COLOUR)) = 'FWLCPX7'  AND LOT = '501031' AND TAGNO = 3795212 )

SELECT * FROM RP_SC WHERE TAGNO = 3795852 ORDER BY HIDE ASC
/*
WLNPA5    LOTE  401121  
                      # 0045 
                  SQF 34.60    CAMBIA  A  21.00 
 
FCWLCPX7    LOTE  401131 
                            #0032 
                          SQF   32.25  CAMBIA  A   31.40 
*/

SELECT  * FROM CCJOBHDR_SQL WHERE JOBNO IN ( '16558 ')

										
SELECT  * FROM cccuthst_sql 
WHERE LTRIM(RTRIM(LOTNO)) = '401131'
AND LTRIM(RTRIM(HIDENO)) = '0032'

SELECT * FROM RP_SC WHERE  /* LTRIM(RTRIM(COLOUR)) = 'FWLNPA5'  AND*/ LOT = '401201' AND HIDE = '0393'

SELECT * FROM RP_SC WHERE  LTRIM(RTRIM(COLOUR)) = 'FWLCPX7'  AND LOT = '401131' AND HIDE = '0032'
--UPDATE RP_SC
--	SET SQF =  0.85
--WHERE ID = 5031858
 --0.8500

SELECT D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE --FOLIO_ORIGEN = 3793314 OR FOLIO_DESTINO = 3793314   
LOTE = 401131
 AND PIEL = 32
ORDER BY K_PIEL_LOG ASC

SELECT top 100 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ('4862719 ', '4862612 ' ) order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ('4862719  ', '4862612 ' )  order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * --ord_no,lev_no,doc_type, item_no, loc,quantity,doc_ord_no,trx_dt,trx_tm, user_name, A4GLIdentity
from IMINVTRX_SQL 
where  item_no = 'FWLCPX7           '   and loc = 'GT2' and trx_dt='20200928' --and doc_type = 'T' AND SEQ_NO <> 0
and doc_ord_no = '16340'
--ord_no in ( '04855875')
order by trx_dt,trx_tm, ORD_NO desc
--order by ord_no asc

--UPDATE IMINVTRX_SQL
--set doc_ord_no = '15003'
--where A4GLIdentity = 59795366


/*

DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '401131', 6) )
DECLARE @VP_TURNO	VARCHAR(5) = '0'

EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
										-- ===========================
										'00000', '0000', '1', @VP_FECHA,
										-- ===========================
										@VP_HORA, @VP_FECHA, 0, 'FWLCPX7', 
										-- ===========================
										@VP_LOTE_CON_ESPACIO, '0032', 9.3500,
										-- ===========================
										'00000', '', '00000', '00000',
										'00000', '00000', '00000', '00000', '00000',
										-- ===========================
										0, 0, 0, 0,
										-- ===========================
																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'
*/
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
