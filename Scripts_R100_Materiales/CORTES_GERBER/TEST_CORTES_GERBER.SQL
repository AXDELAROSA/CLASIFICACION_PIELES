
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('32911')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (119)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '10842/2' AND L_BORRADO = 0 -- AND FILE_NO in (  '210520170913T1000001', '210520180712T1000002', '210520183155T1000001', '210520185401T1000002' )

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '10842/2' AND L_BORRADO = 0 --  AND FILE_NO in (  '210520170913T1000001', '210520180712T1000002', '210520183155T1000001', '210520185401T1000002' )
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '108422'
	--WHERE lote = '10842/2' AND L_BORRADO = 0 
	
	SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '034711',  '003471') order by ID
	
	SELECT TOP 1000 * FROM HIDESHDR_SQL WHERE PLOT = ('32331') AND  FILENO IN ('20210421152800') 
	ORDER BY PLOT DESC

	DELETE  HIDESHDR_SQL WHERE PLOT = ('32331') AND  FILENO IN ('20210421152800') 
		
	SELECT * --SUM(SQF) 
	FROM  HIDESLIN_SQL WHERE FILENO IN ( '20210421152800' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ('20210505164147')

	SELECT *
	FROM RP_SC
	WHERE 
	--COLOUR = 'FWLNPX7' 
	--AND
	LOT = '32331'
	and movement = 'mhi'
	--AND convert(int, LTRIM(RTRIM(hide)))  IN (1602)
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
	WHERE -- ( FOLIO_ORIGEN = 3829794 OR  FOLIO_DESTINO = 3829794 )
	--(ORDEN_ORIGEN = 30195 OR  ORDEN_DESTIDO = 30195 )
	--LOCACION_ORIGEN = 'MQU' AND LOCACION_DESTINO = 'MQU'
	--AND 
	LOTE IN (034311)    
	AND          
	PIEL   IN (SELECT HIDE FROM RP_SC WHERE TAGNO = 3830246)
	----PIEL  BETWEEN 217 and 218
	AND 
	PIEL_LOG.K_TIPO_PIEL_LOG IN (11)
	ORDER BY k_piel_log DESC
	
	SELECT * FROM TIPO_PIEL_LOG

	SELECT * FROM RP_SC_PRT

	SELECT * FROM RP_SC WHERE TAGNO IN ( 3829794) ORDER BY TAGNO, HIDE

	SELECT * FROM RP_Folios WHERE TAG IN (3812387)

	SELECT * FROM pearl_log (NOLOCK) WHERE jobno = '28723' order by ckey

	SELECT * FROM ccjoblin_sql WHERE JOBNO = '29990' ORDER BY col_key

	SELECT * FROM ccjobhdr_sql WHERE JOBNO in ( '26990', '29990' )
	
	SELECT * FROM cccuthst_sql WHERE --jobno IN ('31269')
	--AND 
	LTRIM(RTRIM(LOTNO)) = '032331' 
	AND hideno IN (	'0390', '1602')
	order by hideno		

	--SELECT  '         ' + '0' + SUBSTRING(Ltrim(Rtrim(lotno)), 2, 6)  
	
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
