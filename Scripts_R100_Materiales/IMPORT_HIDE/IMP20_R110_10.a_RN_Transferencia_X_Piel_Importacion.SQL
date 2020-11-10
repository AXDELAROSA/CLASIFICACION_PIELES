-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			[TRANSFER_PIEL_DEVOLUCION]
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	06/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]
GO
/*
 USE [DATA_02Pruebas] 
	EXEC [PG_RN_VALIDA_PIEL_SCRAP] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
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

	-- /////////////////////////////////////////////////////
	
	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL = COUNT(ID)
			-- =====================
			FROM	RP_SC
			WHERE	LTRIM(RTRIM(COLOUR)) = @PP_COLOR 
			AND		( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOT)),2, 10) 
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
			WHERE LTRIM(RTRIM(PCOLOR)) = @PP_COLOR
			AND	( CASE WHEN SUBSTRING(LTRIM(RTRIM(PLOT)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(PLOT)),2, 10) 
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




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
