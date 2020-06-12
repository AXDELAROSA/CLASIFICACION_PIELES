-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANFERIR FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								
-- //////////////////////////////////////////////////////////////
-- EXEC [PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO] 0, 0, 3788882
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT,
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	-- ///////////////////////////////////////////

	DECLARE @VP_N_PIEL_SIN_CLASIFICAR		INT = 0

	SELECT TOP 1 @VP_N_PIEL_SIN_CLASIFICAR = COUNT(ID)
	FROM	RP_SC 
	WHERE	TAGNO = @PP_FOLIO
	AND		K_CLASIFICACION = 0

	IF @VP_N_PIEL_SIN_CLASIFICAR IS NULL
		SET @VP_N_PIEL_SIN_CLASIFICAR = 0

	IF @VP_N_PIEL_SIN_CLASIFICAR > 0
		SET @VP_RESULTADO = 'No se han clasificado todas las pieles del [FOLIO]: ' + CONVERT(VARCHAR(10), @PP_FOLIO)
		

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO
      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								
-- //////////////////////////////////////////////////////////////
-- EXEC [PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO] 0, 0, 3788882

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(20),
	@PP_FOLIO					INT,
	@PP_ORDEN					INT,
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	-- ///////////////////////////////////////////

	DECLARE @VP_PORCENTAJE_MINIMO_BUENO		DECIMAL(8,4)
	DECLARE @VP_PORCENTAJE_MINIMO_REGULAR	DECIMAL(8,4)
	DECLARE @VP_PORCENTAJE_MINIMO_MALO		DECIMAL(8,4)
	DECLARE @VP_PORCENTAJE_MAXIMO_BUENO		DECIMAL(8,4)
	DECLARE @VP_PORCENTAJE_MAXIMO_REGULAR	DECIMAL(8,4)
	DECLARE @VP_PORCENTAJE_MAXIMO_MALO		DECIMAL(8,4)
	DECLARE @VP_SQF_EXTRA_MINIMO			DECIMAL(8,4)
	DECLARE @VP_SQF_EXTRA_MAXIMO			DECIMAL(8,4)

	EXECUTE [dbo].[PG_GET_PARAMETRO_CLASIFICACION_POR_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																@OU_PORCENTAJE_MINIMO_BUENO		 = @VP_PORCENTAJE_MINIMO_BUENO		OUTPUT,
																@OU_PORCENTAJE_MINIMO_REGULAR	 = @VP_PORCENTAJE_MINIMO_REGULAR	OUTPUT,
																@OU_PORCENTAJE_MINIMO_MALO		 = @VP_PORCENTAJE_MINIMO_MALO		OUTPUT,
																@OU_PORCENTAJE_MAXIMO_BUENO		 = @VP_PORCENTAJE_MAXIMO_BUENO		OUTPUT,
																@OU_PORCENTAJE_MAXIMO_REGULAR	 = @VP_PORCENTAJE_MAXIMO_REGULAR	OUTPUT,
																@OU_PORCENTAJE_MAXIMO_MALO		 = @VP_PORCENTAJE_MAXIMO_MALO		OUTPUT,
																@OU_SQF_EXTRA_MINIMO			 = @VP_SQF_EXTRA_MINIMO				OUTPUT,
																@OU_SQF_EXTRA_MAXIMO			 = @VP_SQF_EXTRA_MAXIMO				OUTPUT
					
	-- ///////////////////////////////////////////
	DECLARE	@VP_N_PIEL_BUENA_X_FOLIO		INT = 0
	DECLARE	@VP_N_PIEL_REGULAR_X_FOLIO		INT = 0
	DECLARE	@VP_N_PIEL_MALA_X_FOLIO			INT = 0
	DECLARE @VP_PIEL_PORCENTAJE_BUENO		DECIMAL(19,4)
	DECLARE @VP_PIEL_PORCENTAJE_REGULAR		DECIMAL(19,4)
	DECLARE @VP_PIEL_PORCENTAJE_MALO		DECIMAL(19,4)
	DECLARE	@VP_N_PIEL_X_FOLIO				INT = 0
	-- ///////////////////////////////////////////

	SELECT	@VP_N_PIEL_X_FOLIO = COUNT(ID)
	FROM	RP_SC
	WHERE	RTRIM(LTRIM(COLOUR)) = @PP_COLOR
	AND		RTRIM(LTRIM(TAGNO)) = @PP_FOLIO

	IF @VP_N_PIEL_X_FOLIO IS NULL 
		SET @VP_N_PIEL_X_FOLIO = 0
	-- ==================================

	IF @VP_N_PIEL_X_FOLIO = 0
		SET @VP_RESULTADO = 'No se encontraron pieles en el [FOLIO]: ' + CONVERT(VARCHAR(10), @PP_FOLIO)
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL_BUENA_X_FOLIO = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
			AND		K_CLASIFICACION=1 -- BUENA
					
			IF @VP_N_PIEL_BUENA_X_FOLIO IS NULL 
				SET @VP_N_PIEL_BUENA_X_FOLIO = 0
			-- ==================================

			SET @VP_PIEL_PORCENTAJE_BUENO =	ROUND(CAST(@VP_N_PIEL_BUENA_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100

			IF ( @VP_PIEL_PORCENTAJE_BUENO < @VP_PORCENTAJE_MINIMO_BUENO OR @VP_PIEL_PORCENTAJE_BUENO > @VP_PORCENTAJE_MAXIMO_BUENO )
				BEGIN
					SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [BUENA] debe de estar entre el: '
					SET @VP_RESULTADO = @VP_RESULTADO + '[' + CONVERT(VARCHAR(20),@VP_PORCENTAJE_MINIMO_BUENO) + '% - '
					SET @VP_RESULTADO = @VP_RESULTADO +  CONVERT(VARCHAR(20),@VP_PORCENTAJE_MAXIMO_BUENO) +'%]'
				END
		END
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL_REGULAR_X_FOLIO = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
			AND		K_CLASIFICACION=2 -- REGULAR
			
			IF @VP_N_PIEL_REGULAR_X_FOLIO IS NULL 
				SET @VP_N_PIEL_REGULAR_X_FOLIO = 0
			-- ==================================

			SET @VP_PIEL_PORCENTAJE_REGULAR = ROUND(CAST(@VP_N_PIEL_REGULAR_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100
				
			IF ( @VP_PIEL_PORCENTAJE_REGULAR < @VP_PORCENTAJE_MINIMO_REGULAR OR @VP_PIEL_PORCENTAJE_REGULAR > @VP_PORCENTAJE_MAXIMO_REGULAR )
				BEGIN			
					SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [REGULAR] debe de estar entre el: '
					SET @VP_RESULTADO = @VP_RESULTADO + '[' + CONVERT(VARCHAR(20),@VP_PORCENTAJE_MINIMO_REGULAR) + '% - '
					SET @VP_RESULTADO = @VP_RESULTADO +  CONVERT(VARCHAR(20),@VP_PORCENTAJE_MAXIMO_REGULAR) +'%]'
				END
		END
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO = ''
		BEGIN
			SELECT	@VP_N_PIEL_MALA_X_FOLIO = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(TAGNO))=@PP_FOLIO
			AND		K_CLASIFICACION=3 -- MALA
			
			IF @VP_N_PIEL_MALA_X_FOLIO IS NULL 
				SET @VP_N_PIEL_MALA_X_FOLIO = 0
			-- ==================================

			SET @VP_PIEL_PORCENTAJE_MALO = ROUND(CAST(@VP_N_PIEL_MALA_X_FOLIO AS FLOAT) / CAST(@VP_N_PIEL_X_FOLIO AS FLOAT),3) * 100

			IF ( @VP_PIEL_PORCENTAJE_MALO < @VP_PORCENTAJE_MINIMO_MALO OR @VP_PIEL_PORCENTAJE_MALO > @VP_PORCENTAJE_MAXIMO_MALO )
				BEGIN
					SET @VP_RESULTADO = 'El procentaje de Pieles clasificadas como [MALA] debe de estar entre el: '
					SET @VP_RESULTADO = @VP_RESULTADO + '[' + CONVERT(VARCHAR(20),@VP_PORCENTAJE_MINIMO_MALO) + '% - '
					SET @VP_RESULTADO = @VP_RESULTADO +  CONVERT(VARCHAR(20),@VP_PORCENTAJE_MAXIMO_MALO) +'%]'
				END
			END
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO = ''
		BEGIN
			DECLARE @VP_SQF_ORDEN		DECIMAL(8,4) = 0
			DECLARE @VP_SQF_FOLIO		DECIMAL(8,4) = 0
			DECLARE	@VP_SQF_SOBRANTE	DECIMAL(8,4) = 0

			SELECT TOP  1 @VP_SQF_ORDEN = standardsqm
			FROM	CCJOBHDR_SQL
			WHERE	jobno = @PP_ORDEN

			IF @VP_SQF_ORDEN IS NULL
				SET	@VP_RESULTADO = 'Verifique el [SQF] que requiere la orden: ' + @PP_ORDEN
			-- ==================================		

			IF  @VP_RESULTADO = ''
				BEGIN
					SELECT	@VP_SQF_FOLIO = SUM(CONVERT(DECIMAL(8,4), ISNULL(SQF,0)))
					FROM	RP_SC
					WHERE	TAGNO = @PP_FOLIO
				
					IF @VP_SQF_FOLIO IS NULL
						SET	@VP_RESULTADO = 'Verifique la cantidad de [SQF] del folio: ' + CONVERT(VARCHAR(20),@PP_FOLIO)
				END

			IF  @VP_RESULTADO = ''
				BEGIN
					IF NOT @VP_SQF_FOLIO > @VP_SQF_ORDEN
						SET	@VP_RESULTADO = 'El [SQF] del folio debe ser mayor a lo que requiere la orden.'
				END

				IF  @VP_RESULTADO = ''
					BEGIN 
						SET @VP_SQF_SOBRANTE = @VP_SQF_FOLIO - @VP_SQF_ORDEN

						IF ( @VP_SQF_SOBRANTE < @VP_SQF_EXTRA_MINIMO OR @VP_SQF_SOBRANTE > @VP_SQF_EXTRA_MAXIMO )
							BEGIN
								SET @VP_RESULTADO = 'El [SQF] extra del folio debe ser entre el: ' 
								SET @VP_RESULTADO = @VP_RESULTADO + '[' + CONVERT(VARCHAR(20),@VP_SQF_EXTRA_MINIMO) + ' - '
								SET @VP_RESULTADO = @VP_RESULTADO +  CONVERT(VARCHAR(20),@VP_SQF_EXTRA_MAXIMO) +']'
							END
					END
		END
	-- ///////////////////////////////////////////

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO
	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOCACION				VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_ITEM_NO		VARCHAR(20)
			
	SELECT	@VP_ITEM_NO	=	ITEM_NO
							FROM	IMLSMST_SQL
							WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION
							AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
							AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE
	-- ===========================


	IF @VP_RESULTADO=''
		IF ( @VP_ITEM_NO IS NULL )
			SET @VP_RESULTADO =  'El registro no existe.' 

	-- ===========================

	--IF @VP_RESULTADO=''
	--	IF @VP_L_BORRADO=1
	--		SET @VP_RESULTADO =  'la [PIEL CLASIFICADA] fue dado de baja.' 
		
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]
GO


CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOCACION				VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_CANTIDAD_PIEL_DISPONIBLE	DECIMAL(13,4)
			
	SELECT	@VP_CANTIDAD_PIEL_DISPONIBLE	=	qty_on_hand
											FROM	IMLSMST_SQL
											WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION
											AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
											AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE
	-- ===========================
	IF @VP_CANTIDAD_PIEL_DISPONIBLE IS NULL
		SET @VP_CANTIDAD_PIEL_DISPONIBLE = 0

	IF @VP_RESULTADO=''
		IF ( @PP_SQF > @VP_CANTIDAD_PIEL_DISPONIBLE )
			SET @VP_RESULTADO =  'Cantidad Insuficiente en inventario.' 

	-- ===========================

	--IF @VP_RESULTADO=''
	--	IF @VP_L_BORRADO=1
	--		SET @VP_RESULTADO =  'la [PIEL CLASIFICADA] fue dado de baja.' 
		
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION UPDATE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_IMLSMST_SQL_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]
GO

CREATE PROCEDURE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	-- ===========================		
	@PP_LOCACION					VARCHAR(10),			
	@PP_COLOR						VARCHAR(20),
	@PP_LOTE						VARCHAR(20),
	@PP_SQF							DECIMAL(13,4),
	-- ===========================		
	@OU_RESULTADO_VALIDACION		VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////

	--IF @VP_RESULTADO=''
	--	EXECUTE [dbo].[PG_RN_DATA_ACCESO_UPDATE]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
	--													11, -- @PP_K_DATA_SISTEMA,	
	--													@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
		
	-- ///////////////////////////////////////////
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION, @PP_COLOR, @PP_LOTE, 
																			@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_IMLSMST_SQL_VALIDA_CANTIDAD_PIEL_DISPONIBLE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
																			@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //UPD//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
