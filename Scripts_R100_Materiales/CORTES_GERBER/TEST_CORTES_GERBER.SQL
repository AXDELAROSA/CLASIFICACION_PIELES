
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('450351')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	--AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (9, 12, 68, 13, 6)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	 SELECT * 
	 FROM HIDESLIN_SQL 
	 WHERE FILENO = '2021070964236'

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR]WHERE lote = '10873/2' AND L_BORRADO = 0 -- AND FILE_NO in (  '210709201852T1000002')

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '10873/2' AND L_BORRADO = 0  --AND FILE_NO in (  '210709201852T1000002')
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '108732'
	-- WHERE lote = '10873/2' AND L_BORRADO = 0 

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '108691') order by ID
	
	--UPDATE IncInsp_sql 
	--	SET Lot_size = 536
	--WHERE LTRIM(RTRIM(LOT)) = ( '108561')
	--AND ID = 6920

	SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('750391') AND  FILENO IN ( '20210713162919', '2021071480231' )
	ORDER BY PLOT DESC		

	--UPDATE HIDESHDR_SQL 
	--SET TAREA = CONVERT(DECIMAL(13,3), TAREA) + 1
	--WHERE PLOT = ('108691') AND  FILENO IN ( '20210713162919', '2021071480231' )

	SELECT * --SUM(SQF) 
	FROM HIDESLIN_SQL WHERE FILENO IN ( '210624045436T1000001' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	-- WHERE FILENO IN ( '210624045436T1000001' )
	
	SELECT * --distinct TAGNO , MOVEMENT
	FROM RP_SC--_HIDE_DELETE
	WHERE 
	--COLOUR = 'FCPRHL1' 
	--AND
	LOT = '450351'
	--and movement = 'MHI'
	--AND TAGNO = 3832476
	AND convert(int, LTRIM(RTRIM(hide)))  IN (8)
	--and convert(int, LTRIM(RTRIM(hide))) between 1 and 200
	--AND TAGNO IN (3836822, 3834984)
	ORDER  BY HIDE asc



	SELECT  LOT, HIDE,count(*) FROM RP_SC 
	WHERE  --LTRIM(RTRIM(COLOUR)) = 'FWLNPX7'
		LOT = '34011'
	GROUP BY  LOT, HIDE 
	HAVING COUNT(*)>1
		
	SELECT top 10000  D_TIPO_PIEL_LOG, 
			(CASE WHEN usuario IS NULL THEN (	SELECT CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) 
												FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
												WHERE EN_NUM_EMP = K_USUARIO_ALTA)
				ELSE usuario END) AS RESPONSABLE, 
			PIEL_LOG.*
	FROM PIEL_LOG 
	LEFT JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE  --( FOLIO_ORIGEN = 3839906 OR  FOLIO_DESTINO = 3839906 )
	--(ORDEN_ORIGEN = '35519' OR  ORDEN_DESTIDO = '35519' )
	--COLOR = 'FWLNPX7'
	--AND 
	LOTE IN (67521)    
	AND          
	PIEL    IN (239, 25, 692, 441)
	--PIEL  BETWEEN 217 and 218
	--AND 
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (1)
	ORDER BY k_piel_log desc

	--SELECT * FROM TIPO_PIEL_LOG

	SELECT * FROM RP_SC WHERE TAGNO  IN (3839906)  order by HIDE

	SELECT * FROM RP_SC_PRT

	SELECT * FROM RP_SC (NOLOCK) WHERE LOT = '750061' 
		AND HIDE IN (SELECT HIDE FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3789716 AND LOT = '750061'   )
	AND MOVEMENT <> 'MQU'
	ORDER BY HIDE	

	SELECT DISTINCT LOT FROM RP_SC_FOLIO_TYPE_2 WHERE TAGNO = 3789716 
	
	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO IN ( 3833756, 3834377) 

	SELECT * FROM RP_SC WHERE TAGNO  IN (3839906)  order by HIDE

	SELECT * FROM RP_Folios WHERE TAG  IN ( 3841249) 

	--UPDATE RP_Folios 
	--	SET STATUS = 'C1',
	--	MACHINE = 'Table 79',
	--	JOBNO = '35520'
	--WHERE TAG  IN ( 3841249) 

	SELECT * FROM RP_Folios WHERE JOBNO  IN ( '35522') 

	--SELECT * FROM ccjobhdr_sql WHERE folio in (3819534 )

	SELECT * FROM ccjobhdr_sql WHERE jobno = '35522'
	
	SELECT * FROM pearl_log (NOLOCK) WHERE JOBNO = '34991' order by ckey

	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('23181'
,'23339'
,'23575'
,'23583'
,'28763'
,'34548'
,'28764'
,'34549'
,'24819'
,'28766'
,'28766'
,'29083'
,'29375'
,'30273'
,'34551'
,'18286'
,'18669')
 ORDER BY JOBNO

	SELECT * FROM ccjobhdr_sql WHERE JOBNO in ( '36044' )

	--update ccjobhdr_sql set folio = NULL WHERE JOBNO in ( '33899', '33316', '33930' )
	
	SELECT [dbo].[CONVERT_INT_TO_TIME](4441)
	
	use DATA_02
	SELECT * FROM cccuthst_sql WHERE --jobno IN ('27848') --order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = '034891' 
	AND CONVERT(INT, hideno) IN (21 )
	order by hideno

	--UPDATE cccuthst_sql 
	--SET hidesqm = 1.3
	--WHERE	LTRIM(RTRIM(LOTNO)) = '034891' 
	--AND CONVERT(INT, hideno) IN (21 )

	--402171
	--UPDATE cccuthst_sql 
	--SET LOTNO = '         402171'
	--WHERE jobno IN ('27848') --order by colkey desc
	--AND 
	--LTRIM(RTRIM(LOTNO)) = '002171' 
	--AND CONVERT(INT, hideno) IN ('0100')


	SELECT * FROM RP_SC WHERE TAGNO IN ( 3838989 )

	----SELECT  '         ' + '4' + SUBSTRING(Ltrim(Rtrim(450151)), 2, 6)  
	
	SELECT * FROM	IMLSMST_SQL	
	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('034942') and loc = 'T79'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('T79') AND item_no = 'FMCKTX7'

	USE DATA_02PRUEBAS
	SELECT TOP 100 * FROM IMINVTRX_SQL 
	WHERE ITEM_NO = 'FMCKTX7' AND LOC = 'T79' AND trx_dt = '20210712'
		--AND ORD_NO = 5445264 
	ORDER BY A4GLIdentity DESC

	--UPDATE IMINVTRX_SQL 
	--	SET doc_ord_no = '35519'
	--WHERE ITEM_NO = 'FMCKTX7' AND LOC = 'T79' AND trx_dt = '20210712'
	--AND ORD_NO = 5445260  

	SELECT * FROM IMLSTRX_SQL WHERE ord_no = 5445259  
	SELECT TOP 100 * FROM IMINVTRX_SQL WHERE ord_no = 5445259   
	
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
