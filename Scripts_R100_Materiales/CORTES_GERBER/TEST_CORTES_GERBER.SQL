
	SELECT CONVERT(DATE, (GETDATE()-(DAY(GETDATE())-1))) 'Primer Dia del Mes SIN HORA'

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

	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '403361'   AND L_BORRADO = 0  --AND FILE_NO in (  '211111094233T1000001')
		
		USE DATA_02PRUEBAS
	SELECT * FROM [TICKET_A_IMPORTAR] --WHERE lote = '403361' AND L_BORRADO = 0 --AND FILE_NO in (  '211111094233T1000001') 
	order by [K_TICKET_A_IMPORTAR] DESC

	--UPDATE [TICKET_A_IMPORTAR] 
	--	SET LOTE = '403361'
	--WHERE lote = '4O3361' AND L_BORRADO = 0 

	SELECT * FROM	IMLSMST_SQL	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('402301') and loc = 'MHI' and item_no = 'FNRUML8'

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ('470291') order by ID	

	SELECT * FROM HIDESHDR_SQL WHERE PLOT IN ('470291') --AND  FILENO IN  ( '20211228125704' )
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
	WHERE LTRIM(RTRIM(LOT)) = '470291' --AND MOVEMENT = 'MHI' 
	--AND COLOUR = 'FWLROX7'
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (1072) 
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
	WHERE --( FOLIO_ORIGEN = 3868264 OR  FOLIO_DESTINO = 3868264 )
	--(ORDEN_ORIGEN = '42665' OR  ORDEN_DESTIDO = '42665' )
	LOTE IN (32381) 
	AND  PIEL  IN (1072)
	--AND PIEL_LOG.K_TIPO_PIEL_LOG  IN (6)
	ORDER BY  K_PIEL_LOG desc
	
	 SELECT * 
	 FROM cccuthst_sql
	 WHERE --jobno IN ('30266') order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = RIGHT('000000' + CONVERT(VARCHAR(20), 32381 ), 6)
	AND	CONVERT(INT, hideno) IN (1072)
		
	--UPDATE cccuthst_sql
	--	SET hideno = '0000'
	-- WHERE --jobno IN ('45874') order by colkey desc
	----AND 
	--LTRIM(RTRIM(LOTNO)) = RIGHT('000000' + CONVERT(VARCHAR(20), 62631), 6)
	--AND	CONVERT(INT, hideno) IN (185)
	
	--SELECT * FROM RP_SC WHERE TAGNO IN (3798615) ORDER BY HIDE

	SELECT * FROM ccjobhdr_sql WHERE folio  IN (3853159 )  
	
	select colour as COLOR,lot as LOTE,hide as PIEL,sqf as SQF from RP_Sc where tagno=3869396
	SELECT * FROM RP_sc WHERE tagno IN ( 3825627)

	SELECT * FROM RP_Folios WHERE JOBNO IN ( '30266')

	SELECT * FROM ccjobhdr_sql WHERE jobno IN ( '30266')
	
	SELECT * FROM pearl_log (NOLOCK) WHERE [user_name] = 'FRANCISCOE' AND CDATE = '10/11/2021'
	
	SELECT * FROM	IMLSMST_SQL	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('402301') and loc = 'MHI' and item_no = 'FNRUML8'

	--update IMLSMST_SQL	
	--	set qty_on_hand = qty_on_hand + 53
	--WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('750241') and loc = 'T27' and item_no = 'FYPAWT5'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('MHI') AND item_no = 'FNRUML8'
	-- 20401.4000 - 53 = 20454.4

	--update IMINVLOC_SQL	
	--	set qty_on_hand = qty_on_hand + 53
	-- WHERE	LTRIM(RTRIM(loc)) IN ('T27') AND item_no = 'FYPAWT5'


	USE DATA_02PRUEBAS
	SELECT TOP 100 * FROM   IMINVTRX_SQL 
	WHERE ITEM_NO = 'FYPAWT5' --AND LOC = 'T36' AND trx_dt = '20210906'
	-- and doc_ord_no = '30284' 
	 AND TRX_DT = 20210824
	ORDER BY A4GLIdentity DESC

	SELECT * FROM IMLSTRX_SQL WHERE ord_no IN ( 5492832, 05492829 )
	 
	SELECT TOP 100 * FROM IMINVTRX_SQL WHERE ord_no IN ( 5492832, 05492829 )
	 	

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
