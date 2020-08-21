-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	1/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
/*
 EXEC DBO.[PG_LI_TRACKING_PIEL] 0,0, 'FMCKTX7' , '033241' , 0 , '0355' , '' , '( TODOS )' 
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TRACKING_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TRACKING_PIEL]
GO

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
	SELECT  DISTINCT
			ISNULL(LTRIM(RTRIM(RP_SC.COLOUR)), '')			AS COLOUR,
			ISNULL(LTRIM(RTRIM(LOT)), '')					AS LOT,
			ISNULL(LTRIM(RTRIM(HIDE)), '')					AS HIDE,
			ISNULL(LTRIM(RTRIM(SQF)), '')					AS SQF,
			ISNULL(LTRIM(RTRIM(S_PIEL_CLASIFICACION)),'')	AS CLASIFICACION,
			ISNULL(LTRIM(RTRIM(TAGNO)), 0)					AS TAGNO,
			-- =======================
			(CASE WHEN ISNULL(LTRIM(RTRIM(RP_Folios.STATUS)), '') = 'XX' THEN	'CORTADO'
				ELSE	ISNULL(LTRIM(RTRIM(RP_Folios.STATUS)), '') END	) AS STATUS_FOLIO,
			-- =======================
			ISNULL(LTRIM(RTRIM(LOC)), '')					AS MACHINE,
			ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)), '')	AS JOBNO,
			ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.STATUS)), '')	AS STATUS_ORDEN
	-- =======================
	FROM	RP_SC
	-- =======================
	LEFT JOIN	RP_Folios ON RP_Folios.TAG=RP_SC.TAGNO 
	LEFT JOIN	PIEL_CLASIFICACION ON RP_SC.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
	LEFT  JOIN	CCJOBHDR_SQL ON RP_Folios.JOBNO = CCJOBHDR_SQL.jobno  
	LEFT  JOIN  IMLOCFIL_SQL ON RP_Folios.MACHINE = IMLOCFIL_SQL.loc_desc
	-- =======================
	WHERE	LTRIM(RTRIM(RP_SC.COLOUR)) = @PP_COLOR	
	AND		RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) = ( CASE	WHEN @PP_LOTE = '' THEN LTRIM(RTRIM(LOT))
												ELSE @PP_LOTE	END) 
	AND		LTRIM(RTRIM(TAG)) =			( CASE	WHEN @PP_FOLIO = '0' THEN TAG
												ELSE @PP_FOLIO	END)
	AND		LTRIM(RTRIM(HIDE)) =		( CASE	WHEN @PP_PIEL = '' THEN LTRIM(RTRIM(HIDE))
												ELSE @PP_PIEL	END)
	AND		ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)),'') =	( CASE	WHEN @PP_ORDEN = '' THEN ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)),'')
																ELSE @PP_ORDEN 
															END)	
	AND		LTRIM(RTRIM(D_PIEL_CLASIFICACION)) =( CASE	WHEN @PP_D_CLASIFICACION = '( TODOS )' THEN D_PIEL_CLASIFICACION
														ELSE @PP_D_CLASIFICACION	END)	
	-- ///////////////////////////////////////////
	UNION
	-- ///////////////////////////////////////////
	SELECT  DISTINCT
			ISNULL(RP_SC_END.COLOUR, '')	AS COLOUR,
			ISNULL(LOT, '')					AS LOT,
			ISNULL(HIDE, '')				AS HIDE,
			ISNULL(SQF, '')					AS SQF,
			ISNULL(S_PIEL_CLASIFICACION,'') AS CLASIFICACION,
			ISNULL(TAGNO, 0)				AS TAGNO,
			-- =======================
			(CASE WHEN ISNULL(LTRIM(RTRIM(RP_Folios.STATUS)), '') = 'XX' THEN	'CORTADO'
				ELSE	ISNULL(LTRIM(RTRIM(RP_Folios.STATUS)), '') END	) AS STATUS_FOLIO,
			-- =======================
			ISNULL(LOC, '')	AS MACHINE,
			ISNULL(CCJOBHDR_SQL.JOBNO, '')	AS JOBNO,
			ISNULL(CCJOBHDR_SQL.STATUS, '')	AS STATUS_ORDEN
	-- =======================
	FROM	RP_SC_FOLIO_STATUS_XX RP_SC_END
	-- =======================
	LEFT	JOIN	RP_Folios ON RP_Folios.TAG=RP_SC_END.TAGNO 
	LEFT	JOIN	PIEL_CLASIFICACION ON RP_SC_END.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
	LEFT	JOIN	CCJOBHDR_SQL ON RP_Folios.JOBNO = CCJOBHDR_SQL.jobno 
	LEFT	JOIN  IMLOCFIL_SQL ON RP_Folios.MACHINE = IMLOCFIL_SQL.loc_desc 
	WHERE	LTRIM(RTRIM(RP_SC_END.COLOUR)) = @PP_COLOR	
	AND		RIGHT('000000' + LTRIM(RTRIM(LOT)), 6) = ( CASE	WHEN @PP_LOTE = '' THEN LTRIM(RTRIM(LOT))
												ELSE @PP_LOTE	END) 
	AND		LTRIM(RTRIM(TAG)) =			( CASE	WHEN @PP_FOLIO = '' THEN TAG
												ELSE @PP_FOLIO	END)
	AND		LTRIM(RTRIM(HIDE)) =		( CASE	WHEN @PP_PIEL = '' THEN LTRIM(RTRIM(HIDE))
												ELSE @PP_PIEL	END)
	AND		ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)),'') =	( CASE	WHEN @PP_ORDEN = '' THEN ISNULL(LTRIM(RTRIM(CCJOBHDR_SQL.JOBNO)),'')
																ELSE @PP_ORDEN	END)		
	AND		LTRIM(RTRIM(D_PIEL_CLASIFICACION)) =	( CASE	WHEN @PP_D_CLASIFICACION = '( TODOS )' THEN D_PIEL_CLASIFICACION
																ELSE @PP_D_CLASIFICACION	END)
          
	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
