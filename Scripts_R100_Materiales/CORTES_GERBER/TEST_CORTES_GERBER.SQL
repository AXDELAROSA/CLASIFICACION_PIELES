
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('450411')
	--and HIDESLIN_SQL.fileno = '210310181706T1000002'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (240)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	  SELECT * FROM HIDESLIN_SQL WHERE ID =    

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR]WHERE lote = '685511' AND L_BORRADO = 0  AND FILE_NO in (  '210805131930T1000001')

	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '685511' AND L_BORRADO = 0  --AND FILE_NO in (  '210709201852T1000002') 
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '68551'
	-- WHERE lote = '685511' AND L_BORRADO = 0 

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '450341') order by ID

	SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('68511') -- AND  FILENO IN ( '210805131930T1000001' )
	ORDER BY PLOT DESC		
	
	SELECT * FROM RP_SC WHERE COLOUR = 'FWLCPX7' AND LOT = '00007' AND HIDE IN (
	SELECT HIDE 
	FROM HIDESLIN_SQL WHERE FILENO IN ( '20210811110222' ) 
	)

	SELECT * 
	FROM HIDESLIN_SQL WHERE FILENO IN ( '210805131930T1000001' ) 
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	-- WHERE FILENO IN ( '210715130339T1000002' )
	
	SELECT * --distinct TAGNO , MOVEMENT
	FROM RP_SC --_TEMP
	WHERE 
	--COLOUR = 'FNRUDX9'   
	--AND
	LOT = '68151'
	--and movement = 'MHI'
	--AND
	-- TAGNO = 3777313
	AND convert(int, LTRIM(RTRIM(hide)))  IN ( 202  ) --FWLNPX7
	--and convert(int, LTRIM(RTRIM(hide))) between 1 and 200
	ORDER  BY HIDE asc
	
		
	SELECT top 10000  D_TIPO_PIEL_LOG, 
			(CASE WHEN usuario IS NULL THEN (	SELECT CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) 
												FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
												WHERE EN_NUM_EMP = K_USUARIO_ALTA)
				ELSE usuario END) AS RESPONSABLE, 
			PIEL_LOG.*
	FROM PIEL_LOG 
	LEFT JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE -- ( FOLIO_ORIGEN = 3847472 OR  FOLIO_DESTINO = 3847472 )
	--(ORDEN_ORIGEN = '39193' OR  ORDEN_DESTIDO = '39193' )
	--COLOR = 'FCNPDX9'
	--AND 
	LOTE IN (108831)    
	AND          
	PIEL  IN (443, 444, 445, 446, 447, 448, 449, 450)
	--PIEL  BETWEEN 217 and 218
	--AND 
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (4)
	--and usuario <> 'anag'
	ORDER BY K_PIEL_LOG desc

	--DELETE PIEL_LOG WHERE K_PIEL_LOG = 2779160

	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO IN ( 3848973) order by HIDE
	
	SELECT * FROM RP_SC WHERE TAGNO   IN (3848929)  ORDER BY HIDE

	SELECT * FROM RP_Folios (NOLOCK) WHERE TAG IN (3816864) 

	SELECT * FROM ccjobhdr_sql WHERE folio  IN (3842313,3842316)  

	SELECT * FROM RP_Folios WHERE JOBNO  IN ( '37648')

	SELECT * FROM ccjobhdr_sql WHERE jobno IN ( '39537')
	
	SELECT * FROM ccjobhdr_sql WHERE colour = 'CPRDX9' AND status = 'P' AND machine = 'Table 16' AND ( LOTNO IS NULL OR LOTNO = '' )

	SELECT * FROM pearl_log (NOLOCK) WHERE JOBNO = '37626' order by ckey
	
	use DATA_02
	SELECT * FROM cccuthst_sql WHERE --jobno IN ('39564') --order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = '035131' 
	AND CONVERT(INT, hideno) IN (227)
	order by hideno

	--UPDATE cccuthst_sql
	--SET hidesqm = 32.2000
	-- WHERE --jobno IN ('30261') --order by colkey desc
	----AND 
	--LTRIM(RTRIM(LOTNO)) = '402841' 
	--AND CONVERT(INT, hideno) IN (6)


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
	--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '105881', 6) )
	--DECLARE @VP_TURNO	VARCHAR(5) = '0'
	
	--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
	--										-- ===========================
	--										'00000', '0000', '1', @VP_FECHA,
	--										-- ===========================
	--										@VP_HORA, @VP_FECHA, 0, 'FCNPWA3', 
	--										-- ===========================
	--										@VP_LOTE_CON_ESPACIO, '0165','10.95',
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
