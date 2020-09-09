-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	10/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_SCRAP]	0,0,   'FMCKTX7' , 3788389 , 'GT2' , '11619' , 0 , '33012' , '0899' , '15.00' , 0 , 15.00 , '' , 'franciscoe' , 'IT-010'  
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_SCRAP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_SCRAP]
GO

CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_SCRAP]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CB_COLOR				VARCHAR(20),
	@PP_TAGNO_ORIGEN			INT,
	@PP_LOCACION_ORIGEN			VARCHAR(5),
	@PP_TB_ORDEN				VARCHAR(10),
	@PP_SELECT_TODOS			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
	@PP_SQF_ARRAY				NVARCHAR(MAX),
	-- ===========================
	@PP_PRT_FORM_DEV_EXT		INT, -- INPRIMIR FORMA #0 N0, #1 SI
	@PP_TB_SQF					DECIMAL(13,2),
	-- ===========================
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_K_CLASIFICACION	INT = 0
	DECLARE @VP_F_CREACION_INT	INT = DATA_02.DBO.[CONVERT_DATE_TO_INT](CONVERT(DATE, GETDATE()),'yyyyMMdd')

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
													@PP_TAGNO_ORIGEN, @PP_CB_COLOR,
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	IF @VP_MENSAJE=''
		IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) IN ('T', 'G')
			EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TB_ORDEN,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			
				-- /////////////////////////SI SE SELECIONO TODAS LAS PIELES DE LA PIEL ACTUALIZO EL FOLIO///////////////////////
				IF	@PP_SELECT_TODOS = 1 AND SUBSTRING(@PP_LOCACION_ORIGEN,1,1) <> 'G'
					BEGIN
							EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
																	@PP_TAGNO_ORIGEN, 'A', NULL, NULL
					END

				IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) = 'G'
					BEGIN
						-- /////////////////////////SI ACTUALIZA EL ESTATUS DE LA ORDEN A CERRADO///////////////////////
						EXECUTE [dbo].[PG_UP_CCJOBHDR_SQL_X_ORDEN]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
																	@PP_TB_ORDEN, 'C', @VP_F_CREACION_INT, 
																	0, 0, 0
				
						-- /////////////////////////SI ACTUALIZA EL ESTATUS DEL FOLIO A XX CERRADO///////////////////////
						UPDATE RP_FOLIOS
							SET STATUS = 'XX'
						WHERE TAG = @PP_TAGNO_ORIGEN
					END

				DECLARE @VP_TAGNO_DESTINO		INT = @PP_TAGNO_ORIGEN

				IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) <> 'G'
					BEGIN
						SET @VP_TAGNO_DESTINO = 0
						-- ///////////////OBTENGO UN NUEVO FOLIO//////////////////////////////////////////////////////
						EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																			'DATA_02', 'RP_FOLIOS', 'TAG',
																			@OU_K_TABLA_DISPONIBLE = @VP_TAGNO_DESTINO	OUTPUT

						-- /////////////////////////INGRESO EL NUEVO FOLIO////////////////////////////////////////////
						EXECUTE [dbo].[PG_IN_RP_FOLIOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_TAGNO_DESTINO, 'A', NULL, NULL, NULL

						-- /////////////////////SE IMPRIME EL FOLIO NUEVO////////////////////////////////////////////////
						EXECUTE [PG_IN_RP_SC_PRT]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
													@VP_TAGNO_DESTINO, 1
					END

				-- /////////////////////////////////////////////////////////////////////
				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(20),
						LOTE		VARCHAR(20),
						PIEL		VARCHAR(20),
						SQF			VARCHAR(20)
					)
				SET NOCOUNT ON
				
				IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) = 'G'
					BEGIN
						INSERT INTO @TBL_PIEL_SELECCIONADAS(COLOR, LOTE, PIEL, SQF	)
						SELECT LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), LTRIM(RTRIM(SQF))
						FROM RP_SC
						WHERE TAGNO = @PP_TAGNO_ORIGEN
						
						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible obtener las pieles del folio origen.', 16, 1 ) --MENSAJE - Severity -State.
					END
				ELSE
					BEGIN
						DECLARE @VP_POSICION_PIEL			INT
						DECLARE @VP_POSICION_LOTE			INT
						DECLARE @VP_POSICION_SQF			INT

						DECLARE @VP_LOTE_VALOR				VARCHAR(20)
						DECLARE @VP_PIEL_VALOR				VARCHAR(20)
						DECLARE @VP_SQF_VALOR				VARCHAR(20)
										
						--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
						SET	@PP_LOTE_ARRAY			= @PP_LOTE_ARRAY		+ '/'		
						SET	@PP_PIEL_ARRAY			= @PP_PIEL_ARRAY		+ '/'		
						SET	@PP_SQF_ARRAY			= @PP_SQF_ARRAY			+ '/'
			
						--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
						WHILE patindex('%/%' , @PP_PIEL_ARRAY) <> 0
							BEGIN
								SELECT @VP_POSICION_PIEL	=	patindex('%/%' , @PP_PIEL_ARRAY)
								SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY)
								SELECT @VP_POSICION_SQF		=	patindex('%/%' , @PP_SQF_ARRAY)
								
								--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
								SELECT @VP_PIEL_VALOR		= LEFT(@PP_PIEL_ARRAY, @VP_POSICION_PIEL - 1)
								SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION_LOTE - 1)
								SELECT @VP_SQF_VALOR		= LEFT(@PP_SQF_ARRAY,  @VP_POSICION_SQF - 1)
								

								INSERT	INTO	@TBL_PIEL_SELECCIONADAS
										VALUES	(
													@PP_CB_COLOR,
													@VP_LOTE_VALOR,
													@VP_PIEL_VALOR,
													@VP_SQF_VALOR
												)
																										
								--Reemplazamos lo procesado con nada con la funcion stuff
								SELECT @PP_PIEL_ARRAY			= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
								SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')
								SELECT @PP_SQF_ARRAY			= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION_SQF, '')

							END
					END		
				DECLARE @VP_N_PIEL INT = 0
				SELECT @VP_N_PIEL = COUNT(K_PIEL_SELECCIONADA) FROM @TBL_PIEL_SELECCIONADAS

				-- ////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION//////////////////////////
				IF @VP_N_PIEL IS NULL
					RAISERROR ('NO hay pieles seleccionadas.', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////////////////////////////////////////////////////////////////////////////////
				DECLARE @VP_COLOR_TBL VARCHAR(10)
				DECLARE @VP_LOTE_TBL VARCHAR(10)
				DECLARE @VP_PIEL_TBL VARCHAR(10)
				DECLARE @VP_SQF_TBL	 VARCHAR(10)
				DECLARE @VP_TOTAL_SQF DECIMAL(13,2)

				-- /////////////////////////OBTENGO LA LOCACION DESTINO////////////////////////////////////////////
				DECLARE @VP_LOCACION_DESTINO VARCHAR(5)
				SELECT	@VP_LOCACION_DESTINO =	LTRIM(RTRIM(alt1_loc))
												FROM	imlocfil_sql 
												WHERE	 LTRIM(RTRIM(alt1_loc)) = 'MFP'
				
				IF @VP_LOCACION_DESTINO IS NULL OR @VP_LOCACION_DESTINO = ''
					RAISERROR ('La [Locacion] destino no existe.', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////////////////////SI LAS PIELES A TRANSFERIR SON MAS DE UNA////////////////////////////////////////////
				IF @VP_N_PIEL > 1
					BEGIN
						DECLARE CU_PIEL_SELECCIONADA CURSOR 
						FOR SELECT COLOR, LOTE, PIEL, SQF FROM @TBL_PIEL_SELECCIONADAS
						
						OPEN CU_PIEL_SELECCIONADA
						FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_TBL
						
						WHILE @@FETCH_STATUS = 0
							BEGIN
								DECLARE @VP_LOTE_INT INT			= CAST(@VP_LOTE_TBL AS INT)
								DECLARE @VP_PIEL_INT INT			= CAST(@VP_PIEL_TBL AS INT)
								DECLARE @VP_SQF_DEC DECIMAL(13,4)	= CAST(@VP_SQF_TBL AS DECIMAL(19,4))

								-- ///////////////////VALIDO QUE LA PIEL ESTE CORTADA//////////////////////////////////////////////////
								IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) IN ('T', 'G')
									EXECUTE [dbo].[PG_RN_VALIDA_PIEL_SCRAP]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																				@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @PP_TB_ORDEN,
																				@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
								IF @VP_MENSAJE <> ''
									RAISERROR (@VP_MENSAJE, 16, 1 )

								-- ///////////////////SE BORRA EL REGISTRO DE DE LA PIEL CORTADA//////////////////////////////////////////////////
								IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) = 'T'
									EXECUTE [dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																				@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @PP_TB_ORDEN
																				

								-- ///////////////////OBTENGO LA CLASIFICACION DE LA PIEL//////////////////////////////////////////////////
								SELECT @VP_K_CLASIFICACION = K_CLASIFICACION
															FROM RP_SC
															WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
															AND		TAGNO = @PP_TAGNO_ORIGEN
															AND	LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
															AND	LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL

								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	9, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @VP_SQF_DEC, 
																	@PP_LOCACION_ORIGEN, @PP_TB_ORDEN, 
																	@VP_TAGNO_DESTINO, @VP_LOCACION_DESTINO, '0'
								
								IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) <> 'G'
									BEGIN
										-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
										DECLARE @VP_F_ACTUAL	AS DATE = GETDATE()
										EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@VP_F_ACTUAL, @PP_CB_COLOR, @VP_LOTE_TBL, 
																		@VP_PIEL_TBL, @VP_SQF_TBL, @VP_TAGNO_DESTINO, 
																		NULL, NULL, NULL, 'C', @VP_LOCACION_DESTINO, @VP_K_CLASIFICACION

										-- /////////////////////////ACTUALIZO EL FOLIO ANTERIOR////////////////////////////////////////////
										EXECUTE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_ORIGEN, 'D', @VP_PIEL_TBL, @VP_LOTE_TBL
							
										-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										DECLARE @VP_DETAIL VARCHAR(100) = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@VP_TAGNO_DESTINO) + ' Lot: ' + RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_TBL)), 6)
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosScrap',
																			@PP_TAGNO_ORIGEN, 'Transfer',
																			@VP_DETAIL, @VP_PIEL_TBL

										-- /////////////////////////SI DESEA IMPRIMIR EL FORMATO DE DEVOLUCION Y EXTRAS////////////////////////////////////////////
										IF @PP_PRT_FORM_DEV_EXT = 1 -- SI
											BEGIN
												-- /////////////////VALIDA ESTATUS FOLIO ORIGEN////////////////////////////////////////////////////
												DECLARE	@VP_ESTATUS	VARCHAR(5)
												SELECT	@VP_ESTATUS	= LTRIM(RTRIM(STATUS))
																	FROM RP_Folios
																	WHERE LTRIM(RTRIM(TAG)) = @PP_TAGNO_ORIGEN

												IF @VP_ESTATUS <> 'B' --AND @PP_LOCACION_ORIGEN <> 'MHI'
													BEGIN
														EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_ORIGEN, 5
													END
												ELSE
													BEGIN
														EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_TAGNO_ORIGEN, 'D'
													END

											END	
										ELSE
											BEGIN
												-- //////////////////////////////BORRA EL FOLIO ORIGEN///////////////////////////////////////
												EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_ORIGEN, 'D'

												-- ////////////////////////////INGRESA EL LOG/////////////////////////////////////////
												SET @VP_DETAIL = 'Delete hides por SCRAP (ya se agrego al nuevo folio) Lot:' + @VP_LOTE_TBL
												EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_USER, @PP_COMPUTER_NAME, 'FolioScrap',
																					@PP_TAGNO_ORIGEN, 'Delete hides',
																					@VP_DETAIL, @VP_PIEL_TBL
											
											END
											-- ///////////////////////////////////////////
									END

								FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_TBL
	
							END
	
						CLOSE CU_PIEL_SELECCIONADA
						DEALLOCATE CU_PIEL_SELECCIONADA
					-- ////////////////////////////////////////////////////////////////////	
					END
				ELSE IF @VP_N_PIEL = 1
					BEGIN
						SELECT	TOP 1
								@VP_COLOR_TBL	= COLOR,
								@VP_LOTE_TBL	= LOTE,
								@VP_PIEL_TBL	= PIEL,
								@VP_SQF_TBL		= SQF
								-- =======================
						FROM	@TBL_PIEL_SELECCIONADAS

						SET @VP_LOTE_INT 	= CAST(@VP_LOTE_TBL AS INT)
						SET @VP_PIEL_INT 	= CAST(@VP_PIEL_TBL AS INT)

						-- ///////////////////VALIDO QUE LA PIEL ESTE CORTADA//////////////////////////////////////////////////
						IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) IN ('T', 'G')
							EXECUTE [dbo].[PG_RN_VALIDA_PIEL_SCRAP]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																		@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @PP_TB_ORDEN,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
						IF @VP_MENSAJE <> ''
							RAISERROR (@VP_MENSAJE, 16, 1 )

						-- /////////////////////////////////////////////////////////////////////
						IF (CAST(@VP_SQF_TBL AS DECIMAL(13,2)) = @PP_TB_SQF)
							BEGIN
								-- ///////////////////SE BORRA EL REGISTRO DE DE LA PIEL CORTADA//////////////////////////////////////////////////
								IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) = 'T'
									EXECUTE [dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																				@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @PP_TB_ORDEN

								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	9, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @PP_TB_SQF, 
																	@PP_LOCACION_ORIGEN, @PP_TB_ORDEN, 
																	@VP_TAGNO_DESTINO, @VP_LOCACION_DESTINO, '0'

								IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) <> 'G'
									BEGIN
										-- /////////////////////////REEMPLAZO EL FOLIO ORIGEN POR FOLIO EL DESTINO///////////////
										EXECUTE	[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_TAGNO_ORIGEN, @VP_TAGNO_DESTINO,
																									@VP_PIEL_TBL, @VP_LOTE_TBL, @VP_SQF_TBL

										-- /////////////////////////ACTUALIZO LA PIEL DEL FOLIO DESTINO A TIPO C///////////////
										EXECUTE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@VP_TAGNO_DESTINO, 'C', @VP_PIEL_TBL, @VP_LOTE_TBL
			
										-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@VP_TAGNO_DESTINO) + ' Lot:' + @VP_LOTE_TBL
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FolioScrap',
																			@PP_TAGNO_ORIGEN, 'Transfer',
																			@VP_DETAIL, @VP_PIEL_TBL															
									END	
								-- /////////////////////////////////////////////////////////////////////
								-- /////////////////////////////////////////////////////////////////////							
							END
						ELSE
							BEGIN
								-- ///////////////////SE ACTUALIZA EL SQM DE DE LA PIEL CORTADA//////////////////////////////////////////////////
								IF  SUBSTRING(@PP_LOCACION_ORIGEN,1,1) IN ('T', 'G')
									EXECUTE [dbo].[PG_UP_CCCUTHST_HIDESQM_X_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																					@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, 
																					@PP_TB_ORDEN, @PP_TB_SQF

								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	9, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @PP_TB_SQF, 
																	@PP_LOCACION_ORIGEN, @PP_TB_ORDEN, 
																	@VP_TAGNO_DESTINO, @VP_LOCACION_DESTINO, '0'
								
								IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) <> 'G'
									BEGIN
										-- ///////////////RESTA AL FOLIO ORIGEN EL SQF QUE SE AGREGO AL FOLIO DESTINO ///////////////
										SET @VP_TOTAL_SQF =  CAST(@VP_SQF_TBL AS DECIMAL(13,2)) - @PP_TB_SQF
										
										EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																								@VP_TOTAL_SQF, @PP_TAGNO_ORIGEN,
																								@VP_LOTE_TBL, @VP_PIEL_TBL

										-- ///////////////////OBTENGO LA CLASIFICACION DE LA PIEL//////////////////////////////////////////////////
										SELECT @VP_K_CLASIFICACION = K_CLASIFICACION
																	FROM RP_SC
																	WHERE LTRIM(RTRIM(COLOUR)) = @VP_COLOR_TBL
																	AND		TAGNO = @PP_TAGNO_ORIGEN
																	AND	LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
																	AND	LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL

										-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
										EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@VP_F_ACTUAL, @VP_COLOR_TBL, @VP_LOTE_TBL, 
																		@VP_PIEL_TBL, @PP_TB_SQF, @VP_TAGNO_DESTINO, 
																		NULL, NULL, NULL, 'C', @VP_LOCACION_DESTINO, @VP_K_CLASIFICACION	
																		
											-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'New part hide: ' + @VP_PIEL_TBL + ' / ' + CONVERT(VARCHAR(20),@PP_TB_SQF) + ' from:' + CONVERT(VARCHAR(20),@VP_TAGNO_DESTINO)
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FolioScrap',
																			@PP_TAGNO_ORIGEN, 'Add',
																			@VP_DETAIL, @VP_PIEL_TBL
                    				END	
							END
						-- /////////////////////////////////////////////////////////////////////
						-- /////////////////////////////////////////////////////////////////////
					END

					-- ///////////////OBTENEMOS LOS SQF DE LOS DIFERENTES LOTES A TRANSFERIR//////////////////////////////////////////////////////
					IF (	SELECT COUNT(*) FROM sys.table_types
							WHERE name = 'TVPParam' AND schema_id = 1	) = 0
							CREATE TYPE dbo.TVPParam AS TABLE(	COLOR		VARCHAR(20),
																LOTE		VARCHAR(20),
																SQF			VARCHAR(20)	)
				
					DECLARE @TBL_TOTAL_SQF_X_LOTE	TVPParam
					 
					IF @VP_N_PIEL = 1 AND (CAST(@VP_SQF_TBL AS DECIMAL(13,2)) <> @PP_TB_SQF)
						BEGIN
							INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
							SELECT COLOR, LOTE, @PP_TB_SQF AS SQF 
							FROM @TBL_PIEL_SELECCIONADAS
							GROUP BY COLOR, LOTE
						END
					ELSE
						BEGIN
							INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
							SELECT COLOR, LOTE, SUM(CONVERT(DECIMAL(13,4),SQF)) AS SQF 
							FROM @TBL_PIEL_SELECCIONADAS
							GROUP BY COLOR, LOTE
						END
					
									
					-- ///////////////////////SE REALIZAN LAS TRANSACCIONES//////////////////////////////////////////////
					DECLARE @VP_ORDEN_DESTINO	VARCHAR(10)

					EXECUTE [dbo].[PG_PM_TRANSFER]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_LOCACION_DESTINO, @PP_LOCACION_ORIGEN,
														'', @PP_TB_ORDEN,  @TBL_TOTAL_SQF_X_LOTE,						 	
														@PP_TB_SQF, @PP_COMENTARIO, @PP_USER

						-- //////////////////SE EL MOVIMIENTO/LOCACION AL FOLIO DESTINO////////////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@VP_TAGNO_DESTINO, 0, @VP_LOCACION_DESTINO, 0

					-- //////////////SE ENVIA CORREO A RESPONSABLES DE MFP CON DATOS DE LA TRANSAACION///////////////////////////////////////////////////////
					DECLARE @VP_TOTAL_SQF_MFP  DECIMAL(8,4) = 0
					IF @VP_N_PIEL = 1 AND (CAST(@VP_SQF_TBL AS DECIMAL(13,2)) <> @PP_TB_SQF)
						BEGIN
							SET @VP_TOTAL_SQF_MFP = @PP_TB_SQF
						END
					ELSE
						BEGIN
							SELECT @VP_TOTAL_SQF_MFP = SUM(CONVERT(DECIMAL(13,4),SQF)) 
							FROM @TBL_PIEL_SELECCIONADAS
						END
					
							
					IF @VP_TOTAL_SQF_MFP IS NULL
						SET @VP_TOTAL_SQF_MFP = 0

					EXECUTE [dbo].[PG_CONFIGURAR_CORREO_MFP_ENTRADA_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
																			@PP_LOCACION_ORIGEN, @PP_CB_COLOR, @VP_TAGNO_DESTINO, 
																			@VP_TOTAL_SQF_MFP, @PP_COMENTARIO, @PP_USER
																				
					
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PM_TRANSFER_PIEL_A_FOLIO_SCRAP // ' + @VP_ERROR_TRANS
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

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
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
