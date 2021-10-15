
	SELECT CONVERT(DATE, (GETDATE()-(DAY(GETDATE())-1))) 'Primer Dia del Mes SIN HORA'

	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02 --Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('108601')
	--AND CONVERT(INT, LTRIM(RTRIM(HIDE)))  IN (300)
	----AND
	 --PCOLOR = 'FCPRHL1'
	 --AND SQF < 1
	 ORDER BY HIDESLIN_SQL.HIDE ASC

	 SELECT COUNT(HIDESLIN_SQL.ID) 
			FROM	HIDESHDR_SQL   
			INNER JOIN	HIDESLIN_SQL ON HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
			WHERE --LTRIM(RTRIM(PCOLOR)) = @PP_COLOR
			--AND	
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(PLOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(PLOT)),2, 10) 
						ELSE LTRIM(RTRIM(PLOT)) END ) = '108941'
			AND LTRIM(RTRIM(HIDE)) = '0388'

	--	SELECT  DISTINCT FILE_NO FROM [TICKET_A_IMPORTAR] WHERE MEDIDORA = 1 AND CONVERT(DATE, F_ALTA) = CONVERT(DATE, GETDATE())
	--	SELECT  DISTINCT FILE_NO FROM [TICKET_A_IMPORTAR] WHERE MEDIDORA = 2 AND CONVERT(DATE, F_ALTA) = CONVERT(DATE, GETDATE())
			
	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '109711' AND L_BORRADO = 0  --AND FILE_NO in (  '210805131930T1000001')
		
	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '109711' AND L_BORRADO = 0  --AND FILE_NO in (  '210709201852T1000002') 
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--	SET LOTE = '109111'
	--WHERE lote = '109711' AND L_BORRADO = 0 

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '470172') order by ID	

	--UPDATE IncInsp_sql 
	--SET Description = 'FWLROX7'
	--WHERE LTRIM(RTRIM(LOT)) in ( '470172')

	SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('750021') --AND  FILENO IN ( '210823073112T1000001' )
	ORDER BY ID DESC	
	
	--UPDATE HIDESHDR_SQL 
	--SET PCOLOR = 'FWLROX7'
	-- WHERE PLOT = ('470172')-- AND  FILENO IN ( '20210827210509', '20210827133119', '20210827132717' )
	
	SELECT * 
	FROM HIDESLIN_SQL WHERE  FILENO IN ( '20210202100828' )
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ( '210817130539T1000001' )
	
	SELECT plot, hide, sqf FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('108601')
	AND CONVERT(INT, LTRIM(RTRIM(HIDE))) IN (1240
												,1241
												,1242
												,1243
												,1244
												,1245
												,1246)
	order by hide

	SELECT * --distinct TAGNO , MOVEMENT
	FROM RP_SC --_FOLIO_STATUS_XX--_FOLIO_TYPE_2
	WHERE 
	--COLOUR = 'FCNPDX9'   
	--AND 
	LOT = '108601'
	--and movement = 'mhi'
	--AND
	 --TAGNO = 3829847
	AND convert(int, LTRIM(RTRIM(hide)))  IN (1240
												,1241
												,1242
												,1243
												,1244
												,1245
												,1246)
	--AND convert(int, LTRIM(RTRIM(hide))) BETWEEN 661 AND 716
	ORDER  BY HIDE asc

	SELECT top 10000  D_TIPO_PIEL_LOG, 
			(CASE WHEN usuario IS NULL THEN (	SELECT CONCAT(EP_NOMBRE, ' ', EP_APELLIDO_PATERNO) 
												FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
												WHERE EN_NUM_EMP = K_USUARIO_ALTA)
				ELSE usuario END) AS RESPONSABLE, 
			PIEL_LOG.*
	FROM PIEL_LOG (NOLOCK)
	LEFT JOIN users_pearl (NOLOCK) ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG (NOLOCK) ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE --( FOLIO_ORIGEN = 3850599 OR  FOLIO_DESTINO = 3850599 )
	--(ORDEN_ORIGEN = '42124' OR  ORDEN_DESTIDO = '42124' )
	--COLOR = 'FPABLUE'
	--AND 
	LOTE IN (108601) 
	AND          
	PIEL  IN (1240
												,1241
												,1242
												,1243
												,1244
												,1245
												,1246)
	----AND LOCACION_ORIGEN = 'MHI'
	--AND PIEL_LOG.K_TIPO_PIEL_LOG  IN (8)
	--AND  ORDEN_DESTIDO = '40865'
	ORDER BY  K_PIEL_LOG desc

	 SELECT * 
	 FROM cccuthst_sql
	 WHERE --jobno IN ('41280') order by colkey desc
	----AND 
	LTRIM(RTRIM(LOTNO)) = '108601' 
	AND	CONVERT(INT, hideno) IN (0) 
	(1240
												,1241
												,1242
												,1243
												,1244
												,1245
												,1246) order by hideno

	--SELECT * FROM TIPO_PIEL_LOG

--	DELETE PIEL_LOG WHERE K_PIEL_LOG IN (3167552)

	SELECT * FROM RP_SC WHERE TAGNO IN (3841225 ) ORDER BY HIDE

	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO IN ( 3839549) order by HIDE
	
	
	SELECT * FROM RP_Folios (NOLOCK) WHERE TAG  IN (3853159 ) 

	SELECT * FROM ccjobhdr_sql WHERE folio  IN (3853159 )  
		
	SELECT * FROM RP_Folios WHERE JOBNO IN ( '35218')

	SELECT * FROM ccjobhdr_sql WHERE jobno IN ( '36007   ')
	
	SELECT * FROM ccjobhdr_sql WHERE colour = 'CNPDX9' 
	AND status = 'P' 
	AND FOLIO IS NOT NULL
	AND machine = 'Table 39' 
	AND ( LOTNO IS NULL OR LOTNO = '' )

	SELECT * FROM pearl_log (NOLOCK) WHERE JOBNO = '42124' order by ckey
	
	 SELECT * 
	 FROM cccuthst_sql
	 WHERE jobno IN ('44493') order by colkey desc
	----AND 
	--LTRIM(RTRIM(LOTNO)) = '064521' 
	--AND	CONVERT(INT, hideno) IN (247)
	
	--          750511
	--UPDATE cccuthst_sql
	--SET hideno = '0000'
	--  WHERE --jobno IN ('41280') order by colkey desc
	------AND 
	--LTRIM(RTRIM(LOTNO)) = '064521' 
	--AND	CONVERT(INT, hideno) IN (247, 53)
	
	SELECT * FROM	IMLSMST_SQL	
	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('107781') and loc = 'T39' and item_no = 'FCNPDX9'

	--update IMINVLOC_SQL	
	--	set qty_on_hand = qty_on_hand + 42.3
	--WHERE	 loc = 'T39' and item_no = 'FCNPDX9'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('T39') AND item_no = 'FCNPDX9'
	-- 28126.6000 + 42.3 = 28,168.9

	USE DATA_02PRUEBAS
	SELECT TOP 100 * FROM   IMLSTRX_SQL 
	WHERE --ITEM_NO = 'FWLNPA5' AND LOC = 'T36' AND trx_dt = '20210906'
	 doc_ord_no = '40865' 
	 AND TRX_DT < 20200101
	ORDER BY A4GLIdentity DESC

	SELECT * FROM IMLSTRX_SQL WHERE ord_no IN ( 808718)
	 
	SELECT TOP 100 * FROM IMINVTRX_SQL WHERE ord_no = 05505688   
	 
	--UPDATE IMINVTRX_SQL 
	--SET doc_ord_no = '30945'
	--WHERE ord_no = 05505688 

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
