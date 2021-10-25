-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		SP
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	7/MAY/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////
-- //////////////		CONTENIDO DEL SP
--	[PG_LI_IMPRIMIR_ETIQUETA_ORDEN]
--		[PG_PR_ETIQUETA_ORDEN_RMA]
--		[PG_PR_ETIQUETA_ORDEN_KIT]
--	[PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL]


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN]
GO
/*	
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '29678' --NORMAL
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30088' --NORMAL
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30089' -- U
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30659' -- FAUR
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '28432' -- WPI003
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30761' -- IRVI02
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30555' -- YANG03
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '30901' -- MAGN02
	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '31504' -- MAG02
 	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '34658' -- MAG02
 	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '34659' -- MAG02

 	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '35154' -- MAG02
 	EXEC [PG_LI_IMPRIMIR_ETIQUETA_ORDEN] 0 ,0,  '36297' -- MAG02
*/

CREATE PROCEDURE [dbo].[PG_LI_IMPRIMIR_ETIQUETA_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50)	
AS
	
	IF	(	SELECT	COUNT(K_DETAILS_RMA)
			FROM	DETAILS_RMA
			WHERE	JOBNO	= @PP_ORDEN	) > 0
	BEGIN
		EXECUTE	[dbo].[PG_PR_ETIQUETA_ORDEN_RMA]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ORDEN
	END
	ELSE
	BEGIN
		EXECUTE	[dbo].[PG_PR_ETIQUETA_ORDEN_KIT]	@PP_K_SISTEMA_EXE,	@PP_K_USUARIO_ACCION,
													-- ===========================
													@PP_ORDEN
	END
-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ETIQUETA_ORDEN_RMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ETIQUETA_ORDEN_RMA]
GO
--		 EXECUTE [DBO].[PG_PR_ETIQUETA_ORDEN_RMA] 0,139, 34659
--		 EXECUTE [DBO].[PG_PR_ETIQUETA_ORDEN_RMA] 0,139, 35515
CREATE PROCEDURE [dbo].[PG_PR_ETIQUETA_ORDEN_RMA]
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


	SELECT	1										AS L_IMPRIMIR,
			--LTRIM(RTRIM(ccjoblin_sql.jobno))		AS ORDEN_PRINCIPAL, 
			DETAILS_RMA.JOBNO						AS ORDEN_PRINCIPAL, 
			--''										AS JOBNO_COMPLEMENTO,
			--LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
			LTRIM(RTRIM(DETAILS_RMA.CUS_NO))		AS CUSTOMER, 
			-- ===========================
			LTRIM(RTRIM(ccjobhdr_sql.machine))		AS MESA,
			-- ===========================
			''										AS REF_PO,
			-- ===========================
			--(SELECT CUS_NAME FROM ARCUSFIL_SQL (NOLOCK) WHERE CUS_NO = HEADER_RMA.CUS_NO )						AS SUPPLIER,
			''										AS SUPPLIER,
			-- ===========================
			''										AS SHIP_TO,
			-- ===========================
			--LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
			LTRIM(RTRIM(DETAILS_RMA.CUS_ITEM_NO))	AS CUS_ITEM_NO,
			--LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
			LEFT(DETAILS_RMA.ITEM_NO,8)				AS KIT, 
			--ccjoblin_sql.item_no					AS ITEM_NO,
			DETAILS_RMA.item_no						AS ITEM_NO,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.KitDesc))		AS KIT_DESC, 
			-- ===========================
			(	SELECT TOP (1) LTRIM(RTRIM(ITEM_DESC_1))
				FROM IMITMIDX_SQL (NOLOCK)
				WHERE item_no = ccjoblin_sql.item_no ) AS KIT_DESC_1_IMPRIMIR,
			-- ===========================
			''										AS KIT_DESC_2_IMPRIMIR,
			dbo.CONVERT_INT_TO_DATE(datecreated)	AS FECHA,
			-- ===========================
			--ISNULL(ccjoblin_sql.user_def_fld1, 'N')	AS IMPRESA,
			(	CASE
					WHEN	DETAILS_RMA.K_STATUS_ETIQUETA	= 80	THEN	'NO'
					ELSE	'SI'
				END
			)	AS IMPRESA,
			-- ===========================
			--CONVERT(INT,ccjoblin_sql.plannedqty)	AS PLANNED_QTY, 
			DETAILS_RMA.CANTIDAD_ORDENADA			AS PLANNED_QTY, 
			--CONVERT(INT,ccjoblin_sql.completedqty)	AS COMPLETED_QTY, 
			DETAILS_RMA.CANTIDAD_ENVIADA			AS COMPLETED_QTY, 
			--CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY,
			DETAILS_RMA.CANTIDAD_ORDENADA			AS ORIGINAL_QTY,
			--RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3)	AS SER_NO,
			'XRMA'									AS PROD_CAT,
			-- ===========================
			(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
				FROM INVENTARIO_EMBARQUE (NOLOCK)
				WHERE	(		SERIAL_1 = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
							OR	SERIAL_2 = LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
						)  
				AND K_ESTATUS_INVENTARIO_EMBARQUE > 2
			)										AS ENVIADO,
			-- ===========================
			@VP_TURNO								AS TURNO,
			-- ===========================
			DETAILS_RMA.K_HEADER_RMA				AS JOBNO_COMPLEMENTO,
			DETAILS_RMA.SERIAL						AS SER_NO,
			GRUPO_ORDEN								AS GRUPO_ORDEN,
			ATENCION_A								AS ATENCION_A,
			ITEM_DESC_1								AS COLOR,
			D_ARCUSFIL_PROGRAM_MODEL				AS D_MODELNO
			--(SELECT TOP (1) ITEM_DESC_1					FROM IMITMIDX_SQL			(NOLOCK) WHERE ITEM_NO = CONCAT('F',LTRIM(RTRIM(RIGHT(DETAILS_RMA.ITEM_NO,6))) ))		AS COLOR,
			--(SELECT TOP (1) D_ARCUSFIL_PROGRAM_MODEL	FROM ARCUSFIL_PROGRAM_MODEL (NOLOCK) WHERE S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO)							AS D_MODELNO
	FROM	ccjoblin_sql		(NOLOCK)
	-- ===========================
	INNER JOIN	ccjobhdr_sql	(NOLOCK) ON ccjobhdr_sql.jobno	= ccjoblin_sql.jobno
	INNER JOIN	cccusitm_sql	(NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer	)
	-- ===========================
	INNER JOIN	DETAILS_RMA		(NOLOCK) ON	DETAILS_RMA.SERIAL	= CONCAT(LTRIM(RTRIM(ccjoblin_sql.jobno)) , RIGHT('000' + CONVERT(VARCHAR(5), ccjoblin_sql.Ser_No), 3))
	INNER JOIN	HEADER_RMA		(NOLOCK) ON	HEADER_RMA.K_HEADER_RMA	= DETAILS_RMA.K_HEADER_RMA	---.JOBNO	= ccjoblin_sql.jobno
	INNER JOIN	ARCUSFIL_PROGRAM_MODEL	(NOLOCK)	ON ARCUSFIL_PROGRAM_MODEL.S_ARCUSFIL_PROGRAM_MODEL	= DETAILS_RMA.MODELNO
	INNER JOIN	IMITMIDX_SQL	(NOLOCK) ON		IMITMIDX_SQL.item_no	= CONCAT('F',LTRIM(RTRIM(RIGHT(DETAILS_RMA.ITEM_NO,6))) )
	WHERE	ccjoblin_sql.jobno = @PP_ORDEN 
	-- ===========================
	ORDER BY GRUPO_ORDEN, ccjoblin_sql.Ser_No
		-----////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ETIQUETA_ORDEN_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ETIQUETA_ORDEN_KIT]
GO
--		EXECUTE [dbo].[PG_PR_ETIQUETA_ORDEN_KIT] 0,144, 36568
CREATE PROCEDURE [dbo].[PG_PR_ETIQUETA_ORDEN_KIT]
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
						WHERE	JOBNO = @VP_ORDEN_PRINCIPAL )	AS MESA,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN (	SELECT  LTRIM(RTRIM(ISNULL(filler_0003, '')))
																		FROM IMITMIDX_SQL (NOLOCK)
																		WHERE LTRIM(RTRIM(item_no)) = ccjoblin_sql.item_no )
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'WPIMX000566'
							ELSE '' END ) AS REF_PO,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN '227704'
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'PEA'
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
																			FROM IMITMIDX_SQL (NOLOCK)
																			WHERE item_no = ccjoblin_sql.item_no )	
							ELSE (	SELECT LTRIM(RTRIM(ITEM_DESC_1)) 
									FROM IMITMIDX_SQL (NOLOCK)
									WHERE item_no = imkitfil_sql.item_no )	 END ) AS KIT_DESC_1_IMPRIMIR,
					-- ===========================
					( CASE WHEN imkitfil_sql.comp_item_no IS NULL THEN (	SELECT LTRIM(RTRIM(ITEM_DESC_2))
																			FROM IMITMIDX_SQL (NOLOCK)
																			WHERE item_no = ccjoblin_sql.item_no )	
							ELSE (	SELECT LTRIM(RTRIM(ITEM_DESC_2))
									FROM IMITMIDX_SQL (NOLOCK)
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
					--( CASE	WHEN  ( SELECT COUNT(ORDEN) FROM PPMS_PEARL.DBO.Perforacion where LTRIM(RTRIM(noserie)) = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)), 3) ) > 0 THEN 1
					--		WHEN	( SELECT COUNT(ORDEN) FROM PPMS_PEARL.DBO.Perforacion where LTRIM(RTRIM(noserie)) = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)), 3) ) = 0 
					--			AND  ( SELECT COUNT(ORDEN) FROM PPMS_PEARL.DBO.certificacion_rpt where LTRIM(RTRIM(noserie_caja)) =  LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)), 3) ) > 0 THEN 1
					--		WHEN ( SELECT COUNT(ORDEN) FROM PPMS_PEARL.DBO.Perforacion where LTRIM(RTRIM(noserie)) = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)), 3) ) = 0 
					--			AND  ( SELECT COUNT(ORDEN) FROM PPMS_PEARL.DBO.certificacion_rpt where LTRIM(RTRIM(noserie_caja)) = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)), 3) ) = 0 THEN 0
					-- END ) AS ENVIADO, -- DESDE QUE SE ESCANEA EN INSPEC. PERFO O CERTIFICACION YA NO SE PODRA REIMPRIMIR ETIQUETA					
					-- ===========================
					--(	SELECT COUNT([K_MATERIAL_PROGRAMADO_LOG]) 
					--	FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
					--	WHERE SERIAL = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)   
					--	AND K_TIPO_EVENTO_KIT >= 300 ) AS ENVIADO, -- DESDE QUE SE ESCANEA EN INSPEC. PERFO O CERTIFICACION YA NO SE PODRA REIMPRIMIR ETIQUETA
					-- ===========================
					(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
						FROM INVENTARIO_EMBARQUE (NOLOCK)
						WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
								OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
						AND K_ESTATUS_INVENTARIO_EMBARQUE > 0) AS ENVIADO,
					-- ===========================
					@VP_TURNO	AS TURNO
					-- ===========================
			FROM ccjoblin_sql  (NOLOCK)
			LEFT JOIN imkitfil_sql (NOLOCK) ON ccjoblin_sql.ITEM_NO = imkitfil_sql.comp_item_no
			AND CONCAT('F', RIGHT(LTRIM(RTRIM(imkitfil_sql.item_no)),6)) <> 'FLCPTX7'
			-- ===========================
			INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE	ccjoblin_sql.jobno = @VP_ORDEN_PRINCIPAL 
			-- ===========================
			UNION
			-- ===========================
			SELECT	1										AS IMPRIMIR,
					LTRIM(RTRIM(JOBNO))						AS ORDEN_PRINCIPAL, 
					''										AS JOBNO_COMPLEMENTO,
					LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
					-- ===========================
					(	SELECT LTRIM(RTRIM(MACHINE)) 
						FROM	ccjobhdr_sql (NOLOCK)
						WHERE	JOBNO = @VP_ORDEN_COMPLEMENTO )				AS MESA,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN (	SELECT  LTRIM(RTRIM(ISNULL(filler_0003, '')))
																		FROM IMITMIDX_SQL (NOLOCK)
																		WHERE LTRIM(RTRIM(item_no)) = ccjoblin_sql.item_no )
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'WPIMX000566'
							ELSE '' END ) AS REF_PO,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN '227704'
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'PEA'
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
						FROM IMITMIDX_SQL (NOLOCK)
						WHERE item_no = ccjoblin_sql.item_no ) AS KIT_DESC_1_IMPRIMIR,
					-- ===========================
					(	SELECT  LTRIM(RTRIM(ITEM_DESC_2))
						FROM IMITMIDX_SQL (NOLOCK)
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
					--(	SELECT COUNT([K_MATERIAL_PROGRAMADO_LOG]) 
					--	FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
					--	WHERE SERIAL = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)   
					--	AND K_TIPO_EVENTO_KIT >= 300 ) AS ENVIADO, -- DESDE QUE SE ESCANEA EN INSPEC. PERFO O CERTIFICACION YA NO SE PODRA REIMPRIMIR ETIQUETA
					-- ===========================
					(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
						FROM INVENTARIO_EMBARQUE (NOLOCK)
						WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
								OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
						AND K_ESTATUS_INVENTARIO_EMBARQUE > 0) AS ENVIADO,
					-- ===========================
					@VP_TURNO	AS TURNO
					-- ===========================
			FROM ccjoblin_sql  (NOLOCK)
			-- ===========================
			INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE	ccjoblin_sql.jobno = @VP_ORDEN_COMPLEMENTO 
			AND ccjoblin_sql.ITEM_NO NOT IN (	SELECT comp_item_no 
												FROM imkitfil_sql	(NOLOCK)
												WHERE comp_item_no IN ( SELECT item_no 
																		FROM ccjoblin_sql (NOLOCK)
																		WHERE JOBNO = @VP_ORDEN_COMPLEMENTO ) )
			ORDER BY jobno, SER_NO
		END
	ELSE
		BEGIN
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
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'WPIMX000566'
							ELSE '' END ) AS REF_PO,
					-- ===========================
					( CASE WHEN ccjoblin_sql.customer = 'FAUR01' THEN '227704'
							WHEN ccjoblin_sql.customer = 'WPI003' THEN 'PEA'
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
						FROM IMITMIDX_SQL (NOLOCK)
						WHERE item_no = ccjoblin_sql.item_no ) AS KIT_DESC_1_IMPRIMIR,
					-- ===========================
					(	SELECT  LTRIM(RTRIM(ITEM_DESC_2))
						FROM IMITMIDX_SQL (NOLOCK)
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
					--(	SELECT COUNT([K_MATERIAL_PROGRAMADO_LOG]) 
					--	FROM [MATERIAL_PROGRAMADO_LOG] (NOLOCK)
					--	WHERE SERIAL = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3)   
					--	AND K_TIPO_EVENTO_KIT >= 300 ) AS ENVIADO, -- DESDE QUE SE ESCANEA EN INSPEC. PERFO O CERTIFICACION YA NO SE PODRA REIMPRIMIR ETIQUETA
					-- ===========================
					(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
						FROM INVENTARIO_EMBARQUE (NOLOCK)
						WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
								OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  
						AND K_ESTATUS_INVENTARIO_EMBARQUE > 0) AS ENVIADO,
					-- ===========================
					@VP_TURNO	AS TURNO
					-- ===========================
			FROM ccjoblin_sql  (NOLOCK)
			-- ===========================
			INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
			AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
			AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
															FROM	cccusitm_sql (NOLOCK)
															WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
															AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
			-- ===========================
			WHERE	ccjoblin_sql.jobno = @PP_ORDEN 
			-- ===========================
			ORDER BY ccjoblin_sql.Ser_No
	END
		-----////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL]
GO

/*
	 EXEC [PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL] 1 ,144,  '40730' , '' , 011 , '40730011' , 'TEST SISTEMAS' , 'IT-010' 
*/

CREATE PROCEDURE [dbo].[PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN_PRINCIPAL			VARCHAR(50),
	@PP_ORDEN_COMPLEMENTO		VARCHAR(50),
	@PP_POS_KIT					INT,
	@PP_SERIAL					VARCHAR(50),
	@PP_COMENTARIO				VARCHAR(150),
	@PP_EQUIPO					VARCHAR(100)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''
	DECLARE @VP_CODIGO_CAMARA  VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	DECLARE @VP_N_SERIAL_FACTURADO INT = 0	
	SELECT @VP_N_SERIAL_FACTURADO = COUNT(K_INVENTARIO_EMBARQUE) 
	FROM INVENTARIO_EMBARQUE 
	WHERE SERIAL_1 = @PP_SERIAL
	AND K_ESTATUS_INVENTARIO_EMBARQUE IN (3, 4) -- FACTURADO

	IF @VP_N_SERIAL_FACTURADO IS NULL
		SET @VP_N_SERIAL_FACTURADO = 0

	IF @VP_N_SERIAL_FACTURADO > 0
		SET @VP_MENSAJE = 'El serial ya ha sido enviado con el Cliente!'

	-- ///////////////////////////////////////////
	DECLARE	@VP_CODIGO_ASIGNADO INT = 0
	SELECT	@VP_CODIGO_ASIGNADO = COUNT(ID)
	FROM	SERIALCAM_SQL (NOLOCK)
	WHERE	SERIAL = @PP_SERIAL

	IF @VP_CODIGO_ASIGNADO IS NULL
		SET @VP_CODIGO_ASIGNADO = 0

	IF @VP_CODIGO_ASIGNADO > 1
		SET @VP_MENSAJE = 'El serial tiene mas de un codigo Asignado!'

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				IF @VP_CODIGO_ASIGNADO = 1
					BEGIN
						IF LTRIM(RTRIM(@PP_COMENTARIO)) = ''
							RAISERROR ('ERROR: Por favor proporcione el motivo de la Reimpresión de la etiqueta!', 16, 1 ) --MENSAJE - Severity -State.

						-- ///////INGRESA EL LOG EN [MATERIAL_PROGRAMADO_LOG] DEL MATERIAL REETIQUETADO//////////////////////////////////////////////
						DECLARE @VP_ITEM_NO VARCHAR(100) = ''

						SELECT @VP_ITEM_NO = LTRIM(RTRIM(ITEM_NO))
						FROM ccjoblin_sql (NOLOCK) 
						WHERE LTRIM(RTRIM(ccjoblin_sql.jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) = @PP_SERIAL

						INSERT INTO [MATERIAL_PROGRAMADO_LOG]	
										(					
											[K_TIPO_EVENTO_KIT],			
											-- =====================				
											[SERIAL],					
											[ITEM_NO],				
											[USUARIO_EVENTO],			
											[ESTACION],				
											[K_RESPONSABLE],			
											[CODIGO_ETIQUETA],		
											[F_LOG],			
											-- ===========================
											[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
											[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									VALUES	
										(	1,	-- REIMPRESION DE ETIQURTA
											@PP_SERIAL,				
											@VP_ITEM_NO,				
											'REIMPRESION_ETIQUETA',			
											@PP_EQUIPO,						
											@PP_K_USUARIO_ACCION,		
											@PP_COMENTARIO,								
											GETDATE(),
											-- ===========================				
											@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
											0, NULL, NULL )	
							
							IF @@ROWCOUNT = 0
								RAISERROR ('ERROR: No fue posible guardar el Log de la Reimpresion en [PG_IN_MATERIAL_PROGRAMADO_LOG]', 16, 1 ) --MENSAJE - Severity -State.

						-- ///////SE OBTIENE EL CODIGO ASIGNADO AL SERIAL//////////////////////////////////////////////
						SELECT @VP_CODIGO_CAMARA = LTRIM(RTRIM(CODE))
						FROM SERIALCAM_SQL (NOLOCK)
						WHERE SERIAL = @PP_SERIAL

						IF @VP_CODIGO_CAMARA IS NULL OR @VP_CODIGO_CAMARA = ''
							RAISERROR ('ERROR: No fue posible Obtener el codigo asignado en [SERIALCAM_SQL]', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						-- ///////SE ACTUALIZA LA TABLA ccjoblin_sql PARA ESPECIFICAR QUE YA SE IMPRIMIO LA ETIQUETA DEL KIT//////////////////////////////////////////////
						UPDATE ccjoblin_sql
							SET User_def_Fld1 = 'Y'
						WHERE JOBNO = @PP_ORDEN_PRINCIPAL
						AND Ser_No = @PP_POS_KIT

						IF @@ROWCOUNT = 0
							RAISERROR ('ERROR: No fue posible Actualizar el kit en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.
						
						-- ///////SE OBTIENE UN CODIGO QUE AUN NO ESTE ASIGNADO//////////////////////////////////////////////
						SELECT TOP 1 @VP_CODIGO_CAMARA = LTRIM(RTRIM(CODE)) 
						FROM	SERIALCAM_SQL (NOLOCK)
						WHERE	SERIAL IS NULL 
						ORDER BY ID

						IF @VP_CODIGO_CAMARA IS NULL OR @VP_CODIGO_CAMARA = ''
							RAISERROR ('ERROR: No fue posible Obtener el codigo para el serial en [SERIALCAM_SQL]', 16, 1 ) --MENSAJE - Severity -State.

						IF @PP_ORDEN_COMPLEMENTO = ''
							BEGIN
								UPDATE SERIALCAM_SQL
									SET SERIAL = @PP_SERIAL
								WHERE CODE = @VP_CODIGO_CAMARA

								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Asignar el Serial en [SERIALCAM_SQL]', 16, 1 ) --MENSAJE - Severity -State.

							END
						ELSE
							BEGIN
								UPDATE SERIALCAM_SQL
									SET SERIAL = @PP_SERIAL,
										SERIAL2 = @PP_ORDEN_COMPLEMENTO
								WHERE CODE = @VP_CODIGO_CAMARA

								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Asignar el Serial en [SERIALCAM_SQL]', 16, 1 ) --MENSAJE - Severity -State.
							END
					END
			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_ASIGNAR_CODIGO_CAMARA_X_SERIAL] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible imprimir la Etiqueta del Serial: ' + '[' + @PP_SERIAL +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_CODIGO_CAMARA AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_POS_KIT, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
