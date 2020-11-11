-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	14/OCT/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR]	0,0,  'FMCKTX7' , '33232' , 1 , 50.00 , '00005' , '0519' , '50.00' , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_A_IMPORTAR]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_COLOR								VARCHAR(50),
	@PP_LOTE								VARCHAR(50),
	@PP_TOTAL_PIEL_LOTE						INT,
	@PP_TOTAL_SQF_LOTE						DECIMAL(13,2),
	@PP_FACTURA								VARCHAR(50),
	-- ===========================
	@PP_PIEL_ARRAY							NVARCHAR(MAX),
	@PP_SQF_ARRAY							NVARCHAR(MAX),
	-- ===========================
	@PP_USER								VARCHAR(25),
	@PP_COMPUTER_NAME						VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	DECLARE @VP_LOCACION_DESTINO VARCHAR(255) = 'MHI'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--EXECUTE [dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_TAGNO_ORIGEN,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- /////////SE OBTIENE DE LOS ARRAY EL LOTE Y PIEL INGRESADOS///////////////////////////////////////////////////////////	
				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(50),
						LOTE		VARCHAR(50),
						PIEL		VARCHAR(10),
						SQF			VARCHAR(10)
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_PIEL	INT
				DECLARE @VP_POSICION_SQF	INT

				DECLARE @VP_PIEL_VALOR		VARCHAR(20)
				DECLARE @VP_SQF_VALOR		VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_SQF_ARRAY	= @PP_SQF_ARRAY		+ '/'		
				SET	@PP_PIEL_ARRAY	= @PP_PIEL_ARRAY		+ '/'		
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_PIEL_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_PIEL	=	patindex('%/%' , @PP_PIEL_ARRAY)
						SELECT @VP_POSICION_SQF		=	patindex('%/%' , @PP_SQF_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_PIEL_VALOR	= LEFT(@PP_PIEL_ARRAY, @VP_POSICION_PIEL - 1)
						SELECT @VP_SQF_VALOR	= LEFT(@PP_SQF_ARRAY, @VP_POSICION_SQF - 1)
						
						-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
						EXECUTE [dbo].[PG_RN_VALIDA_PIEL_A_IMPORTAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_COLOR, @PP_LOTE, @VP_PIEL_VALOR,
																		@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
						
						IF @VP_MENSAJE <> ''
							RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.

						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_PIEL_SELECCIONADAS
								VALUES	( @PP_COLOR,
										  @PP_LOTE,
										  @VP_PIEL_VALOR,
										  @VP_SQF_VALOR )

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_PIEL_ARRAY	= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
						SELECT @PP_SQF_ARRAY	= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION_SQF, '')

					END
				
				-- ////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION//////////////////////////			
				DECLARE @VP_N_PIEL INT = 0
				SELECT @VP_N_PIEL = COUNT(K_PIEL_SELECCIONADA) FROM @TBL_PIEL_SELECCIONADAS
								
				IF @VP_N_PIEL IS NULL OR @VP_N_PIEL = 0
					RAISERROR ('NO hay pieles para importar', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////////////////SI HAY MAS DE UN LOTE GENERAMOS UN ERROR DE TRANSACCION//////////////////////////			
				DECLARE @VP_N_LOTE INT = 0
				SELECT @VP_N_LOTE = COUNT(DISTINCT(LOTE)) 
				FROM @TBL_PIEL_SELECCIONADAS
												
				IF @VP_N_LOTE > 1
					RAISERROR ('Se encontraron mas de un Lote en las pieles capturadas', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////////////////SI HAY MAS DE UN COLOR GENERAMOS UN ERROR DE TRANSACCION//////////////////////////			
				DECLARE @VP_N_COLOR INT = 0
				SELECT @VP_N_COLOR = COUNT(DISTINCT(COLOR)) 
				FROM @TBL_PIEL_SELECCIONADAS
												
				IF @VP_N_COLOR > 1
					RAISERROR ('Se encontraron mas de un Color en las pieles capturadas', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////SE OBTIENE EL FOLIO BASE DEL COLOR///////////////////////////////////////////////////////////	
				DECLARE @VP_FOLIO	INT = 0
				SELECT	TOP 1 @VP_FOLIO=TAG
				-- =====================
				FROM	RP_Folios  
				-- =====================
				INNER JOIN RP_SC ON TAG = TAGNO
				AND RTRIM(LTRIM(STATUS)) = 'B' 
				AND COLOUR = @PP_COLOR
				-- =====================
				GROUP BY TAG, COLOUR
				
				-- /////////SI NO EXISTE UN FOLIO BASE PARA EL COLOR NUEVO SE CREA///////////////////////////////////////////////////////////	
				IF @VP_FOLIO IS NULL OR @VP_FOLIO = ''
					BEGIN
						EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																			'DATA_02', 'RP_FOLIOS', 'TAG',
																			@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT

						EXECUTE [dbo].[PG_IN_RP_FOLIOS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@VP_FOLIO, 'B', '', '', ''
					END

				-- /////////SE INGRESA LA PIEL AL FOLIO BASE DEL COLOR NUEVO///////////////////////////////////////////////////////////	
				INSERT INTO RP_SC( 
									[CDATE], [COLOUR], [LOT], [HIDE], [SQF], [TAGNO], [YARDAS], [YLB], [PESO], [TYPE], [MOVEMENT], [K_CLASIFICACION]
								)
							SELECT	GETDATE(), [COLOR], [LOTE], [PIEL], [SQF],  @VP_FOLIO, NULL, NULL, NULL, 'C', @VP_LOCACION_DESTINO, 0 
							FROM	@TBL_PIEL_SELECCIONADAS 								
				
				-- /////////SE INGRESA LOS DATOS DE LA IMPORTACION EN HIDESHDR_SQL///////////////////////////////////////////////////////////	
				DECLARE @VP_N_CABALLO_IMPORTADO INT = 0
								
				SELECT	@VP_N_CABALLO_IMPORTADO = COUNT(ID) 
				FROM	HIDESHDR_SQL 
				WHERE	PLOT = @PP_LOTE
				AND		THIDES = @PP_TOTAL_PIEL_LOTE
				AND		TAREA = @PP_TOTAL_SQF_LOTE
				AND		PCOLOR = @PP_COLOR
				AND		INVOICE = @PP_FACTURA

				
				IF @VP_N_CABALLO_IMPORTADO IS NULL
					SET @VP_N_CABALLO_IMPORTADO = 0

				IF @VP_N_CABALLO_IMPORTADO > 0
					RAISERROR ('El caballo ya fue importado anteriormente...', 16, 1 ) --MENSAJE - Severity -State.

				DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
				DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');

				DECLARE @VP_FILE_NO VARCHAR(100) = CONCAT(@VP_FECHA, @VP_HORA)
				INSERT INTO HIDESHDR_SQL (
											FILENO, LDATE, TDATE, CUSTOMER, PLOT, THIDES, TAREA, STATUS, PCOLOR, INVOICE
										) 
								VALUES (    
											@VP_FILE_NO, @VP_FECHA, @VP_FECHA, 'XX', @PP_LOTE, @PP_TOTAL_PIEL_LOTE, @PP_TOTAL_SQF_LOTE, @VP_LOCACION_DESTINO, @PP_COLOR, @PP_FACTURA
										)

				-- /////////SE INGRESAN LAS PIELES IMPORTADAS EN HIDESLIN_SQL///////////////////////////////////////////////////////////	
				INSERT INTO HIDESLIN_SQL (
											FILENO,HIDE,SQF,PRINTED
										) 
									SELECT	@VP_FILE_NO, [PIEL], [SQF], 1
									FROM	@TBL_PIEL_SELECCIONADAS 
                                                         
				-- /////////SE INGRESA EL LOG DEL INGROSO MANUAL DE LA PIEL///////////////////////////////////////////////////////////							
				INSERT INTO PIEL_LOG	
								(	
									[K_TIPO_PIEL_LOG], [FOLIO_ORIGEN], [COLOR],	[LOTE], [PIEL], [LOCACION_ORIGEN], [ORDEN_ORIGEN],
									[FOLIO_DESTINO], [LOCACION_DESTINO], [ORDEN_DESTIDO], [SQF], [F_LOG],	
									-- ===========================
									[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO],
									[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]  )	
									-- ===========================
							SELECT	12, 0, [COLOR], [LOTE], [PIEL], '', 0, 
									@VP_FOLIO, @VP_LOCACION_DESTINO, 0, [SQF], GETDATE(),
									-- ===========================
									@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(),
									0, NULL, NULL
							FROM	@TBL_PIEL_SELECCIONADAS 

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
				DECLARE @VP_COLOR_TBL	VARCHAR(10) = ''
				DECLARE @VP_LOTE_TBL	VARCHAR(10)	= ''
				DECLARE @VP_SQF_TBL		DECIMAL(13,4) = 0
				DECLARE @VP_CONTADOR INT = 0

				DECLARE CU_SQF_X_LOTE CURSOR 
				FOR SELECT  LTRIM(RTRIM(COLOR)) , LTRIM(RTRIM(LOTE)), SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF))))
					FROM @TBL_PIEL_SELECCIONADAS 
					GROUP BY COLOR, LOTE

				OPEN CU_SQF_X_LOTE
				FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
				
						DECLARE @VP_INDICE	VARCHAR(10) = CONVERT(VARCHAR(10), @VP_CONTADOR)
						SET @VP_LOTE_TBL	= RIGHT( '000000' + @VP_LOTE_TBL, 6)					
				
						-- ///////////////////////////////////////////
						EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@VP_LOCACION_DESTINO, @VP_LOCACION_DESTINO, @VP_COLOR_TBL,
																							@VP_LOTE_TBL, @VP_SQF_TBL, @VP_TRANSACCION_DOC

						-- ///////////////////////////////////////////
						EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
																@VP_TRANSACCION_DOC, @VP_INDICE, 0

						-- ///////////////////////////////////////////
						EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@VP_LOCACION_DESTINO, @VP_COLOR_TBL, @VP_SQF_TBL

						-- ////////////////////////////////////////////////////////////////////
				
						DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
						DECLARE @VP_ORDERNO VARCHAR (50) =  '00000'

						SET @VP_TRXIDNO = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000010000'

						EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
																@VP_LOCACION_DESTINO, @VP_SQF_TBL, @VP_ORDERNO, 
																@PP_USER, 'importación de pieles manual', 0, @VP_INDICE,
																'R', 'M', @VP_SQF_TBL

						-- ///////////////////////////////////////////
						SET @VP_CONTADOR = @VP_CONTADOR + 1
						-- ///////////////////////////////////////////
						
						FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
					END
	
				CLOSE CU_SQF_X_LOTE
				DEALLOCATE CU_SQF_X_LOTE

				-- ///////////////SE NOTIFICA A CALIDAD PARA INSPECCION /////////////////////////////////////////////////////	
				DECLARE @VP_N_LOTE_INSPECCION INT = 0
				SELECT	@VP_N_LOTE_INSPECCION = COUNT(ID)
				FROM	IncInsp_sql 
				WHERE	LTRIM(RTRIM([Date])) = @VP_FECHA 
				AND		LTRIM(RTRIM(Lot)) = @VP_LOTE_TBL 
				AND		LTRIM(RTRIM([Description])) = @PP_COLOR

				IF ( @VP_N_LOTE_INSPECCION IS NULL OR  @VP_N_LOTE_INSPECCION = 0 )
					BEGIN
						DECLARE @VP_MUESTRA INT = 3

						IF @PP_TOTAL_PIEL_LOTE > 5
							SET @VP_MUESTRA = 5

						INSERT INTO IncInsp_sql (	[Date], Lot, [Description], Lot_size, Sample_size, [Status], Accepted ) 
										VALUES (	@VP_FECHA, CONCAT('         ', @VP_LOTE_TBL), @PP_COLOR, @PP_TOTAL_PIEL_LOTE, @VP_MUESTRA, '-', '-')
					END
				
				-- ///////SE ENVIA CORREO TEMPORALMENTE PARA ESTAR MONITORIANDO////////////////////////////////////////////
				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
				DECLARE @VP_SUBJECT		VARCHAR(255) = 'Importación de Pieles Manuales...'
				DECLARE @VP_BODY		NVARCHAR(MAX) 

				SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="7">Importacion de pieles Manuales... </th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>File No</th><th>Color</th><th>Lote</th><th>Total Piel</th><th>Total SQF</th><th>Factura</th><th>Usuario</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
									  N'<td>'+ @VP_FILE_NO +'</td><td>'+ @PP_COLOR +'</td><td>'+ @PP_LOTE +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_PIEL_LOTE) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TOTAL_SQF_LOTE) +'</td><td>'+ @PP_FACTURA +'</td><td>'+  @PP_USER +'</td>' + 
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
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PM_TRANSFER_PIEL_A_IMPORTAR] // ' + @VP_ERROR_TRANS
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

	--EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'PROCESO',
	--												'',
	--												-- ===========================================
	--												'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
