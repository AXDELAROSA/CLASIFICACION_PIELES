-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	21/ABR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PART_NO_X_CLIENTE_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PART_NO_X_CLIENTE_COLOR]
GO

/*
	 EXEC [PG_LI_PART_NO_X_CLIENTE_COLOR] 0 ,0, 'MAGN02' , 'FWLNPX7' , '( TODOS )' , '' , 0
	 EXEC [PG_LI_PART_NO_X_CLIENTE_COLOR] 0 ,0, 'YANG03' , 'FYCPAX7' , '( TODOS )' , '' , 0 
*/

CREATE PROCEDURE [dbo].[PG_LI_PART_NO_X_CLIENTE_COLOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_MESA					VARCHAR(50),
	@PP_MODELO					VARCHAR(50),
	@PP_OPCION					INT
AS

	-- ///////////SE CREA TABLA TEMPORAL////////////////////////////////
	SET NOCOUNT ON
	DECLARE @TBL_ITEM_X_CLIENTE_COLOR AS TABLE(
	ID			INT IDENTITY(1,1),
	ITEM_NO		VARCHAR(100),
	COLOR		VARCHAR(50),
	CUS_ITEM_NO	VARCHAR(50),
	CUSTOMER	VARCHAR(50),
	VERSIONNO	VARCHAR(50),
	MODELNO		VARCHAR(50)
	)

	-- ///////////SE INGRESAN LOS DATOS LOS NUMEROS DE PARTES VIGENTES A LA TABLA TEMPORAL////////////////////////////////
	-- part_no_view CORRECTA
	INSERT INTO @TBL_ITEM_X_CLIENTE_COLOR
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
		AND L_ACTIVO = 1
	INNER JOIN  IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
		AND IMCATFIL_SQL.L_BORRADO = 0
	WHERE ccverhdr_sql.specstatus = 'U' 
	AND ccverhdr_sql.status = 'L' 
	AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = @PP_COLOR 
	AND ccverhdr_sql.cus_no = @PP_CLIENTE 
	ORDER BY cus_item_no

	--SELECT * FROM @TBL_ITEM_X_CLIENTE_COLOR

	-- ///////////SE CREA TABLA TEMPORAL////////////////////////////////
	CREATE TABLE #ITEM_EN_MESA (
	ID					INT IDENTITY(1,1),
	KIT					VARCHAR(100),
	ITEM_NO				VARCHAR(100),
	D_ITEM_NO			VARCHAR(255),
	COLOR				VARCHAR(50),
	CUSTOMER			VARCHAR(50),
	CUS_PART_NO			VARCHAR(50),
	VERSIONNO			VARCHAR(50),
	MODELNO				VARCHAR(50),
	ORDEN				VARCHAR(50),
	MESA				VARCHAR(50),
	NET_SQM				VARCHAR(50),--DECIMAL(13,4),
	STANDARD_SQM		VARCHAR(50),--DECIMAL(13,4),
	INICIO_CORTE		VARCHAR(50),--VARCHAR(10),
	CANTIDAD_PROGRAMADA	VARCHAR(50) --INT
	)

	-- ///////////SE INGRESAN LOS DATOS LOS KIT PROGRAMADOS A LA TABLA TEMPORAL////////////////////////////////
	INSERT #ITEM_EN_MESA
	SELECT	LEFT(LTRIM(RTRIM(ITEM_X_CLIENTE_COLOR.ITEM_NO)),7) AS KIT,
			LTRIM(RTRIM(ITEM_X_CLIENTE_COLOR.ITEM_NO)),		
			LTRIM(RTRIM(item_desc_1))	AS	KIT_DESCRIPCION,
			LTRIM(RTRIM(COLOR)),
			LTRIM(RTRIM(ITEM_X_CLIENTE_COLOR.CUSTOMER)),	
			LTRIM(RTRIM(CUS_ITEM_NO)),	
			LTRIM(RTRIM(VERSIONNO)),	
			LTRIM(RTRIM(MODELNO)),
			ISNULL(LTRIM(RTRIM(ccjoblin_sql.JOBNO)), 'N/P') AS ORDEN,
			--==================================================
			( CASE WHEN LTRIM(RTRIM(ccjoblin_sql.JOBNO)) IS NULL THEN ''
					ELSE LTRIM(RTRIM(ccjobhdr_sql.MACHINE)) END ) AS MESA,
			--==================================================
			( CASE WHEN LTRIM(RTRIM(ccjoblin_sql.JOBNO)) IS NULL THEN 0
					ELSE ISNULL(ccjobhdr_sql.netsqm, 0) END ) AS NET_SQM,
			--==================================================
			( CASE WHEN LTRIM(RTRIM(ccjoblin_sql.JOBNO)) IS NULL THEN 0
					ELSE ISNULL(ccjobhdr_sql.standardsqm, 0) END ) AS STANDARD_SQM,
			--==================================================
			( CASE WHEN LTRIM(RTRIM(startedflag)) = 'Y' THEN 'Y'
					ELSE 'N' END ) AS INICIO_CORTE,
			--==================================================
			--ISNULL(OriginalQty, 0) CANTIDAD_PROGRAMADA
			( CASE WHEN OriginalQty IS NULL THEN '0'
					ELSE (SELECT SUM(OriginalQty) FROM ccjoblin_sql WHERE JOBNO = ccjobhdr_sql.JOBNO AND ITEM_NO = ITEM_X_CLIENTE_COLOR.ITEM_NO) END ) AS CANTIDAD_PROGRAMADA
	FROM @TBL_ITEM_X_CLIENTE_COLOR AS ITEM_X_CLIENTE_COLOR
	INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = ITEM_X_CLIENTE_COLOR.item_no
	LEFT JOIN ccjobhdr_sql ON  status='P' AND CONCAT('F', ccjobhdr_sql.colour) = ITEM_X_CLIENTE_COLOR.COLOR
		AND ccjobhdr_sql.CUSTOMER = ITEM_X_CLIENTE_COLOR.CUSTOMER
		AND ccjobhdr_sql.JOBNO < 50000 
		AND LTRIM(RTRIM(ccjobhdr_sql.MACHINE)) = (CASE	WHEN @PP_MESA = '( TODOS )' THEN machine
														ELSE @PP_MESA END)
		AND SUBSTRING(LTRIM(RTRIM(ccjobhdr_sql.MACHINE)), 1, 1) = 'T'
	LEFT JOIN ccjoblin_sql ON  ccjoblin_sql.jobno=ccjobhdr_sql.jobno AND ITEM_X_CLIENTE_COLOR.item_no = ccjoblin_sql.item_no
	ORDER BY ITEM_X_CLIENTE_COLOR.item_no, ccjobhdr_sql.JOBNO
	
	DECLARE @VP_N_KITS INT = 0
	SELECT @VP_N_KITS = COUNT(ID) 
	FROM #ITEM_EN_MESA

	IF @VP_N_KITS IS NULL
		SET @VP_N_KITS = 0
	
	IF @VP_N_KITS > 0
		BEGIN
			DECLARE @VP_N_ORDEN INT = 0
			SELECT @VP_N_ORDEN = COUNT(ORDEN) 
			FROM #ITEM_EN_MESA
			WHERE ORDEN <> 'N/P'

			IF @VP_N_ORDEN IS NULL
				SET @VP_N_ORDEN = 0
			
			IF @VP_N_ORDEN > 0
				BEGIN
					-- ////////////////////SE OBTIENEN LOS DATOS DE LOS PACKING DINAMICAMENTE QUE SE CONVERTIRAN EN LAS COLUMNAS DE LA TABLA//////////////////////////	
					DECLARE @cols1 AS NVARCHAR(MAX), @query1 AS NVARCHAR(MAX)
					select @cols1 = STUFF(( SELECT ',' + QUOTENAME(ORDEN) 
											FROM #ITEM_EN_MESA  
											WHERE ORDEN <> 'N/P'
											GROUP BY ORDEN
											ORDER BY ORDEN
											FOR XML PATH(''), TYPE ).value('.', 'NVARCHAR(MAX)') ,1,1,'' ) 					
					--SELECT @cols1

					SET @query1 = N'SELECT  ''''  KIT, ''''  CUS_PART_NO, ''Machine'' D_ITEM_NO, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[MESA_X_ORDEN]  from ( SELECT  MESA, ORDEN  from #ITEM_EN_MESA GROUP BY MESA, ORDEN) x pivot ( MAX(MESA) for ORDEN in (' + @cols1 + N') ) p ' 
					EXEC sp_executesql @query1;
					--SELECT * FROM [tempdb].[dbo].[MESA_X_ORDEN]

					SET @query1 = N'SELECT  ''''  KIT, ''''  CUS_PART_NO, ''Gross'' D_ITEM_NO, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[GROSS_X_ORDEN]  from ( SELECT  STANDARD_SQM, ORDEN  from #ITEM_EN_MESA GROUP BY STANDARD_SQM, ORDEN) x pivot ( MAX(STANDARD_SQM) for ORDEN in (' + @cols1 + N') ) p ' 
					EXEC sp_executesql @query1;
					--SELECT * FROM [tempdb].[dbo].[GROSS_X_ORDEN]

					SET @query1 = N'SELECT  ''''  KIT, ''''  CUS_PART_NO, ''Net SF'' D_ITEM_NO, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[NETO_X_ORDEN]  from ( SELECT  NET_SQM, ORDEN  from #ITEM_EN_MESA GROUP BY NET_SQM, ORDEN) x pivot ( MAX(NET_SQM) for ORDEN in (' + @cols1 + N') ) p ' 
					EXEC sp_executesql @query1;
					--SELECT * FROM [tempdb].[dbo].[NETO_X_ORDEN]

					SET @query1 = N'SELECT  ''''  KIT, ''''  CUS_PART_NO, ''Started?'' D_ITEM_NO, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[CORTADA_X_ORDEN]  from ( SELECT  INICIO_CORTE, ORDEN  from #ITEM_EN_MESA GROUP BY INICIO_CORTE, ORDEN) x pivot ( MAX(INICIO_CORTE) for ORDEN in (' + @cols1 + N') ) p ' 
					EXEC sp_executesql @query1;
					--SELECT * FROM [tempdb].[dbo].[CORTADA_X_ORDEN]

					SET @query1 = N'SELECT   KIT, CUS_PART_NO, D_ITEM_NO, '''' CANTIDAD, ' + @cols1 + N' into [tempdb].[dbo].[KIT_X_ORDEN]  from ( SELECT  KIT, CUS_PART_NO, D_ITEM_NO, CANTIDAD_PROGRAMADA, ORDEN from #ITEM_EN_MESA) x pivot ( MAX(CANTIDAD_PROGRAMADA) for ORDEN in (' + @cols1 + N') ) p ' 
					EXEC sp_executesql @query1;
					--SELECT * FROM [tempdb].[dbo].[KIT_X_ORDEN]
					
					-- ///////SE CREA TABLA TEMPORAL [KIT_DISPONIBLE_PROGRAMADO] CON DATOS DE TABLA TEMPORAL [KIT_X_ORDEN]/////////////////////////////////////////
					SELECT * INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO] FROM [tempdb].[dbo].[KIT_X_ORDEN]

					-- ///////SE BORRAN LOS DATOS DE TABLA TEMPORAL [KIT_DISPONIBLE_PROGRAMADO]/////////////////////////////////////////
					DELETE [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]

					-- ///////SE COPIAN LOS DATOS DE TABLA TEMPORALES A [KIT_DISPONIBLE_PROGRAMADO]/////////////////////////////////////////
					INSERT INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
					SELECT * FROM [tempdb].[dbo].[MESA_X_ORDEN]

					INSERT INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
					SELECT * FROM [tempdb].[dbo].[GROSS_X_ORDEN]

					INSERT INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
					SELECT * FROM [tempdb].[dbo].[NETO_X_ORDEN]

					INSERT INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
					SELECT * FROM [tempdb].[dbo].[CORTADA_X_ORDEN]

					INSERT INTO [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
					SELECT * FROM [tempdb].[dbo].[KIT_X_ORDEN]
					
					SET NOCOUNT OFF
					SELECT * FROM [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO] ORDER BY CUS_PART_NO

					SET NOCOUNT ON
					--DROP TABLE #ITEM_EN_MESA
					DROP TABLE [tempdb].[dbo].[MESA_X_ORDEN]
					DROP TABLE [tempdb].[dbo].[GROSS_X_ORDEN]
					DROP TABLE [tempdb].[dbo].[NETO_X_ORDEN]
					DROP TABLE [tempdb].[dbo].[CORTADA_X_ORDEN]
					DROP TABLE [tempdb].[dbo].[KIT_X_ORDEN]
					DROP TABLE [tempdb].[dbo].[KIT_DISPONIBLE_PROGRAMADO]
				END
			ELSE
				BEGIN
					INSERT INTO  #ITEM_EN_MESA
					SELECT '', '', '', '', '',  '', '', '', '', '', '', '', '', 'Machine'

					INSERT INTO  #ITEM_EN_MESA
					SELECT '', '', '', '', '',  '', '', '', '', '', '', '', '', 'Gross'

					INSERT INTO  #ITEM_EN_MESA
					SELECT '', '', '', '', '',  '', '', '', '', '', '', '', '', 'Net SF'

					INSERT INTO  #ITEM_EN_MESA
					SELECT '', '', '', '', '',  '', '', '', '', '', '', '', '', 'Started?'

					SET NOCOUNT OFF
					SELECT	KIT, 
							CUS_PART_NO, 
							D_ITEM_NO, 
							CANTIDAD_PROGRAMADA AS CANTIDAD
					FROM #ITEM_EN_MESA
					ORDER BY CUS_PART_NO
				END
		END
	
		DROP TABLE #ITEM_EN_MESA
		
	--////////////////////////////////////////////////////////////////
	 --	EXEC [PG_LI_PART_NO_X_CLIENTE_COLOR] 0 ,0, 'MAGN03' , 'FCNPJRR' , '( TODOS )' , '' , 0
	 --	EXEC [PG_LI_PART_NO_X_CLIENTE_COLOR] 0 ,0, 'YANG03' , 'FYCPAX7' , '( TODOS )' , '' , 0 
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_GROSS_NETO_X_KIT_PROGRAMADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_GROSS_NETO_X_KIT_PROGRAMADO]
GO

/*
 EXEC PG_GET_GROSS_NETO_X_KIT_PROGRAMADO 0 ,0,  'MAGN03', 'FCNPJRR', 'PW2FDVL', 3  
*/

CREATE PROCEDURE [dbo].[PG_GET_GROSS_NETO_X_KIT_PROGRAMADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_KIT						VARCHAR(50),
	@PP_CANTIDAD				INT
AS

	-- /////////SE OBTIENE LA UTILIDAD//////////////////////////////////
	DECLARE @VP_UTILIDAD_MINIMA DECIMAL(13,2) = 0
	SELECT @VP_UTILIDAD_MINIMA = User_Def_Fld_2
	FROM arcusfil_sql 
	WHERE CUS_NO = @PP_CLIENTE

	IF @VP_UTILIDAD_MINIMA IS NULL
		SET @VP_UTILIDAD_MINIMA = 0

	SET @VP_UTILIDAD_MINIMA = @VP_UTILIDAD_MINIMA / 1000000

	-- ////////SE FORMA EL ITEM_NO///////////////////////////////////
	DECLARE @VP_ITEM_NO VARCHAR(20) = @PP_KIT + SUBSTRING(@PP_COLOR, 2, 10)
	DECLARE @VP_CUBE_LENGTH DECIMAL(13,4) = 0, @VP_CUBE_WIDTH DECIMAL(13,4) = 0, @VP_CUBE_QTY_PER DECIMAL(13,4) = 0;

	-- ////////SE OBTIENE EL GROSS, NETO Y PATRONES DEL KIT///////////////////////////////////
	SELECT TOP 1 @VP_CUBE_LENGTH	= CUBE_LENGTH,
			@VP_CUBE_WIDTH			= CUBE_WIDTH,
			@VP_CUBE_QTY_PER		= CUBE_QTY_PER
	FROM IMITMIDX_SQL   
	WHERE	LTRIM(RTRIM(ITEM_NO)) = @VP_ITEM_NO

	IF @VP_CUBE_LENGTH IS NULL
		SET @VP_CUBE_LENGTH = 0

	IF @VP_CUBE_WIDTH IS NULL
		SET @VP_CUBE_WIDTH = 0

	IF @VP_CUBE_QTY_PER IS NULL
		SET @VP_CUBE_QTY_PER = 0

	DECLARE @VP_GROSS DECIMAL(16,4) = 0, @VP_NETO DECIMAL(16,4) = 0, @VP_PATRON INT = 0; 

	SET @VP_GROSS	= @VP_CUBE_LENGTH	* @PP_CANTIDAD
	SET @VP_NETO	= @VP_CUBE_WIDTH	* @PP_CANTIDAD
	SET @VP_PATRON	= @VP_CUBE_QTY_PER	* @PP_CANTIDAD

	SELECT	@VP_UTILIDAD_MINIMA	AS UTILIDAD,
			@VP_GROSS			AS GROSS,
			@VP_NETO			AS NETO,
			@VP_PATRON			AS N_PATRON
	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_KIT_PROGRAMADO_X_ORDEN_EN_CCJOBLIN_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_KIT_PROGRAMADO_X_ORDEN_EN_CCJOBLIN_SQL]
GO

/*
 EXEC PG_GET_KIT_PROGRAMADO_X_ORDEN_EN_CCJOBLIN_SQL 0 ,0,  '18518'
 EXEC PG_GET_KIT_PROGRAMADO_X_ORDEN_EN_CCJOBLIN_SQL 0 ,0,  '29487'
*/

CREATE PROCEDURE [dbo].[PG_GET_KIT_PROGRAMADO_X_ORDEN_EN_CCJOBLIN_SQL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50)	
AS

		-- ///////////////////////////////////////////
	SELECT	JOBNO, 
			(	SELECT COUNT(K_INVENTARIO_EMBARQUE) 
				FROM INVENTARIO_EMBARQUE 
				WHERE (	SERIAL_1 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) 
						OR SERIAL_2 = LTRIM(RTRIM(jobno)) + RIGHT('000'+ LTRIM(RTRIM(ser_no)),3) )  ) AS MFP,
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
			LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
			ccjoblin_sql.plannedqty					AS PLANNED_QTY, 
			ccjoblin_sql.completedqty				AS COMPLETED_QTY, 
			CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
			ccjoblin_sql.netsqmper					AS NETSQMPER, 
			ccjoblin_sql.stdsqmper					AS STDSQMPER, 
			ccjoblin_sql.patternsper				AS PATTERNSPER, 
			LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
			ccjoblin_sql.item_no					AS ITEM_NO,
			ccjoblin_sql.Ser_No						AS SER_NO,
			-- ===========================
			LTRIM(RTRIM(part_no_view.cus_item_no))	AS CUS_ITEM_NO
			-- ===========================
	FROM ccjoblin_sql  
	-- ===========================
	INNER JOIN	part_no_view ON ccjoblin_sql.Item_No = part_no_view.item_no 
		AND		ccjoblin_sql.customer = part_no_view.Customer  
		AND		part_no_view.versionno = (	SELECT	MAX(versionno) 
												FROM	part_no_view 
												WHERE	ccjoblin_sql.Item_No = part_no_view.item_no  
												AND		ccjoblin_sql.customer = part_no_view.Customer	)
		AND SUBSTRING(LTRIM(RTRIM(CHANGELEVEL)), 1, 3) = LTRIM(RTRIM(MODELNO))
	-- ===========================
	WHERE	ccjoblin_sql.jobno = @PP_ORDEN 
	-- ===========================
    ORDER BY CUS_ITEM_NO
    --ORDER BY ccjoblin_sql.Ser_No
	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_KIT_DISPONIBLE_X_CLIENTE_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_KIT_DISPONIBLE_X_CLIENTE_COLOR]
GO

/*
 EXEC PG_GET_KIT_DISPONIBLE_X_CLIENTE_COLOR 0 ,0, 'MAGN03', 'FCNPJRR'
*/

CREATE PROCEDURE [dbo].[PG_GET_KIT_DISPONIBLE_X_CLIENTE_COLOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50)
AS

		-- ///////////////////////////////////////////
		-- ///////////SE CREA TABLA TEMPORAL////////////////////////////////
	SET NOCOUNT ON
	DECLARE @TBL_KIT_DISPONIBLE_X_CLIENTE_COLOR AS TABLE(
	ID			INT IDENTITY(1,1),
	KIT			VARCHAR(50),
	ITEM_NO		VARCHAR(100),
	COLOR		VARCHAR(50),
	CUS_ITEM_NO	VARCHAR(50),
	D_ITEM_NO	VARCHAR(250),
	CUSTOMER	VARCHAR(50),
	VERSIONNO	VARCHAR(50),
	MODELNO		VARCHAR(50)
	)

	-- ///////////SE INGRESAN LOS DATOS LOS NUMEROS DE PARTES VIGENTES A LA TABLA TEMPORAL////////////////////////////////
	-- part_no_view CORRECTA
	INSERT INTO @TBL_KIT_DISPONIBLE_X_CLIENTE_COLOR
	SELECT	DISTINCT TOP (100) PERCENT 
			LEFT(LTRIM(RTRIM(cccusitm_sql.ITEM_NO)),7) AS KIT,
			 cccusitm_sql.item_no, 
			 CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) AS COLOR, 
			 LTRIM(RTRIM(cus_item_no)) AS cus_item_no, 
			 LTRIM(RTRIM(item_desc_1)) D_ITEM_NO, 
			 ccverhdr_sql.cus_no AS Customer, 
			 ccverhdr_sql.versionno, 
			 ccverhdr_sql.modelno
	FROM	dbo.ccverhdr_sql
	INNER JOIN cccusitm_sql ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
		AND SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)  = 'P' 
		AND cus_item_no <> ''
	INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = cccusitm_sql.item_no 
		AND L_ACTIVO = 1
	INNER JOIN  IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
		AND IMCATFIL_SQL.L_BORRADO = 0
	WHERE ccverhdr_sql.specstatus = 'U' 
	AND ccverhdr_sql.status = 'L' 
	AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = @PP_COLOR 
	AND ccverhdr_sql.cus_no = @PP_CLIENTE 
	ORDER BY cus_item_no

	SET NOCOUNT OFF
	SELECT * FROM @TBL_KIT_DISPONIBLE_X_CLIENTE_COLOR
	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
