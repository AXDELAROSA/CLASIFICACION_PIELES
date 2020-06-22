
--	USE DATA_02
SELECT TOP 1000 D_TIPO_PIEL_LOG,usuario,
PIEL_LOG.*  
FROM PIEL_LOG 
INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG=TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
--WHERE PIEL_LOG.K_TIPO_PIEL_LOG = 5 AND LOCACION_DESTINO = 'MHI' AND ORDEN_DESTIDO <> 0
ORDER BY F_ALTA desc


SELECT * FROM  RP_SC WHERE TAGNO  IN (3789388)

SELECT * FROM	RP_FOLIOS WHERE TAG IN (3789388)

/*
UPDATE RP_SC
	SET MOVEMENT = 'T39'
WHERE TAGNO  IN (3789388)
AND COLOUR = 'FMCKVT9'
*/
	USE DATA_02Pruebas

SELECT *
	FROM cccuthst_sql 
	WHERE LTRIM(RTRIM(COLOUR)) = 'FMCKTX7'   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim('33012')), 6) 
	AND LTRIM(RTRIM(hideno))   = '0482'
	AND	LTRIM(RTRIM(JOBNO))   = '11551'

SELECT * FROM IMLSTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4632691 ' )
SELECT * FROM IMINVTRX_SQL	WHERE LTRIM(RTRIM(ord_no)) IN ( '4632691 ' )

select * --ord_no,lev_no,doc_type, item_no, loc,quantity,doc_ord_no,trx_dt,trx_tm, user_name, A4GLIdentity
from IMINVTRX_SQL 
where doc_type = 'T' and item_no = 'FMCKTX7        '    /*and loc = 'T39'*/ and trx_dt>='20200618'
--and doc_ord_no = '00000'
--and ord_no in ( '4630052')
order by ord_no asc

/*
UPDATE IMINVTRX_SQL
	SET doc_ord_no= '00000'
WHERE ord_no = '4632691' 
and doc_type = 'T' 
and item_no = 'FMCKTX7        '    
and loc = 'T19' and trx_dt>='20200609'
*/