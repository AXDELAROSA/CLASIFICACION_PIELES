
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

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR]WHERE lote = '10877/2' AND L_BORRADO = 0 -- AND FILE_NO in (  '210709201852T1000002')

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '10877/2' AND L_BORRADO = 0  --AND FILE_NO in (  '210709201852T1000002') 
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '108772'
	-- WHERE lote = '10877/2' AND L_BORRADO = 0 

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '450341') order by ID

	SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('450341') --AND  FILENO IN ( '210715130339T1000002' )
	ORDER BY PLOT DESC		

	SELECT * --SUM(SQF) 
	FROM HIDESLIN_SQL WHERE FILENO IN ( '210715130339T1000002' ) --AND PRINTED = 1 
	ORDER BY HIDE ASC 
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	-- WHERE FILENO IN ( '210715130339T1000002' )
	
	SELECT * --distinct TAGNO , MOVEMENT
	FROM RP_SC--_HIDE_DELETE
	WHERE 
	--COLOUR = 'FCPRHL1' 
	--AND
	LOT = '401771'
	--and movement = 'MHI'
	--AND TAGNO = 3832476
	AND convert(int, LTRIM(RTRIM(hide)))  IN (49, 57)
	--and convert(int, LTRIM(RTRIM(hide))) between 1 and 200
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
	WHERE  --( FOLIO_ORIGEN = 3842443 OR  FOLIO_DESTINO = 3842443 )
	--(ORDEN_ORIGEN = '35519' OR  ORDEN_DESTIDO = '35519' )
	--COLOR = 'FWLNPX7'
	--AND 
	LOTE IN (34171)    
	AND          
	PIEL  IN (1)
	----PIEL  BETWEEN 217 and 218
	--AND 
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (4)
	ORDER BY k_piel_log desc
	
	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO IN ( 3814277) order by HIDE

	SELECT * FROM RP_SC WHERE TAGNO  IN (3837020)  order by HIDE

	SELECT * FROM RP_Folios WHERE TAG  IN ( 3837020) 


	SELECT * FROM ccjobhdr_sql WHERE folio in (3837020 )

	SELECT * FROM RP_Folios WHERE JOBNO  IN ( '33197') 

	SELECT * FROM ccjobhdr_sql WHERE jobno = '33197'

	SELECT * FROM pearl_log (NOLOCK) WHERE JOBNO = '34991' order by ckey
	
	use DATA_02
	SELECT * FROM cccuthst_sql WHERE --jobno IN ('27848') --order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = '034171' 
	AND CONVERT(INT, hideno) IN (149)
	order by hideno

	SELECT * FROM	IMLSMST_SQL	
	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('034942') and loc = 'T79'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('T79') AND item_no = 'FMCKTX7'

	USE DATA_02PRUEBAS
	SELECT TOP 100 * FROM IMINVTRX_SQL 
	WHERE ITEM_NO = 'FMCKTX7' AND LOC = 'T79' AND trx_dt = '20210712'
		--AND ORD_NO = 5445264 
	ORDER BY A4GLIdentity DESC

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
