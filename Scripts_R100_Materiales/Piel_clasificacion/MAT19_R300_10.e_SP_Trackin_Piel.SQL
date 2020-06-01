-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	13/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
--	USE DATA_02	--Pruebas
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRACKING_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRACKING_PIEL]
GO
/*
 EXEC DBO.[PG_LI_TRACKING_PIEL] 0,0, 'FMCKTX7', '', '', '0431', '11196', '(PENDIENTE)'
*/
CREATE PROCEDURE [dbo].[PG_LI_TRACKING_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(10),
	@PP_FOLIO					INT,
	@PP_PIEL					VARCHAR(10),
	@PP_ORDEN					VARCHAR(10),
	@PP_D_CLASIFICACION			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
	/*
	SELECT TOP 10 * FROM RP_SC WHERE TAGNO = '3788351'
	SELECT TOP 10 * FROM RP_Folios
	*/

	SELECT  DISTINCT
			ISNULL(RP_SC.COLOUR, '')		AS COLOUR,
			ISNULL(LOT, '')					AS LOT,
			ISNULL(HIDE, '')				AS HIDE,
			ISNULL(SQF, '')					AS SQF,
			ISNULL(D_PIEL_CLASIFICACION,'') AS CLASIFICACION,
			ISNULL(TAGNO, 0)				AS TAGNO,
			ISNULL(RP_Folios.STATUS, '')	AS STATUS_FOLIO,
			ISNULL(RP_Folios.MACHINE, '')	AS MACHINE,
			ISNULL(CCJOBHDR_SQL.JOBNO, '')	AS JOBNO,
			ISNULL(CCJOBHDR_SQL.STATUS, '')	AS STATUS_ORDEN
	-- =======================
	FROM	RP_SC
	-- =======================
	INNER JOIN	RP_Folios ON RP_Folios.TAG=RP_SC.TAGNO 
	INNER JOIN	PIEL_CLASIFICACION ON RP_SC.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
	LEFT  JOIN	CCJOBHDR_SQL ON RP_Folios.JOBNO = CCJOBHDR_SQL.jobno  
	WHERE	LTRIM(RTRIM(RP_SC.COLOUR)) =( CASE	WHEN @PP_COLOR = '' THEN RP_SC.COLOUR
												ELSE @PP_COLOR	
											END )
	AND		LTRIM(RTRIM(LOT)) =			( CASE	WHEN @PP_LOTE = '' THEN LOT
												ELSE @PP_LOTE
											END) 
	AND		LTRIM(RTRIM(TAG)) =			( CASE	WHEN @PP_FOLIO = '' THEN TAG
												ELSE @PP_FOLIO 
											END)
	AND		LTRIM(RTRIM(HIDE)) =		( CASE	WHEN @PP_PIEL = '' THEN HIDE
												ELSE @PP_PIEL 
											END)
	AND		LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)) =	( CASE	WHEN @PP_ORDEN = '' THEN CCJOBHDR_SQL.JOBNO
														ELSE @PP_ORDEN 
													END)	
	AND		LTRIM(RTRIM(D_PIEL_CLASIFICACION)) =( CASE	WHEN @PP_D_CLASIFICACION = '' THEN D_PIEL_CLASIFICACION
																ELSE @PP_D_CLASIFICACION 
															END)	
	-- ///////////////////////////////////////////
	UNION
	-- ///////////////////////////////////////////
	SELECT  DISTINCT
			ISNULL(RP_SC_END.COLOUR, '')	AS COLOUR,
			ISNULL(LOT, '')					AS LOT,
			ISNULL(HIDE, '')				AS HIDE,
			ISNULL(SQF, '')					AS SQF,
			ISNULL(D_PIEL_CLASIFICACION,'') AS CLASIFICACION,
			ISNULL(TAGNO, 0)				AS TAGNO,
			ISNULL(RP_Folios.STATUS, '')	AS STATUS_FOLIO,
			ISNULL(RP_Folios.MACHINE, '')	AS MACHINE,
			ISNULL(CCJOBHDR_SQL.JOBNO, '')	AS JOBNO,
			ISNULL(CCJOBHDR_SQL.STATUS, '')	AS STATUS_ORDEN
	-- =======================
	FROM	RP_SC_FOLIO_STATUS_XX RP_SC_END
	-- =======================
	INNER JOIN	RP_Folios ON RP_Folios.TAG=RP_SC_END.TAGNO 
	INNER JOIN	PIEL_CLASIFICACION ON RP_SC_END.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
	LEFT  JOIN	CCJOBHDR_SQL ON RP_Folios.JOBNO = CCJOBHDR_SQL.jobno  
	WHERE	LTRIM(RTRIM(RP_SC_END.COLOUR)) =( CASE	WHEN @PP_COLOR = '' THEN RP_SC_END.COLOUR
													ELSE @PP_COLOR	
												END )
	AND		LTRIM(RTRIM(LOT)) =			( CASE	WHEN @PP_LOTE = '' THEN LOT
												ELSE @PP_LOTE
											END) 
	AND		LTRIM(RTRIM(TAG)) =			( CASE	WHEN @PP_FOLIO = '' THEN TAG
												ELSE @PP_FOLIO 
											END)
	AND		LTRIM(RTRIM(HIDE)) =		( CASE	WHEN @PP_PIEL = '' THEN HIDE
												ELSE @PP_PIEL 
											END)
	AND		LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)) =		( CASE	WHEN @PP_ORDEN = '' THEN CCJOBHDR_SQL.JOBNO
															ELSE @PP_ORDEN 
														END)	
	AND		LTRIM(RTRIM(D_PIEL_CLASIFICACION)) =	( CASE	WHEN @PP_D_CLASIFICACION = '' THEN D_PIEL_CLASIFICACION
																ELSE @PP_D_CLASIFICACION 
														END)
          

	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
