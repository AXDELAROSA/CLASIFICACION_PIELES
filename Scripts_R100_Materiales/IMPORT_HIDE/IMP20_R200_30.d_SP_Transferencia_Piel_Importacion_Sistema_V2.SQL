-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	25/FEB/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA_V2]
GO

/*
	EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA_V2]	0,144,  '210402200432T1000001' ,  'C-(15)-040221', 'FCNPDX9', 'franciscoe'
*/

CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA_V2]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50),
	@PP_PACKING_NO							VARCHAR(50),
	@PP_PEARL_COLOR							VARCHAR(50),
	-- ===========================
	@PP_USER								VARCHAR(25)
AS

	-- /////////VARIABLES//////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_LOCACION_DESTINO VARCHAR(255) = 'MIT', @VP_N_TICKET_A_IMPORTAR INT = 0
	
	DECLARE @PP_F_TICKET VARCHAR(10), @PP_D_COLOR VARCHAR(50), @PP_COLOR VARCHAR(50)
	DECLARE @PP_CLIENTE VARCHAR(50), @PP_CRUST_LOT VARCHAR(50), @PP_LOTE VARCHAR(50)
	DECLARE @PP_TOTAL_PIEL_LOTE INT, @PP_TOTAL_AVG_AREA DECIMAL(13,2), @PP_TOTAL_SQF_LOTE DECIMAL(13,2)
	
	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO
	-- /////////SE OBTIENE EL LOTE DEL TICKET//////////////////////////////////
	SELECT	TOP 1	
			@PP_LOTE = LOTE
	FROM	TICKET_A_IMPORTAR 
	WHERE	FILE_NO = @PP_FILE_NO
	AND L_BORRADO = 0 --#0 NO IMPORTADO #1 IMPORTADO

	IF ( @PP_LOTE IS NULL OR @PP_LOTE = '' )
		SET @VP_MENSAJE = 'No fue posible obtener el Lote del Ticket.'

	-- /////////SE OBTIENE EL TOTAL DE PIEL Y SQF DEL TICKET//////////////////////////////////
	SELECT  @PP_TOTAL_PIEL_LOTE = COUNT(K_TICKET_A_IMPORTAR),
			@PP_TOTAL_SQF_LOTE = SUM(SQF)
	FROM	TICKET_A_IMPORTAR
	WHERE	FILE_NO = @PP_FILE_NO
	AND L_BORRADO = 0 --#0 NO IMPORTADO #1 IMPORTADO

	IF ( @PP_TOTAL_SQF_LOTE IS NULL OR @PP_TOTAL_SQF_LOTE = 0 )
		SET @VP_MENSAJE = 'Tikect No cuenta con SQF.'	
			 	
	IF ( @PP_TOTAL_PIEL_LOTE IS NULL OR @PP_TOTAL_PIEL_LOTE = 0 )
		SET @VP_MENSAJE = 'Tikect No encontrado.'	

	IF @VP_MENSAJE = ''
		BEGIN
			-- /////////SE VALIDA QUE EL TICKET NO ALLA SIDO IMPORTADO ANTERIORMENTE//////////////////////////////////
			DECLARE @VP_N_CABALLO_IMPORTADO INT = 0
			SELECT	@VP_N_CABALLO_IMPORTADO = COUNT(ID) 
			FROM	HIDESHDR_SQL 
			WHERE	PLOT = @PP_LOTE
			AND		THIDES = @PP_TOTAL_PIEL_LOTE
			AND		TAREA = @PP_TOTAL_SQF_LOTE
			
			IF @VP_N_CABALLO_IMPORTADO IS NULL
				SET @VP_N_CABALLO_IMPORTADO = 0

			IF @VP_N_CABALLO_IMPORTADO > 0
				SET @VP_MENSAJE = 'El caballo ya fue importado anteriormente...'
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- /////////ASIGNACION DE VALOR A LAS VARIABLES//////////////////////////////////
				SELECT TOP 1
						@PP_F_TICKET	= [FECHA_TICKET],	
						@PP_CLIENTE		= [CLIENTE],
						@PP_COLOR		= [COLOR],
						@PP_D_COLOR		= [D_COLOR],		
						@PP_CRUST_LOT	= [CRUST_LOT]
						-- ===========================
				FROM	TICKET_A_IMPORTAR
				WHERE	FILE_NO = @PP_FILE_NO
				AND L_BORRADO = 0											
					
				-- /////////SE INGRESA LOS DATOS DE LA IMPORTACION EN HIDESHDR_SQL///////////////////////////////////////////////////////////	
				DECLARE @VP_FECHA	INT = [dbo].[CONVERT_DATE_TO_INT](GETDATE(),'yyyyMMdd')	
				DECLARE @VP_HORA	INT =  FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				DECLARE @VP_F_TICKET_INT INT = [dbo].[CONVERT_DATE_TO_INT](@PP_F_TICKET,'yyyyMMdd')
				SET @PP_TOTAL_AVG_AREA = @PP_TOTAL_SQF_LOTE / @PP_TOTAL_PIEL_LOTE

				INSERT INTO HIDESHDR_SQL (
											FILENO, LDATE, TDATE, CUSTOMER, TYPE, 
											COLOR, CLOT, PLOT, THIDES, AVGAREA, 
											TAREA, STATUS, PCOLOR, INVOICE
										) 
								VALUES (    
											@PP_FILE_NO, @VP_FECHA, @VP_F_TICKET_INT, @PP_CLIENTE, @PP_D_COLOR,
											@PP_COLOR, @PP_CRUST_LOT, @PP_LOTE, @PP_TOTAL_PIEL_LOTE, @PP_TOTAL_AVG_AREA, 
											@PP_TOTAL_SQF_LOTE, @VP_LOCACION_DESTINO, @PP_PEARL_COLOR, @PP_PACKING_NO
										)	
				
				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible agregar el emcabezado del Ticket en [HIDESHDR_SQL].', 16, 1 ) --MENSAJE - Severity -State.		
								
				-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
				DECLARE @VP_NUMERO_PIEL VARCHAR(5) = ''
				EXECUTE [dbo].[PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOTE,
																			@OU_RESULTADO_VALIDACION = @VP_NUMERO_PIEL		OUTPUT

				IF @VP_NUMERO_PIEL = ''
					RAISERROR ('NO fue posible obtener el consecutivo de piel para el lote', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////////////////SE RECORREN LAS PIELES DEL TICKET PARA AGREGARLAS A LAS TABLAS//////////////////////////	
				DECLARE @VP_SQF DECIMAL(13,2) = 0

				DECLARE CU_TICKET_A_IMPORTAR CURSOR 
				FOR SELECT	SQF
					FROM	TICKET_A_IMPORTAR
					WHERE	FILE_NO = @PP_FILE_NO
					AND		L_BORRADO = 0
					ORDER BY CONSECUTIVO ASC
				
				OPEN CU_TICKET_A_IMPORTAR
				FETCH NEXT FROM CU_TICKET_A_IMPORTAR INTO @VP_SQF
				
				WHILE @@FETCH_STATUS = 0
					BEGIN	
						-- /////////SE INGRESAN LAS PIELES IMPORTADAS EN HIDESLIN_SQL///////////////////////////////////////////////////////////	
						INSERT INTO HIDESLIN_SQL (
												FILENO, HIDE, SQF, PRINTED
												) 
										VALUES (
												@PP_FILE_NO, @VP_NUMERO_PIEL, CONVERT(VARCHAR(10),@VP_SQF), 0
												)
						                             
						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible agregar la piel en [HIDESLIN_SQL].', 16, 1 ) --MENSAJE - Severity -State.   
							         
						--/////////SE INGRESA EL LOG DEL INGRESO MANUAL DE LA PIEL///////////////////////////////////////////////////////////	
						INSERT INTO PIEL_LOG (	[K_TIPO_PIEL_LOG], [FOLIO_ORIGEN], [COLOR], [LOTE],	[PIEL],
													[LOCACION_ORIGEN], [FOLIO_DESTINO], [LOCACION_DESTINO],[SQF], [F_LOG],
													-- ===========================
													[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO], 
													[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]    
												) 
                                         VALUES (	1, 0, @PP_PEARL_COLOR, @PP_LOTE, @VP_NUMERO_PIEL, 
													'', 0, @VP_LOCACION_DESTINO, @VP_SQF, GETDATE(),
													-- ===========================
                           							@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
													0, NULL, NULL
												)
						
						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible agregar el log de la piel en [PIEL_LOG].', 16, 1 ) --MENSAJE - Severity -State.   

						DECLARE @VP_CONSECUTIVO INT = CONVERT(INT, @VP_NUMERO_PIEL)
						SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1

						SET @VP_NUMERO_PIEL = RIGHT('0000' + CONVERT(VARCHAR(4), @VP_CONSECUTIVO), 4) 
						FETCH NEXT FROM CU_TICKET_A_IMPORTAR INTO @VP_SQF							
					END

				CLOSE CU_TICKET_A_IMPORTAR
				DEALLOCATE CU_TICKET_A_IMPORTAR
				
				-- /////////SE ACTUALIZA EL EL TICKET EN TICKET_A_IMPORTAR//////////////////////////////////
				UPDATE	TICKET_A_IMPORTAR
					SET L_BORRADO = 1,
						[K_USUARIO_CAMBIO] = @PP_K_USUARIO_ACCION, 
						[F_CAMBIO] = GETDATE()
				WHERE	FILE_NO = @PP_FILE_NO

				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible actualizar el Ticket en [TICKET_A_IMPORTAR].', 16, 1 ) --MENSAJE - Severity -State.	

				--/////////////SE TRANSFIEREN LOS PIES CUADRADOS A LA LOCACION Y LOTE DESTINO///////////////////////////////////////////////////////	
				DECLARE @VP_TRANSACCION_DOC	INT = 0

				SELECT	TOP 1
						@VP_TRANSACCION_DOC  = RIGHT('00000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(NEXT_DOC_NO))), 8)
				-- =====================
				FROM	IMCTLFIL_SQL

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	1 
				-- ///////////////////////////////////////////
				DECLARE @VP_COMENTARIO VARCHAR(255) = 'importación de: '+ CONVERT(VARCHAR(25), @PP_TOTAL_PIEL_LOTE) +' pieles por sistema'
				DECLARE @VP_INDICE	VARCHAR(10) = '0'
				DECLARE @VP_LOTE_TBL VARCHAR(10) = RIGHT( '000000' + @PP_LOTE, 6)					
				
				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@VP_LOCACION_DESTINO, @VP_LOCACION_DESTINO, @PP_PEARL_COLOR,
																					@VP_LOTE_TBL, @PP_TOTAL_SQF_LOTE, @VP_TRANSACCION_DOC

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_PEARL_COLOR, @VP_LOTE_TBL, @PP_TOTAL_SQF_LOTE, 
														@VP_TRANSACCION_DOC, @VP_INDICE, 0

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@VP_LOCACION_DESTINO, @PP_PEARL_COLOR, @PP_TOTAL_SQF_LOTE

				-- ////////////////////////////////////////////////////////////////////
				DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
				DECLARE @VP_ORDERNO VARCHAR (50) =  '00000'
				
				EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_TRXIDNO, @VP_TRANSACCION_DOC, @PP_PEARL_COLOR, 
														@VP_LOCACION_DESTINO, @PP_TOTAL_SQF_LOTE, @VP_ORDERNO, 
														@PP_USER, @VP_COMENTARIO, 0, @VP_INDICE,
														'R', 'M', @PP_TOTAL_SQF_LOTE

				-- ///////////////SE INGRESA EL REGISTRO EN DEL LOTE EN IncInsp_sql /////////////////////////////////////////////////////	
				EXECUTE [dbo].[PG_IN_UP_INCINSP_SQL_CORREO_CALIDAD]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_FILE_NO, @VP_FECHA, @PP_PEARL_COLOR, @PP_LOTE,
																		@PP_TOTAL_PIEL_LOTE, @PP_TOTAL_SQF_LOTE, 
																		@PP_PACKING_NO, 0, @PP_USER				

			-- ////////////////////////////////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Importar las pieles del [Lote]: ' + '[#Lot.' + @PP_LOTE +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOTE AS CLAVE
	
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
													0, 0, @PP_LOTE, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
