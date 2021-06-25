-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	21/ABR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_PLANNING_MODIFICAR_ORDER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_PLANNING_MODIFICAR_ORDER]
GO

/*
	 EXEC [PG_PR_PLANNING_MODIFICAR_ORDER] 0 ,144,  '09309' , 'IRVI02' , 'FMCKTX7' , 'Table 06' , 
										'PJL2RC6/PJL2RC4/PJLFCRL/PJLFCRL/PJLSFBR/PJLSFBL/PJL2RB4/PJL2RB6' , 
										'30/30/30/30/30/30/30/30' , '4/3/5/6/8/7/1/2' , '0/0/0/0/0/0/0/0' , 
										'' , '' , 'franciscoe' , 'IT-010' 
*/

CREATE PROCEDURE [dbo].[PG_PR_PLANNING_MODIFICAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_MESA					VARCHAR(50),
	@PP_KIT_ARRAY				NVARCHAR(MAX),
	@PP_CANTIDAD_ARRAY			NVARCHAR(MAX),
	@PP_SER_NO_ARRAY			NVARCHAR(MAX),
	@PP_MFP_ARRAY				NVARCHAR(MAX),
	@PP_ORDEN_2_TONO			VARCHAR(50),
	@PP_COMENTARIO				VARCHAR(255),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

		-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	IF	(	SELECT	COUNT(K_DETAILS_RMA)
			FROM	DETAILS_RMA
			WHERE	JOBNO	= @PP_ORDEN	) > 0
		SET @VP_MENSAJE = 'ERROR: La orden [RMA] no es modificable.'

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	IF @VP_MENSAJE=''
		IF @PP_ORDEN_2_TONO <> ''
			EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_ORDEN_2_TONO,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
								
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ORDEN,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- /////////////SI SE MODIFICO LA LOCACION SE VALIDA QUE NO TENGA SQF EN LA LOCACION ANTERIOR/////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			DECLARE @VP_LOCACION_ANTERIOR VARCHAR(50) = ''
			SELECT @VP_LOCACION_ANTERIOR = LTRIM(RTRIM(MACHINE))
			FROM ccjobhdr_sql 
			WHERE JOBNO = @PP_ORDEN

			IF @VP_LOCACION_ANTERIOR IS NULL OR @VP_LOCACION_ANTERIOR = ''
				SET @VP_MENSAJE = 'ERROR: No fue posible obtener la Locacion de la orden en [ccjobhdr_sql].'

			IF @VP_MENSAJE = ''
				BEGIN
					IF @PP_MESA <> @VP_LOCACION_ANTERIOR
						BEGIN
							DECLARE @VP_LOCACION VARCHAR(50) = ''
							SELECT	@VP_LOCACION = LTRIM(RTRIM(LOC))
							FROM	imlocfil_sql 
							WHERE	loc_desc = @VP_LOCACION_ANTERIOR

							IF @VP_LOCACION IS NULL OR @VP_LOCACION = ''
								SET @VP_MENSAJE = 'ERROR: No fue posible obtener la Locacion en [imlocfil_sql].'
								
							IF @VP_MENSAJE = ''
								EXECUTE [dbo].[PG_RN_PLANNING_VALIDA_SQF_TRANSFERIDO_A_LOCACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_ORDEN, @PP_COLOR, @VP_LOCACION,
																									@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
						END
				END 
		END

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY	
				DECLARE @VP_COLOR_SIN_F VARCHAR(25) = SUBSTRING(@PP_COLOR, 2 , 10)

				-- ///////SE CREA TABLA TEMPORAL /////////////////////////////////////////////	
				DECLARE @TBL_KIT_A_MODIFICAR  TABLE (
						K_KIT_A_MODIFICAR	INT IDENTITY(1,1),
						KIT					VARCHAR(50),
						ITEM_NO				VARCHAR(100),
						CANTIDAD			INT,
						POSICION			INT,
						MFP					INT
					)
				SET NOCOUNT ON
								
				DECLARE @VP_POSICION_KIT		INT
				DECLARE @VP_POSICION_CANTIDAD	INT
				DECLARE @VP_POSICION_MFP		INT
				DECLARE @VP_POSICION_SERNO		INT
				DECLARE @VP_KIT_VALOR			VARCHAR(20)
				DECLARE @VP_CANTIDAD_VALOR		VARCHAR(20)
				DECLARE @VP_MFP_VALOR			VARCHAR(20)
				DECLARE @VP_SERNO_VALOR			VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_KIT_ARRAY		= @PP_KIT_ARRAY		+ '/'		
				SET	@PP_SER_NO_ARRAY	= @PP_SER_NO_ARRAY	+ '/'		
				SET	@PP_CANTIDAD_ARRAY	= @PP_CANTIDAD_ARRAY	+ '/'		
				SET	@PP_MFP_ARRAY		= @PP_MFP_ARRAY	+ '/'		
				
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_KIT_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_KIT			=	patindex('%/%' , @PP_KIT_ARRAY)
						SELECT @VP_POSICION_CANTIDAD	=	patindex('%/%' , @PP_CANTIDAD_ARRAY)
						SELECT @VP_POSICION_MFP			=	patindex('%/%' , @PP_MFP_ARRAY)
						SELECT @VP_POSICION_SERNO		=	patindex('%/%' , @PP_SER_NO_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_KIT_VALOR		= LEFT(@PP_KIT_ARRAY, @VP_POSICION_KIT - 1)
						SELECT @VP_CANTIDAD_VALOR	= LEFT(@PP_CANTIDAD_ARRAY, @VP_POSICION_CANTIDAD - 1)
						SELECT @VP_MFP_VALOR		= LEFT(@PP_MFP_ARRAY, @VP_POSICION_MFP - 1)
						SELECT @VP_SERNO_VALOR		= LEFT(@PP_SER_NO_ARRAY, @VP_POSICION_SERNO - 1)

						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_KIT_A_MODIFICAR
								VALUES	( 
											@VP_KIT_VALOR,
											(@VP_KIT_VALOR + @VP_COLOR_SIN_F),
											@VP_CANTIDAD_VALOR,
											@VP_SERNO_VALOR,
											@VP_MFP_VALOR
										)

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_KIT_ARRAY		= STUFF(@PP_KIT_ARRAY, 1, @VP_POSICION_KIT, '')
						SELECT @PP_CANTIDAD_ARRAY	= STUFF(@PP_CANTIDAD_ARRAY, 1, @VP_POSICION_CANTIDAD, '')
						SELECT @PP_MFP_ARRAY		= STUFF(@PP_MFP_ARRAY, 1, @VP_POSICION_MFP, '')
						SELECT @PP_SER_NO_ARRAY		= STUFF(@PP_SER_NO_ARRAY, 1, @VP_POSICION_SERNO, '')
					END
			
				-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
				DECLARE @VP_N_KIT_A_MODIFICAR INT = 0
				SELECT @VP_N_KIT_A_MODIFICAR = COUNT(K_KIT_A_MODIFICAR)
				FROM @TBL_KIT_A_MODIFICAR

				IF @VP_N_KIT_A_MODIFICAR IS NULL OR @VP_N_KIT_A_MODIFICAR = 0
					RAISERROR ('ERROR: No hay Kits para Actualizar.', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SI EXITEN KIT EN MFP NO SE ELIMINAN///////////////////////////////////////////////////////
				DECLARE @VP_N_KIT_EN_MFP INT = 0
				SELECT @VP_N_KIT_EN_MFP = COUNT(K_KIT_A_MODIFICAR)
				FROM @TBL_KIT_A_MODIFICAR
				WHERE MFP = 1

				IF @VP_N_KIT_EN_MFP IS NULL 
					SET  @VP_N_KIT_EN_MFP = 0

				-- ///////SE VALIDA SI QUEDARON KITS EN LA ORDEN///////////////////////////////////////////////////////
				DECLARE @VP_CONSECUTIVO INT = 1

				IF @VP_N_KIT_EN_MFP > 0
					BEGIN
						-- ///////SE ELIMINAN LOS KITS LOS CODIGOS DE LA CAMARA DEL CAMPO SERIAL///////////////////////////////////////////////////////
						INSERT INTO SERIALCAM_SQL 
						SELECT code, NULL, NULL 
						FROM SERIALCAM_SQL 
						WHERE SERIAL IN (	SELECT @PP_ORDEN + RIGHT('000'+ LTRIM(RTRIM(1)), 3) 
											FROM ccjoblin_sql 
											WHERE JOBNO = @PP_ORDEN 
											AND Ser_No NOT IN ( SELECT POSICION 
															FROM @TBL_KIT_A_MODIFICAR 
															WHERE MFP = 1 
															)
										)

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						DELETE SERIALCAM_SQL 
						WHERE SERIAL IN (	SELECT @PP_ORDEN + RIGHT('000'+ LTRIM(RTRIM(1)), 3) 
											FROM ccjoblin_sql 
											WHERE JOBNO = @PP_ORDEN 
											AND Ser_No NOT IN ( SELECT POSICION 
															FROM @TBL_KIT_A_MODIFICAR 
															WHERE MFP = 1 
															)
										)
						
						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						-- ///////SE ELIMINAN LOS KITS LOS CODIGOS DE LA CAMARA DEL CAMPO SERIAL2///////////////////////////////////////////////////////
						INSERT INTO SERIALCAM_SQL 
						SELECT code, NULL, NULL 
						FROM SERIALCAM_SQL 
						WHERE SERIAL2 IN (	SELECT @PP_ORDEN + RIGHT('000'+ LTRIM(RTRIM(1)), 3) 
											FROM ccjoblin_sql 
											WHERE JOBNO = @PP_ORDEN 
											AND Ser_No NOT IN ( SELECT POSICION 
															FROM @TBL_KIT_A_MODIFICAR 
															WHERE MFP = 1 
															)
										)
						
						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						DELETE SERIALCAM_SQL 
						WHERE SERIAL2 IN (	SELECT @PP_ORDEN + RIGHT('000'+ LTRIM(RTRIM(1)), 3) 
											FROM ccjoblin_sql 
											WHERE JOBNO = @PP_ORDEN 
											AND Ser_No NOT IN ( SELECT POSICION 
															FROM @TBL_KIT_A_MODIFICAR 
															WHERE MFP = 1 
															)
										)
						
						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						-- ///////SE ELIMINAN LOS KITS QUE NO ESTAN EN MFP///////////////////////////////////////////////////////
						DELETE ccjoblin_sql 
						WHERE JOBNO = @PP_ORDEN
						AND Ser_No NOT IN ( SELECT POSICION FROM @TBL_KIT_A_MODIFICAR WHERE MFP = 1 )

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a eliminar en [ccjoblin_sql].', 16, 1 ) --MENSAJE - Severity -State

						SELECT TOP 1 @VP_CONSECUTIVO = Ser_No
						FROM ccjoblin_sql
						WHERE JOBNO = @PP_ORDEN 
						ORDER BY Ser_No DESC

						SET @VP_CONSECUTIVO  = @VP_CONSECUTIVO + 1
					END
				ELSE
					BEGIN
						-- ///////SE ELIMINAN LOS KITS DE LA ORDEN///////////////////////////////////////////////////////
						DELETE ccjoblin_sql 
						WHERE JOBNO = @PP_ORDEN

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a eliminar en [ccjoblin_sql].', 16, 1 ) --MENSAJE - Severity -State

						INSERT INTO SERIALCAM_SQL 
						SELECT code, NULL, NULL FROM SERIALCAM_SQL WHERE SERIAL LIKE @PP_ORDEN	+ '%'

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						DELETE SERIALCAM_SQL 
						WHERE SERIAL LIKE @PP_ORDEN	+ '%'

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						INSERT INTO SERIALCAM_SQL 
						SELECT code, NULL, NULL FROM SERIALCAM_SQL WHERE SERIAL2 LIKE @PP_ORDEN	+ '%'

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Ingresar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State

						DELETE SERIALCAM_SQL 
						WHERE SERIAL2 LIKE @PP_ORDEN + '%'

						IF @@ROWCOUNT > 50
							RAISERROR ('ERROR: Verifique el numero de Kits a Eliminar en [SERIALCAM_SQL].', 16, 1 ) --MENSAJE - Severity -State
					END				

				-- //////SE DECLARAN VARIABLES A USARSE/////////////////////////////////////
				DECLARE @VP_KIT VARCHAR(50) = '', @VP_ITEM_NO VARCHAR(100) = '', @VP_CANTIDAD INT = 0, @VP_MFP INT = 0 ;
				DECLARE @VP_GROSS DECIMAL(16,4) = 0, @VP_NETO DECIMAL(16,4) = 0, @VP_PATRON INT = 0;
				DECLARE @VP_TOTAL_GROSS DECIMAL(16,4) = 0, @VP_TOTAL_NETO DECIMAL(16,4) = 0, @VP_TOTAL_PATRON INT = 0;
				
				-- //////SE CREA CURSOR PARA DARLE FORMATO A LOS DATOS/////////////////////////////////////
				DECLARE CU_KIT_A_MODIFICAR CURSOR 
				FOR SELECT	KIT, ITEM_NO, CANTIDAD, MFP
					FROM	@TBL_KIT_A_MODIFICAR
					--WHERE	MFP = 0

				OPEN CU_KIT_A_MODIFICAR
				FETCH NEXT FROM CU_KIT_A_MODIFICAR INTO @VP_KIT, @VP_ITEM_NO, @VP_CANTIDAD, @VP_MFP

				WHILE @@FETCH_STATUS = 0
					BEGIN
						DECLARE @VP_CUBE_LENGTH DECIMAL(13,4) = 0, @VP_CUBE_WIDTH DECIMAL(13,4) = 0, @VP_CUBE_QTY_PER DECIMAL(13,4) = 0;
						DECLARE @VP_D_ITEM	VARCHAR(255), @VP_CHANGE_LEVEL	VARCHAR(100), @VP_MODELO	VARCHAR(50), @VP_VERSION VARCHAR(50);

						SELECT	DISTINCT TOP (1) PERCENT 
							 @VP_VERSION = ccverhdr_sql.versionno, 
							 @VP_MODELO = ccverhdr_sql.modelno
						FROM	dbo.ccverhdr_sql
						INNER JOIN cccusitm_sql ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
							AND SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)  = 'P' 
							AND cus_item_no <> ''
						INNER JOIN IMITMIDX_SQL ON IMITMIDX_SQL.item_no = cccusitm_sql.item_no
						INNER JOIN  IMCATFIL_SQL ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
							AND IMCATFIL_SQL.L_BORRADO = 0
						WHERE ccverhdr_sql.specstatus = 'U' 
						AND ccverhdr_sql.status = 'L' 
						AND CONCAT('F', RIGHT(LTRIM(RTRIM(cccusitm_sql.item_no)),6)) = @PP_COLOR
						AND ccverhdr_sql.cus_no = @PP_CLIENTE
						AND cccusitm_sql.item_no = @VP_ITEM_NO
						--ORDER BY versionno DESC

						SET @VP_CHANGE_LEVEL = @VP_MODELO + @VP_VERSION

						-- ////////SE OBTIENE EL GROSS, NETO Y PATRONES DEL KIT///////////////////////////////////
						SELECT TOP 1 @VP_CUBE_LENGTH	= CUBE_LENGTH,
								@VP_CUBE_WIDTH			= CUBE_WIDTH,
								@VP_CUBE_QTY_PER		= CUBE_QTY_PER,
								@VP_D_ITEM				= LTRIM(RTRIM(item_desc_1)) --,
								--@VP_CHANGE_LEVEL		= LTRIM(RTRIM(Last_item_revision))
						FROM IMITMIDX_SQL   
						WHERE	LTRIM(RTRIM(ITEM_NO)) = @VP_ITEM_NO

						IF @VP_CUBE_LENGTH IS NULL
							SET @VP_CUBE_LENGTH = 0

						IF @VP_CUBE_WIDTH IS NULL
							SET @VP_CUBE_WIDTH = 0

						IF @VP_CUBE_QTY_PER IS NULL
							SET @VP_CUBE_QTY_PER = 0						 

						SET @VP_GROSS	= @VP_CUBE_LENGTH	* @VP_CANTIDAD
						SET @VP_NETO	= @VP_CUBE_WIDTH	* @VP_CANTIDAD
						SET @VP_PATRON	= @VP_CUBE_QTY_PER	* @VP_CANTIDAD 

						SET @VP_TOTAL_GROSS = @VP_TOTAL_GROSS + @VP_GROSS
						SET @VP_TOTAL_NETO = @VP_TOTAL_NETO + @VP_NETO
						SET @VP_TOTAL_PATRON = @VP_TOTAL_PATRON + @VP_PATRON
												
						IF @VP_MFP = 0
							BEGIN
								INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
															netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	)
												VALUES(		@PP_ORDEN, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO, @VP_CANTIDAD, @VP_CANTIDAD, 0,
															@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO	)
								
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.

								SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
							END

						FETCH NEXT FROM CU_KIT_A_MODIFICAR INTO @VP_KIT, @VP_ITEM_NO, @VP_CANTIDAD, @VP_MFP
					END
				
				CLOSE CU_KIT_A_MODIFICAR
				DEALLOCATE CU_KIT_A_MODIFICAR
						
				-- ///////SE OBTIENE LA ORDEN QUE TIENE LIGADA EN CCJOBHDR_SQL//////////////////////////////////////////////
				DECLARE @VP_ORDEN_LIGADA VARCHAR(10) = ''
				SELECT @VP_ORDEN_LIGADA = LOTNO
				FROM CCJOBHDR_SQL
				WHERE jobno	= @PP_ORDEN

				IF @VP_ORDEN_LIGADA IS NULL
					SET @VP_ORDEN_LIGADA = ''

				-- ///////SE ACTUALIZA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
				UPDATE CCJOBHDR_SQL 
					SET machine		=	@PP_MESA,
						netsqm		=	@VP_TOTAL_NETO,
						standardsqm	=	@VP_TOTAL_GROSS,
						patterns	=	@VP_TOTAL_PATRON,
						LOTNO		=	@PP_ORDEN_2_TONO,
						instruct1	=	@PP_COMENTARIO,
						comments	=	@PP_COMENTARIO
				WHERE jobno	= @PP_ORDEN
				
				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Actualizar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SE ACTUALIZA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
				IF @VP_ORDEN_LIGADA <> @PP_ORDEN_2_TONO
					BEGIN
						IF @VP_ORDEN_LIGADA <> ''
							BEGIN
								UPDATE CCJOBHDR_SQL 
									SET	LOTNO	=	''
								WHERE jobno	= @VP_ORDEN_LIGADA
							
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Actualizar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.
							END

						IF @PP_ORDEN_2_TONO <> ''
							BEGIN
								UPDATE CCJOBHDR_SQL 
									SET	LOTNO	=	@PP_ORDEN
								WHERE jobno	= @PP_ORDEN_2_TONO
							
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible Actualizar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.
							END
					END
				
				-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
				DECLARE @VP_DETAIL VARCHAR(100) = 'Modificacion de Orden: ' + @PP_ORDEN
				EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'Planning',
													@PP_ORDEN, 'Modificar orden',
													@VP_DETAIL, ''

			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_PLANNING_MODIFCAR_ORDER] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Actualizar la Orden: ' + '[' + @PP_ORDEN +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ORDEN AS CLAVE
	
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
													0, 0, @PP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
