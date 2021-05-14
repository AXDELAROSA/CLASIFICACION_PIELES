
USE DATA_02PRUEBAS
	
	SELECT * FROM INVENTARIO_EMBARQUE WHERE --K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND 
	SERIAL_2 LIKE  '27037%' 
		
	--UPDATE  INVENTARIO_EMBARQUE 
	--SET SERIAL_1 = 'DUPLICADO'
	--WHERE K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND SERIAL_1 = '29487008' AND K_INVENTARIO_EMBARQUE = 39746

	SELECT Kit, IMKITFIL_SQL.Item_No, ccjoblin_sql.item_no, OriginalQty
	FROM IMKITFIL_SQL
	INNER JOIN ccjoblin_sql ON   ccjoblin_sql.Item_No = comp_item_no
	WHERE JOBNO = 30080
	ORDER BY Ser_No

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30092') ORDER BY jobno, Ser_No
	SELECT * FROM pearl_log WHERE jobno = '30092'

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('27037', '27081') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('27037', '27081')

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30089', '30089') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('30089', '30089')

	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN (
	SELECT jobno FROM pearl_log WHERE [user_name] = 'franciscoe' and screen_opt = 'Planning' and jobno > 29000 --JOBNO IN ('30080', '30081', '30087') order by cdate
	)

	select imkitfil_sql.* from imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('30089')) ORDER BY item_no

	select * from imkitfil_sql where item_no = 'UMW2TBLCNPJRR' AND comp_item_no <> 'PWD2TBLCNPJRR'

	SELECT CONCAT('F', RIGHT(LTRIM(RTRIM('PWD2TBLCNPDX9')),6))
	
	SELECT Kit, IMKITFIL_SQL.Item_No, OriginalQty, ccjoblin_sql.item_no
					FROM IMKITFIL_SQL
					INNER JOIN ccjoblin_sql ON   ccjoblin_sql.Item_No = comp_item_no
					WHERE JOBNO = '30089'

	SELECT * FROM pearl_log WHERE JOBNO = '30092'
	
	SELECT * FROM cccuthst_sql WHERE JOBNO = '18518'

	SELECT TOP 100 * FROM ccjobhdr_sql WHERE CUSTOMER = 'FAUR01' AND STATUS = 'p' ORDER BY JOBNO DESC
		
	select * from imitmidx_sql where user_def_fld_1 LIKE 'WPI%' AND item_no LIKE 'P%'
	
	--CLIENTES Y direcciones
	SELECT * FROM arcusfil_sql where cus_no LIKE ('WPI%')
	ORDER BY CUS_NO 
	
	SELECT * FROM arcusfil_address where A4GLIdentity in (51)

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30323') ORDER BY jobno, Ser_No

	select top(1) user_def_fld_5 from ccitmidx_sql where rtrim(item_no)='PWD2TBLCNPJRR' order by versionno desc


	SELECT TOP 100 * FROM pearl_log WHERE JOBNO = '28432' 

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30659') ORDER BY jobno, Ser_No

	select * from imitmidx_sql where item_no IN ('UW2SRB4CNPJRR' , 'PW2RB40CNPJRR') --(SELECT Item_No FROM ccjoblin_sql WHERE JOBNO IN ('30080'))

	SELECT * FROM part_no_view WHERE Customer = 'MAGN02' ORDER BY MODELNO, ITEM_NO
	-- SE SACA LA DESCRIPCION DEL COLOR

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('28955') ORDER BY Item_No
	select * from imitmidx_sql where item_no IN (SELECT Item_No FROM ccjoblin_sql WHERE JOBNO IN ('28955'))
	ORDER BY item_no
	-- LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)

	SELECT TOP 20 * from serialcam_sql where SUBSTRING(serial, 1,5) IN	('30088', '30089', '30659', '28432')

	SELECT TOP 20 * from ccjoblin_sql where JOBNO = '30088' AND Ser_No = 4

	SELECT TOP 20 * from serialcam_sql where serial IN	('30089008')
	SELECT TOP 20 * from ccjoblin_sql where JOBNO = '30089' -- AND Ser_No = 4

	SELECT CODE from serialcam_sql where serial IS NOT NULL AND SERIAL2 IS NULL
	
	select top(1) user_def_fld_5 from ccitmidx_sql where rtrim(item_no)='PWD2TBLCNPJRR' order by versionno desc
	
	SELECT CUS_NAME, User_Def_Fld_2 FROM ARCUSFIL_SQL WHERE CUS_NO = 'MAGN03' -- 70000000

	SELECT * FROM imlocfil_sql WHERE LOC = 'MFP'

	-- part_no_view VISTA MAL
	SELECT * FROM part_no_view WHERE COLOR = 'FCNPJRR' AND Customer = 'MAGN03' and item_no = 'PW2RB40CNPJRR'
	
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
	--AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = 'FCNPJRR'
	AND ccverhdr_sql.cus_no = 'MAGN03'
	AND cccusitm_sql.item_no like 'PWD2TBL%'
	ORDER BY versionno DESC

	select * from ccverhdr_sql where modelno = 'WD2' order by versionno

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