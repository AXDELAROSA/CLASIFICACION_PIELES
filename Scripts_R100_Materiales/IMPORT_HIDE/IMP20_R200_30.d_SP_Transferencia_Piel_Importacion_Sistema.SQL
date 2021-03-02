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

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA]
GO

/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA]	0,0, '02/24/2021' , 'DX9 CAPRI' , 'BLACK' , 'F5531TC' , '15' , 'K-10761 P-3484' , '107611' , 43 , 32.80 , 1409.10 , 'RU-021921' , '210224043653T1000002' , 
'35.60/32.40/28.10/31.20/32.70/34.90/29.80/42.10/27.40/34.70/39.30/32.00/27.30/33.70/29.00/31.40/31.80/35.50/34.00/29.90/29.10/39.90/36.30/31.40/26.90/41.20/32.10/31.50/32.90/31.70/32.30/37.00/34.00/29.90/30.70/28.50/27.20/31.90/36.10/30.30/31.60/34.30/39.50' , 
'franciscoe' 
*/

CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR_X_SISTEMA]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_F_TICKET							VARCHAR(10),
	@PP_D_COLOR								VARCHAR(50),
	@PP_COLOR								VARCHAR(50),
	@PP_PEARL_COLOR							VARCHAR(50),
	@PP_CLIENTE								VARCHAR(50),
	@PP_CRUST_LOT							VARCHAR(50),
	@PP_LOTE								VARCHAR(50),
	@PP_TOTAL_PIEL_LOTE						INT,
	@PP_TOTAL_AVG_AREA						DECIMAL(13,2),
	@PP_TOTAL_SQF_LOTE						DECIMAL(13,2),
	@PP_PACKING_NO							VARCHAR(50),
	-- ===========================
	@PP_FILE_NO								NVARCHAR(50),
	@PP_SQF_ARRAY							NVARCHAR(MAX),
	-- ===========================
	@PP_USER								VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_LOCACION_DESTINO VARCHAR(255) = 'MIT'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
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

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- /////////SE OBTIENE DE LOS ARRAY DE SQF INGRESADOS///////////////////////////////////////////////////////////	
				DECLARE @TBL_PIEL_A_IMPORTAR TABLE (
						K_PIEL_A_IMPORTAR INT IDENTITY(1,1),
						SQF			DECIMAL(13,2)
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_SQF	 INT = 0
				DECLARE @VP_SQF_VALOR		VARCHAR(20) = ''
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_SQF_ARRAY	= @PP_SQF_ARRAY		+ '/'			
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_SQF_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_SQF		=	patindex('%/%' , @PP_SQF_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_SQF_VALOR	= LEFT(@PP_SQF_ARRAY, @VP_POSICION_SQF - 1)						
						
						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_PIEL_A_IMPORTAR VALUES	( @VP_SQF_VALOR )

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_SQF_ARRAY	= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION_SQF, '')
					END
				
				-- ////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION//////////////////////////			
				DECLARE @VP_N_PIEL INT = 0
				SELECT @VP_N_PIEL = COUNT(K_PIEL_A_IMPORTAR) FROM @TBL_PIEL_A_IMPORTAR
								
				IF @VP_N_PIEL IS NULL OR @VP_N_PIEL = 0
					RAISERROR ('NO hay pieles para importar', 16, 1 ) --MENSAJE - Severity -State.
				
				-- /////////SE INGRESA LOS DATOS DE LA IMPORTACION EN HIDESHDR_SQL///////////////////////////////////////////////////////////	
				DECLARE @VP_FECHA	INT = [dbo].[CONVERT_DATE_TO_INT](GETDATE(),'yyyyMMdd')	--FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
				DECLARE @VP_HORA	INT =  FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				DECLARE @VP_F_TICKET_INT INT = [dbo].[CONVERT_DATE_TO_INT](@PP_F_TICKET,'yyyyMMdd')

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

				-- ////////////////////SE RECORREN LAS PIELES DEL TICKET PARA AGREGARLAS A LAS TABLAS//////////////////////////	
				DECLARE @VP_SQF DECIMAL(13,2) = 0

				DECLARE CU_TICKET_A_IMPORTAR CURSOR 
				FOR SELECT SQF
					FROM @TBL_PIEL_A_IMPORTAR
					ORDER BY K_PIEL_A_IMPORTAR ASC
				
				OPEN CU_TICKET_A_IMPORTAR
				FETCH NEXT FROM CU_TICKET_A_IMPORTAR INTO @VP_SQF
				
				WHILE @@FETCH_STATUS = 0
					BEGIN	
						-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
						DECLARE @VP_NUMERO_PIEL VARCHAR(5) = ''
						EXECUTE [dbo].[PG_RN_CONSECUTIVO_PIEL_X_LOTE_A_IMPORTAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_LOTE,
																					@OU_RESULTADO_VALIDACION = @VP_NUMERO_PIEL		OUTPUT

						IF @VP_NUMERO_PIEL = ''
							RAISERROR ('NO fue posible obtener el consecutivo de piel para el lote', 16, 1 ) --MENSAJE - Severity -State.

						-- /////////SE INGRESAN LAS PIELES IMPORTADAS EN HIDESLIN_SQL///////////////////////////////////////////////////////////	
						INSERT INTO HIDESLIN_SQL (
												FILENO, HIDE, SQF, PRINTED
												) 
										VALUES (
												@PP_FILE_NO, @VP_NUMERO_PIEL, @VP_SQF, 0
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

						FETCH NEXT FROM CU_TICKET_A_IMPORTAR INTO @VP_SQF							
					END

				CLOSE CU_TICKET_A_IMPORTAR
				DEALLOCATE CU_TICKET_A_IMPORTAR
			
				--/////////////SE TRANSFIEREN LOS PIES CUADRADOS A LA LOCACION Y LOTE DESTINO///////////////////////////////////////////////////////	
				DECLARE @VP_TRANSACCION_DOC	VARCHAR(10) = ''

				SELECT	TOP 1
						@VP_TRANSACCION_DOC  = RIGHT('00000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(NEXT_DOC_NO))), 8)
				-- =====================
				FROM	IMCTLFIL_SQL

				-- ///////////////////////////////////////////
				EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	1 
				-- ///////////////////////////////////////////
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
														@PP_USER, 'importación de pieles por sistema', 0, @VP_INDICE,
														'R', 'M', @PP_TOTAL_SQF_LOTE

				-- ///////////////SE INGRESA EL REGISTRO EN DEL LOTE EN IncInsp_sql /////////////////////////////////////////////////////	
				DECLARE @VP_MUESTRA INT = 3
				DECLARE @VP_N_LOTE_INSPECCION INT = 0

				SELECT	@VP_N_LOTE_INSPECCION = COUNT(ID)
				FROM	IncInsp_sql 
				WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
				AND		PACKING_NO = @PP_PACKING_NO 
				 
				IF ( @VP_N_LOTE_INSPECCION IS NULL OR  @VP_N_LOTE_INSPECCION = 0 )
					BEGIN
						IF @PP_TOTAL_PIEL_LOTE > 5
							SET @VP_MUESTRA = 5

						INSERT INTO IncInsp_sql (	[Date], Lot, [Description], Lot_size, Sample_size, [Status], Accepted, PACKING_NO ) 
										VALUES (	@VP_FECHA, CONCAT('         ', @VP_LOTE_TBL), @PP_PEARL_COLOR, @PP_TOTAL_PIEL_LOTE, @VP_MUESTRA, '-', '-', @PP_PACKING_NO)

						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible agregar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   
					END
				ELSE
					BEGIN
						DECLARE @VP_N_LOTE_INSPECCION_PENDIENTE INT = 0
						SELECT	@VP_N_LOTE_INSPECCION_PENDIENTE = COUNT(ID)
						FROM	IncInsp_sql 
						WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
						AND		PACKING_NO = @PP_PACKING_NO
						AND STATUS <> 'C'

						IF ( @VP_N_LOTE_INSPECCION_PENDIENTE IS NULL OR  @VP_N_LOTE_INSPECCION_PENDIENTE = 0 )
							BEGIN							

								IF @PP_TOTAL_PIEL_LOTE > 5
									SET @VP_MUESTRA = 5

								INSERT INTO IncInsp_sql (	[Date], Lot, [Description], Lot_size, Sample_size, [Status], Accepted, PACKING_NO ) 
												VALUES (	@VP_FECHA, CONCAT('         ', @VP_LOTE_TBL), @PP_PEARL_COLOR, @PP_TOTAL_PIEL_LOTE, @VP_MUESTRA, '-', '-', @PP_PACKING_NO)
								
								IF @@ROWCOUNT = 0
									RAISERROR ('NO fue posible agregar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   
							END
						ELSE
							BEGIN
								DECLARE @VP_ID INT = 0
								DECLARE @VP_TOTAL_LOT_QTY INT = 0
								DECLARE @VP_LOT_QTY INT = 0

								SELECT	@VP_ID = ID,
										@VP_LOT_QTY = Lot_size
								FROM	IncInsp_sql 
								WHERE	LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
								AND		PACKING_NO = @PP_PACKING_NO -- PENDIENTE AGREGAR CAMPO
								AND STATUS <> 'C'

								SET @VP_TOTAL_LOT_QTY = @VP_LOT_QTY + @PP_TOTAL_PIEL_LOTE

								IF @VP_TOTAL_LOT_QTY > 5
									SET @VP_MUESTRA = 5

								UPDATE IncInsp_sql
									SET Lot_size	= @VP_TOTAL_LOT_QTY,
										Sample_size	= @VP_MUESTRA
								WHERE ID = @VP_ID

								IF @@ROWCOUNT = 0
									RAISERROR ('NO fue posible actualizar el lote en [IncInsp_sql].', 16, 1 ) --MENSAJE - Severity -State.   

							END
					END
				
				--///////SE ENVIA CORREO A CALIDAD PARA QUE REALIZE LA INSPECCION////////////////////////////////////////////
				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx' --;monicag@pearlleather.com.mx'
				DECLARE @VP_SUBJECT		VARCHAR(255) = 'Entrada a inventario MIT en espera de inspección...'
				DECLARE @VP_BODY		NVARCHAR(MAX)  = ''

				--SELECT  @VP_RECIPIENTS	=	@VP_RECIPIENTS + ';' + CORREO_USUARIO_PEARL
				--				FROM	BD_GENERAL.dbo.USUARIO_PEARL AS USERS
				--				INNER	JOIN	BD_GENERAL.dbo.GRUPO_APROBADOR GP_APROB ON GP_APROB.K_USUARIO=USERS.K_USUARIO_PEARL
				--				WHERE   GP_APROB.S_GRUPO_APROBADOR = 'RECIBI_BPO'
				--				AND		GP_APROB.K_TIPO_GRUPO_APROBADOR = 7900
				--				AND		K_ESTATUS_GRUPO_APROBADOR = 1

				--SET @VP_RECIPIENTS = SUBSTRING(@VP_RECIPIENTS,2,LEN(@VP_RECIPIENTS))

				SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="7">Entrada a inventario MIT en espera de inspección...</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>File No</th><th>Color</th><th>Lote</th><th>Total Piel</th><th>Total SQF</th><th>Packing No.</th><th>Usuario</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
									  N'<td>'+ @PP_FILE_NO +'</td><td>'+ @PP_PEARL_COLOR +'</td><td>'+ @PP_LOTE +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_PIEL_LOTE) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_SQF_LOTE) +'</td><td>'+ @PP_PACKING_NO +'</td><td>'+  @PP_USER +'</td>' + 
									  N'</tr>' + 
									N'</tbody>' + 
								N'</table>' ;
				SET ROWCOUNT 0
					 				
				EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

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
