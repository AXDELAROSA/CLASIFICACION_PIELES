
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	/*
	--INSERT INTO RP_SC( 
	--		[CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[TYPE],MOVEMENT
	--		)
	--SELECT GETDATE(), 'FMCKTX7'   ,'33641','0575','40.30', 3797972,'C','T45'
	--FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3788317
	*/

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('32691')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (153 )
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF = '40.90'
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '6031D1' AND FILE_NO in( '210424115108T1000001')

	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '60311'
	--WHERE lote = '6031D1' AND FILE_NO in( '210424115108T1000001')

	SELECT SUM(sqf) FROM [TICKET_A_IMPORTAR]  WHERE lote = '6031D1' AND FILE_NO in( '210424035611T1000001')

	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '108021'
	--WHERE lote = '10802/2'  AND FILE_NO = '210402193455T1000001'

	SELECT * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) = '402431' ORDER BY ID DESC 

	SELECT * FROM HIDESHDR_SQL WHERE PLOT = '402431' -- AND  FILENO IN ('20210416224344') 

	SELECT * --SUM(SQF) 
	FROM  HIDESLIN_SQL WHERE FILENO IN ('20210429201915') --AND PRINTED = 1 
	ORDER BY HIDE ASC

	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ('210421190301T1000001')

	SELECT *
	FROM RP_SC
	WHERE 
	--LTRIM(RTRIM(LOT)) = ('34622')
	--and 
	colour = 'FCSL5B8'
	--AND convert(int, LTRIM(RTRIM(hide)))  IN (153)
	--and convert(int, LTRIM(RTRIM(hide))) between 1 and 172
	--AND SQF = '43.80'
	ORDER  BY HIDE asc

	SELECT top 10000 D_TIPO_PIEL_LOG, usuario, PIEL_LOG.*
	FROM PIEL_LOG 
	INNER JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE -- ( FOLIO_ORIGEN = 3823991 OR  FOLIO_DESTINO = 3823991 )
	--(ORDEN_ORIGEN = 26245 OR  ORDEN_DESTIDO = 26245 )
	--AND 
	LOTE IN (402391)    
	AND          
	PIEL   IN (466, 1033)
	--PIEL  BETWEEN 217 and 218
	AND 
	PIEL_LOG.K_TIPO_PIEL_LOG IN (8)
	--AND USUARIO = 'alondrah'
	ORDER BY k_piel_log DESC

	--DELETE PIEL_LOG WHERE K_PIEL_LOG IN (1810825
	--,1810792)

	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE --TAGNO  = '3813706' --ORDER BY HIDE
	--and 
	LTRIM(RTRIM(LOT)) = ('59071')
	AND HIDE IN ('0504')

	--SELECT * FROM RP_SC WHERE TAGNO  = '3806256' 
	--and LTRIM(RTRIM(LOT)) = ('67971')
	--and colour = 'FNRUML8'
	--AND HIDE IN ('0357')
	--ORDER BY HIDE

	SELECT * FROM RP_SC WHERE TAGNO  in (3790456) order by lot
	
	SELECT * FROM RP_SC WHERE TAGNO  in (3823991) 
	
	SELECT * FROM RP_Folios WHERE JOBNO = '29257'
	
	SELECT *  FROM ccjobhdr_sql WHERE JOBNO IN ('24568')
	
	SELECT * FROM cccuthst_sql WHERE jobno = '24568'
	--AND 
	--LTRIM(RTRIM(LOTNO)) = '107751' 
	--AND hideno = '1245' 
	order by linenum

	SELECT * FROM pearl_log WHERE jobno = '3821799'AND  MOVEMENT = 'Delete'
	
	SELECT '         ' + '0' + SUBSTRING(Ltrim(Rtrim('106771')), 2, 6)  
	
	--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
	--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '32861', 6) )
	--DECLARE @VP_TURNO	VARCHAR(5) = '0'
	
	--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
	--										-- ===========================
	--										'10234', '0000', '1', @VP_FECHA,
	--										-- ===========================
	--										@VP_HORA, @VP_FECHA, 0, 'FMCKTX7', 
	--										-- ===========================
	--										@VP_LOTE_CON_ESPACIO, '0071','12.10',
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
