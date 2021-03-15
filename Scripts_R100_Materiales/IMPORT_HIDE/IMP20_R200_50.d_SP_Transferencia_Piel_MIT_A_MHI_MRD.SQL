-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	26/FEB/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_MIT_A_MHI_O_MRD]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_MIT_A_MHI_O_MRD]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_MIT_A_MHI_O_MRD]	0, 144, '210226074936T1000002' , 'MHI' , 'franciscoe' 
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_MIT_A_MHI_O_MRD]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50),
	@PP_LOCACION_DESTINO					VARCHAR(5),
	-- ===========================
	@PP_USER								VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''
	DECLARE @VP_LOCACION_ORIGEN	VARCHAR(5) = 'MIT'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	EXECUTE [dbo].[PG_RN_VALIDA_LOCACION_TICKET_IMPORTADO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_FILE_NO,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- ////////SE OBTIENE EL COLOR DONDE DEL TICKET IMPORTADO///////////////////////////////////
	DECLARE @VP_COLOR VARCHAR(20) = '', @VP_LOTE VARCHAR(20) = '', @VP_TOTAL_SQF DECIMAL(13,2) = 0;
	
	SELECT	@VP_COLOR = LTRIM(RTRIM(PCOLOR)),
			@VP_LOTE = LTRIM(RTRIM(PLOT)),
			@VP_TOTAL_SQF = TAREA
	FROM HIDESHDR_SQL 
	WHERE FILENO = @PP_FILE_NO

	IF @VP_MENSAJE = ''
		BEGIN
			DECLARE @VP_N_PIEL_EXISTE INT = 0
			SELECT @VP_N_PIEL_EXISTE = COUNT(ID) 
			FROM RP_SC 
			WHERE LOT = @VP_LOTE
			AND HIDE IN (	SELECT HIDE 
							FROM  HIDESLIN_SQL 
							WHERE FILENO = @PP_FILE_NO )

			IF @VP_N_PIEL_EXISTE > 0
				SET @VP_MENSAJE = 'La piel ya existe en [RP_SC].'
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
					-- ////////SE ACTUALIZA LA LOCACION DEL TICKET///////////////////////////////////
				UPDATE	HIDESHDR_SQL 
					SET [STATUS] = @PP_LOCACION_DESTINO
				WHERE FILENO = @PP_FILE_NO
				
				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible actualizar la locación en [HIDESHDR_SQL].', 16, 1 ) --MENSAJE - Severity -State.		
					
				-- /////////SE OBTIENE EL FOLIO BASE DEL COLOR///////////////////////////////////////////////////////////	
				DECLARE @VP_FOLIO	INT = 0

				SELECT	TOP 1 @VP_FOLIO = TAG
				FROM	RP_Folios  
				INNER JOIN RP_SC ON TAG = TAGNO
				AND RTRIM(LTRIM(STATUS)) = 'B' 
				AND COLOUR = @VP_COLOR
				GROUP BY TAG, COLOUR
				
				-- /////////SI NO EXISTE UN FOLIO BASE PARA EL COLOR NUEVO SE CREA///////////////////////////////////////////////////////////	
				IF @VP_FOLIO IS NULL OR @VP_FOLIO = 0
					BEGIN
						DECLARE @VP_TIPO_FOLIO VARCHAR(5) = 'B'

						IF @PP_LOCACION_DESTINO = 'MRD'
							SET @VP_TIPO_FOLIO = 'A'
												
						EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																			'DATA_02', 
																			--'DATA_02PRUEBAS', 
																			'RP_FOLIOS', 'TAG',
																			@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT

						EXECUTE [dbo].[PG_IN_RP_FOLIOS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_FOLIO, @VP_TIPO_FOLIO, '', '', ''
					END

				-- /////////SE INGRESA LA PIEL AL FOLIO BASE DEL COLOR NUEVO///////////////////////////////////////////////////////////	
				INSERT INTO RP_SC( 
									[CDATE], [COLOUR], [LOT], [HIDE], [SQF], [TAGNO], [YARDAS], [YLB], [PESO], [TYPE], [MOVEMENT], [K_CLASIFICACION]
								)
							SELECT	GETDATE(), @VP_COLOR, @VP_LOTE, HIDE, [SQF],  @VP_FOLIO, NULL, NULL, NULL, 'C', @PP_LOCACION_DESTINO, 0 
							FROM	HIDESLIN_SQL 							
							WHERE FILENO = @PP_FILE_NO

				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible agregar las pieles del ticket en [RP_SC]', 16, 1 ) --MENSAJE - Severity -State.		
                                                         
				-- /////////SE INGRESA EL LOG DE LA TRANSFERENCIA DE LAS PIELES DE MIT A MHI O MRD///////////////////////////////////////////////////////////							
				INSERT INTO PIEL_LOG	
								(	
									[K_TIPO_PIEL_LOG], [FOLIO_ORIGEN], [COLOR],	[LOTE], [PIEL], [LOCACION_ORIGEN], [ORDEN_ORIGEN],
									[FOLIO_DESTINO], [LOCACION_DESTINO], [ORDEN_DESTIDO], [SQF], [F_LOG],	
									-- ===========================
									[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
									[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									-- ===========================
							SELECT	2, 0, @VP_COLOR, @VP_LOTE, HIDE, @VP_LOCACION_ORIGEN, 0, 
									@VP_FOLIO, @PP_LOCACION_DESTINO, 0, [SQF], GETDATE(),
									-- ===========================
									@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
									0, NULL, NULL
							FROM	HIDESLIN_SQL
							WHERE FILENO = @PP_FILE_NO 
				
				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible agregar las pieles del ticket en [PIEL_LOG]', 16, 1 ) --MENSAJE - Severity -State.		
                      
				-- /////////////SE TRANSFIEREN LOS PIES CUADRADOS A LA LOCACION DESTINO///////////////////////////////////////////////////////	
				DECLARE @VP_TRANSACCION_DOC	INT = 0

				SELECT	TOP 1
						@VP_TRANSACCION_DOC  = RIGHT('00000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(NEXT_DOC_NO))), 8)
				-- =====================
				FROM	IMCTLFIL_SQL

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	1 
				-- ///////////////////////////////////////////
				DECLARE @VP_LOTE_TBL	VARCHAR(10)	= ''
				DECLARE @VP_COMENTARIO VARCHAR(255) = 'MIT to ' + @PP_LOCACION_DESTINO
				DECLARE @VP_INDICE	VARCHAR(10) = '0'
				SET @VP_LOTE_TBL	= RIGHT( '000000' + @VP_LOTE, 6)					
				DECLARE @VP_ORDERNO VARCHAR (50) =  '00000'

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@VP_LOCACION_ORIGEN, @VP_COLOR,
																					@VP_LOTE_TBL, @VP_TOTAL_SQF
				
				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@VP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO, @VP_COLOR,
																					@VP_LOTE_TBL, @VP_TOTAL_SQF, @VP_TRANSACCION_DOC

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_COLOR, @VP_LOTE_TBL, @VP_TOTAL_SQF, 
														@VP_TRANSACCION_DOC, @VP_INDICE, 0

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_COLOR, @VP_LOTE_TBL, @VP_TOTAL_SQF, 
														@VP_TRANSACCION_DOC, @VP_INDICE, 1
				
				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@VP_LOCACION_ORIGEN, @VP_COLOR, @VP_TOTAL_SQF

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_LOCACION_DESTINO, @VP_COLOR, @VP_TOTAL_SQF
																								
				-- ////////////////////////////////////////////////////////////////////
				DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
				
				EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR, 
														@VP_LOCACION_ORIGEN, @VP_TOTAL_SQF, @VP_ORDERNO, 
														@PP_USER, @VP_COMENTARIO, 0, @VP_INDICE,
														'T', 'M', @VP_TOTAL_SQF

				-- ////////////////////////////////////////////////////////////////////
				SET @VP_TRXIDNO = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000010000'

				EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR, 
														@PP_LOCACION_DESTINO, @VP_TOTAL_SQF, @VP_ORDERNO, 
														@PP_USER, @VP_COMENTARIO, 1, @VP_INDICE,
														'T', 'M', @VP_TOTAL_SQF

				-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_MIT_A_MHI_O_MRD] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Importar las pieles del [Ticket]: ' + '[' + @PP_FILE_NO +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FILE_NO AS CLAVE
	
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
													0, 0, @PP_FILE_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
