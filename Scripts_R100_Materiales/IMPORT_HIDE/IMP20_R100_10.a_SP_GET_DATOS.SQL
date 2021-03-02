-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORE PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02PRUEBAS] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
																	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_TICKET_IMPORTADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_TICKET_IMPORTADO]
GO

/*
 EXEC [PG_LI_TICKET_IMPORTADO] 0 ,0, '' 
 EXEC [PG_LI_TICKET_IMPORTADO] 0 ,0, '210226073445T1000001'
*/

CREATE PROCEDURE [dbo].[PG_LI_TICKET_IMPORTADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FILE_NO					VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_N_ETIQUETA_IMPRESA INT = 0
	SELECT @VP_N_ETIQUETA_IMPRESA = COUNT(ID) 
	FROM  HIDESLIN_SQL 
	WHERE FILENO = @PP_FILE_NO
	AND PRINTED = 1  

	-- ///////////////////////////////////////////
	SELECT	TOP 10000	
			FILENO as Name,
			PCOLOR as Color,
			LDATE as LoadDate,
			Type,
			COLOR as Descr,
			PLOT as PearlLot,
			THIDES as TotalHides,
			TAREA as TotalArea,
			Status
			-- ===========================
    FROM	HIDESHDR_SQL 
    WHERE	FILENO = ( CASE	WHEN @PP_FILE_NO = '' THEN FILENO
							ELSE @PP_FILE_NO END )
	ORDER BY ID DESC

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
																	
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_PIEL_IMPORTADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_PIEL_IMPORTADA]
GO

/*
 EXEC [PG_LI_PIEL_IMPORTADA] 0 ,0, '210226073445T1000001'
*/

CREATE PROCEDURE [dbo].[PG_LI_PIEL_IMPORTADA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FILE_NO					VARCHAR(50),
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(5)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_N_ETIQUETA_IMPRESA INT = 0
	SELECT @VP_N_ETIQUETA_IMPRESA = COUNT(ID) 
	FROM  HIDESLIN_SQL 
	WHERE FILENO = @PP_FILE_NO
	AND PRINTED = 1  

	-- ///////////////////////////////////////////
	SELECT	TOP 10000	
			HIDESHDR_SQL.FILENO,
			HIDESLIN_SQL.HIDE,
			HIDESLIN_SQL.SQF, 
			HIDESHDR_SQL.PLOT,
			-- ===========================
			(	CASE WHEN ( SELECT	COUNT(K_PIEL_LOG) 
							FROM	PIEL_LOG 
							WHERE	LOTE = CONVERT(INT, PLOT) 
							AND		PIEL = CONVERT(INT, Hide) 
							AND		PIEL_LOG.SQF = HIDESLIN_SQL.SQF 
							AND		K_TIPO_PIEL_LOG = 11 ) <= 0 
						THEN PCOLOR 
					ELSE (	SELECT TOP 1 COLOR_DESTINO 
							FROM PIEL_LOG 
							WHERE LOTE = CONVERT(INT, PLOT) 
							AND PIEL = CONVERT(INT, HIDE) 
							AND PIEL_LOG.SQF = HIDESLIN_SQL.SQF  
							AND K_TIPO_PIEL_LOG = 11 
							ORDER BY K_PIEL_LOG DESC ) 
				END	) AS PCOLOR, 
			-- ===========================
			PRINTED ,
			-- ===========================
			@VP_N_ETIQUETA_IMPRESA AS N_ETIQUETA_IMPRESA
			-- ===========================
    FROM HIDESLIN_SQL 
    INNER JOIN HIDESHDR_SQL ON HIDESLIN_SQL.FILENO=HIDESHDR_SQL.FILENO 
    WHERE	HIDESHDR_SQL.FILENO = ( CASE	WHEN @PP_FILE_NO = '' THEN HIDESHDR_SQL.FILENO
											ELSE @PP_FILE_NO END ) 
	AND		PLOT = ( CASE	WHEN @PP_LOTE = '' THEN PLOT
							ELSE @PP_LOTE END )
	AND		HIDE = ( CASE	WHEN @PP_PIEL = '' THEN HIDE
							ELSE @PP_PIEL END )
	ORDER BY hide DESC

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_CONSECUTIVO_PIEL_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_CONSECUTIVO_PIEL_IMPORTAR]
GO

/*
 EXEC PG_GET_CONSECUTIVO_PIEL_IMPORTAR 0 ,0, 'FMCKTX7', '750021'
*/

CREATE PROCEDURE [dbo].[PG_GET_CONSECUTIVO_PIEL_IMPORTAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(10), 
	@PP_LOTE					VARCHAR(15)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_CONSECUTIVO INT = 0
	DECLARE @VP_LOTE_PIEL_ULTIMA_RP_SC INT = 0
	DECLARE @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL INT = 0

	SELECT  TOP 1 @VP_LOTE_PIEL_ULTIMA_RP_SC = CONVERT(INT, LTRIM(RTRIM(HIDE)))
	FROM	RP_SC 
	WHERE	LTRIM(RTRIM(LOT)) = @PP_LOTE
	ORDER BY HIDE DESC

	IF @VP_LOTE_PIEL_ULTIMA_RP_SC IS NULL
		SET @VP_LOTE_PIEL_ULTIMA_RP_SC = 0

	SELECT	TOP 1  @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL = CONVERT(INT, LTRIM(RTRIM(HIDE))) 
	FROM	HIDESLIN_SQL 
	INNER JOIN HIDESHDR_SQL ON HIDESLIN_SQL.FILENO=HIDESHDR_SQL.FILENO 
	WHERE LTRIM(RTRIM(PLOT)) = @PP_LOTE
	ORDER BY hide DESC

	IF @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL IS NULL
		SET @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL = 0

	IF @VP_LOTE_PIEL_ULTIMA_RP_SC > @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL
		SET @VP_CONSECUTIVO = @VP_LOTE_PIEL_ULTIMA_RP_SC + 1
	ELSE
		SET @VP_CONSECUTIVO = @VP_LOTE_PIEL_ULTIMA_HIDESLIN_SQL + 1

	SELECT RIGHT('0000' + CONVERT(VARCHAR(4), @VP_CONSECUTIVO), 4) AS CONSECUTIVO

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02PRUEBAS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_PACKING_NO_LOTE_IMPORTADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_PACKING_NO_LOTE_IMPORTADO]
GO

/*
 EXEC PG_GET_PACKING_NO_LOTE_IMPORTADO 0 ,0, '100061'
*/

CREATE PROCEDURE [dbo].[PG_GET_PACKING_NO_LOTE_IMPORTADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(15)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_PACKING_NO VARCHAR(20) = ''
	
	SELECT TOP 1 @VP_PACKING_NO = ISNULL(INVOICE,'')   
	FROM HIDESHDR_SQL   
	INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
	AND	LTRIM(RTRIM(PLOT)) = @PP_LOTE
	ORDER BY HIDE DESC

	SELECT @VP_PACKING_NO AS PACKING_NO

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
