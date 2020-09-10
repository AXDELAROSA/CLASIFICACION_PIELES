-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PROYECTO/GERBER
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN / cccuthst_sql
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(   N'[dbo].[PG_PR_IN_CCCUTHST_SQL_X_FOLIO_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_IN_CCCUTHST_SQL_X_FOLIO_GERBER]
GO
/*
EXEC [PG_PR_IN_UP_CCCUTHST_SQL] 0 ,144, '11345' , 'FMCKSA5' , 'Table 03' , '0263' , '32991' , 39.90 , 
								0 , 35 , 0 , 'HAN - No issues' , '13000' , '12366' , '13480' , '13141' , 
								'09144' , '07067' , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_PR_IN_CCCUTHST_SQL_X_FOLIO_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT,
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////RN VALIDACIONES////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
				BEGIN TRY
					DECLARE @PP_ORDEN				VARCHAR(10)
					DECLARE @PP_COLOR				VARCHAR(10)
					DECLARE @PP_LOCACION			VARCHAR(5)
					DECLARE @PP_PIEL				VARCHAR(5)
					DECLARE @PP_LOTE				VARCHAR(15)
					DECLARE @PP_PIEL_SQF_CORTADO	DECIMAL(13,4)

					-- ////////////////////SE OBTIENE LA ORDEN DEL FOLIO//////////////////////////	
					SELECT @PP_ORDEN = LTRIM(RTRIM(JOBNO))
									FROM RP_FOLIOS
									WHERE TAG = @PP_FOLIO

					IF @PP_ORDEN IS NULL
						RAISERROR ('ERROR: No fue posible obtener la orden del folio en [RP_FOLIOS]', 16, 1 ) --MENSAJE - Severity -State.

					-- ////////////////////SE CREA EL CURSOR CON LAS PIELES DEL FOLIO//////////////////////////	
					DECLARE CU_FOLIO_GERBER CURSOR 
					FOR SELECT LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), LTRIM(RTRIM(SQF)), LTRIM(RTRIM(MOVEMENT))
						FROM RP_SC WHERE TAGNO = @PP_FOLIO
		
					OPEN CU_FOLIO_GERBER
					FETCH NEXT FROM CU_FOLIO_GERBER INTO @PP_COLOR, @PP_LOTE, @PP_PIEL, @PP_PIEL_SQF_CORTADO, @PP_LOCACION

					-- ////////////////////SE RECORRE EL CURSOR//////////////////////////	
					WHILE @@FETCH_STATUS = 0
						BEGIN
							DECLARE @VP_PIEL_EXISTE INT = 0

							SELECT @VP_PIEL_EXISTE	=	COUNT(JOBNO)
											FROM	cccuthst_sql
											WHERE LTRIM(RTRIM(JOBNO)) = @PP_ORDEN
											AND	LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
											AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + @PP_LOTE, 6) 
											AND LTRIM(RTRIM(hideno)) = @PP_PIEL
							-- ===========================
							IF @VP_PIEL_EXISTE IS NULL
								SET @VP_PIEL_EXISTE = 0
							
							-- /////////////////OBTENEMOS EL SQF DE LA PIEL ASIGNADA AL FOLIO//////
							DECLARE @VP_N_K_PIEL_LOG INT = 0
							
							SELECT @VP_N_K_PIEL_LOG = COUNT(K_PIEL_LOG)
							FROM PIEL_LOG 
							WHERE K_TIPO_PIEL_LOG = 6 --DEVOLUCION
							AND	FOLIO_ORIGEN = @PP_FOLIO
							AND	PIEL = CONVERT(INT, @PP_PIEL)
							AND LOCACION_ORIGEN = @PP_LOCACION
							AND	ORDEN_ORIGEN = CONVERT(INT, @PP_ORDEN)

							IF @VP_N_K_PIEL_LOG IS NULL
								SET @VP_N_K_PIEL_LOG = 0

							IF (@VP_N_K_PIEL_LOG > 0 AND @VP_PIEL_EXISTE > 0)
								RAISERROR ('ERROR: Se le realizo movimiento de devolucion', 16, 1 ) --MENSAJE - Severity -State.
											
							-- /////////////SE OBTINE EL DIA Y LA HORA////////////////////
							DECLARE @VP_FECHA	INT = FORMAT(CAST(GETDATE() AS DATE), N'yyyyMMdd');
							DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
							DECLARE @VP_DETAIL	VARCHAR(100) = ''
							DECLARE @VP_TURNO	VARCHAR(5) = '1'
			
							IF @VP_HORA > 2000 AND @VP_HORA < 60002
								SET @VP_TURNO = '2'
							ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
								SET @VP_TURNO = '0'
								
							-- ////////////////////////////////////////////////////////////////////////////
							IF @VP_PIEL_EXISTE > 0
								BEGIN
									-- /////////////////////SE ACTUALIZA LA PIEL CORTADA////////////////////////////////////
									UPDATE	cccuthst_sql
										SET cdate			= @VP_FECHA,
											ctime			= @VP_HORA,
											cshiftdate		= @VP_FECHA,
											cshift			= @VP_TURNO,
											hideinspector	= '00000',
											hidesqm			= @PP_PIEL_SQF_CORTADO,
											operator1		= '00000',
											operator2		= '00000',
											operator4		= '00000',
											operator6		= '00000',
											operator7		= '00000',
											rawpatterns		= 0,
											rawpatternsqm	= 0,
											patternsqm		= 0,
											lowutilcd		= ''
									-- ===========================
									WHERE	LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
									AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
									AND	LTRIM(RTRIM(hideno)) = @PP_PIEL
									AND	LTRIM(RTRIM(JOBNO)) = @PP_ORDEN 

									IF @@ROWCOUNT = 0
										RAISERROR ('ERROR: No fue posible Actualizar la piel en [cccuthst_sql]', 16, 1 ) --MENSAJE - Severity -State.

									-- /////////////////////SE INGRESA EL LOG////////////////////////////////////////////////
									SET @VP_DETAIL = 'Los datos de la piel: ' + @PP_PIEL + ' fueron modificados'  
									EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_USER, @PP_COMPUTER_NAME, 'CORTE EN GERBER',
																		@PP_ORDEN, 'Modify',
																		@VP_DETAIL, @PP_PIEL
										
								END
							ELSE
								BEGIN
									-- /////////////////////SE OBTINE EL ULTIMO NUMERO DE LINEA///////////////////////////////////////
									DECLARE @VP_N_PIEL_CORTADA	INT = 0
									DECLARE @VP_LINEA_ULTIMA	INT = 0
									DECLARE @VP_LINEA_NUEVA		VARCHAR(5) = ''

									SELECT	@VP_N_PIEL_CORTADA = COUNT(JOBNO)
									FROM	cccuthst_sql
									WHERE	LTRIM(RTRIM(jobno)) = @PP_ORDEN    	

									IF @VP_N_PIEL_CORTADA IS NULL
										SET @VP_N_PIEL_CORTADA = 0
									-- ===========================

									IF @VP_N_PIEL_CORTADA > 0
										BEGIN
											SELECT	@VP_LINEA_ULTIMA = MAX(CONVERT(INT, linenum))
											FROM	cccuthst_sql
											WHERE	LTRIM(RTRIM(jobno)) = @PP_ORDEN  
											
											IF @VP_LINEA_ULTIMA IS NULL
												 RAISERROR ('ERROR: No fue posible obtener el numero de linea de la orden en [cccuthst_sql]', 16, 1 ) --MENSAJE - Severity -State.
												  
											SET @VP_LINEA_ULTIMA = @VP_LINEA_ULTIMA + 1
											SET @VP_LINEA_NUEVA =  RIGHT( '0000' + CONVERT(VARCHAR(4),@VP_LINEA_ULTIMA), 4) 
											  	
										END
									ELSE
										BEGIN
											SET @VP_LINEA_NUEVA =  '0000'
										END

									DECLARE @VP_LOCACION_DESC VARCHAR(50) = ''
									SELECT @VP_LOCACION_DESC = LTRIM(RTRIM(LOC_DESC))
									FROM IMLOCFIL_SQL
									WHERE LTRIM(RTRIM(LOC)) = @PP_LOCACION

									-- /////////////////////SE INGRESA LA PIEL CORTADA///////////////////////////////////////
									DECLARE @VP_LOTE_CON_ESPACIO VARCHAR(50) = CONCAT('         ', RIGHT('000000' + @PP_LOTE, 6) )
									EXECUTE [dbo].[PG_IN_CCCUTHST_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			-- ===========================
																			@PP_ORDEN, @VP_LINEA_NUEVA, '1', @VP_FECHA,
																			-- ===========================
																			@VP_HORA, @VP_FECHA, @VP_TURNO, @PP_COLOR, 
																			-- ===========================
																			@VP_LOTE_CON_ESPACIO, @PP_PIEL, @PP_PIEL_SQF_CORTADO,
																			-- ===========================
																			'00000', @VP_LOCACION_DESC, '00000', '00000',
																			'00000', '00000', '00000', '00000', '00000',
																			-- ===========================
																			0, 0, 0, 0,
																			-- ===========================
																			1, 0, 'P', '', '', @PP_USER, @PP_COMPUTER_NAME
						
									-- /////////////////////SE INGRESA EL LOG////////////////////////////////////////////////
									SET @VP_DETAIL = 'New hide' 
									EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_USER, @PP_COMPUTER_NAME, 'CORTE GERBER',
																		@PP_ORDEN, 'Add',
																		@VP_DETAIL, @PP_PIEL

								END

							FETCH NEXT FROM CU_FOLIO_GERBER INTO @PP_COLOR, @PP_LOTE, @PP_PIEL, @PP_PIEL_SQF_CORTADO, @PP_LOCACION
						END
			
					-- ////////////////////SE CIERRA EL CURSOR//////////////////////////
					CLOSE CU_FOLIO_GERBER
					DEALLOCATE CU_FOLIO_GERBER
				
				COMMIT TRANSACTION 
			END TRY
			
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PR_IN_CCCUTHST_SQL_X_FOLIO_GERBER // ' + @VP_ERROR_TRANS
			END CATCH
					
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Guardar las pieles del [FOLIO: '+CONVERT(VARCHAR(10),@PP_FOLIO)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_PIEL AS CLAVE
	
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
													0, 0, @PP_FOLIO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> IN / cccuthst_sql
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(   N'[dbo].[PG_PR_DL_CCCUTHST_SQL_X_FOLIO_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_DL_CCCUTHST_SQL_X_FOLIO_GERBER]
GO
/*
EXEC [PG_PR_IN_UP_CCCUTHST_SQL] 0 ,144, '11345' , 'FMCKSA5' , 'Table 03' , '0263' , '32991' , 39.90 , 
								0 , 35 , 0 , 'HAN - No issues' , '13000' , '12366' , '13480' , '13141' , 
								'09144' , '07067' , 'franciscoe' , 'IT-010' 
*/
CREATE PROCEDURE [dbo].[PG_PR_DL_CCCUTHST_SQL_X_FOLIO_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////RN VALIDACIONES////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
				BEGIN TRY
					-- ////////////////////SE OBTIENE LA ORDEN DEL FOLIO//////////////////////////	
					DECLARE @PP_ORDEN	VARCHAR(10)
					SELECT @PP_ORDEN	= LTRIM(RTRIM(JOBNO))
										FROM RP_FOLIOS
										WHERE TAG = @PP_FOLIO

					IF @PP_ORDEN IS NULL
						RAISERROR ('ERROR: No fue posible obtener la orden del folio en [RP_FOLIOS]', 16, 1 ) --MENSAJE - Severity -State.

					-- ////////////////////SE ELIMINAN LAS PIELES QUE SE CORTARON EN LA ORDEN//////////////////////////	
					DELETE cccuthst_sql
					WHERE LTRIM(RTRIM(JOBNO)) = @PP_ORDEN 	

					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR SP: No se encontraron pieles cortadas de la Orden en [cccuthst_sql]', 16, 1 ) --MENSAJE - Severity -State.

				COMMIT TRANSACTION 
			END TRY
			
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_PR_DL_CCCUTHST_SQL_X_FOLIO_GERBER // ' + @VP_ERROR_TRANS
			END CATCH
					
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Eliminar las pieles del [FOLIO: '+CONVERT(VARCHAR(10),@PP_FOLIO)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FOLIO AS CLAVE
	
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
													0, 0, @PP_FOLIO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
