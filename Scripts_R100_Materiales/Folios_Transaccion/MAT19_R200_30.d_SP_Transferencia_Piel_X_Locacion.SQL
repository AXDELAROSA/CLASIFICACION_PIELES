-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_CLASIFICADA
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]	0,0, 3783339 , '-' , '' , 'MHI' , 'MFP' , 1 , 'FMCKTX7' , '0' , 
												'' , 'franciscoe' , 'ITX-002' 
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]
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
	@PP_CARGAR_ORDEN			INT, 
	-- ===========================
	@PP_COLOR_PIEL				VARCHAR(20),
	@PP_TB_SQF					VARCHAR(10),
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- ////////////////////////////////////////////////////////////////////		
			IF SUBSTRING(@PP_LOCACION_DESTINO, 1, 1) = 'T' AND @PP_ORDEN_DESTINO <> '' AND  @PP_CARGAR_ORDEN = 1
				BEGIN
					EXECUTE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, @PP_ORDEN_DESTINO, 
																	@PP_LOCACION_DESTINO, @PP_USER, @PP_COMPUTER_NAME		
																						
					-- /////////////////////////////////////////////////////////////////////

					EXECUTE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_TAGNO_ORIGEN, @PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
																				@PP_LOCACION_ORIGEN ,@PP_LOCACION_DESTINO,
																				@PP_COLOR_PIEL, @PP_TB_SQF, @PP_COMENTARIO,
																				@PP_USER, @PP_COMPUTER_NAME
				END
			ELSE IF @PP_ORDEN_ORIGEN = '-' AND @PP_CARGAR_ORDEN = 1
					BEGIN	
						EXECUTE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, @PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
																					@PP_LOCACION_ORIGEN ,@PP_LOCACION_DESTINO,
																					@PP_COLOR_PIEL, @PP_TB_SQF, @PP_COMENTARIO,
																					@PP_USER, @PP_COMPUTER_NAME
					END
				ELSE  IF @PP_ORDEN_ORIGEN <> '-' AND @PP_CARGAR_ORDEN = 1
						BEGIN
							SET	@PP_ORDEN_DESTINO = @PP_ORDEN_ORIGEN

							EXECUTE [dbo].[PG_UP_RP_FOLIO_X_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TAGNO_ORIGEN, 'A', NULL, NULL

							EXECUTE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_COMPLEMENTO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_TAGNO_ORIGEN, @PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
																						@PP_LOCACION_ORIGEN ,@PP_LOCACION_DESTINO,
																						@PP_COLOR_PIEL, @PP_TB_SQF, @PP_COMENTARIO,
																						@PP_USER, @PP_COMPUTER_NAME
					END
		-- ////////////////////////////////////////////////////////////////////	
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @ErrorMessage NVARCHAR(4000);
				SET @ErrorMessage = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. [PG_PM_TRANSFER_PIEL_X_LOCACION] // '
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
