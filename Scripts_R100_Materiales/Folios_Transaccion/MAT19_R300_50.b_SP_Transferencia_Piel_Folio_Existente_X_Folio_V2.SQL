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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE_V2]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE_V2] 0,0, 46 , 'DEVOLUCION' , 'B' , 'FMCKTX7' , 3788360 , 
					2137674 , 'T17' , 'MHI' , '11611' , '-' , 0 , 0 , 0 , 0 , 0 , '' , 'franciscoe' , 'IT-010' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE_V2]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_K_PIEL_A_TRANSFERIR_TRANSACCION		INT,
	@PP_TIPO_TRANSFERENCIA					VARCHAR(50),
	@PP_ESTATUS								VARCHAR(5),
	@PP_CB_COLOR							VARCHAR(20),
	-- ===========================
	@PP_TAGNO_ORIGEN						INT,
	@PP_TAGNO_DESTINO						INT,
	-- ===========================
	@PP_LOCACION_ORIGEN						VARCHAR(10),
	@PP_LOCACION_DESTINO					VARCHAR(10),
	-- ===========================
	@PP_ORDEN_ORIGEN						VARCHAR(10),
	@PP_ORDEN_DESTINO						VARCHAR(10),
	-- ===========================
	@PP_PRT_FORM_DEV_EXT					INT, -- INPRIMIR FORMA #0 N0, #1 SI
	@PP_SELECT_TODOS						INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_TB_SQF								DECIMAL(13,2),
	-- ===========================
	@PP_LOTE_PIEL_EXISTE					INT, -- SI EXISTE #
	@PP_LOTE_PIEL_EXISTE_ADD				INT, -- SI EXISTE Y DESEA ACTUALIZAR #1
	-- ===========================
	@PP_COMENTARIO							VARCHAR(255),
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	DECLARE @VP_TIPO_PIEL_LOG INT = 5

	IF @PP_TIPO_TRANSFERENCIA = 'DEVOLUCION'
		SET @VP_TIPO_PIEL_LOG = 6

	-- ///////////SE VALIDA SI ES UN FOLIO DE MESA/GERBER TENGA UNA ORDEN ASIGNADA////////////////////////////////
	IF @VP_MENSAJE = ''
		IF ( SUBSTRING( @PP_LOCACION_ORIGEN, 1, 1 ) IN ('T', 'G') AND LEN( @PP_ORDEN_ORIGEN ) < 5 )
			SET @VP_MENSAJE = 'El folio Origen: ' + CONVERT(VARCHAR(30), @PP_TAGNO_ORIGEN) + ' de la Locacion: ' + @PP_LOCACION_ORIGEN + ' no tiene una orden asignada!'
	
	IF @VP_MENSAJE = ''
		IF ( SUBSTRING( @PP_LOCACION_DESTINO, 1, 1) IN ('T', 'G') AND LEN( @PP_ORDEN_DESTINO ) < 5 )
			SET @VP_MENSAJE = 'El folio Destino: ' + CONVERT(VARCHAR(30), @PP_TAGNO_DESTINO) + ' de la Locacion: ' + @PP_LOCACION_DESTINO + ' no tiene una orden asignada!'

	-- ///////////////////////////////////////////		
	DECLARE @VP_COLOR_ORIGEN VARCHAR(20) = '', @VP_COLOR_DESTINO VARCHAR(20) = @PP_CB_COLOR;
	DECLARE @VP_K_CLASIFICACION	INT = 0,  @VP_F_ACTUAL DATE = GETDATE();

	IF @VP_MENSAJE = ''
		BEGIN
			IF @PP_TIPO_TRANSFERENCIA <> 'DEVOLUCION'
				BEGIN
					SELECT	TOP 1 @VP_COLOR_DESTINO		= LTRIM(RTRIM(COLOUR))
												FROM	RP_SC (NOLOCK)
												WHERE	TAGNO = @PP_TAGNO_DESTINO
				
					IF ( @VP_COLOR_DESTINO IS NULL OR @VP_COLOR_DESTINO = '' )
						SET @VP_MENSAJE = 'No fue posible obtener el color del Folio Destino.' 
				END
		END
	-- ///////////////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN			
			SELECT	TOP 1 @VP_COLOR_ORIGEN	=	LTRIM(RTRIM(COLOUR))
											FROM	RP_SC (NOLOCK)
											WHERE	TAGNO = @PP_TAGNO_ORIGEN

			IF ( @VP_COLOR_ORIGEN IS NULL OR @VP_COLOR_ORIGEN = '' )
				SET @VP_MENSAJE = 'No fue posible obtener el color del Folio Origen.' 
		END

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF @VP_MENSAJE=''
		IF @PP_TIPO_TRANSFERENCIA = 'DEVOLUCION'
			BEGIN
				EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
																@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
			END
		ELSE
			BEGIN
				EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_A_FOLIO_EXISTENTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
																		@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
			END

	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
			BEGIN
				IF @PP_TIPO_TRANSFERENCIA = 'DEVOLUCION'
					BEGIN
						 IF @PP_LOCACION_DESTINO NOT IN( 'MHI', 'MQU', 'MRD', 'MFP', 'MHH', 'MSL') --, 'GT1', 'GT2','GT3' )
							BEGIN
								EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_ORDEN_DESTINO,
																					@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
								IF @VP_MENSAJE=''
									EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_ORDEN_DESTINO,
																						@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
								IF @VP_MENSAJE=''
									EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_ORDEN_DESTINO, @VP_COLOR_ORIGEN,
																						@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
							END
					END
				ELSE
					BEGIN
						IF @PP_LOCACION_DESTINO NOT IN( 'MHI', 'MQU', 'MRD', 'MFP', 'MHH', 'MSL') --, 'GT1', 'GT2','GT3' )
							BEGIN
								EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_ORDEN_DESTINO,
																					@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
								IF @VP_MENSAJE=''
									EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_ORDEN_DESTINO,
																						@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
								IF @VP_MENSAJE=''
									EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_ORDEN_DESTINO, @VP_COLOR_ORIGEN,
																						@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
							END
					END
			END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				IF @PP_TIPO_TRANSFERENCIA = 'DEVOLUCION'
					BEGIN
						-- ////////////////////SE VALIDA QUE EXISTA UN FOLIO BASE PARA EL COLOR, SI NO SE CREA//////////////////////////
						IF NOT EXISTS(	SELECT	TOP 1 TAG	
										FROM RP_Folios  (NOLOCK)
										INNER JOIN RP_SC (NOLOCK) ON TAG=TAGNO 
										WHERE TAGNO = @PP_TAGNO_DESTINO AND STATUS=@PP_ESTATUS AND COLOUR = @PP_CB_COLOR	)
							BEGIN
								-- COMANDO PARA OBTENER LA BASE DE DATOS ACTUAL
								DECLARE @VP_BD_NAME VARCHAR(100) = DB_NAME();

								--IF @VP_BD_NAME <> 'DATA_02PRUEBAS'
								--	RAISERROR ('Base de Datos Incorrecta.', 16, 1 ) --MENSAJE - Severity -State.

								EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																--'DATA_02', 
																--'DATA_02PRUEBAS',
																@VP_BD_NAME,
																'RP_FOLIOS', 'TAG',
																@OU_K_TABLA_DISPONIBLE = @PP_TAGNO_DESTINO	OUTPUT

								EXECUTE [dbo].[PG_IN_RP_FOLIOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_DESTINO, @PP_ESTATUS, NULL, NULL, NULL
							END
					END

				-- ////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION//////////////////////////
				DECLARE @VP_N_PIEL INT = 0
				SELECT	@VP_N_PIEL = COUNT(K_PIEL_A_TRANSFERIR) 
				FROM	[PIEL_A_TRANSFERIR] (NOLOCK)
				WHERE	K_PIEL_A_TRANSFERIR_TRANSACCION = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION

				IF ( @VP_N_PIEL IS NULL OR @VP_N_PIEL = 0 )
					RAISERROR ('NO hay pieles seleccionadas.', 16, 1 ) --MENSAJE - Severity -State.
															
				-- ///////SE DECLARAN VARIABLES A USAR//////////////////////////////////////////////////////////////////////////////
				DECLARE @VP_COLOR_TBL VARCHAR(10) = '', @VP_LOTE_TBL VARCHAR(10) = '', @VP_PIEL_TBL VARCHAR(10) = '', @VP_SQF_TBL VARCHAR(10) = '';
				DECLARE @VP_SQF_DISPONIBLE_TBL	VARCHAR(10) = '', @VP_SQF_CORTADO_TBL VARCHAR(10) = '', @VP_TOTAL_SQF DECIMAL(13,2) = 0;

				-- /////////////////////////SI LAS PIELES A TRANSFERIR SON MAS DE UNA////////////////////////////////////////////
				IF @VP_N_PIEL > 1
					BEGIN
						DECLARE CU_PIEL_SELECCIONADA CURSOR 
						FOR SELECT	COLOR, LOTE, PIEL, SQF_ENVIAR, SQF_CORTADO, SQF_RECIBIR 
							FROM	[PIEL_A_TRANSFERIR]
							WHERE	[K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
						
						OPEN CU_PIEL_SELECCIONADA
						FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_DISPONIBLE_TBL, @VP_SQF_CORTADO_TBL, @VP_SQF_TBL						

						WHILE @@FETCH_STATUS = 0
							BEGIN
								-- ///////////////////SE VALIDA QUE EL SQF DE LA PIEL EN EL FOLIO NO SEA MENOR AL SQF A TRANFERIR//////////////////////////////////////////////////
								IF CONVERT(DECIMAL(13,2),LTRIM(RTRIM(@VP_SQF_DISPONIBLE_TBL))) < CONVERT(DECIMAL(13,2),LTRIM(RTRIM(@VP_SQF_TBL)))
									RAISERROR ('El SQF a transferir es mayor a lo disponible en el folio.', 16, 1 ) --MENSAJE - Severity -State.

								-- ///////////////////SE DECLARAN VARIABLES A USAR EN EL CURSOR//////////////////////////////////////////////////
								DECLARE @VP_LOTE_INT INT			= CAST(LTRIM(RTRIM(@VP_LOTE_TBL)) AS INT)
								DECLARE @VP_PIEL_INT INT			= CAST(LTRIM(RTRIM(@VP_PIEL_TBL)) AS INT)
								DECLARE @VP_SQF_DEC DECIMAL(13,4)	= CAST(LTRIM(RTRIM(@VP_SQF_TBL)) AS DECIMAL(13,2))
								
								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@VP_TIPO_PIEL_LOG, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @VP_SQF_DEC, 
																	@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN, 
																	@PP_TAGNO_DESTINO, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

								-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_F_ACTUAL, @PP_CB_COLOR, @VP_LOTE_TBL, 
																@VP_PIEL_TBL, @VP_SQF_TBL, @PP_TAGNO_DESTINO, 
																NULL, NULL, NULL, 'E', @PP_LOCACION_DESTINO, @VP_K_CLASIFICACION

								-- /////////////////////////ACTUALIZA EL FOLIO ANTERIOR////////////////////////////////////////////
								IF CAST(LTRIM(RTRIM(@VP_SQF_DISPONIBLE_TBL)) AS DECIMAL(13,2)) = CAST(LTRIM(RTRIM(@VP_SQF_TBL)) AS DECIMAL(13,2)) 
									BEGIN
										EXECUTE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_ORIGEN, 'D', @VP_PIEL_TBL, @VP_LOTE_TBL
									END
								ELSE
									BEGIN
										-- ///////SE ACTUALIZA EL SQF DE LA PIEL CON EL SQF DEL CORTE////////////////////////////////////////////
										UPDATE RP_SC
											SET SQF = LTRIM(RTRIM(@VP_SQF_CORTADO_TBL))
										WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR
										AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
										AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
										AND TAGNO = @PP_TAGNO_ORIGEN

										IF @@ROWCOUNT = 0
											RAISERROR ('NO fue posible Actualizar la piel con el SQF cortado en el folio origen.', 16, 1 ) --MENSAJE - Severity -State.

										-- ///INGRESA UNA COPIA DE LA PIEL CORTADA CON EL SQF DEVUELTO PARA QUE SE PUEDA IMPRIMIR EN EL FORMATO DE DEVOLUCION///////////////
										INSERT INTO RP_SC( [CDATE],[COLOUR],[LOT],[HIDE],[SQF],[TAGNO],[YARDAS],[YLB],[PESO],[TYPE],[MOVEMENT],[K_CLASIFICACION] )
													SELECT [CDATE],[COLOUR],[LOT],[HIDE],@VP_SQF_TBL,[TAGNO],[YARDAS],[YLB],[PESO],'D',[MOVEMENT],[K_CLASIFICACION]
													FROM	RP_SC (NOLOCK)
													WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR
													AND LTRIM(RTRIM(LOT)) = @VP_LOTE_TBL
													AND LTRIM(RTRIM(HIDE)) = @VP_PIEL_TBL
													AND TAGNO = @PP_TAGNO_ORIGEN
										
										IF @@ROWCOUNT = 0
											RAISERROR ('NO fue posible insertar la piel cortada como tipo [D] para imprimir como devolución en el folio origen.', 16, 1 ) --MENSAJE - Severity -State. 
									END

								-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
								DECLARE @VP_DETAIL VARCHAR(100) = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO) + ' Lot: ' + RIGHT('000000' + LTRIM(RTRIM(@VP_LOTE_TBL)), 6)
								EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																	@PP_TAGNO_ORIGEN, 'Transfer',
																	@VP_DETAIL, @VP_PIEL_TBL

								FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_DISPONIBLE_TBL, @VP_SQF_CORTADO_TBL, @VP_SQF_TBL		
							END

						CLOSE CU_PIEL_SELECCIONADA
						DEALLOCATE CU_PIEL_SELECCIONADA
					END
				ELSE IF @VP_N_PIEL = 1
					BEGIN
						SELECT	TOP 1
								@VP_COLOR_TBL	= COLOR,
								@VP_LOTE_TBL	= LOTE,
								@VP_PIEL_TBL	= PIEL,
								@VP_SQF_TBL		= SQF_ENVIAR,
								@PP_TB_SQF		= CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF_RECIBIR)))
								-- =======================
						FROM	[PIEL_A_TRANSFERIR] (NOLOCK)
						WHERE	[K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION

						IF CONVERT(DECIMAL(13,2),LTRIM(RTRIM(@VP_SQF_TBL))) < @PP_TB_SQF
							RAISERROR ('El SQF a transferir es mayor a lo disponible en el folio.', 16, 1 ) --MENSAJE - Severity -State.

						-- /////////////////////////////////////////////////////////////////////
						DECLARE @VP_SQF		VARCHAR(10) = ''
						SELECT  @VP_SQF		= SQF 
											FROM RP_SC (NOLOCK)
											WHERE	TAGNO = @PP_TAGNO_DESTINO
											AND		LTRIM(RTRIM(COLOUR))=@PP_CB_COLOR
											AND		LTRIM(RTRIM(HIDE))=@VP_PIEL_TBL
											AND		LTRIM(RTRIM(LOT))=@VP_LOTE_TBL

						-- /////////////////////////////////////////////////////////////////////
						IF (CAST(LTRIM(RTRIM(@VP_SQF_TBL)) AS DECIMAL(13,2)) = @PP_TB_SQF)
							BEGIN
								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								 SET @VP_LOTE_INT 	= CAST(LTRIM(RTRIM(@VP_LOTE_TBL)) AS INT)
								 SET @VP_PIEL_INT 	= CAST(LTRIM(RTRIM(@VP_PIEL_TBL)) AS INT)

								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@VP_TIPO_PIEL_LOG, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @PP_TB_SQF, 
																	@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN, 
																	@PP_TAGNO_DESTINO, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

								-- ///////////////////////////SI LA PIEL EXISTE SE SUMA A LO QUE TIENE, SI NO SOLO SE AGREGA////////////
								IF (@PP_LOTE_PIEL_EXISTE=1)
									BEGIN
										IF  @PP_LOTE_PIEL_EXISTE_ADD = 1
											BEGIN
												SET @VP_TOTAL_SQF = CAST(LTRIM(RTRIM(@VP_SQF)) AS DECIMAL(13,2)) + @PP_TB_SQF
												
												-- /////////////////////////SUMA AL FOLIO DESTINO LOS SQF////////////////////////////////
												EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																										@VP_TOTAL_SQF, @PP_TAGNO_DESTINO, 
																										@VP_LOTE_TBL, @VP_PIEL_TBL
												-- /////////////////////////BORRA EL FOLIO ORIGEN////////////////////////////////////////////
												EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																								@PP_TAGNO_ORIGEN, @VP_LOTE_TBL, @VP_PIEL_TBL 
												
												-- /////////////////////////INGRESA EL LOG////////////////////////////////////////////
												SET @VP_DETAIL = 'Delete hide sqf restantes en 0 Lot: ' + @VP_LOTE_TBL
												EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																					@PP_TAGNO_ORIGEN, 'Delete hide',
																					@VP_DETAIL, @VP_PIEL_TBL
											END
									END
								ELSE
									BEGIN
										-- /////////////////////////REEMPLAZO EL FOLIO ORIGEN POR FOLIO EL DESTINO///////////////
										EXECUTE	[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
																									@VP_PIEL_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
			
										-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO) + ' Lot:' + @VP_LOTE_TBL
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																			@PP_TAGNO_ORIGEN, 'Transfer',
																			@VP_DETAIL, @VP_PIEL_TBL															
									END
								-- /////////////////////////////////////////////////////////////////////
								-- /////////////////////////////////////////////////////////////////////							
							END
						ELSE
							BEGIN
								-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
								 SET @VP_LOTE_INT 	= CAST(LTRIM(RTRIM(@VP_LOTE_TBL)) AS INT)
								 SET @VP_PIEL_INT 	= CAST(LTRIM(RTRIM(@VP_PIEL_TBL)) AS INT)

								EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@VP_TIPO_PIEL_LOG, @PP_TAGNO_ORIGEN, @VP_COLOR_TBL,
																	@VP_LOTE_INT, @VP_PIEL_INT, @PP_TB_SQF, 
																	@PP_LOCACION_ORIGEN, @PP_ORDEN_ORIGEN, 
																	@PP_TAGNO_DESTINO, @PP_LOCACION_DESTINO, @PP_ORDEN_DESTINO

								-- ///////////////RESTA AL FOLIO ORIGEN EL SQF QUE SE AGREGO AL FOLIO DESTINO ///////////////
								SET @VP_TOTAL_SQF =  CAST(LTRIM(RTRIM(@VP_SQF_TBL)) AS DECIMAL(13,2)) - @PP_TB_SQF
								
								EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@VP_TOTAL_SQF, @PP_TAGNO_ORIGEN,
																						@VP_LOTE_TBL, @VP_PIEL_TBL

								IF (@PP_LOTE_PIEL_EXISTE=1)
									BEGIN
										IF  @PP_LOTE_PIEL_EXISTE_ADD = 1
											BEGIN
												SET @VP_TOTAL_SQF = CAST(LTRIM(RTRIM(@VP_SQF)) AS DECIMAL(13,2)) + @PP_TB_SQF

												-- /////////////////////////SUMA AL FOLIO DESTINO LOS SQF////////////////////////////////
												EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																										@VP_TOTAL_SQF, @PP_TAGNO_DESTINO, 
																										@VP_LOTE_TBL, @VP_PIEL_TBL
											END
									END
								ELSE
									BEGIN
										-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
										EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@VP_F_ACTUAL, @VP_COLOR_TBL, @VP_LOTE_TBL, 
																		@VP_PIEL_TBL, @PP_TB_SQF, @PP_TAGNO_DESTINO, 
																		NULL, NULL, NULL, 'C', @PP_LOCACION_DESTINO, @VP_K_CLASIFICACION	
																		
											-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'New part hide: ' + @VP_PIEL_TBL + ' / ' + CONVERT(VARCHAR(20),@PP_TB_SQF) + ' from:' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO)
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																			@PP_TAGNO_ORIGEN, 'Add',
																			@VP_DETAIL, @VP_PIEL_TBL
                    								
									END
							END
					END

					-- ///////////////OBTENEMOS LOS SQF DE LOS DIFERENTES LOTES A TRANSFERIR//////////////////////////////////////////////////////
					IF (	SELECT COUNT(*) FROM sys.table_types
							WHERE name = 'TVPParam' AND schema_id = 1	) = 0
							CREATE TYPE dbo.TVPParam AS TABLE(	COLOR		VARCHAR(20),
																LOTE		VARCHAR(20),
																SQF			VARCHAR(20)	)
				
					DECLARE @TBL_TOTAL_SQF_X_LOTE	TVPParam
					
					INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
					SELECT COLOR, LOTE, SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF_RECIBIR)))) AS SQF 
					FROM	[PIEL_A_TRANSFERIR]
					WHERE	[K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
					GROUP BY COLOR, LOTE					
														
					-- ////////SE TRANSFIEREN LOS PIES CUADRADOS/////////////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_PM_TRANSFER]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_LOCACION_DESTINO, @PP_LOCACION_ORIGEN,
														@PP_ORDEN_DESTINO, @PP_ORDEN_ORIGEN,  @TBL_TOTAL_SQF_X_LOTE,						 	
														@PP_TB_SQF, @PP_COMENTARIO, @PP_USER


					-- ///////////////SE ACTUALIZA LA LOCACION AL FOLIO DESTINO/////////////////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TAGNO_DESTINO, 0, @PP_LOCACION_DESTINO, 0
																							
					-- ///////////////SE BORRA LA TRANSACCION//////////////////////////////////////////////////////
					DELETE	FROM	[PIEL_A_TRANSFERIR]
					WHERE	[K_PIEL_A_TRANSFERIR_TRANSACCION] = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
					
					IF @@ROWCOUNT = 0
					BEGIN
						DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255)= 'No fue posible borrar la transaccion: ' + CONVERT(VARCHAR(10), @PP_K_PIEL_A_TRANSFERIR_TRANSACCION)
						RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
					END

					-- ////SE VERIFICA QUE QUEDEN PIELES EN EL FOLIO ORIGEN DESPUES DEL PROCESO SI NO SE DESCAZA EL FOLIO DE LA ORDEN Y VICEVERSA////////////
					IF SUBSTRING(@PP_LOCACION_ORIGEN,1,1) IN ('T', 'G')
						BEGIN 
							DECLARE @VP_N_PIEL_EN_FOLIO INT = 0
							SELECT	@VP_N_PIEL_EN_FOLIO	=	COUNT(ID)
							FROM	RP_SC (NOLOCK)
							WHERE	TAGNO = @PP_TAGNO_ORIGEN
							AND TYPE = 'C'
							
							IF	( @VP_N_PIEL_EN_FOLIO IS NULL OR @VP_N_PIEL_EN_FOLIO = 0 )
								BEGIN
									-- ///////SE QUITA LA ORDEN DEL FOLIO/////////////////////////////////////////////
									EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
																			@PP_TAGNO_ORIGEN, 'A', NULL, NULL

									-- ///////SE QUITA EL FOLIO DE LA ORDEN///////////////////////////////////////////
									UPDATE ccjobhdr_sql 
									 SET FOLIO = NULL
									WHERE FOLIO = @PP_TAGNO_ORIGEN

									IF @@ROWCOUNT = 0
										RAISERROR ('No fue posible quitar la Orden del Folio Origen.', 16, 1 ) --MENSAJE - Severity -State.
								END
						END

					-- ////////////SE AGREGA EL REGISTRO PARA IMRPIMIR LOS FOLIOS/////////////////////////////////////////////////////////
					IF @VP_N_PIEL > 1
						BEGIN					
							-- //////////////////////////////BORRA EL FOLIO ORIGEN///////////////////////////////////////
							EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TAGNO_ORIGEN, 'D'

							-- ////////////////////////////INGRESA EL LOG/////////////////////////////////////////
							
							SET @VP_DETAIL = 'Delete hides por devolucion (ya se agrego al nuevo folio) Lot:' + @VP_LOTE_TBL
							EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																@PP_TAGNO_ORIGEN, 'Delete hides',
																@VP_DETAIL, @VP_PIEL_TBL

							-- //////////////////////////////ACTUALIZA EL FOLIO DESTINO A TIPO C ///////////////////////////////////////
							EXECUTE	[dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_TAGNO_DESTINO, 'E', 'C'
						END
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE_V2 // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible transferir las pieles del [FOLIO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_DESTINO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	--EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'PROCESO',
	--												'',
	--												-- ===========================================
	--												'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_TAGNO_DESTINO, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
