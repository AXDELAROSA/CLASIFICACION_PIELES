
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('34171')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (149)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '3481/2' --AND L_BORRADO = 0  AND FILE_NO in (  '210601182836T1000001')

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '3481/2' AND L_BORRADO = 0  --AND FILE_NO in (  '210601182836T1000001')
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '34812'
	--WHERE lote = '3481/2' AND L_BORRADO = 0  --AND FILE_NO in (  '210601182836T1000001')

	SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '108411') order by ID
	
	SELECT * FROM HIDESHDR_SQL WHERE PLOT = ('900071')-- AND  FILENO IN ('20210421152800') 
	ORDER BY PLOT DESC
			
	SELECT * --SUM(SQF) 
	FROM  HIDESLIN_SQL WHERE FILENO IN ( '210108120942T1000001' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ('210108120942T1000001')

	SELECT *
	FROM RP_SC
	WHERE 
	--COLOUR = 'FWLNPX7' 
	--AND
	LOT = '450181'
	--and movement = 'mhi'
	AND convert(int, LTRIM(RTRIM(hide)))  IN (422, 488, 489, 485, 486, 493, 494, 491, 492)
	--and convert(int, LTRIM(RTRIM(hide))) between 426 and 604
	ORDER  BY HIDE asc
	---3827585

	SELECT  LOT, HIDE,count(*) FROM RP_SC 
	WHERE  --LTRIM(RTRIM(COLOUR)) = 'FWLNPX7'
		LOT = '34011'
	GROUP BY  LOT, HIDE 
	HAVING COUNT(*)>1
		
	SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
	FROM PIEL_LOG 
	INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE  ( FOLIO_ORIGEN = 3802010 OR  FOLIO_DESTINO = 3802010 )
	--(ORDEN_ORIGEN = 30195 OR  ORDEN_DESTIDO = 30195 )
	--LOCACION_ORIGEN = 'MQU' AND LOCACION_DESTINO = 'MQU'
	--AND 
	--LOTE IN (402522)    
	--AND          
	--PIEL   IN (73)
	----PIEL  BETWEEN 217 and 218
	--AND 
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (13)
	--AND usuario = 'ANAG'
	ORDER BY k_piel_log DESC
	
	SELECT * FROM TIPO_PIEL_LOG

	SELECT * FROM RP_SC_PRT

	SELECT * FROM RP_SC WHERE TAGNO IN ( 3802010) ORDER BY TAGNO, HIDE

	SELECT * FROM RP_Folios WHERE jobno IN ('31147')

	SELECT * FROM RP_Folios WHERE TAG = 3828374

	SELECT * FROM pearl_log (NOLOCK) WHERE jobno = '31147' order by ckey

	SELECT * FROM ccjoblin_sql WHERE JOBNO = '31147' ORDER BY col_key

	SELECT * FROM ccjobhdr_sql WHERE JOBNO in ( '31147', '31145' )
	
	SELECT * FROM cccuthst_sql WHERE --jobno IN ('31450')
	--AND 
	LTRIM(RTRIM(LOTNO)) = '034171' 
	AND hideno IN (	'0149')
	order by hideno		

	--SELECT  '         ' + '4' + SUBSTRING(Ltrim(Rtrim(450151)), 2, 6)  
	
	SELECT * FROM	IMLSMST_SQL	
	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('031581')

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('MSL')

	SELECT TOP 100 * FROM IMINVTRX_SQL ORDER BY A4GLIdentity DESC

	SELECT * FROM IMLSTRX_SQL WHERE ord_no = 05390374 
	
	--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
	--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '33561', 6) )
	--DECLARE @VP_TURNO	VARCHAR(5) = '0'
	
	--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
	--										-- ===========================
	--										'00000', '0000', '1', @VP_FECHA,
	--										-- ===========================
	--										@VP_HORA, @VP_FECHA, 0, 'FWSPAX7', 
	--										-- ===========================
	--										@VP_LOTE_CON_ESPACIO, '0021','30.60',
	--										-- ===========================
	--										'00000', '', '00000', '00000',
	--										'00000', '00000', '00000', '00000', '00000',
	--										-- ===========================
	--										0, 0, 0, 0,
	--										-- ===========================
	--																	1, 0, 'P', '', '', 'FRANCISCOE', 'IT-10'



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
