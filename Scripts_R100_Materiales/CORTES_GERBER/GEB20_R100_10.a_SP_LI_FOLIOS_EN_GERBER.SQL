-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_FOLIO_EN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_FOLIO_EN_GERBER]
GO

--3793219
--2137674
/*
 EXEC PG_LI_FOLIO_EN_GERBER 0 ,0, 3793219 
*/

CREATE PROCEDURE [dbo].[PG_LI_FOLIO_EN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	-- ///////////////////////////////////////////
	
--SELECT * FROM RP_SC WHERE  SUBSTRING(MOVEMENT, 1,2) = 'GT'

	SELECT TOP 1000
			ISNULL(RP_SC.CDATE, '')		AS CDATE,
			ISNULL(RP_SC.COLOUR, '')		AS COLOR,
			ISNULL(LOT, '')			AS LOTE,
			ISNULL(HIDE, '')		AS PIEL,
			ISNULL(SQF, '')			AS SQF,
			CONVERT(DECIMAL(13,2),ISNULL(hidesqm, 0.0000))	AS SQF_CORTADO_ORIGINAL,
			'0.00'					AS SQF_CORTADO,
			ISNULL(TAGNO, 0)		AS FOLIO,
			ISNULL(YARDAS, '')		AS YARDAS,
			ISNULL(YLB, '')			AS YLB,
			ISNULL(PESO, '')		AS PESO,
			ISNULL(RP_SC.TYPE, '')		AS TYPE,
			(CASE WHEN ISNUMERIC(MOVEMENT)  = 1 THEN (	SELECT TOP 1	LTRIM(RTRIM(IMINVTRX_SQL.Loc))
																-- ===================== 
														FROM	IMLSTRX_SQL, IMINVTRX_SQL 
																-- =====================
														WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
														AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
														AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
														AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
														AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
														AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
														AND		IMINVTRX_SQL.ord_no	= MOVEMENT
														-- =====================
														AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
																OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
														)
				ELSE	LTRIM(RTRIM(MOVEMENT)) END ) AS LOCACION,
				S_PIEL_CLASIFICACION,
				(CASE	WHEN RP_Folios.JOBNO IS NULL THEN 'SN/EVENT'
						WHEN RP_Folios.JOBNO = '-' THEN 'SN/EVENT'
						WHEN RP_Folios.JOBNO = '' THEN 'SN/EVENT'
						ELSE	LTRIM(RTRIM(RP_Folios.JOBNO)) END) AS EVENTO
	FROM	RP_SC 
	-- =======================
	INNER	JOIN	PIEL_CLASIFICACION ON RP_SC.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
	INNER	JOIN	RP_Folios ON RP_SC.TAGNO = RP_Folios.TAG
	LEFT	JOIN	cccuthst_sql	ON RP_Folios.JOBNO = cccuthst_sql.jobno
		AND		LTRIM(RTRIM(RP_SC.COLOUR)) = LTRIM(RTRIM(cccuthst_sql.COLOUR))    
		AND	LTRIM(RTRIM(cccuthst_sql.lotno)) = 	LTRIM(RTRIM(RP_SC.LOT))
		AND LTRIM(RTRIM(cccuthst_sql.hideno)) =  LTRIM(RTRIM(RP_SC.HIDE))
	WHERE	TAGNO = @PP_FOLIO
	AND		SUBSTRING(MOVEMENT, 1,2) = 'GT'
	-- =======================
	ORDER BY HIDE ASC

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
