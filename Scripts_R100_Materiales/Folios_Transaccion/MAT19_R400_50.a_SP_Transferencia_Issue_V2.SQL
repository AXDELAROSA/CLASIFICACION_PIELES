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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_ISSUE_V2]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE_V2]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_ISSUE_V2] 0,144, 3798063 , 'FCNPWA3' , 'T68' , '17843' , '105721/105721' , '0069/0068' , '46.30/38.80' , 'Pruebas de movimiento issue out por piel seleccionada.' , 'franciscoe' , 'IT-010' 
EXECUTE  [dbo].[PG_PM_TRANSFER_ISSUE_V2] 0,144, 3798290 , 'FCPATX7' , 'MHI' , '-' , '501011' , '0035' , '34.80' , 'TEST ISUE OUT DE MHI' , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE_V2]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO_ORIGEN			INT,
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(5),
	@PP_ORDEN					VARCHAR(10),
	-- ===========================
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
	@PP_SQF_ARRAY				NVARCHAR(MAX),
	-- ===========================
	@PP_COMENTARIO				VARCHAR(MAX),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF LTRIM(RTRIM(@PP_COMENTARIO)) = '' OR @PP_COMENTARIO IS NULL
		SET  @VP_MENSAJE = 'Es necesario agregar un comentario para poder realizar la acción.'

	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_N_FOLIO_BASE INT = 0
			SELECT @VP_N_FOLIO_BASE = COUNT(ID) 
			FROM RP_Folios 
			WHERE TAG = @PP_FOLIO_ORIGEN 
			AND STATUS = 'B'

			IF @VP_N_FOLIO_BASE IS NULL
				SET @VP_N_FOLIO_BASE = 0 

			IF @VP_N_FOLIO_BASE > 0
				SET  @VP_MENSAJE = 'No se pueden borrar pieles del folio Base.'
		END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- /////////////////////////////////////////////////////////////////////
				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(20),
						LOTE		VARCHAR(20),
						PIEL		VARCHAR(20),
						SQF			VARCHAR(20)
					)

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
											@PP_COLOR,
											@VP_LOTE_VALOR,
											@VP_PIEL_VALOR,
											@VP_SQF_VALOR
										)
																								
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_PIEL_ARRAY			= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
						SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')
						SELECT @PP_SQF_ARRAY			= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION_SQF, '')

					END

				DECLARE @VP_N_PIEL INT = 0
				SELECT @VP_N_PIEL = COUNT(K_PIEL_SELECCIONADA) FROM @TBL_PIEL_SELECCIONADAS

				-- ////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION//////////////////////////
				IF @VP_N_PIEL IS NULL
					RAISERROR ('NO hay pieles seleccionadas.', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////INGRESAMOS LAS PIELES DEL FOLIO A LOS LOS DIFERENTES LOGS PARA SEGUIMINETO ANTES DE BORRARLAS///////
				DECLARE @VP_COLOR	VARCHAR(10)
				DECLARE @VP_LOTE	INT
				DECLARE @VP_PIEL	INT
				DECLARE @VP_SQF		DECIMAL(13,4)

				DECLARE CU_PIEL_ISSUE_OUT CURSOR 
				FOR SELECT	LTRIM(RTRIM(COLOR)), LTRIM(RTRIM(LOTE)), LTRIM(RTRIM(PIEL)), LTRIM(RTRIM(SQF)) 
					FROM	@TBL_PIEL_SELECCIONADAS
				
				OPEN CU_PIEL_ISSUE_OUT
				FETCH NEXT FROM CU_PIEL_ISSUE_OUT INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					-- ///////////////////INGRESO EL LOG DE LA PIEL//////////////////////////////////////////////////
					EXECUTE [dbo].[PG_IN_PIEL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														7, @PP_FOLIO_ORIGEN, @VP_COLOR,
														@VP_LOTE, @VP_PIEL, @VP_SQF, 
														@PP_LOCACION, 0, 
														0, 0, 0

					-- /////////////////////////////////////////////////////////////////////
					DECLARE @VP_DETAIL VARCHAR(100) = 'Scrap Ticket'
					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_USER, @PP_COMPUTER_NAME, 'Transactions',
														@PP_FOLIO_ORIGEN, 'Issue Out',
														@VP_DETAIL, @VP_PIEL

					-- ////////////////////////////////////////////////////////////////////	
					DELETE	RP_SC
					WHERE	LTRIM(RTRIM(TAGNO)) = @PP_FOLIO_ORIGEN
					AND LTRIM(RTRIM(COLOUR)) = @VP_COLOR
					AND LTRIM(RTRIM(LOT)) = @VP_LOTE
					AND LTRIM(RTRIM(HIDE)) = @VP_PIEL

					IF @@ROWCOUNT = 0
						RAISERROR ('No fue posible borrar las Piles', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////////////////////////////////////////////////////////////////	
				  FETCH NEXT FROM CU_PIEL_ISSUE_OUT INTO @VP_COLOR, @VP_LOTE, @VP_PIEL, @VP_SQF
	
				END
				
				CLOSE CU_PIEL_ISSUE_OUT
				DEALLOCATE CU_PIEL_ISSUE_OUT
				-- ////////////////////////////////////////////////////////////////////	
				
				DECLARE @VP_TRANSACCION_DOC	INT = 0

				SELECT	TOP 1
						@VP_TRANSACCION_DOC  = RIGHT('00000000' + Ltrim(Rtrim(NEXT_DOC_NO)), 8)
				-- =====================
				FROM	IMCTLFIL_SQL
				-- ///////////////////////////////////////////

				EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	1 
				-- ///////////////////////////////////////////
				DECLARE @VP_COLOR_TBL	VARCHAR(10)
				DECLARE @VP_LOTE_TBL	VARCHAR(10)
				DECLARE @VP_SQF_TBL		VARCHAR(10)
				DECLARE @VP_CONTADOR	INT = 0
				
				DECLARE CU_SQF_X_LOTE_ISSUE_OUT CURSOR 
				FOR SELECT	LTRIM(RTRIM(COLOR)), LTRIM(RTRIM(LOTE)), SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF)))) AS SQF 
					FROM	@TBL_PIEL_SELECCIONADAS
					GROUP BY COLOR, LOTE
				
				OPEN CU_SQF_X_LOTE_ISSUE_OUT
				FETCH NEXT FROM CU_SQF_X_LOTE_ISSUE_OUT INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
				
					DECLARE @VP_INDICE	VARCHAR(10) = CONVERT(VARCHAR(10), @VP_CONTADOR)
					SET @VP_LOTE_TBL	= RIGHT( '000000' + @VP_LOTE_TBL, 6)
											
					-- ///////////////////////////////////////////
					
					EXECUTE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@PP_LOCACION, @VP_COLOR_TBL,
																						@VP_LOTE_TBL, @VP_SQF_TBL
					-- ///////////////////////////////////////////
					EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
															@VP_TRANSACCION_DOC, @VP_INDICE, 0

					-- ///////////////////////////////////////////
					EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_LOCACION, @VP_COLOR_TBL, @VP_SQF_TBL
					-- ///////////////////////////////////////////
					SET @VP_CONTADOR = @VP_CONTADOR + 1
					-- ///////////////////////////////////////////
					
				    FETCH NEXT FROM CU_SQF_X_LOTE_ISSUE_OUT INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
				
				END
				
				CLOSE CU_SQF_X_LOTE_ISSUE_OUT
				DEALLOCATE CU_SQF_X_LOTE_ISSUE_OUT
						
				-- ////////////////////////////////////////////////////////////////////
				DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
				DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
				DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
				SET	@PP_ORDEN = LEFT(@PP_ORDEN + '00000' , 5)

				-- ////////////////////////////////////////////////////////////////////
				INSERT INTO  IMINVTRX_SQL (	SOURCE, ORD_NO, ITEM_NO, LOC, TRX_DT, 

											TRX_TM, DOC_DT, DOC_TYPE, DOC_SOURCE, QUANTITY, 

											DOC_ORD_NO, OLD_QUANTITY, USER_NAME, ID_NO, PROMISE_DT,

											LEV_NO, SEQ_NO, CTL_NO, LINE_NO, FROM_CTL_NO, FROM_LINE_NO, 
											
											FROM_LEV_NO, FROM_SEQ_NO, UNIT_COST, OLD_UNIT_COST, NEW_UNIT_COST, 

											PRICE, BUILD_QTY, BUILD_QTY_PER, AMT, LANDED_COST, RECEIPT_ORD_NO, 

											TRX_QTY_BKORD, DEALL_AMT, batch_id, jnl, item_filler, comment	) 

								VALUES	  ( 'I', @VP_TRANSACCION_DOC, @VP_COLOR_TBL, @PP_LOCACION, @VP_F_TRANSACCION,

											@VP_TIME, @VP_F_TRANSACCION, 'I', 'M', 0, 

											@PP_ORDEN, 0, @PP_USER, @VP_TRXIDNO, @VP_F_TRANSACCION,

											0, 0, 0, 0, 0, 0,
											
											0, 0, 0, 0, 0, 
											
											0, 0, 0, 0, 0, '0', 
											
											00000000, 0, '' , '', '', @PP_COMENTARIO	)

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: INSERT INTO  IMINVTRX_SQL', 16, 1 ) --MENSAJE - Severity -State.	

				-- ////////////////////////////////////////////////////////////////////	

				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = '' -- 'franciscoe@pearlleather.com.mx'
				SET @VP_RECIPIENTS = 'manuelg@pearlleather.com.mx;omard@pearlleather.com.mx;adelaree@pearlleather.com.mx;guillermom@pearlleather.com.mx;jorgeh@pearlleather.com.mx;miguelc@pearlleather.com.mx;pedrov@pearlleather.com.mx'

				DECLARE @VP_SUBJECT		VARCHAR(255) = 'Issue Out'
				DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
				DECLARE @VP_BODY		NVARCHAR(MAX) 
				
				SET @VP_BODY = N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="9">Se han eliminado las siguientes pieles</th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>Folio</th><th>Locación</th><th>Color</th><th>Lote</th><th>Piel</th><th>SQF</th><th>Comentario</th><th>Usuario</th><th>Fecha</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
										CAST ( ( SELECT td = @PP_FOLIO_ORIGEN, '',  
												 td = @PP_LOCACION, '',
								                td = RTRIM(LTRIM(COLOR)), '',  
								                td = RTRIM(LTRIM(LOTE)), '',  
								                td = RTRIM(LTRIM(PIEL)), '',  
								                td = RTRIM(LTRIM(SQF)), '', 
												td = @PP_COMENTARIO, '',  
												td = @PP_USER, '',  
								                td = CONVERT(DATE,GETDATE())  
								         FROM @TBL_PIEL_SELECCIONADAS
								          FOR XML PATH('tr'), TYPE   
										) AS NVARCHAR(MAX) ) +  
									N'</tbody>' + 
								N'</table>' ; 
					SET ROWCOUNT 0
					 				
				EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY
						
		COMMIT TRANSACTION 
		END TRY
	
		BEGIN CATCH
			/* Ocurrió un error, deshacemos los cambios*/ 
			ROLLBACK TRANSACTION
			DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
			SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
			SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PM_TRANSFER_ISSUE_V2 // ' + @VP_ERROR_TRANS
		END CATCH
			
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Eliminar el [FOLIO]: '+CONVERT(VARCHAR(10),@PP_FOLIO_ORIGEN)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO_ORIGEN AS CLAVE
	
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
													0, 0, @PP_FOLIO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
