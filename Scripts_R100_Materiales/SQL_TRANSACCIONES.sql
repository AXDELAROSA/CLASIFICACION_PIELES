
--	USE DATA_02
SELECT TOP 1000 D_TIPO_PIEL_LOG,usuario,
PIEL_LOG.*  
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG=TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE 
--ORDEN_ORIGEN = 13600 or ORDEN_DESTIDO = 13600
--and FOLIO_ORIGEN = 3791088
PIEL = 2031
AND LOTE = 33111
--AND COLOR = 'FMCKTX7' 
--ORDER BY K_PIEL_LOG asc

SELECT * FROM  RP_SC WHERE TAGNO IN (3791748) --AND LTRIM(RTRIM(HIDE)) = '2031'

SELECT * FROM	RP_FOLIOS WHERE TAG IN (3791748)

--WHERE HIDE  IN (0764)
--AND LOT = '105081'
--AND COLOUR = 'FCPRDX9'

/*
*/

/* 
*/
	USE DATA_02Pruebas

select * from HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '33101' 
 AND LTRIM(RTRIM(HIDE))   LIKE '101'--IN ('0345')
 AND PCOLOR = 'FMCKTX7'


SELECT *
	FROM cccuthst_sql 
	WHERE LTRIM(RTRIM(COLOUR)) = 'FMCKTX7'   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim('33111')), 6) 
	AND LTRIM(RTRIM(hideno))   = '2031'
	--AND	LTRIM(RTRIM(JOBNO))   = '11551'

	/*
	
*/

SELECT * FROM ccjobhdr_sql WHERE folio = '12338'
SELECT * FROM ccjobhdr_sql WHERE jobno = '13986'
SELECT * FROM ccjobhdr_sql WHERE jobno = '12851'

USE DATA_02
SELECT TOP 1000 D_TIPO_PIEL_LOG,usuario,
PIEL_LOG.*  
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG=TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE 
ORDEN_ORIGEN = 13600 --or ORDEN_DESTIDO = 13600

SELECT top 10 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4721463  ')

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '04720615 ','4720503 ')

select top 1000 * --ord_no,lev_no,doc_type, item_no, loc,quantity,doc_ord_no,trx_dt,trx_tm, user_name, A4GLIdentity
from IMINVTRX_SQL 
where  item_no = 'FMCKTX7        '    /*and loc = 'T45'*/ and trx_dt>='20200714'
and doc_ord_no = '13620'
--and ord_no in ( '4642651','4642598')
order by trx_dt, ORD_NO desc
--order by ord_no asc

/*

UPDATE IMINVTRX_SQL
	SET LOC= 'T45'
WHERE ord_no = '4721463' 
AND LEV_NO = 1

*/


/*
UPDATE IMINVTRX_SQL
	SET doc_ord_no= '12803'
WHERE ord_no = '4643540' 
and doc_type = 'T' 
and item_no = 'FMCKTX7        '    
and doc_ord_no = '12891'
and loc = 'T18' 
AND LEV_NO = 1
*/