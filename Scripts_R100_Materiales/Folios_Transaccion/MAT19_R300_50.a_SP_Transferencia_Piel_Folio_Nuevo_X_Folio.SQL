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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO]	0,0,  FMCKTX7 , 2137674 , '-' , '-' , 0 , 
					'103741/103741/103741/103741/103741/103741/103741/103741/103741/103741' , 
					'0025/0061/0059/0062/0063/0064/0065/0066/0067/0022' , 
					'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CB_COLOR				VARCHAR(20),
	@PP_TAGNO_ORIGEN			INT,
	@PP_LOCACION_ORIGEN			VARCHAR(5),
	@PP_TB_ORDEN				VARCHAR(10),
	@PP_TB_MAQUINA				VARCHAR(10),
	@PP_SELECT_TODOS			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
	@PP_SQF_ARRAY				NVARCHAR(MAX),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
		--												@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			
				-- /////////////////////////////////////////////////////////////////////
				IF	@PP_SELECT_TODOS = 1
					EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
															@PP_TAGNO_ORIGEN, 'A', NULL, NULL
				-- /////////////////////////////////////////////////////////////////////
				
				DECLARE @VP_TAGNO_DESTINO		INT = 0
				EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																	'DATA_02', 'RP_SC', 'TAGNO',
																	@OU_K_TABLA_DISPONIBLE = @VP_TAGNO_DESTINO	OUTPUT
				-- =====================

				IF @VP_MENSAJE = ''
					BEGIN
						INSERT INTO RP_Folios (	
								TAG, STATUS, MACHINE, JOBNO	) 
						VALUES(
								@VP_TAGNO_DESTINO, 'A', @PP_TB_MAQUINA, @PP_TB_ORDEN	)
						
						IF @@ROWCOUNT = 0
							SET @VP_MENSAJE = 'ERROR: // INSERT RP_Folios // '
					END
				-- /////////////////////////////////////////////////////////////////////
				
				IF @VP_MENSAJE = ''
					BEGIN
						EXECUTE [PG_IN_RP_SC_PRT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
													@VP_TAGNO_DESTINO, 1
					END
				-- /////////////////////////////////////////////////////////////////////

				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(20),
						LOTE		VARCHAR(20),
						PIEL		VARCHAR(20),
						SQF			VARCHAR(20),
						MOVIMIENTO	VARCHAR(20)
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_PIEL			INT
				DECLARE @VP_POSICION_LOTE			INT
				DECLARE @VP_POSICION_SQF			INT

				DECLARE @VP_LOTE_VALOR				VARCHAR(20)
				DECLARE @VP_PIEL_VALOR				VARCHAR(20)
				DECLARE @VP_SQF_VALOR				VARCHAR(20)
				DECLARE @VP_MOVIMIENTO_VALOR		VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_LOTE_ARRAY			= @PP_LOTE_ARRAY		+ '/'		
				SET	@PP_PIEL_ARRAY			= @PP_PIEL_ARRAY		+ '/'		
				SET	@PP_SQF_ARRAY			= @PP_SQF_ARRAY			+ '/'
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_PIEL_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_PIEL	=	patindex('%/%' , @PP_PIEL_ARRAY)
						SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY)
						SELECT @VP_POSICION_SQF	=		patindex('%/%' , @PP_SQF_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_PIEL_VALOR		= LEFT(@PP_PIEL_ARRAY, @VP_POSICION_PIEL - 1)
						SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION_LOTE - 1)
						SELECT @VP_SQF_VALOR		= LEFT(@PP_SQF_ARRAY,  @VP_POSICION_SQF - 1)
						
						SELECT	TOP 1 
								@VP_MOVIMIENTO_VALOR = LTRIM(RTRIM(MOVEMENT))
												FROM	RP_SC 
												WHERE	LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR 
												AND		LTRIM(RTRIM(TAGNO)) = @PP_TAGNO_ORIGEN
												AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_VALOR
												AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_VALOR
												AND		LTRIM(RTRIM(SQF)) = @VP_SQF_VALOR

						INSERT	INTO	@TBL_PIEL_SELECCIONADAS
								VALUES	(
											@PP_CB_COLOR,
											@VP_LOTE_VALOR,
											@VP_PIEL_VALOR,
											@VP_SQF_VALOR,
											@VP_MOVIMIENTO_VALOR	)
																								
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_PIEL_ARRAY			= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
						SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')
						SELECT @PP_SQF_ARRAY			= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION_SQF, '')

					END
								
				DECLARE @VP_N_PIEL INT = 0
				SELECT @VP_N_PIEL = COUNT(K_PIEL_SELECCIONADA) FROM @TBL_PIEL_SELECCIONADAS

				-- /////////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION////////////////////////////////////////////
				IF @VP_N_PIEL IS NULL
					RAISERROR ('Error raised in TRY block.', 16, 1 ) --MENSAJE - Severity -State.
				-- ///////////////////////////////////////////
								
				DECLARE @VP_LOTE AS VARCHAR(20)
				DECLARE @VP_PIEL AS VARCHAR(20)
				DECLARE @VP_SQF AS VARCHAR(20)
				DECLARE @VP_MOVIMIENTO AS VARCHAR(20)

				DECLARE CU_PIEL_SELECCIONADA CURSOR 
				FOR SELECT LOTE, PIEL, SQF, MOVIMIENTO FROM @TBL_PIEL_SELECCIONADAS
				
				OPEN CU_PIEL_SELECCIONADA
				FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_LOTE, @VP_PIEL, @VP_SQF, @VP_MOVIMIENTO
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
						-- ///////////////////////////////////////////
						DECLARE @VP_LOCACION AS VARCHAR(5) = @PP_LOCACION_ORIGEN

						--IF ISNUMERIC(@VP_MOVIMIENTO) = 1 
						--	BEGIN
						--		SELECT	@VP_LOCACION = LTRIM(RTRIM(IMINVTRX_SQL.Loc))
						--				-- ===================== 
						--		FROM	IMLSTRX_SQL, IMINVTRX_SQL 
						--				-- =====================
						--		WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
						--		AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
						--		AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
						--		AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
						--		AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
						--		AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
						--		AND		IMINVTRX_SQL.ord_no	= @VP_MOVIMIENTO
						--		-- =====================
						--		AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
						--				OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
						--		-- =====================

						--		IF @VP_LOCACION IS NULL
						--			SET @VP_LOCACION = ''
						--		-- =====================
						--	END
						--ELSE
						--	BEGIN
						--		SET @VP_LOCACION = @VP_MOVIMIENTO
						--	END

						-- ///////////////////////////////////////////
						DECLARE @VP_LOTE_INT INT			= CAST(@VP_LOTE AS INT)
						DECLARE @VP_PIEL_INT INT			= CAST(@VP_PIEL AS INT)
						DECLARE @VP_SQF_DEC DECIMAL(13,4)	= CAST(@VP_SQF AS DECIMAL(19,4))

						-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////

						EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															3, @PP_TAGNO_ORIGEN, @PP_CB_COLOR,
															@VP_LOTE_INT, @VP_PIEL_INT, @VP_SQF_DEC, 
															@VP_LOCACION, 0, 
															@VP_TAGNO_DESTINO, @VP_LOCACION, 0
						-- ///////////////////////////////////////////

						EXECUTE	[dbo].[PG_UP_RP_SC_TAGNO_Y_MOVEMENT_X_FOLIO_PIEL_LOTE_SQF]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																								@PP_TAGNO_ORIGEN, @VP_TAGNO_DESTINO,
																								@VP_PIEL, @VP_LOTE, @VP_SQF, @VP_LOCACION
						-- /////////////////////////////////////////////////////////////////////
	
						DECLARE @VP_DETAIL VARCHAR(100) = 'Transfer hide: ' + @VP_PIEL + ' to: ' + CONVERT(VARCHAR(20),@VP_TAGNO_DESTINO) + ' Lot: ' + RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE)), 6)
							
						EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
															@PP_TAGNO_ORIGEN, 'Transfer Nuevo',
															@VP_DETAIL, @VP_PIEL

						FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_LOTE, @VP_PIEL, @VP_SQF, @VP_MOVIMIENTO
	
					END
	
				CLOSE CU_PIEL_SELECCIONADA
				DEALLOCATE CU_PIEL_SELECCIONADA
			
	-- ////////////////////////////////////////////////////////////////////	
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible transferir el [FOLIO]: '+CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN)+']' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_TAGNO_DESTINO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @VP_TAGNO_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
