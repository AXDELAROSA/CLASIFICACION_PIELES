
--	USE DATA_02
SELECT TOP 1000 D_TIPO_PIEL_LOG,usuario,
PIEL_LOG.*  
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG=TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
WHERE ORDEN_ORIGEN = 13600 or ORDEN_DESTIDO = 13620
and FOLIO_ORIGEN = 3791088
--PIEL = 345
--AND LOTE = 32931
--AND COLOR = 'FMCKTX7' 
--ORDER BY F_ALTA asc

SELECT * FROM  RP_SC WHERE TAGNO IN (3791158)

SELECT * FROM	RP_FOLIOS WHERE TAG IN (3791158)

--WHERE HIDE  IN (0764)
--AND LOT = '105081'
--AND COLOUR = 'FCPRDX9'

/*
UPDATE RP_SC
	SET MOVEMENT = 'T45'
WHERE TAGNO = 3791158
*/

/*
UPDATE RP_FOLIOS
	SET JOBNO = '12867',
	MACHINE = 'Table 61'
WHERE TAG  = 3789966
AND COLOUR = 'FMCKTX7' 
*/
	USE DATA_02Pruebas

select * from HIDESHDR_SQL   
 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
AND	LTRIM(RTRIM(PLOT)) = '32931' 
 AND LTRIM(RTRIM(HIDE))   IN ('0345')
 AND PCOLOR = 'FMCKTX7'


SELECT *
	FROM cccuthst_sql 
	WHERE LTRIM(RTRIM(COLOUR)) = 'FCPRDX9'   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim('105081')), 6) 
	AND LTRIM(RTRIM(hideno))   = '0764'
	--AND	LTRIM(RTRIM(JOBNO))   = '11551'

SELECT * FROM ccjobhdr_sql WHERE folio = '3791158'
SELECT * FROM ccjobhdr_sql WHERE jobno = '12867'
SELECT * FROM ccjobhdr_sql WHERE jobno = '12851'

SELECT top 10 * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '04718701',
'04716177',
'04713298',
'04713839',
'04711148',
'04711149',
'04711307')

SELECT top 10 * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4718701',
'4716177',
'4713298',
'4713839',
'4711148',
'4711149',
'4711307')

select top 1000 * --ord_no,lev_no,doc_type, item_no, loc,quantity,doc_ord_no,trx_dt,trx_tm, user_name, A4GLIdentity
from IMINVTRX_SQL 
where  item_no = 'FCPRDX9        '    and loc = 'T10' and trx_dt>='20200129'
and doc_ord_no = '13222'
--and ord_no in ( '4642651','4642598')
order by trx_dt desc
--order by ord_no asc

/*
original entraron 1530.3 y se le restaron 65.4 orden 13222

UPDATE IMLSTRX_SQL
	SET trx_qty= trx_qty - 65.40
WHERE ord_no = '04711148' 
AND LEV_NO = 1
and ser_lot_no = '         105131'

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