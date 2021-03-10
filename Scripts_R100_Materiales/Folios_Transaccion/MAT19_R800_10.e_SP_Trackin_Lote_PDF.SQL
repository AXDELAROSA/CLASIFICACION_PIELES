-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / TRACKING LOTE
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/MAR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_TRACKING_LOTE_RESUMEN_PDF]
GO
/*
 EXECUTE	[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF] 0,0, '34301'
  EXECUTE	[dbo].[PG_TRACKING_LOTE_DETALLE_PDF] 0,0, '34301'
  
 EXECUTE	[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF] 0,0, '34331'
  EXECUTE	[dbo].[PG_TRACKING_LOTE_DETALLE_PDF] 0,0, '34331'
*/
CREATE PROCEDURE [dbo].[PG_TRACKING_LOTE_RESUMEN_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(20)
AS

	-- ////////////SE CREA TABLA TEMPORAL///////////////////////////////
	DECLARE @VP_TBL_SUMARY_X_LOTE AS TABLE(
		ID			INT IDENTITY(1,1),
		LOCACION	VARCHAR(20),
		TOTAL_PIEL	INT,
		TOTAL_SQF	DECIMAL(13,2)
	)
	
	-- ///////SE INGRESA EL SUMARY DE LO RECIVIDO/IMPORTADO////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT 'RECEIVED',
			COUNT(HIDESLIN_SQL.ID),
			SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF))))
	FROM HIDESHDR_SQL   
	INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	PLOT = @PP_LOTE

	-- ///////SE INGRESA EL SUMARY DE LAS LOCACIONES QUE NO SON DE PRODUCCION////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	LTRIM(RTRIM(MOVEMENT)),
			COUNT(ID),
			SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF))))
	FROM RP_SC
	WHERE LOT = @PP_LOTE
	AND SUBSTRING(LTRIM(RTRIM(MOVEMENT)), 1,1 ) NOT IN ('T', 'G') 
	GROUP BY LTRIM(RTRIM(MOVEMENT))

	-- ///////SE INGRESA EL SUMARY DE LAS LOCACIONES QUE SON DE PRODUCCION////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	'WIP',
			COUNT(ID),
			SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF))))
	FROM RP_SC
	WHERE LOT = @PP_LOTE
	AND SUBSTRING(LTRIM(RTRIM(MOVEMENT)), 1,1 ) IN ('T', 'G')
	
	-- ///////SE INGRESA EL SUMARY DE PIELES DE ORDENES CERRADAS////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	'INVOICED',
			COUNT(ID),
			SUM(CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF))))
	FROM RP_SC_FOLIO_STATUS_XX
	WHERE LOT = @PP_LOTE
	AND SUBSTRING(LTRIM(RTRIM(MOVEMENT)), 1,1 ) IN ('T', 'G') 

	-- ///////SE INGRESA EL SUMARY DE PIELES SOBRANTES O FALTANTES////////////////////////////////////
	-- ////////////SE CREA TABLA TEMPORAL///////////////////////////////
	DECLARE @VP_TBL_PIEL_X_SOBRANTE AS TABLE(
		ID			INT IDENTITY(1,1),
		PIEL		VARCHAR(10),
		SQF			DECIMAL(13,2)
	)

	-- //////////SE INGRESAN LAS PIELES QUE NO FUERON IMPORTADAS/////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_SOBRANTE
	SELECT	LTRIM(RTRIM(HIDE)),			
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF)))
	FROM RP_SC
	WHERE LOT = @PP_LOTE
	AND HIDE NOT IN (	SELECT HIDE
						FROM HIDESHDR_SQL   
						INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						WHERE	PLOT = @PP_LOTE )

	-- ///////SE INGRESAN LAS PIELES QUE NO FUERON IMPORTADAS DE ORDENES CERRADAS////////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_SOBRANTE
	SELECT	LTRIM(RTRIM(HIDE)),				
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF))) 
	FROM RP_SC_FOLIO_STATUS_XX
	WHERE LOT = @PP_LOTE
	AND HIDE NOT IN (	SELECT HIDE
						FROM HIDESHDR_SQL   
						INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						WHERE	PLOT = @PP_LOTE )

	-- ///////SE INGRESA EL SUMARY DE LO SOBRANTE////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	'EXCESS',
			COUNT(ID),
			ISNULL(SUM(SQF), 0)
	FROM @VP_TBL_PIEL_X_SOBRANTE

	-- ////////////SE CREA TABLA TEMPORAL///////////////////////////////
	DECLARE @VP_TBL_PIEL_X_FALTANTE AS TABLE(
		ID			INT IDENTITY(1,1),
		PIEL		VARCHAR(10),
		SQF			DECIMAL(13,2)
	)

	INSERT INTO @VP_TBL_PIEL_X_FALTANTE
	SELECT  HIDE,
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF)))
	FROM HIDESHDR_SQL   
	INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	PLOT = @PP_LOTE
	AND	HIDE NOT IN ( SELECT HIDE FROM RP_SC WHERE LOT = @PP_LOTE )
		
	--////////SE BORRA EL CONTENIDO DE LA TABLA TEMPORAL ANTERIOR PARA REUTILIZARLA////////////////////////////////////////////////////////
	DELETE @VP_TBL_PIEL_X_SOBRANTE

	INSERT INTO @VP_TBL_PIEL_X_SOBRANTE
	SELECT  PIEL,
			SQF
	FROM @VP_TBL_PIEL_X_FALTANTE   
	WHERE PIEL NOT IN (	SELECT HIDE FROM RP_SC_FOLIO_STATUS_XX WHERE LOT = @PP_LOTE )

	-- ///////SE EL SUMARY DE LO FALTANTE////////////////////////////////////
	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	'NOT FOUND',
			COUNT(ID),
			ISNULL(SUM(SQF), 0)
	FROM @VP_TBL_PIEL_X_SOBRANTE

	-- ///////SE OBTIENE EL TOTAL DE PIELES Y SQF DE LO NO RECIBIDO////////////////////////////////////
	DECLARE @VP_TOTAL_PIEL INT = 0, @VP_TOTAL_SQF DECIMAL(13,2) = 0
	
	SELECT	@VP_TOTAL_PIEL = SUM(TOTAL_PIEL),
			@VP_TOTAL_SQF = SUM(TOTAL_SQF)
	FROM @VP_TBL_SUMARY_X_LOTE 
	WHERE TOTAL_PIEL > 0
	AND LOCACION <> 'RECEIVED'

	INSERT INTO @VP_TBL_SUMARY_X_LOTE
	SELECT	'TOTAL',
			@VP_TOTAL_PIEL,
			@VP_TOTAL_SQF

	-----////////////////////////////////////////////////////////////////
	SELECT * FROM @VP_TBL_SUMARY_X_LOTE WHERE TOTAL_PIEL > 0

	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_TRACKING_LOTE_YIELD_RESUMEN_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_TRACKING_LOTE_YIELD_RESUMEN_PDF]
GO
/*
 EXECUTE	[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF] 0,0, '34301'
 EXECUTE	[dbo].[PG_TRACKING_LOTE_DETALLE_PDF] 0,0, '34301'
 EXECUTE	[dbo].[PG_TRACKING_LOTE_YIELD_RESUMEN_PDF] 0,0, '34301'

 EXECUTE	[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF] 0,0, '34331'
 EXECUTE	[dbo].[PG_TRACKING_LOTE_DETALLE_PDF] 0,0, '34331'
 EXECUTE	[dbo].[PG_TRACKING_LOTE_YIELD_RESUMEN_PDF] 0,0, '34331'
*/
CREATE PROCEDURE [dbo].[PG_TRACKING_LOTE_YIELD_RESUMEN_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(20)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_NET_SQM DECIMAL(13,2) = 0, @VP_GROSS_SQM DECIMAL(13,2) = 0, @VP_YIELD DECIMAL(13,2) = 0

	SELECT	@VP_NET_SQM = SUM(CONVERT(DECIMAL(13,2),NetSqm)),
			@VP_GROSS_SQM = SUM(CONVERT(DECIMAL(13,2),GrossSqm)) 
	FROM JOBSCOMP 
	WHERE PACKNO = RIGHT('000000' + @PP_LOTE, 6)


	SET @VP_YIELD =  ( @VP_NET_SQM / @VP_GROSS_SQM ) * 100

	SELECT @VP_YIELD AS YIELD
	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_TRACKING_LOTE_DETALLE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_TRACKING_LOTE_DETALLE_PDF]
GO
/*
  EXECUTE	[dbo].[PG_TRACKING_LOTE_RESUMEN_PDF] 0,0, '34331'
  EXECUTE	[dbo].[PG_TRACKING_LOTE_DETALLE_PDF] 0,0, '34331'
*/
CREATE PROCEDURE [dbo].[PG_TRACKING_LOTE_DETALLE_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(20)
AS

	-- ////////////SE CREA TABLA TEMPORAL///////////////////////////////
	DECLARE @VP_TBL_PIEL_X_LOTE AS TABLE(
		ID			INT IDENTITY(1,1),
		LOCACION	VARCHAR(20),
		COLOR		VARCHAR(20),
		LOTE		VARCHAR(20),
		PIEL		VARCHAR(10),
		SQF			DECIMAL(13,2),
		FOLIO		INT,
		ORDEN		VARCHAR(20)
	)

	-- //////////SE INGRESAN LAS PIELES QUE SE ENCUENTRAN EN RP_SC/////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_LOTE
	SELECT	LTRIM(RTRIM(MOVEMENT)),
			LTRIM(RTRIM(COLOUR)),
			RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) ,
			LTRIM(RTRIM(HIDE)),
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF))),
			TAGNO,
			-- ===========================
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(MOVEMENT)), 1,1) IN ('T', 'G')
					THEN (  SELECT TOP 1 ISNULL(JOBNO, '') 
							FROM RP_Folios 
							WHERE TAG = TAGNO	) 
					ELSE 'N/A' END) AS ORDEN
			-- ===========================
	FROM RP_SC
	WHERE LOT = @PP_LOTE
	ORDER BY MOVEMENT, HIDE

	-- ///////SE INGRESAN LAS PIELES DE ORDENES CERRADAS QUE SE ENCUENTRAN EN RP_SC_FOLIO_STATUS_XX////////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_LOTE
	SELECT	LTRIM(RTRIM('INVOICED')),
			LTRIM(RTRIM(COLOUR)),
			RIGHT('000000' + LTRIM(RTRIM(LOT)), 6),
			LTRIM(RTRIM(HIDE)),
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF))) AS SQF,
			TAGNO,
			-- ===========================
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(MOVEMENT)), 1,1) IN ('T', 'G')
					THEN (  SELECT TOP 1 ISNULL(JOBNO, '') 
							FROM RP_Folios 
							WHERE TAG = TAGNO	) 
					ELSE 'N/A' END) AS ORDEN
			-- ===========================
	FROM RP_SC_FOLIO_STATUS_XX
	WHERE LOT = @PP_LOTE
	ORDER BY MOVEMENT, HIDE

	--SELECT * FROM RP_SC_FOLIO_STATUS_XX WHERE LOT = '34331' AND HIDE = 0810

	--UPDATE RP_SC_FOLIO_STATUS_XX --0810 
	--	SET HIDE = '0810' 
	--WHERE ID = 5010212

	-- /////SE INGRESAN LAS PIELES QUE NO SE IMPORTARON//////////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_LOTE
	SELECT 'EXCESS',
		   COLOR,	
		   LOTE,	
		   PIEL,	
		   SQF,		
		   FOLIO,	
		   ORDEN
	FROM @VP_TBL_PIEL_X_LOTE
	WHERE LOTE = RIGHT('000000' + @PP_LOTE, 6)	--@PP_LOTE
	AND PIEL NOT IN (	SELECT HIDE
						FROM HIDESHDR_SQL   
						INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						WHERE	PLOT = @PP_LOTE )

	-- /////SE INGRESAN LAS PIELES QUE SE IMPORTARON PERO NO ESTAN EN RP_SC NI EN ORDENES CERRADAS//////////////////////////////////////
	INSERT INTO @VP_TBL_PIEL_X_LOTE
	SELECT 'NOT FOUND',
			PCOLOR,
			RIGHT('000000' + LTRIM(RTRIM(PLOT)), 6),
			HIDE,
			LTRIM(RTRIM(CONVERT(DECIMAL(13,2),SQF))) AS SQF,
			0,
			''
	FROM HIDESHDR_SQL   
	INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	WHERE	PLOT = @PP_LOTE
	AND	HIDE NOT IN (SELECT PIEL FROM @VP_TBL_PIEL_X_LOTE )
	
	-- /////SE MUESTRA EL RESULTADO//////////////////////////////////////
	SELECT ID,
			LOCACION,
		   COLOR,	
		   LOTE,	
		   PIEL,	
		   SQF,		
		   FOLIO,	
		   ORDEN,
		   -- ===========================
		   ( CASE WHEN JOBNO IS NULL THEN 0
				ELSE CONVERT(DECIMAL(13,2), (rawpatternsqm / hidesqm) * 100) END ) AS YIELD,
		   -- ===========================
		   ( CASE	WHEN SUBSTRING(LTRIM(RTRIM(LOCACION)), 1,1) NOT IN ('T', 'G', 'F') AND JOBNO IS NULL THEN ''
					WHEN SUBSTRING(LTRIM(RTRIM(LOCACION)), 1,1) IN ('T', 'G', 'F') AND JOBNO IS NULL THEN 'PENDING'
				ELSE	'CUT' END ) AS ESTATUS
		  -- ===========================
	FROM @VP_TBL_PIEL_X_LOTE AS PIEL_DISPONIBLE
	LEFT JOIN cccuthst_sql ON PIEL_DISPONIBLE.ORDEN = cccuthst_sql.jobno AND LTRIM(RTRIM(cccuthst_sql.lotno)) = PIEL_DISPONIBLE.LOTE AND PIEL_DISPONIBLE.PIEL = cccuthst_sql.hideno
	ORDER BY ID
	
	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
