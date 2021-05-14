
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('32691')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (153 )
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF = '40.90'
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	SELECT SUM(sqf) FROM [TICKET_A_IMPORTAR]  WHERE lote = 'K402461' AND L_BORRADO = 0 --AND FILE_NO in( '210424115108T1000001')

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = 'K402461' AND L_BORRADO = 0 --AND FILE_NO in( '210424115108T1000001')
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '402461'
	--WHERE lote = 'K402461' AND L_BORRADO = 0  

	SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(Lot)) = '034691'  --Description = 'FMCKDX9' order by date desc
		
	SELECT TOP 1000 * FROM HIDESHDR_SQL WHERE PLOT = '33561' --AND  FILENO IN ('20210505164147') 
	ORDER BY ID DESC

	SELECT * --SUM(SQF) 
	FROM  HIDESLIN_SQL WHERE FILENO IN ('20210511124124' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 

	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ('210504132018T1000002')

	SELECT *
	FROM RP_SC
	WHERE 
	--COLOUR = 'FMCKTX7' AND
	LOT = '402461'
	--and movement = 'mhi'
	--AND convert(int, LTRIM(RTRIM(hide)))  IN (153)
	--and convert(int, LTRIM(RTRIM(hide))) between 1378 and 1568
	ORDER  BY HIDE asc

	SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
	FROM PIEL_LOG 
	INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE -- ( FOLIO_ORIGEN = 3826735 OR  FOLIO_DESTINO = 3826735 )
	--(ORDEN_ORIGEN = 30195 OR  ORDEN_DESTIDO = 30195 )
	--AND 
	LOTE IN (34561)    
	AND          
	PIEL   IN (59)
	----PIEL  BETWEEN 217 and 218
	AND 
	PIEL_LOG.K_TIPO_PIEL_LOG IN (8)
	--AND USUARIO = 'alondrah'
	ORDER BY k_piel_log DESC

	SELECT * FROM TIPO_PIEL_LOG 

	--	DELETE PIEL_LOG WHERE K_PIEL_LOG IN (1930127)
		

	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE LOT = '401811'
	AND HIDE IN (	SELECT HIDE FROM RP_SC_FOLIO_TYPE_2 
					WHERE TAGNO = 3789543
					AND LOT = '401811'
				)
	AND TAGNO  = 3817357
	ORDER BY TAGNO

	SELECT * FROM RP_SC_PRT

	SELECT * FROM RP_SC WHERE TAGNO  in (3824753) AND COLOUR  in ('FWLNPT5') order by TAGNO

	SELECT * FROM RP_Folios WHERE TAG IN ('3805149', '3806606', '3807084')

	SELECT * FROM pearl_log WHERE jobno = '30195' --AND  MOVEMENT = 'Delete'

	SELECT *  FROM ccjobhdr_sql WHERE JOBNO IN ('26938 ')

	SELECT * FROM cccuthst_sql WHERE --jobno IN ('30195')
	--AND 
	LTRIM(RTRIM(LOTNO)) = '033561' 
	AND hideno IN (	'0017', '0018' , '0021'
				)
	order by hideno
		
	SELECT * FROM RP_SC WHERE TAGNO  in (3824753) 

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
