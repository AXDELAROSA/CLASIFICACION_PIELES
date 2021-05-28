-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR MESA
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	05/ABR/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ESTATUS_X_MESA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ESTATUS_X_MESA]
GO
/*
											(MESA)		(ESTATUS)
 EXEC	[dbo].[PG_LI_ESTATUS_X_MESA] 0,0, 'Table 20',	'P'
 EXEC	[dbo].[PG_LI_ESTATUS_X_MESA] 0,0, 'Table 01',	'C'
 EXEC	[dbo].[PG_LI_ESTATUS_X_MESA] 0,0, '',			'P'
 EXEC	[dbo].[PG_LI_ESTATUS_X_MESA] 0,0, '',			'C'
*/


CREATE PROCEDURE [dbo].[PG_LI_ESTATUS_X_MESA]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================
	@PP_MESA						VARCHAR(150),
	@PP_ESTATUS_ORDEN				VARCHAR(50)
AS

	-- //////////////////////////////////////////////////////////////////////////////////////
	SET NOCOUNT ON
	DECLARE @TBL_ORDENES_ABIERTAS AS TABLE(
	ID					INT IDENTITY(1,1),
	ORDEN				VARCHAR(50),
	ESTATUS				VARCHAR(10),
	COLOR				VARCHAR(50),
	D_COLOR				VARCHAR(150),
	CLIENTE				VARCHAR(100),
	MESA				VARCHAR(50),
	F_CREACION			DATE,
	F_PLANEADA			DATE,
	NETO_REQUERIDO		DECIMAL(13,2),
	STAND_SQM_REQUERIDO	DECIMAL(13,2),
	PATTERNS_REQUERIDO	INT,
	LOTE_USADO			VARCHAR(50),
	FOLIO_ASIGNADO		INT,
	PIELES_FOLIO		INT,
	PIELES_CORTADA		INT,
	PATTERNS_CORTADO	INT,
	NETO_CORTADO		DECIMAL(13,2),
	SQF_CORTADO			DECIMAL(13,2)	
	)
	
	SET NOCOUNT ON	
	INSERT INTO @TBL_ORDENES_ABIERTAS
	SELECT DISTINCT jobno, status, CONCAT('F', LTRIM(RTRIM(ccjobhdr_sql.colour))),
					LTRIM(RTRIM(colourdesc)), 
					LTRIM(RTRIM(customer)), 
					LTRIM(RTRIM(machine)), 
					[dbo].[CONVERT_INT_TO_DATE](datecreated), 
					[dbo].[CONVERT_INT_TO_DATE](dateplanned), 
					netsqm, standardsqm, 
					patterns,
					--=============================================
					ISNULL((	SELECT TOP 1 LTRIM(RTRIM(LOT)) 
								FROM RP_SC (NOLOCK)
								WHERE TAGNO = ISNULL(FOLIO, 0) 
								GROUP BY LOT 
								ORDER BY SUM( (CASE WHEN ISNUMERIC(LTRIM(RTRIM(SQF))) = 0 THEN 0 ELSE CONVERT(DECIMAL(13,2), ISNULL(LTRIM(RTRIM(SQF)), 0)) END )) DESC
								), '') AS LOTE,

					--ISNULL((	SELECT TOP 1 LTRIM(RTRIM(LOT)) 
					--			FROM RP_SC (NOLOCK)
					--			WHERE TAGNO = ISNULL(FOLIO, 0) 
					--			GROUP BY LOT 
					--			ORDER BY SUM(CONVERT(DECIMAL(13,2), ISNULL(LTRIM(RTRIM(SQF)), 0))) DESC
					--			), '') AS LOTE,
					--=============================================
					ISNULL(FOLIO, 0) AS FOLIO, 
					--=============================================
					ISNULL((	SELECT COUNT(ID) 
								FROM RP_SC (NOLOCK) 
								WHERE TAGNO = ISNULL(FOLIO, 0)), 0) AS HIDES,
					--=============================================
					ISNULL((	SELECT COUNT(colkey) 
								FROM cccuthst_sql (NOLOCK) 
								WHERE cccuthst_sql.jobno = ccjobhdr_sql.jobno), 0) AS CUT_PIEL,
					--=============================================
					ISNULL((	SELECT SUM(rawpatterns) 
								FROM cccuthst_sql (NOLOCK) 
								WHERE cccuthst_sql.jobno = ccjobhdr_sql.jobno), 0) AS CUT_PATRON,
					--=============================================
					ISNULL((	SELECT SUM(rawpatternsqm) 
								FROM cccuthst_sql (NOLOCK) 
								WHERE cccuthst_sql.jobno = ccjobhdr_sql.jobno), 0) AS CUT_NET,
					--=============================================
					ISNULL((	SELECT SUM(hidesqm) 
								FROM cccuthst_sql (NOLOCK)
								WHERE  cccuthst_sql.jobno = ccjobhdr_sql.jobno), 0) AS CUT_SQF
					--=============================================
	FROM	ccjobhdr_sql (NOLOCK)
	WHERE machine = ( CASE WHEN @PP_MESA <> '' THEN @PP_MESA
							ELSE machine END) 
	AND status = ( CASE WHEN @PP_ESTATUS_ORDEN <> '' THEN @PP_ESTATUS_ORDEN
							ELSE status END)  
	AND startedflag = 'Y'
	AND FOLIO IS NOT NULL
	AND LTRIM(RTRIM(INSTRUCT2)) = 'A'
	--ORDER BY datecreated DESC

	-- //////////////////////////////////////////////////////////////////////////////////////
	SET NOCOUNT OFF
	SELECT ID,				
		   ORDEN,				
		   ESTATUS,				
		   COLOR,				
		   D_COLOR,				
		   CLIENTE,				
		   MESA,				
		   F_CREACION,			
		   F_PLANEADA,			
		   NETO_REQUERIDO,		
		   STAND_SQM_REQUERIDO,	
		   PATTERNS_REQUERIDO,	
		   FOLIO_ASIGNADO,		
		   LOTE_USADO,			
		   PIELES_FOLIO,		
		   PIELES_CORTADA,		
		   PATTERNS_CORTADO,	
		   --=============================================
		   ( CASE WHEN PATTERNS_CORTADO > 0 AND PATTERNS_REQUERIDO > 0 THEN (PATTERNS_CORTADO * 100) / PATTERNS_REQUERIDO 
				ELSE 0 END ) AS PORC_PATRON_COMPLETADO,
			--=============================================
			( CASE WHEN (PIELES_FOLIO - PIELES_CORTADA) <= 0 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 1
					WHEN (PIELES_FOLIO - PIELES_CORTADA) = 1 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 2
					WHEN (PIELES_FOLIO - PIELES_CORTADA) = 2 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 3
					WHEN (PIELES_FOLIO - PIELES_CORTADA) = 3 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 4
					WHEN (PIELES_FOLIO - PIELES_CORTADA) = 4 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 5
					WHEN (PIELES_FOLIO - PIELES_CORTADA) = 5 AND PATTERNS_CORTADO < PATTERNS_REQUERIDO THEN 6
					WHEN PATTERNS_CORTADO >= PATTERNS_REQUERIDO THEN 7
				ELSE 8 END ) AS PRIORIDAD_EXTRAS,
			--=============================================
		   NETO_CORTADO,	
		   SQF_CORTADO
	FROM @TBL_ORDENES_ABIERTAS AS ORD_ABI
	--WHERE MESA = 'Table 01'
	ORDER BY PRIORIDAD_EXTRAS, MESA ASC
	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


