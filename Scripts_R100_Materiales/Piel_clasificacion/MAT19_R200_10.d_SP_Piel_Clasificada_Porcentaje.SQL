-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	14/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- EXECUTE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_K_PIEL_LOTE] 0,0,0, 2

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]
GO
-- EXECUTE PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE 0,0,'FMCKTX7/FCPRDX9','33001/104313'

CREATE PROCEDURE [dbo].[PG_SK_PIEL_CLASIFICADA_PORCENTAJE_X_LOTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR_ARRAY				NVARCHAR(MAX),
	@PP_LOTE_ARRAY				NVARCHAR(MAX)
AS

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////OBTENER VALORES DE LA ETIQUETA PIEL////////////////////////////////////////////
	
	DECLARE @TBL_LOTE_CLASIFICADO TABLE (
				K_LOTE_CLASIFICADO  INT IDENTITY(1,1),
				COLOR_CLASIFICADO	VARCHAR(10),
				LOTE_CLASIFICADO	VARCHAR(10)
			)
	SET NOCOUNT ON
				
	DECLARE @VP_POSICION_COLOR	INT
	DECLARE @VP_POSICION_LOTE	INT
	DECLARE @VP_COLOR_VALOR		VARCHAR(10)
	DECLARE @VP_LOTE_VALOR		VARCHAR(10)
					
	--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
	SET	@PP_LOTE_ARRAY	= @PP_LOTE_ARRAY	+ '/'	
	SET	@PP_COLOR_ARRAY	= @PP_COLOR_ARRAY	+ '/'				
	
	--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
	WHILE patindex('%/%' , @PP_LOTE_ARRAY) <> 0
		BEGIN
			SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY)
			SELECT @VP_POSICION_COLOR	=	patindex('%/%' , @PP_COLOR_ARRAY)

			--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
			SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION_LOTE - 1)
			SELECT @VP_COLOR_VALOR		= LEFT(@PP_COLOR_ARRAY, @VP_POSICION_COLOR - 1)

			IF NOT EXISTS	(	SELECT	K_LOTE_CLASIFICADO 
								FROM	@TBL_LOTE_CLASIFICADO	
								WHERE	COLOR_CLASIFICADO=@VP_COLOR_VALOR	AND LOTE_CLASIFICADO = @VP_LOTE_VALOR	)
				BEGIN
					INSERT	INTO	@TBL_LOTE_CLASIFICADO
							VALUES(
									@VP_COLOR_VALOR,
									@VP_LOTE_VALOR		)
				END
																				
			--Reemplazamos lo procesado con nada con la funcion stuff
			SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')
			SELECT @PP_COLOR_ARRAY			= STUFF(@PP_COLOR_ARRAY, 1, @VP_POSICION_COLOR, '')
		END
	-- =========================================

		SELECT	PIEL_CLASIFICADA_PORCENTAJE.*,
				CAST(PIEL_PORCENTAJE_BUENO AS DECIMAL(13,2))	AS PORCENTAJE_BUENO,
				CAST(PIEL_PORCENTAJE_REGULAR AS DECIMAL(13,2))	AS PORCENTAJE_REGULAR,
				CAST(PIEL_PORCENTAJE_MALO AS DECIMAL(13,2))		AS PORCENTAJE_MALO,
				(PIEL_TOTAL - PIEL_TOTAL_CLASIFICADA)			AS PIEL_X_CLASIFICAR
		-- =====================
		FROM	PIEL_CLASIFICADA_PORCENTAJE
		INNER JOIN	@TBL_LOTE_CLASIFICADO AS TBL_CLASIFICADO ON PIEL_CLASIFICADA_PORCENTAJE.COLOR = TBL_CLASIFICADO.COLOR_CLASIFICADO
					AND	PIEL_CLASIFICADA_PORCENTAJE.LOTE = TBL_CLASIFICADO.LOTE_CLASIFICADO
		-- =====================
	

	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / FICHA
-- //////////////////////////////////////////////////////////////
-- EXECUTE PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE 0,0,'104313'
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]
GO


CREATE PROCEDURE [dbo].[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_COLOR							VARCHAR(10),
	@PP_LOTE							VARCHAR(10)
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_K_PIEL_CLASIFICADA_PORCENTAJE		INT = 0

		EXECUTE [DATA_02Pruebas].[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																	'DATA_02Pruebas','PIEL_CLASIFICADA_PORCENTAJE', 'K_PIEL_CLASIFICADA_PORCENTAJE',
																	@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_CLASIFICADA_PORCENTAJE	OUTPUT
	-- ==================================

	--IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_PIEL_CLASIFICADA_INSERT]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@VP_K_PIEL_CLASIFICADA,@PP_D_PIEL_CLASIFICADA,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
															
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN	

			DECLARE	@VP_N_PIEL_X_LOTE			INT = 0

			SELECT	@VP_N_PIEL_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(LOT))=@PP_LOTE

			IF @VP_N_PIEL_X_LOTE IS NULL 
				SET @VP_N_PIEL_X_LOTE = 0
			-- ==================================

			DECLARE	@VP_N_PIEL_BUENA_X_LOTE		INT = 0
			DECLARE	@VP_N_PIEL_REGULAR_X_LOTE	INT = 0
			DECLARE	@VP_N_PIEL_MALA_X_LOTE		INT = 0

			/*
			K_PIEL_CLASIFICADA
			#1 BUENA | #2 REGULAR | #3 MALA
			*/

			SELECT	@VP_N_PIEL_BUENA_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=1 -- BUENA
					
			IF @VP_N_PIEL_BUENA_X_LOTE IS NULL 
				SET @VP_N_PIEL_BUENA_X_LOTE = 0
			-- ==================================

			SELECT	@VP_N_PIEL_REGULAR_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=2 -- REGULAR
			
			IF @VP_N_PIEL_REGULAR_X_LOTE IS NULL 
				SET @VP_N_PIEL_REGULAR_X_LOTE = 0
			-- ==================================

			SELECT	@VP_N_PIEL_MALA_X_LOTE = COUNT(ID)
			FROM	RP_SC
			WHERE	RTRIM(LTRIM(COLOUR))=@PP_COLOR
			AND		RTRIM(LTRIM(LOT))=@PP_LOTE
			AND		K_CLASIFICACION=3 -- MALA
			
			IF @VP_N_PIEL_MALA_X_LOTE IS NULL 
				SET @VP_N_PIEL_MALA_X_LOTE = 0
			-- ==================================

			DECLARE @VP_PIEL_PORCENTAJE_BUENO		DECIMAL(19,4)
			DECLARE @VP_PIEL_PORCENTAJE_REGULAR		DECIMAL(19,4)
			DECLARE @VP_PIEL_PORCENTAJE_MALO		DECIMAL(19,4)

			SET @VP_PIEL_PORCENTAJE_BUENO =	ROUND(CAST(@VP_N_PIEL_BUENA_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100
	
			SET @VP_PIEL_PORCENTAJE_REGULAR = ROUND(CAST(@VP_N_PIEL_REGULAR_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100

			SET @VP_PIEL_PORCENTAJE_MALO = ROUND(CAST(@VP_N_PIEL_MALA_X_LOTE AS FLOAT) / CAST(@VP_N_PIEL_X_LOTE AS FLOAT),3) * 100
			-- ==================================

			DECLARE @VP_PIEL_TOTAL_CLASIFICADA INT = (@VP_N_PIEL_BUENA_X_LOTE	+  @VP_N_PIEL_REGULAR_X_LOTE + @VP_N_PIEL_MALA_X_LOTE)		


			IF NOT EXISTS(SELECT K_PIEL_CLASIFICADA_PORCENTAJE FROM PIEL_CLASIFICADA_PORCENTAJE WHERE RTRIM(LTRIM(COLOR))=@PP_COLOR AND	RTRIM(LTRIM(LOTE))=@PP_LOTE )
				BEGIN
					INSERT INTO [PIEL_CLASIFICADA_PORCENTAJE]	
						(	[K_PIEL_CLASIFICADA_PORCENTAJE],
							[COLOR], 
							[LOTE],						
							[PIEL_TOTAL],				
							[PIEL_TOTAL_CLASIFICADA],	
							[PIEL_TOTAL_BUENO],		
							[PIEL_TOTAL_REGULAR],		
							[PIEL_TOTAL_MALO],			
							[PIEL_PORCENTAJE_BUENO],		
							[PIEL_PORCENTAJE_REGULAR],	
							[PIEL_PORCENTAJE_MALO]	
							)		
					VALUES	
						(	@VP_K_PIEL_CLASIFICADA_PORCENTAJE, 
							@PP_COLOR,
							@PP_LOTE,
							@VP_N_PIEL_X_LOTE,
							@VP_PIEL_TOTAL_CLASIFICADA,
							@VP_N_PIEL_BUENA_X_LOTE,
							@VP_N_PIEL_REGULAR_X_LOTE,
							@VP_N_PIEL_MALA_X_LOTE,
							@VP_PIEL_PORCENTAJE_BUENO,
							@VP_PIEL_PORCENTAJE_REGULAR,		
							@VP_PIEL_PORCENTAJE_MALO	)				
				END
			ELSE
				BEGIN
					UPDATE	PIEL_CLASIFICADA_PORCENTAJE
					SET		
						[PIEL_TOTAL_CLASIFICADA]	= @VP_PIEL_TOTAL_CLASIFICADA,
						[PIEL_TOTAL_BUENO]			= @VP_N_PIEL_BUENA_X_LOTE,		
						[PIEL_TOTAL_REGULAR]		= @VP_N_PIEL_REGULAR_X_LOTE,	
						[PIEL_TOTAL_MALO]			= @VP_N_PIEL_MALA_X_LOTE,		
						[PIEL_PORCENTAJE_BUENO]		= @VP_PIEL_PORCENTAJE_BUENO,	
						[PIEL_PORCENTAJE_REGULAR]	= @VP_PIEL_PORCENTAJE_REGULAR,			
						[PIEL_PORCENTAJE_MALO]		= @VP_PIEL_PORCENTAJE_MALO	
						
					WHERE RTRIM(LTRIM(COLOR))=@PP_COLOR 
					AND	RTRIM(LTRIM(LOTE))=@PP_LOTE

					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE', 16, 1 ) --MENSAJE - Severity -State.

				END

		END

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
