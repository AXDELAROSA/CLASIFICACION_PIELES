
-- ////////////////////////////////////////////////////////////// 
USE DATA_02Pruebas

SELECT * FROM IMITMIDX_SQL WHERE LTRIM(RTRIM(item_no)) = 'FMCKTX7'

SELECT * FROM ARCUSFIL_SQL WHERE LTRIM(RTRIM(cus_no)) = 'FMCKTX7'

SELECT * FROM RP_SC WHERE COLOUR = 'FNPJTX7   ' AND HIDE = '0123 ' AND LOT = '33471     '

SELECT * FROM RP_SC WHERE TAGNO = 3793506

SELECT * FROM RP_SC WHERE MOVEMENT = 'GT2'

SELECT TOP 100 * FROM RP_FOLIOS ORDER BY TAG DESC WHERE TAG = 3793219

SELECT * FROM ESTATUS_ORDEN

SELECT  * FROM cccuthst_sql WHERE cccuthst_sql.jobno = '00000' order by linenum

SELECT TOP 10 * FROM CCJOBHDR_SQL 	WHERE	JOBNO < '26379' ORDER BY JOBNO DESC

SELECT * FROM [PIEL_A_TRANSFERIR]

SELECT * FROM [PIEL_A_TRANSFERIR_TRANSACCION]

SELECT TOP 10 * FROM CCJOBHDR_SQL WHERE JOBNO = '11619'

SELECT * FROM RP_SC WHERE TAGNO = 3788389

SELECT * FROM RP_FOLIOS  WHERE TAG = 3788389

SELECT  * FROM cccuthst_sql WHERE cccuthst_sql.jobno = '11619'

SELECT top 10 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4454166', '4454167 ') order by trx_dt,trx_tm, ORD_NO desc

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4454166', '4454167 ') order by trx_dt,trx_tm, ORD_NO desc

select top 1000 * --ord_no,lev_no,doc_type, item_no, loc,quantity,doc_ord_no,trx_dt,trx_tm, user_name, A4GLIdentity
from IMINVTRX_SQL 
where  item_no = 'FMCKTX7        '    /*and loc = 'T61'*/ and trx_dt>='20200828' --and doc_type = 'T' AND SEQ_NO <> 0
--and doc_ord_no = '14905'
--and ord_no in ( '4642651','4642598')
order by trx_dt,trx_tm, ORD_NO desc
--order by ord_no asc


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
