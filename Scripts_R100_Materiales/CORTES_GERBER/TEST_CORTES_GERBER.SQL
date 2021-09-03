
	-- ////////////////////////////////////////////////////////////// 
	USE DATA_02Pruebas

	SELECT * FROM HIDESHDR_SQL   
	 inner join HIDESLIN_SQL on  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	LTRIM(RTRIM(PLOT)) IN ('108941')
	--AND CONVERT(INT, LTRIM(RTRIM(HIDE)))  IN (0304 )
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

			
	SELECT SUM(sqf) AS TOTAL_SQF FROM [TICKET_A_IMPORTAR] WHERE lote = '45052' AND L_BORRADO = 0  --AND FILE_NO in (  '210805131930T1000001')
	
	--SELECT  DISTINCT FILE_NO FROM [TICKET_A_IMPORTAR] WHERE MEDIDORA = 2
	
	SELECT * FROM [TICKET_A_IMPORTAR] WHERE lote = '45052' AND L_BORRADO = 0  --AND FILE_NO in (  '210709201852T1000002') 
	order by [K_TICKET_A_IMPORTAR]
	
	--UPDATE [TICKET_A_IMPORTAR] 
	--SET LOTE = '450521'
	-- WHERE lote = '45052' AND L_BORRADO = 0 

	SELECT top 100 * FROM IncInsp_sql WHERE LTRIM(RTRIM(LOT)) in ( '108941') order by ID	
	
	SELECT * FROM  HIDESHDR_SQL WHERE PLOT = ('108931') --AND  FILENO IN ( '20210901132512' )
	ORDER BY ID DESC	

	--UPDATE HIDESHDR_SQL 
	--SET PCOLOR = 'FWLCPX7'
	-- WHERE PLOT = ('450421') AND  FILENO IN ( '20210827210509', '20210827133119', '20210827132717' )
	
	SELECT * 
	FROM HIDESLIN_SQL WHERE  FILENO IN ( '210817130539T1000001' )
	
	--UPDATE  HIDESLIN_SQL 
	--SET PRINTED = 0
	--WHERE FILENO IN ( '210817130539T1000001' )
	
	SELECT * FROM RP_SC WHERE COLOUR = 'FCNPDX9' AND LOT = '108932' AND HIDE IN (
	SELECT HIDE 
	FROM HIDESLIN_SQL WHERE  FILENO IN ( '20210831200345' )
	)

	SELECT * --distinct TAGNO , MOVEMENT
	FROM RP_SC --_TEMP
	WHERE 
	--COLOUR = 'FWLCPX7'   
	--AND 
	LOT = '402431'
	--and movement = 'MQU'
	--AND
	 --TAGNO = 3777313
	AND convert(int, LTRIM(RTRIM(hide)))  IN (109)
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
	--(ORDEN_ORIGEN = '31600' OR  ORDEN_DESTIDO = '31600' )
	--COLOR = 'FPABLUE'
	--AND 
	LOTE IN (402801)    
	AND          
	PIEL  IN (40)
	--PIEL  BETWEEN 217 and 218
	--AND 
	--PIEL_LOG.K_TIPO_PIEL_LOG IN (5)
	--and usuario <> 'anag'
	ORDER BY K_PIEL_LOG desc

	--	DELETE PIEL_LOG WHERE K_PIEL_LOG = 2993766

	SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE TAGNO IN ( 3849504) order by HIDE
	
	SELECT * FROM RP_SC_TEMP WHERE TAGNO   IN (3850954) AND LOT = '66611'

	SELECT * FROM RP_SC WHERE TAGNO IN (3816402)  
	
	SELECT * FROM RP_Folios (NOLOCK) WHERE TAG  IN (3816402)  

	SELECT * FROM ccjobhdr_sql WHERE folio  IN (3849504)  
	
	SELECT * FROM RP_Folios WHERE JOBNO  IN ( '39790')
	
	SELECT * FROM ccjobhdr_sql WHERE jobno IN ( '32143',
												'36341',
												'32713',
												'32821',
												'35221',
												'35602',
												'32823',
												'33330',
												'32266',
												'32269',
												'25296',
												'26348',
												'26391',
												'26539'
)
and status = 'P' AND folio IS NOT NULL
	
	SELECT * FROM ccjobhdr_sql WHERE colour = 'cnpdx9' AND status = 'P' AND machine = 'Table 39' AND ( LOTNO IS NULL OR LOTNO = '' )

	SELECT * FROM pearl_log (NOLOCK) WHERE JOBNO = '37626' order by ckey
	 
	 SELECT * FROM cccuthst_sql
	 WHERE jobno IN ('26539') --order by colkey desc
	--AND 
	LTRIM(RTRIM(LOTNO)) = '402801' 
	AND	CONVERT(INT, hideno) IN (40)

	--UPDATE cccuthst_sql
	--SET HIDENO = '0'
	-- WHERE --jobno IN ('30261') --order by colkey desc
	----AND 
	--LTRIM(RTRIM(LOTNO)) = '067521' 
	--AND	CONVERT(INT, hideno) IN (0316, 0014)


	SELECT * FROM	IMLSMST_SQL	
	WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('107711') and loc = 'T39' and item_no = 'FCNPDX9'

	--update IMLSMST_SQL	
	--	set qty_on_hand = qty_on_hand + 36
	--WHERE	LTRIM(RTRIM(SER_LOT_NO)) IN ('107711') and loc = 'T39' and item_no = 'FCNPDX9'

	SELECT TOP 10 * FROM	IMINVLOC_SQL	
	WHERE	LTRIM(RTRIM(loc)) IN ('T39') AND item_no = 'FCNPDX9'

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
