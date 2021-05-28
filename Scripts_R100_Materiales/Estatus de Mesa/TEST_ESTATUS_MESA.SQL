
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
	FROM PIEL_LOG 
	INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE  ( FOLIO_ORIGEN = 3826452 OR  FOLIO_DESTINO = 3826452 )
	--(ORDEN_ORIGEN = 30195 OR  ORDEN_DESTIDO = 30195 )
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (13)
	ORDER BY k_piel_log DESC

	

	SELECT * FROM pearl_log (NOLOCK) WHERE jobno = '26778' order by ckey

	SELECT *  FROM ccjobhdr_sql (NOLOCK) WHERE JOBNO IN ('30543')
	SELECT *  FROM CCCUTHST_SQL (NOLOCK) WHERE JOBNO IN ('30543') order by hideno

	SELECT * FROM RP_Folios WHERE TAG IN (3829403)
	SELECT * FROM RP_SC WHERE TAGNO  in (3829403)  order by hide
	select * from RP_SC where ISNUMERIC(LTRIM(RTRIM(SQF))) = 0

--INSERT INTO RP_SC( 
--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE]
--		)
--SELECT GETDATE(), 'FCPRDX9', '', '', '', 3829403, 'C'

	SELECT *  FROM ccjobhdr_sql (NOLOCK) WHERE JOBNO IN ('31079')
	SELECT *  FROM CCCUTHST_SQL (NOLOCK) WHERE JOBNO IN ('31079') order by hideno
	SELECT * FROM RP_SC /*_FOLIO_STATUS_XX*/ WHERE TAGNO  in (3828081)  order by hide

	SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
	FROM PIEL_LOG 
	INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE  ( FOLIO_ORIGEN = 3826452 OR  FOLIO_DESTINO = 3826452 )
	--(ORDEN_ORIGEN = 30195 OR  ORDEN_DESTIDO = 30195 )
	--AND 
	--LOTE IN (68291)    
	--AND          
	--PIEL   IN (382)
	----PIEL  BETWEEN 217 and 218
	AND 
	PIEL_LOG.K_TIPO_PIEL_LOG IN (13)
	ORDER BY k_piel_log DESC
	--FWSPAX7   
	

	SELECT *  FROM ccjoblin_sql (NOLOCK) WHERE JOBNO IN ('26778')
	SELECT *  FROM ccjobhdr_sql (NOLOCK) WHERE JOBNO IN ('30474')
	SELECT *  FROM ccjobhdr_sql (NOLOCK) WHERE CONVERT(INT, JOBNO) BETWEEN 30470 AND 30550 AND STATUS = 'P'

	SELECT *  FROM ccjobhdr_sql (NOLOCK) WHERE INSTRUCT2 = 'A' AND CONVERT(INT, JOBNO) BETWEEN 30470 AND 30550 AND STATUS = 'P'

	--UPDATE ccjobhdr_sql 
	--SET INSTRUCT2 = ''
	--WHERE INSTRUCT2 = 'A' AND CONVERT(INT, JOBNO) BETWEEN 30470 AND 30550 AND STATUS = 'P'

	--UPDATE ccjobhdr_sql
	--SET INSTRUCT2 = 'A'
	--WHERE CONVERT(INT, JOBNO) BETWEEN 30470 AND 30550 AND STATUS = 'P'
	
	--UPDATE ccjobhdr_sql 
	--SET INSTRUCT2 = ''
	--WHERE JOBNO IN ('31079')

	SELECT *  FROM ccjobhdr_sql WHERE LTRIM(RTRIM(comments)) <> ''

	SELECT * FROM cccuthst_sql WHERE --jobno IN ('30943')
	--AND 
	LTRIM(RTRIM(LOTNO)) = '033741' 
	AND hideno IN (	'0088'	)
	ORDER BY hideno

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
