
USE DATA_02PRUEBAS
	
	SELECT * FROM INVENTARIO_EMBARQUE WHERE --K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND 
	SERIAL_2 LIKE  '27037%' 
		
	--UPDATE  INVENTARIO_EMBARQUE 
	--SET SERIAL_1 = 'DUPLICADO'
	--WHERE K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND SERIAL_1 = '29487008' AND K_INVENTARIO_EMBARQUE = 39746

	SELECT * FROM pearl_log WHERE screen_opt = 'Planning' AND movement = 'Crear orden'  ORDER BY ckey DESC
	SELECT * FROM pearl_log WHERE movement = 'REVERSE' AND user_name = 'RAFAELF' ORDER BY ckey DESC

	SELECT * FROM pearl_log WHERE JOBNO = '29426'  ORDER BY ckey DESC
	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30905') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO = '29426'
	SELECT TOP 20 * from serialcam_sql where SUBSTRING(serial, 1,5) IN	('30905')
	SELECT * FROM ccjobhdr_sql WHERE JOBNO > '30900' ORDER BY JOBNO 
	
	SELECT * FROM ccjobhdr_sql WHERE customer = 'YANG03' AND DATECREATED = '20210506' ORDER BY jobno
	
	select imkitfil_sql.* from imkitfil_sql where comp_item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8') -- IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('30958')) ORDER BY item_no
	SELECT * FROM imkitfil_sql where item_no = 'UMDL3CRSNODY3'

	select * from imkitfil_sql where comp_item_no='PWLDFCLWLCPX7'
	SELECT CONCAT('F', RIGHT(LTRIM(RTRIM('PWD2TBLCNPDX9')),6))

	select TOP 10 * from IMCATFIL_SQL WHERE PROD_CAT = 'PDS'
	select TOP 10 * from IMITMIDX_SQL WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')
	select TOP 10 * from cccusitm_sql WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')
	select TOP 10 * from OECUSITM_SQL WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')

	--UPDATE IMITMIDX_SQL
	--SET L_ACTIVO = 1
	-- WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')

	-- standar pack
	select top(1) user_def_fld_5 from ccitmidx_sql where rtrim(item_no)='PWD2TBLCNPJRR' order by versionno desc
	
	SELECT * FROM part_no_view WHERE item_no = 'PMDL3CRSNODY3'

	--========PARA LISTADO DE NUMEROS DE PARTE QUE SE PUEDEN PROGRAMAR=========================================================
	SELECT	DISTINCT TOP (100) PERCENT 
		 cccusitm_sql.item_no, 
		 CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) AS COLOR, 
		 cus_item_no, 
		 ccverhdr_sql.cus_no AS Customer, 
		 ccverhdr_sql.versionno, 
		 ccverhdr_sql.modelno
	FROM	dbo.ccverhdr_sql
	INNER JOIN cccusitm_sql ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
		AND SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)  = 'P' 
		AND cus_item_no <> ''
	INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = cccusitm_sql.item_no
	INNER JOIN  IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
		AND IMCATFIL_SQL.L_BORRADO = 0
	WHERE ccverhdr_sql.specstatus = 'U' 
	AND ccverhdr_sql.status = 'L' 
	AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = 'FWLROT3'
	--AND ccverhdr_sql.cus_no = 'FAUR01'
	--AND cccusitm_sql.item_no = 'PWSSC20WSPAA6'
	ORDER BY versionno DESC

	   -- part_no_view CONSULTA MAL
	--SELECT        item_no, 
	--			{ fn CONCAT('F', SUBSTRING(item_no, LEN(LTRIM(RTRIM(item_no))) - 5, 6)) } AS COLOR,
 --                            (SELECT        TOP (1) cus_item_no
 --                              FROM            dbo.cccusitm_sql AS CUST_TEMP
 --                              WHERE        (item_no = dbo.cccusitm_sql.item_no) AND (modelno = dbo.cccusitm_sql.modelno) AND (cus_no = dbo.cccusitm_sql.cus_no)
 --                              ORDER BY versionno DESC) AS cus_item_no, 
	--				cus_no AS Customer, 
	--				MAX(versionno) AS versionno, modelno
	--FROM            dbo.cccusitm_sql
	--WHERE        (item_no LIKE 'P%') AND (cus_item_no <> '') AND (modelno IN
	--                             (SELECT DISTINCT modelno
	--                               FROM            dbo.COLORES_ACTIVOS))
	--GROUP BY item_no, cus_no, modelno