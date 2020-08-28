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

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_V2]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]	0,0,  3785638 , '-' , '09400' , 'MHI' , 'T12' , 1 , 
												'FMCKTX7' , '0' , '' , 'franciscoe' , 'ITX-002' 
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION_V2]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_K_PIEL_A_TRANSFERIR_TRANSACCION		INT,
	@PP_TAGNO_ORIGEN						INT,
	-- ===========================
	@PP_ORDEN_ORIGEN						VARCHAR(10),
	@PP_ORDEN_DESTINO						VARCHAR(10),
	-- ===========================
	@PP_LOCACION_ORIGEN						VARCHAR(10),
	@PP_LOCACION_DESTINO					VARCHAR(10),
	-- ===========================
	@PP_CARGAR_ORDEN						INT, 
	-- ===========================
	@PP_COLOR_PIEL							VARCHAR(20),
	@PP_TB_SQF								VARCHAR(10),
	@PP_COMENTARIO							VARCHAR(255),
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- ////////////////////////////////////////////////////////////////////	

			DECLARE @VP_COLOR_TBL	VARCHAR(10)
			DECLARE @VP_LOTE_TBL	VARCHAR(10)
			DECLARE @VP_PIEL_TBL	VARCHAR(10)
			DECLARE @VP_SQF_RECIBIR	VARCHAR(20)

			DECLARE CU_PIEL_SELECCIONADA CURSOR 
			FOR SELECT COLOR, LOTE, PIEL, SQF_RECIBIR FROM [PIEL_A_TRANSFERIR]
				WHERE CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF_ENVIAR))) <> CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF_RECIBIR)))
				AND K_PIEL_A_TRANSFERIR_TRANSACCION = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
				AND FOLIO_ORIGEN = @PP_TAGNO_ORIGEN
				AND COLOR = @PP_COLOR_PIEL
				AND LOCACION_ORIGEN = @PP_LOCACION_ORIGEN

			OPEN CU_PIEL_SELECCIONADA
			FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_RECIBIR
				
			WHILE @@FETCH_STATUS = 0
				BEGIN
					
					UPDATE	RP_SC
						SET	SQF = @VP_SQF_RECIBIR
					WHERE	LTRIM(RTRIM(TAGNO))	= @PP_TAGNO_ORIGEN
					AND		LTRIM(RTRIM(COLOUR))	= @PP_COLOR_PIEL
					AND		LTRIM(RTRIM(LOT))	= @VP_LOTE_TBL
					AND		LTRIM(RTRIM(HIDE))	= @VP_PIEL_TBL

					IF @@ROWCOUNT = 0
					BEGIN
						DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255)= 'No fue posible actualizar la piel: ' + @VP_PIEL_TBL
						RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
					END


					FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_RECIBIR
	
				END
	
			CLOSE CU_PIEL_SELECCIONADA
			DEALLOCATE CU_PIEL_SELECCIONADA

			-- ////////////////////////////////////////////////////////////////////		
			DELETE	FROM	[PIEL_A_TRANSFERIR]
			WHERE	[K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
			
			IF @@ROWCOUNT = 0
			BEGIN
				DECLARE @VP_MENSAJE_DEL_TRANSACCION VARCHAR(255)= 'No fue posible borrar la transaccion: ' + CONVERT(VARCHAR(10), @PP_K_PIEL_A_TRANSFERIR_TRANSACCION)
				RAISERROR (@VP_MENSAJE_DEL_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
			END
			-- ////////////////////////////////////////////////////////////////////	

			IF SUBSTRING(@PP_LOCACION_DESTINO, 1, 1) IN ('T', 'G') AND @PP_ORDEN_DESTINO <> '' AND  @PP_CARGAR_ORDEN = 1
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
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_X_LOCACION] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible transferir el [FOLIO]: ' + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
