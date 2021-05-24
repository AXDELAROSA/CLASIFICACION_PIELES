
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('34011')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (17)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] 
	WHERE lote = '3474/3' AND L_BORRADO = 0  --AND FILE_NO in (  '210513090728T1000001', '210513092529T1000002', '210513115652T1000002' )

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '3474/3' AND L_BORRADO = 0  --AND FILE_NO in (  '210513090728T1000001', '210513092529T1000002', '210513115652T1000002' )
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '34743'
	--WHERE lote = '3474/3' AND L_BORRADO = 0   

	SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(Lot)) = '501011'  --Description = 'FMCKDX9' order by date desc
		
	SELECT TOP 1000 * FROM HIDESHDR_SQL WHERE PLOT IN ('68291') --AND  FILENO IN ('20210505164147') 
	ORDER BY PLOT DESC
		
	SELECT * --SUM(SQF) 
	FROM  HIDESLIN_SQL WHERE FILENO IN ( '210420112637T1000001' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 

	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ('210420112637T1000001')

	SELECT *
	FROM RP_SC
	WHERE 
	--COLOUR = 'FNPJTX7' 
	--AND
	LOT = '34601'
	and movement = 'mhi'
	--AND convert(int, LTRIM(RTRIM(hide)))  IN (592)
	--and convert(int, LTRIM(RTRIM(hide))) between 814 and 1020
	ORDER  BY HIDE asc
	---3827585

SELECT  LOT, HIDE,count(*) FROM RP_SC 
WHERE  --LTRIM(RTRIM(COLOUR)) = 'FWLNPX7'
	LOT = '34011'
GROUP BY  LOT, HIDE 
HAVING COUNT(*)>1
	
	SELECT * FROM RP_Folios WHERE TAG IN (3802962)
	
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

	--	DELETE PIEL_LOG WHERE K_PIEL_LOG IN (1956697)
		
	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE LOT = '34601'
	AND HIDE = '1420'
	ORDER BY hide

	SELECT * FROM RP_SC_PRT

	SELECT * FROM RP_SC WHERE TAGNO  in (3819498)  --AND COLOUR  in ('FWLNPT5') 
	order by hide

	SELECT * FROM RP_SC WHERE COLOUR = 'FWLRCX7'

	SELECT * FROM RP_Folios WHERE TAG IN (3820449)

	SELECT * FROM pearl_log (NOLOCK) WHERE jobno = '26778' order by ckey

	SELECT * FROM ccjobhdr_sql WHERE DATECREATED >= 20210517 AND CUSTOMER = 'FAUR01' ORDER BY JOBNO 

	SELECT * FROM cccuthst_sql WHERE --jobno IN ('28124')
	--AND 
	LTRIM(RTRIM(LOTNO)) = '034601' 
	AND hideno IN (	'1420'
				)
	order by hideno
		
	
SELECT * FROM	IMLSMST_SQL	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('501051')

	--SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('         032191')), 2, 6)  
	
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
