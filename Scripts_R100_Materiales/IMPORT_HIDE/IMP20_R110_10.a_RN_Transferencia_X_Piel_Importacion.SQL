-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			[IMPORTACION DE PIELES]
-- // OPERACION:		LIBERACION / RN VALIDACIONES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	06/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]
GO
/*
 USE [DATA_02Pruebas] 
	EXEC [PG_RN_VALIDA_PIEL_A_REIMPRIMIR] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_FILE_NO					VARCHAR(50),
	@PP_LOTE					VARCHAR(50),
	@PP_PIEL					VARCHAR(50),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 
	DECLARE @VP_N_IMPRESION			INT = 0
	DECLARE @VP_N_IMPRESION_LOG		INT = 0

	-- /////////////////////////////////////////////////////
	SELECT	@VP_N_IMPRESION = COUNT(ID)
	FROM	HIDESLIN_SQL
	WHERE	FILENO = @PP_FILE_NO
	AND		HIDE = @PP_PIEL
	AND		PRINTED = 1

	IF @VP_N_IMPRESION IS NULL
		SET @VP_N_IMPRESION = 0

	-- /////////////////////////////////////////////////////
	SELECT	@VP_N_IMPRESION_LOG = COUNT(K_PIEL_LOG)
	FROM	PIEL_LOG
	WHERE	LOTE = @PP_LOTE
	AND		PIEL = @PP_PIEL
	AND		K_TIPO_PIEL_LOG = 8 --#REIMPRESION
	
	IF @VP_N_IMPRESION_LOG IS NULL
		SET @VP_N_IMPRESION_LOG = 0

	-- /////////////////////////////////////////////////////
	IF @VP_N_IMPRESION > 0 AND @VP_N_IMPRESION_LOG > 0
		SET @VP_RESULTADO = 'La piel ya se reimprimio una vez.'
	
	-- /////////////////////////////////////////////////////
	IF @VP_RESULTADO = ''
		BEGIN
			DECLARE @VP_SQF_ORIGINAL DECIMAL(13,2) = 0
			SELECT	@VP_SQF_ORIGINAL = SQF
			FROM	HIDESLIN_SQL
			WHERE	FILENO = @PP_FILE_NO
			AND		HIDE = @PP_PIEL

			IF @VP_SQF_ORIGINAL IS NULL
				SET @VP_SQF_ORIGINAL = 0

			-- /////////////////////////////////////////////////////
			DECLARE @VP_SQF_CORTADO	DECIMAL(13,2) = 0
			SELECT	@VP_SQF_CORTADO = SUM(hidesqm) 
			FROM	cccuthst_sql 
			WHERE	LTRIM(RTRIM(lotno)) = RIGHT( '000000' + @PP_LOTE, 6)
			AND	hideno = @PP_PIEL

			IF @VP_SQF_CORTADO IS NULL
				SET @VP_SQF_CORTADO = 0
			-- /////////////////////////////////////////////////////

			SET @VP_SQF_ORIGINAL = @VP_SQF_ORIGINAL - @VP_SQF_CORTADO

			IF @VP_SQF_ORIGINAL <= 0
				SET @VP_RESULTADO = 'La piel ya fue cortada.' 
		END

	-- /////////////////////////////////////////////////////

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]
GO
/*
 USE [DATA_02Pruebas] 
	EXEC [PG_RN_VALIDA_PIEL_A_IMPORTAR] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_COLOR					VARCHAR(50),
	@PP_LOTE					VARCHAR(50),
	@PP_PIEL					VARCHAR(50),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	DECLARE @VP_N_PIEL			INT = 0

	-- /////////LA VALIDACION DEBE SER SOBRE EL LOTE YA QUE EL LOTE ES UNICO NO SE PUEDE REPETIR EL LOTE EN DIFERENTES COLORES////////////////////////////////////////////
	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL = COUNT(ID)
			-- =====================
			FROM	RP_SC
			WHERE	--LTRIM(RTRIM(COLOUR)) = @PP_COLOR 
			--AND		
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOT)),2, 10) 
							ELSE LTRIM(RTRIM(LOT)) END ) = @PP_LOTE
			AND		LTRIM(RTRIM(HIDE)) = @PP_PIEL 

			-- /////////////////////////////////////////////////////
			IF @VP_N_PIEL IS NULL
				SET @VP_N_PIEL = 0

			IF @VP_N_PIEL > 0
				SET @VP_RESULTADO = 'La Piel:' + @PP_PIEL + ' ya existe en [RP_SC]'

			-- /////////////////////////////////////////////////////
		END

	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL = COUNT(HIDESLIN_SQL.ID) 
			FROM	HIDESHDR_SQL   
			INNER JOIN	HIDESLIN_SQL ON HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
			WHERE --LTRIM(RTRIM(PCOLOR)) = @PP_COLOR
			--AND	
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(PLOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(PLOT)),2, 10) 
						ELSE LTRIM(RTRIM(PLOT)) END ) = @PP_LOTE
			AND LTRIM(RTRIM(HIDE)) = @PP_PIEL

			-- /////////////////////////////////////////////////////
			IF @VP_N_PIEL IS NULL
				SET @VP_N_PIEL = 0

			IF @VP_N_PIEL > 0
				SET @VP_RESULTADO = 'La Piel:' + @PP_PIEL + ' ya existe en [HIDESLIN_SQL]'

			-- /////////////////////////////////////////////////////
		END
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////
--  USE [DATA_02Pruebas] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR]
GO
/*
	EXEC [PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOTE					VARCHAR(50),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	-- ////////SE OBTIENE LA ULTIMA PIEL INGRESADA PARA ESE LOTE///////////////////////////////////
	DECLARE @VP_NUMERO_PIEL VARCHAR(5) = ''
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

	--SET @VP_NUMERO_PIEL = RIGHT('0000' + CONVERT(VARCHAR(4), @VP_CONSECUTIVO), 4) 
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = RIGHT('0000' + CONVERT(VARCHAR(4), @VP_CONSECUTIVO), 4) 

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////
--  USE [DATA_02Pruebas] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_LOCACION_TICKET_IMPORTADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION_TICKET_IMPORTADO]
GO
/*
	EXEC [PG_RN_VALIDA_LOCACION_TICKET_IMPORTADO] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION_TICKET_IMPORTADO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_FILE_NO					VARCHAR(50),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 

	-- ////////SE OBTIENE LA LOCACION DONDE SE ENCUENTRAN LAS PIELES DEL TICKET IMPORTADO///////////////////////////////////
	DECLARE @VP_LOCACION VARCHAR(5) = ''
	
	SELECT @VP_LOCACION = [STATUS]
	FROM HIDESHDR_SQL 
	WHERE FILENO = @PP_FILE_NO

	IF @PP_FILE_NO <> 'MIT'
		SET @VP_RESULTADO = 'El Ticket no se encientra en MIT.'
	
	IF @VP_RESULTADO = ''
		BEGIN
			-- ////////SE VALIDA QUE EL TICKET CUENTA CON PIELES IMPORTADAS///////////////////////////////////
			DECLARE @VP_N_PIELE INT = 0

			SELECT @VP_N_PIELE = COUNT(ID) 
			FROM  HIDESLIN_SQL WHERE FILENO = @PP_FILE_NO

			IF ( @VP_N_PIELE IS NULL OR @VP_N_PIELE = 0 )
				SET @VP_RESULTADO = 'El Ticket no tiene piles importadas.'
		END

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
