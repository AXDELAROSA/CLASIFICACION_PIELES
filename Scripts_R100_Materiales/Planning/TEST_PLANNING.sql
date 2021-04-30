
USE DATA_02PRUEBAS
	
	SELECT * FROM INVENTARIO_EMBARQUE WHERE --K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND 
	SERIAL_2 LIKE  '27037%' 
		
	--UPDATE  INVENTARIO_EMBARQUE 
	--SET SERIAL_1 = 'DUPLICADO'
	--WHERE K_ESTATUS_INVENTARIO_EMBARQUE = 0 AND SERIAL_1 = '29487008' AND K_INVENTARIO_EMBARQUE = 39746
	
	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('27037', '29886') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('27037', '29886')
	
	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('27081', '29887') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('27081', '29887')

	SELECT * FROM ccjobhdr_sql WHERE JOBNO IN ('27081', '29813')
	SELECT * FROM pearl_log WHERE JOBNO IN ('29812', '29813') order by cdate

	select * from imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('27081')) ORDER BY item_no
	select * from imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('27037'))  ORDER BY item_no

	SELECT * FROM pearl_log WHERE JOBNO = '27037'
	
	SELECT * FROM cccuthst_sql WHERE JOBNO = '18518'

	SELECT TOP 100 * FROM ccjobhdr_sql WHERE JOBNO IN ( '29487')
	
	--SELECT TOP 100 * FROM ccjobhdr_sql WHERE JOBNO < 50000 order by jobno desc

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('29812', '29813') ORDER BY jobno, Ser_No

	-- SE SACA LA DESCRIPCION DEL COLOR
	select * from imitmidx_sql where item_no IN (SELECT Item_No FROM ccjoblin_sql WHERE JOBNO IN ('29247'))
	ORDER BY ITEM_NO
	-- LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)

	SELECT TOP 20 * from serialcam_sql where serial IN	(LTRIM(RTRIM(29247)) + RIGHT('000'+ LTRIM(RTRIM(1)),3))
	SELECT TOP 20 * from serialcam_sql where serial IS NULL AND SERIAL2 IS NULL
	
	select top(1) user_def_fld_5 from ccitmidx_sql where rtrim(item_no)='PLWCFBRWLNPX7' order by versionno desc
	
	SELECT CUS_NAME, User_Def_Fld_2 FROM ARCUSFIL_SQL WHERE CUS_NO = 'MAGN03' -- 70000000

	SELECT * FROM imlocfil_sql WHERE LOC = 'MFP'

	-- part_no_view MAL
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
	AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = 'FCNPJRR'
	AND ccverhdr_sql.cus_no = 'MAGN03'
	AND cccusitm_sql.item_no = 'PW2RB40CNPJRR'
	ORDER BY versionno DESC

	select * from  ccverhdr_sql 
	where --ccverhdr_sql.specstatus = 'U' 
	--AND --ccverhdr_sql.status = 'L' 
	--and 
	modelno = 'WD2'

	select Customer as cus_no,part_no_view.modelno,part_no_view.versionno as version,
	part_no_view.item_no,cus_item_no,item_desc_1,item_desc_2,prod_cat,cube_width,cube_length,
	concat(rtrim(modelno),rtrim(versionno)) as modver,color,cube_qty_per 
	from part_no_view 
	inner join IMITMIDX_SQL on part_no_view.item_no=IMITMIDX_SQL.item_no and color='FCNPJRR' and customer='MAGN03' 
	WHERE IMITMIDX_SQL.ITEM_NO = 'PW2RB40CNPJRR'
	order by part_no_view.item_no
       
	select * from imitmidx_sql where item_no = 'PW2RB40CNPJRR  ' --IN (SELECT Item_No FROM ccjoblin_sql WHERE JOBNO IN ('29812'))