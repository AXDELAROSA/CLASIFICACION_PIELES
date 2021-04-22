
USE DATA_02PRUEBAS

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('18216') ORDER BY JOBNO, Kit
	
	SELECT TOP 100 * FROM ccjobhdr_sql WHERE JOBNO IN ('18216')
	
	SELECT TOP 100 * FROM ccjobhdr_sql WHERE JOBNO < 50000 --IN ('28531', '28689') 
	ORDER BY JOBNO DESC
	
	-- SE SACA LA DESCRIPCION DEL COLOR
	select top 1 item_no,search_desc,last_item_revision from imitmidx_sql where item_no like 'FCNPJRR'
	
	-- part_no_view MAL
	SELECT * FROM part_no_view WHERE COLOR = 'FCNPJRR' AND Customer = 'MAGN03'
	
	select ccjoblin_sql.jobno, sum(PlannedQty) as PlannedQty, netsqmper, status, machine 
	from ccjoblin_sql inner join ccjobhdr_sql on ccjoblin_sql.jobno=ccjobhdr_sql.jobno 
	--and item_no='" & DG_PLANEACION.Rows(t).Cells(0).Value & Mid(CB_COLOR_ORDEN.Text, 2, 6) & "' 
	AND  CONCAT('F', RIGHT(LTRIM(RTRIM(item_no)),6)) = 'FCNPJRR'
	and status='P' 
	group by ccjoblin_sql.jobno,netsqmper,status,machine 
	order by ccjoblin_sql.jobno


	-- ////////////////////SE OBTIENEN LOS DATOS DE LOS PACKING DINAMICAMENTE QUE SE CONVERTIRAN EN LAS COLUMNAS DE LA TABLA//////////////////////////	
	DECLARE @cols1 AS NVARCHAR(MAX), @query1 AS NVARCHAR(MAX), @query AS NVARCHAR(MAX), @query2 AS NVARCHAR(MAX), @query3 AS NVARCHAR(MAX)
	select @cols1 = STUFF(( SELECT ',' + QUOTENAME(LTRIM(RTRIM(ccjobhdr_sql.JOBNO))) 
							FROM ccjobhdr_sql 
							inner join ccjoblin_sql on ccjoblin_sql.jobno=ccjobhdr_sql.jobno 
							WHERE  CONCAT('F', LTRIM(RTRIM(colour))) = 'FCNPJRR'
							AND ccjobhdr_sql.customer = 'MAGN03'
							AND status='P' 
							GROUP BY ccjobhdr_sql.JOBNO
							ORDER BY ccjobhdr_sql.JOBNO
							FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'' ) 					

	SELECT @cols1

	--SET @query1 = N'SELECT  ''''  KIT, ''''  CUS_PART_NO, '''' DESCRIPCION, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[MESA_X_ORDEN]  from ( SELECT  MACHINE, JOBNO  from ccjobhdr_sql) x pivot ( MAX(JOBNO) for JOBNO in (' + @cols1 + N') ) p ' 
	--EXEC sp_executesql @query1;

	--SELECT * FROM [tempdb].[dbo].[MESA_X_ORDEN]

	--DROP TABLE [tempdb].[dbo].[MESA_X_ORDEN]

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
	ORDER BY cus_item_no
