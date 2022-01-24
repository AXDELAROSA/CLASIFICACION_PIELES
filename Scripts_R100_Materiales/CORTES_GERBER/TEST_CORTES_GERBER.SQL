
	SELECT CONVERT(DATE, (GETDATE()-(DAY(GETDATE())-1))) 'Primer Dia del Mes'
	SELECT  CONVERT(VARCHAR(10),GETDATE(), 105)  'Fecha(DD-MM-YYYY)'

	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('29851')
	--AND CONVERT(INT, LTRIM(RTRIM(HIDE)))  IN (300)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC
			
	select * from rp_sc_prt

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '35811'   AND L_BORRADO = 0  --AND FILE_NO in (  '211111094233T1000001')
		
		--USE DATA_02PRUEBAS
	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote LIKE '%35811%' --AND L_BORRADO = 0 --AND FILE_NO in (  '211111094233T1000001') 
	order by [K_TICKET_A_IMPORTAR] DESC

	--UPDATE [TICKET_A_IMPORTAR] 
	--	SET LOTE = '403361'
	--WHERE lote = '4O3361' AND L_BORRADO = 0 

	SELECT * FROM	IMLSMST_SQL	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('402301') and loc = 'MHI' and item_no = 'FNRUML8'

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ('470291') order by ID	

	SELECT * FROM HIDESHDR_SQL WHERE PLOT IN ('502141') AND STATUS = 'MIT' --AND  FILENO IN  ( '20211228125704' )
	ORDER BY ID DESC	

	SELECT * 
	FROM HIDESLIN_SQL
	WHERE FILENO IN ( '20211228125704' )
	--AND HIDE  BETWEEN 1 AND 398
	
	SELECT * -- plot, hide, sqf 
	FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('32381')
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (1072)
	order by hide
		
	SELECT * FROM RP_SC
	WHERE LTRIM(RTRIM(LOT)) = '900011' --AND MOVEMENT = 'MHI' 
	--AND COLOUR = 'FWLROX7'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (5, 29, 43, 44, 48) 
	ORDER  BY HIDE ASC	 

	SELECT TOP 1000
			D_TIPO_PIEL_LOG, 
			( CASE WHEN usuario IS NULL THEN (	SELECT CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) 
												FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
												WHERE EN_NUM_EMP = K_USUARIO_ALTA)
				ELSE usuario END) AS RESPONSABLE, 
			PIEL_LOG.*
	FROM PIEL_LOG (NOLOCK)
	LEFT JOIN users_pearl (NOLOCK) ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG (NOLOCK) ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE --( FOLIO_ORIGEN = 3882799 OR  FOLIO_DESTINO = 3882799 )
	--(ORDEN_ORIGEN = '42665' OR  ORDEN_DESTIDO = '42665' )
	--LOTE IN (403441) 
	--AND  PIEL  IN (9)
	AND PIEL_LOG.K_TIPO_PIEL_LOG  IN (5)
	ORDER BY  K_PIEL_LOG desc
	

	SELECT * FROM TIPO_PIEL_LOG

	 SELECT * 
	 FROM cccuthst_sql
	 WHERE --jobno --IN ('19558') order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = RIGHT('000000' + CONVERT(VARCHAR(20), 35241          ), 6)
	AND	CONVERT(INT, hideno) IN (0060 )
		
	--UPDATE cccuthst_sql
	--	SET hideno = '0000'
	-- WHERE --jobno IN ('45874') order by colkey desc
	----AND 
	--LTRIM(RTRIM(LOTNO)) = RIGHT('000000' + CONVERT(VARCHAR(20), 65981), 6)
	--AND	CONVERT(INT, hideno) IN  (40, 16, 22)
	
	--SELECT * FROM RP_SC WHERE TAGNO IN (3798615) ORDER BY HIDE

	--SELECT * FROM ccjobhdr_sql WHERE folio  IN (3845781 ) 
	 
	SELECT * FROM ccjobhdr_sql WHERE jobno  IN (
'51450',
'51440',
'51449',
'51439',
'51971'
)  

	SELECT * FROM RP_SC WHERE tagno IN ( 3856529) ORDER BY HIDE

	--SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE tagno IN ( 3831793) ORDER BY HIDE

	SELECT * FROM   RP_Folios  WHERE TAG IN ( 3831793)

	SELECT * FROM pearl_log (NOLOCK) WHERE jobno IN ( '51439', '51440' )
	
	SELECT * FROM	IMLSMST_SQL	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('035241') and loc = 'GT2' and item_no = 'FMCKTX7'

	--update IMLSMST_SQL	
	--	set qty_on_hand = qty_on_hand - 289.2000
	--WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('068151') and loc = 'GT2' and item_no = 'FNRUDX9'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	loc = 'GT2' and item_no = 'FMCKTX7'
	-- 20401.4000 - 53 = 20454.4

	--update IMINVLOC_SQL	
	--	set qty_on_hand = qty_on_hand - 289.2000
	-- WHERE	loc = 'GT2' and item_no = 'FNRUDX9'

	USE DATA_02PRUEBAS
	SELECT TOP 100 * FROM   IMINVTRX_SQL 
	WHERE ITEM_NO = 'FCPRDX9' AND LOC = 'T64' AND trx_dt = '20220119'
	-- and doc_ord_no = '30284' 
	 --AND TRX_DT = 20210824
	ORDER BY A4GLIdentity DESC

	SELECT * FROM IMLSTRX_SQL WHERE ord_no IN (5631818  )
	 
	SELECT TOP 100 * FROM IMINVTRX_SQL WHERE ord_no IN ( 5631818 )

	--DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
	--DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	--DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + '32381', 6) )
	--DECLARE @VP_TURNO	VARCHAR(5) = '0'
	
	--EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		0, 0,
	--										-- ===========================
	--										'00000', '0000', '1', @VP_FECHA,
	--										-- ===========================
	--										@VP_HORA, @VP_FECHA, 0, 'FMCKTX7', 
	--										-- ===========================
	--										@VP_LOTE_CON_ESPACIO, '1072','24.15',
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
