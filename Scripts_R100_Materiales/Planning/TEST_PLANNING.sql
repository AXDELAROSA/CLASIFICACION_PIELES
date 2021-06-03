
USE DATA_02PRUEBAS
	
	SELECT * FROM ccjobhdr_sql WHERE JOBNO  in ( SELECT jobno FROM pearl_log WHERE screen_opt = 'Planning' AND movement = 'Crear orden' )
	AND status = 'P' AND FOLIO IS NOT NULL ORDER BY JOBNO

	SELECT * FROM imlocfil_sql WHERE LOC = 'MFP'

	SELECT * FROM pearl_log (nolock) WHERE  movement = 'Crear orden' ORDER BY ckey DESC
	SELECT * FROM pearl_log WHERE JOBNO = '31979'  ORDER BY ckey DESC
	SELECT * FROM pearl_log WHERE JOBNO = '25021'  ORDER BY ckey asc

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('31901') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO = '25021'

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('30851') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO = '32104'

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('31673') ORDER BY jobno, Ser_No
	SELECT * FROM ccjobhdr_sql WHERE JOBNO = '31673'
	
	SELECT * FROM pearl_log WHERE screen_opt = 'Planning' AND JOBNO < 50000  ORDER BY ckey DESC

	SELECT TOP 20 * from serialcam_sql where SUBSTRING(serial, 1,5) IN	('30905')
	SELECT * FROM ccjobhdr_sql WHERE JOBNO < '50000' ORDER BY JOBNO DESC
	
	SELECT * FROM ccjobhdr_sql WHERE JOBNO = '31503'
	
	select imkitfil_sql.* from imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('31503') ) -- IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('30958')) ORDER BY item_no
	SELECT * FROM imkitfil_sql where item_no = 'UWLDLFWLROTX7'

	SELECT * FROM ccjoblin_sql WHERE JOBNO IN ('31504') ORDER BY jobno, Ser_No
	SELECT * FROM  ccjoblin_sql WHERE JOBNO = '31504' AND ITEM_NO NOT IN (SELECT comp_item_no FROM imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('31504') ))

	select * from imkitfil_sql where comp_item_no='PWLDFCLWLCPX7'
	SELECT CONCAT('F', RIGHT(LTRIM(RTRIM('PWD2TBLCNPDX9')),6))

	select TOP 10 * from IMCATFIL_SQL WHERE PROD_CAT = 'PDS'
	select TOP 10 * from IMITMIDX_SQL WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')
	select TOP 10 * from cccusitm_sql WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')
	select TOP 10 * from OECUSITM_SQL WHERE item_no IN ('PMDL3CRSNODY3', 'PMDLTCRSNODY8')

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


	/*
-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN_TEST]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN_TEST]
GO

/*
SELECT * FROM  ccjoblin_sql WHERE JOBNO = '31503' AND ITEM_NO NOT IN (SELECT comp_item_no FROM imkitfil_sql where comp_item_no IN (SELECT item_no FROM ccjoblin_sql WHERE JOBNO IN ('31503') ))
 EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN_TEST] 0 ,0,  '31504' --NORMAL
 EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN_TEST] 0 ,0,  '30088' --NORMAL
*/

CREATE PROCEDURE [dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN_TEST]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50)	
AS
	
	-- /////SE OBTIENE EL TURNO EN QUE SE REALIZA LA IMPRESION//////////////////////////////////////
	DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
	DECLARE @VP_TURNO	VARCHAR(5) = '2'
	
	IF @VP_HORA > 2000 AND @VP_HORA < 60002
		SET @VP_TURNO = '3'
	ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
		SET @VP_TURNO = '1'

	-- /////SE VALIDA SI LA ORDEN VA LIGADA CON OTRA//////////////////////////////////////
	DECLARE @VP_ORDEN_LIGADA VARCHAR(50) = '' 
	SELECT @VP_ORDEN_LIGADA = LTRIM(RTRIM(LOTNO))
	FROM ccjobhdr_sql (NOLOCK)
	WHERE jobno = @PP_ORDEN

	IF @VP_ORDEN_LIGADA IS NULL
		SET @VP_ORDEN_LIGADA = ''

	IF @VP_ORDEN_LIGADA <> ''
		BEGIN
			-- /////SE OBTIENE EL GROSS DE LAS DOS ORDENES//////////////////////////////////////
			DECLARE @VP_GROSS_1 DECIMAL(13,4) = 0
			DECLARE @VP_GROSS_2 DECIMAL(13,4) = 0

			SELECT @VP_GROSS_1 = STANDARDSQM 
			FROM ccjobhdr_sql (NOLOCK)
			WHERE jobno = @PP_ORDEN

			SELECT @VP_GROSS_2 = STANDARDSQM 
			FROM ccjobhdr_sql (NOLOCK)
			WHERE jobno = @VP_ORDEN_LIGADA

			-- /////SE VALIDA EL GROSS DE LAS DOS ORDENES PARA DEFINIR CUAL ES LA ORDEN PRINCIPAL Y LA SECUNDARIA//////////////////////////////////////
			DECLARE @VP_ORDEN_PRINCIPAL VARCHAR(50) = @VP_ORDEN_LIGADA
			DECLARE @VP_ORDEN_COMPLEMENTO VARCHAR(50) = @PP_ORDEN

			IF @VP_GROSS_1 > @VP_GROSS_2
				BEGIN
					SET @VP_ORDEN_PRINCIPAL = @PP_ORDEN
					SET @VP_ORDEN_COMPLEMENTO = @VP_ORDEN_LIGADA
				END

			SELECT	1							AS IMPRIMIR,
					JOBNO						AS ORDEN_PRINCIPAL, 
					-- ===========================
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN ''
							ELSE @VP_ORDEN_COMPLEMENTO END ) AS JOBNO_COMPLEMENTO,
					LTRIM(RTRIM(ccjoblin_sql.customer))	AS CUSTOMER, 
					-- ===========================
					(	SELECT	LTRIM(RTRIM(MACHINE)) 
						FROM	ccjobhdr_sql (NOLOCK)
						WHERE	JOBNO = ccjoblin_sql.JOBNO )	AS MESA,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN (	SELECT  LTRIM(RTRIM(ISNULL(filler_0003, '')))
																		FROM IMITMIDX_SQL (NOLOCK)
																		WHERE LTRIM(RTRIM(item_no)) = ccjoblin_sql.item_no )
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'WPIMX077'
							ELSE '' END ) AS REF_PO,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN '227704'
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'ADZ'
							ELSE '' END ) AS SUPPLIER,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN 'Faurecia Sistemas Automotrices de Mexico, BAU-AS-SNA-PR-Puebla C&S'
							ELSE '' END ) AS SHIP_TO,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
					LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
					-- ===========================
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN ccjoblin_sql.item_no	
							ELSE imkitfil_sql.item_no END ) AS ITEM_NO,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.KitDesc))			AS KIT_DESC, 
					-- ===========================
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN (	SELECT LTRIM(RTRIM(ITEM_DESC_1)) 
																			FROM IMITMIDX_SQL 
																			WHERE item_no = ccjoblin_sql.item_no )	
							ELSE (	SELECT LTRIM(RTRIM(ITEM_DESC_1)) 
									FROM IMITMIDX_SQL 
									WHERE item_no = imkitfil_sql.item_no )	 END ) AS KIT_DESC_1_IMPRIMIR,
					-- ===========================
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN (	SELECT LTRIM(RTRIM(ITEM_DESC_2))
																			FROM IMITMIDX_SQL 
																			WHERE item_no = ccjoblin_sql.item_no )	
							ELSE (	SELECT LTRIM(RTRIM(ITEM_DESC_2))
									FROM IMITMIDX_SQL 
									WHERE item_no = imkitfil_sql.item_no )	 END ) AS KIT_DESC_2_IMPRIMIR,
					-- ===========================
					ISNULL(ccjoblin_sql.user_def_fld1, 'N')	AS IMPRESA,
					-- ===========================
					CONVERT(INT,ccjoblin_sql.plannedqty)	AS PLANNED_QTY, 
					CONVERT(INT,ccjoblin_sql.completedqty)	AS COMPLETED_QTY, 
					CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY,
					RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
					LEFT(LTRIM(RTRIM(ChangeLevel)), 3) AS PROD_CAT,
					-- ===========================
					(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
						FROM INVENTARIO_EMBARQUE (NOLOCK)
						WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
								OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
						AND K_ESTATUS_INVENTARIO_EMBARQUE > 2) AS ENVIADO,
					-- ===========================
					@VP_TURNO	AS TURNO
					-- ===========================
			FROM ccjoblin_sql  (NOLOCK)
			LEFT JOIN imkitfil_sql (NOLOCK) ON ccjoblin_sql.ITEM_NO = imkitfil_sql.comp_item_no
			-- ===========================
			INNER JOIN	cccusitm_sql ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE	ccjoblin_sql.jobno = @VP_ORDEN_PRINCIPAL 
			-- ===========================
			UNION
			SELECT	1										AS IMPRIMIR,
					LTRIM(RTRIM(JOBNO))						AS ORDEN_PRINCIPAL, 
					''										AS JOBNO_COMPLEMENTO,
					LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
					-- ===========================
					(	SELECT LTRIM(RTRIM(MACHINE)) 
						FROM	ccjobhdr_sql (NOLOCK)
						WHERE	JOBNO = ccjoblin_sql.JOBNO )				AS MESA,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN (	SELECT  LTRIM(RTRIM(ISNULL(filler_0003, '')))
																		FROM IMITMIDX_SQL (NOLOCK)
																		WHERE LTRIM(RTRIM(item_no)) = ccjoblin_sql.item_no )
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'WPIMX077'
							ELSE '' END ) AS REF_PO,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN '227704'
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'ADZ'
							ELSE '' END ) AS SUPPLIER,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN 'Faurecia Sistemas Automotrices de Mexico, BAU-AS-SNA-PR-Puebla C&S'
							ELSE '' END ) AS SHIP_TO,
					-- ===========================
					LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
					LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
					ccjoblin_sql.item_no					AS ITEM_NO,
					-- ===========================
					LTRIM(RTRIM(ccjoblin_sql.KitDesc))			AS KIT_DESC, 
					-- ===========================
					(	SELECT LTRIM(RTRIM(ITEM_DESC_1))
						FROM IMITMIDX_SQL 
						WHERE item_no = ccjoblin_sql.item_no ) AS KIT_DESC_1_IMPRIMIR,
					-- ===========================
					(	SELECT  LTRIM(RTRIM(ITEM_DESC_2))
						FROM IMITMIDX_SQL 
						WHERE item_no = ccjoblin_sql.item_no ) AS KIT_DESC_2_IMPRIMIR,
					-- ===========================
					ISNULL(ccjoblin_sql.user_def_fld1, 'N')	AS IMPRESA,
					-- ===========================
					CONVERT(INT,ccjoblin_sql.plannedqty)	AS PLANNED_QTY, 
					CONVERT(INT,ccjoblin_sql.completedqty)	AS COMPLETED_QTY, 
					CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY,
					RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
					LEFT(LTRIM(RTRIM(ChangeLevel)), 3) AS PROD_CAT,
					-- ===========================
					(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
						FROM INVENTARIO_EMBARQUE (NOLOCK)
						WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
								OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
						AND K_ESTATUS_INVENTARIO_EMBARQUE > 2) AS ENVIADO,
					-- ===========================
					@VP_TURNO	AS TURNO
					-- ===========================
			FROM ccjoblin_sql  (NOLOCK)
			-- ===========================
			INNER JOIN	cccusitm_sql ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE	ccjoblin_sql.jobno = @VP_ORDEN_COMPLEMENTO 
			AND ccjoblin_sql.ITEM_NO NOT IN (	SELECT comp_item_no 
												FROM imkitfil_sql	
												WHERE comp_item_no IN ( SELECT item_no 
																		FROM ccjoblin_sql 
																		WHERE JOBNO = @VP_ORDEN_COMPLEMENTO ) )
			ORDER BY jobno, SER_NO
		END

		-----////////////////////////////////////////////////////////////////
		-- ////////////////////////////////////////////////////////////////////
GO
*/


