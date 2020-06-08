-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC
-- // OPERACION:		LIBERACION / REGLAS DE NEGOCIO
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	8/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_TRANSFERENCIA_FOLIO_A_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_TRANSFERENCIA_FOLIO_A_ORDEN]
GO
/*
	EXEC [dbo].[PG_RN_VALIDA_TRANSFERENCIA_FOLIO_A_ORDEN] 0,0, 'FMCKTX7', '12336', 3787113, 1035.4
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_TRANSFERENCIA_FOLIO_A_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_COLOR					VARCHAR(20),
	@PP_ORDEN					VARCHAR(10),
	@PP_FOLIO					INT,
	@PP_SQF_FOLIO				DECIMAL(8,4)
	-- ===========================		
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	DECLARE @VP_SQF_ORDEN		DECIMAL(8,4) = 0
	DECLARE @VP_SQF_SOBRANTE	DECIMAL(8,4) = 0
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													@PP_FOLIO, @PP_COLOR,
													@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_VALIDA_PIEL_CLASIFICADA_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																@PP_FOLIO,
																@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_VALIDA_PORCENTAJE_PIEL_CLASIFICADA_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																			@PP_COLOR, @PP_FOLIO,
																			@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
	EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
														@PP_ORDEN,
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
															@PP_ORDEN,
															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
															@PP_ORDEN, @PP_COLOR,
															@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		BEGIN
			SELECT TOP  1 @VP_SQF_ORDEN = standardsqm
			FROM	CCJOBHDR_SQL
			WHERE	jobno = @PP_ORDEN

			IF @VP_SQF_ORDEN IS NULL
				SET	@VP_RESULTADO = 'Verifique el [SQF] que requiere la orden: ' + @PP_ORDEN
			
			IF  @VP_RESULTADO = ''
				BEGIN
					IF NOT @PP_SQF_FOLIO > @VP_SQF_ORDEN
					SET	@VP_RESULTADO = 'El [SQF] del folio debe ser mayor a lo que requiere la orden.'
				END

			IF  @VP_RESULTADO = ''
				BEGIN 
					SET @VP_SQF_SOBRANTE = @PP_SQF_FOLIO - @VP_SQF_ORDEN
					SELECT @VP_SQF_SOBRANTE
					IF ( @VP_SQF_SOBRANTE >= 50 AND @VP_SQF_SOBRANTE <= 100 )
						SET @VP_RESULTADO = 'El [SQF] extra del folio debe ser entre [50 a 100]'
				END
		END
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		BEGIN
			SELECT 'TODO CORRECTO EL FOLIO SE ASIGNO A LA ORDEN'
			--SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO
		END
	ELSE
		BEGIN
			SELECT @VP_RESULTADO
		END
	-- /////////////////////////////////////////////////////
GO




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
