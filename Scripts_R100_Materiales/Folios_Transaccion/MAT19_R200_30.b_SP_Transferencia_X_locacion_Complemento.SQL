-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]		0,0,   FMCKTX7 , 3783329 , '07869' , 'Table 67' , 
																0 , '32701' , '1071' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	-- ===========================
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_ORDEN_DESTINO			VARCHAR(10),
	-- ===========================
	@PP_LOCACION_ORIGEN			VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(10),
	-- ===========================
	@PP_COLOR_PIEL				VARCHAR(20),
	@PP_TB_SQF					VARCHAR(10),
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE	@VP_SQF DECIMAL(13,2) = CONVERT(DECIMAL(13,2),@PP_TB_SQF)

	-- ///////////////////////////////////////////
	IF (	SELECT COUNT(*) FROM sys.table_types
			WHERE name = 'TVPParamXLocacion' AND schema_id = 1	) = 0
			CREATE TYPE dbo.TVPParamXLocacion AS TABLE(	COLOR		VARCHAR(20),
												LOTE		VARCHAR(20),
												SQF			VARCHAR(20)	)
	
	DECLARE @TBL_TOTAL_SQF_X_LOTE	TVPParamXLocacion 
	
	INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
	SELECT	COLOUR,
			RIGHT('000000' + Ltrim(Rtrim(LOT)), 6),
			SUM(CAST(SQF AS DECIMAL(4,2)))
	-- =====================
	FROM	RP_SC
	-- =====================
	WHERE	TAGNO=@PP_TAGNO_ORIGEN 
	-- =====================
	GROUP BY	COLOUR, LOT
	-- =====================

	-- /////////////////////////////////////////////////////////////////////
	EXECUTE [dbo].[PG_PM_TRANSFER_X_LOCACION]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_LOCACION_DESTINO, @PP_LOCACION_ORIGEN,
													@PP_ORDEN_DESTINO, @PP_ORDEN_ORIGEN, @TBL_TOTAL_SQF_X_LOTE,						 	
													@VP_SQF, @PP_COMENTARIO, @PP_USER

	-- /////////////////////////////////////////////////////////////////////
	IF @PP_LOCACION_ORIGEN = 'MIT' And @PP_LOCACION_DESTINO = 'MHI' 
		BEGIN
			IF EXISTS ( SELECT TOP 1 RP_Folios.ID FROM RP_Folios INNER JOIN RP_SC ON TAG=TAGNO and STATUS='B' AND LTRIM(RTRIM(COLOUR)) = @PP_COLOR_PIEL)
				BEGIN
					DECLARE @VP_FOLIO	INT
					SELECT TOP 1 @VP_FOLIO = TAG from RP_Folios INNER JOIN RP_SC ON TAG=TAGNO and STATUS='B' AND LTRIM(RTRIM(COLOUR)) = @PP_COLOR_PIEL 
					
					-- /////////////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_PR_IN_PIEL_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														1, @PP_TAGNO_ORIGEN, @PP_COLOR_PIEL, 
														@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN,
														@VP_FOLIO, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

					-- /////////////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, @VP_FOLIO, @PP_LOCACION_DESTINO, 1
				END
			ELSE
				BEGIN
					-- /////////////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_PR_IN_PIEL_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														1, @PP_TAGNO_ORIGEN, @PP_COLOR_PIEL, 
														@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN,
														0, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

					-- /////////////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, 0, @PP_LOCACION_DESTINO, 0
					
					-- /////////////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_RP_FOLIO_X_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TAGNO_ORIGEN, 'B', NULL, NULL
				END
		END
	ELSE
		BEGIN
			DECLARE @VP_TIPO_PIEL_LOG INT = 4

			IF @PP_ORDEN_DESTINO = ''
				SET @VP_TIPO_PIEL_LOG = 2

			-- /////////////////////////////////////////////////////////////////////
			EXECUTE [dbo].[PG_PR_IN_PIEL_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_TIPO_PIEL_LOG, @PP_TAGNO_ORIGEN, @PP_COLOR_PIEL, 
												@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN,
												0, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

			-- /////////////////////////////////////////////////////////////////////
			EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_TAGNO_ORIGEN, 0, @PP_LOCACION_DESTINO, 0
		END
	
	-- /////////////////////////////////////////////////////////////////////
	DECLARE @VP_DETAIL VARCHAR(255)= 'from: ' + @PP_LOCACION_ORIGEN + ' to: ' +@PP_LOCACION_DESTINO + ' orden:' + @PP_ORDEN_DESTINO
	EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
										@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
										@PP_TAGNO_ORIGEN, 'Transfer Folio',
										@VP_DETAIL, ''

	-- /////////////////////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF_TRANSFER  DECIMAL(13,4) = 0
	SELECT	@VP_TOTAL_SQF_TRANSFER	=  SUM(CAST(SQF AS DECIMAL(13,4)))
									FROM	RP_SC
									WHERE	TAGNO=@PP_TAGNO_ORIGEN 
							
	IF @VP_TOTAL_SQF_TRANSFER IS NULL
		SET @VP_TOTAL_SQF_TRANSFER = 0

	IF 	@PP_LOCACION_DESTINO = 'MFP'
			EXECUTE [dbo].[PG_CONFIGURAR_CORREO_MFP_ENTRADA_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																	@PP_LOCACION_ORIGEN, @PP_COLOR_PIEL, @PP_TAGNO_ORIGEN, 
																	@VP_TOTAL_SQF_TRANSFER, @PP_COMENTARIO, @PP_USER

	IF 	 ( @PP_LOCACION_ORIGEN IN ('MQU','MRD') AND @PP_LOCACION_DESTINO = 'MHI' )
		EXECUTE [dbo].[PG_CONFIGURAR_CORREO_MHI_ENTRADA_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																@PP_LOCACION_ORIGEN, @PP_COLOR_PIEL, @PP_TAGNO_ORIGEN, 
																@VP_TOTAL_SQF_TRANSFER, @PP_COMENTARIO, @PP_USER
	

	
	-- ////////////////////////////////////////////////////////////////////	
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
