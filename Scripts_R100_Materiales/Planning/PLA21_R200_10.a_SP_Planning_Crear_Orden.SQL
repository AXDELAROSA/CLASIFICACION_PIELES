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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_PLANNING_CREAR_ORDER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_PLANNING_CREAR_ORDER]
GO

/*
	 EXEC [PG_PR_PLANNING_CREAR_ORDER] 0 ,144, 'MAGN03' , 'FCNPJRR' , 'Table 38' , 
								'PLMWARM/PWD2TFB/PWD2TBL/PWD2TCR/PWD2TCL/PW2RB40/PW2RB60/PW2RC40/PWDRC60' , 
								'30/30/30/30/30/30/30/30/30' , '' , 'ORDEN GENERADA POR SISTEMAS PARA PRUEBAS' , 'franciscoe' , 'IT-010'  
*/

CREATE PROCEDURE [dbo].[PG_PR_PLANNING_CREAR_ORDER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CLIENTE					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_MESA					VARCHAR(50),
	@PP_KIT_ARRAY				NVARCHAR(MAX),
	@PP_CANTIDAD_ARRAY			NVARCHAR(MAX),
	--@PP_ORDEN_2_TONO			VARCHAR(50),
	@PP_COMENTARIO				VARCHAR(255),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

		-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''
	DECLARE @VP_ORDEN VARCHAR(10) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--IF @PP_ORDEN_2_TONO <> ''
	--	EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@PP_ORDEN_2_TONO,
	--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE OBTIENE EL NUMERO DE LA ULTIMA ORDEN GENERADA//////////////////////////////////////////////
				SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(user_def_fld_4)))
				FROM	imlocfil_sql (NOLOCK)
				WHERE LOC = 'MFP'

				IF @VP_ORDEN IS NULL
					RAISERROR ('ERROR: No fue posible obtener el numero de orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

				SET @VP_ORDEN = @VP_ORDEN + 1
				SET @VP_ORDEN = RIGHT('00000' + @VP_ORDEN, 5)

				-- ///////SE ACTUALIZA LA LOCACION MFP CON LA ORDEN CREADA//////////////////////////////////////////////	
				UPDATE imlocfil_sql 
					SET user_def_fld_4 = @VP_ORDEN
				WHERE LOC = 'MFP'

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Actualizar la orden en [imlocfil_sql]', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////SE OBTIENE LA DESCRIPCION DEL COLOR//////////////////////////////////////////////
				DECLARE @VP_COLOR_SIN_F VARCHAR(25) = SUBSTRING(@PP_COLOR, 2 , 10)
				DECLARE @VP_D_COLOR VARCHAR(255) = ''

				SELECT TOP 1 @VP_D_COLOR = LTRIM(RTRIM(ITEM_DESC_1))
				FROM IMITMIDX_SQL   (NOLOCK)
				WHERE	LTRIM(RTRIM(ITEM_NO)) = @PP_COLOR

				-- ///////SE OBTIENE LA FECHA EN FORMATO NUMERICO//////////////////////////////////////////////
				DECLARE @VP_FECHA	INT = DBO.CONVERT_DATE_TO_INT(GETDATE(), 'yyyyMMdd');
				DECLARE @VP_HORA	INT = FORMAT(CAST(GETDATE() AS TIME(0)), N'hhmmss');
				DECLARE @VP_TURNO	VARCHAR(5) = '2'
			
				IF @VP_HORA > 2000 AND @VP_HORA < 60002
					SET @VP_TURNO = '3'
				ELSE IF @VP_HORA > 60001 AND @VP_HORA < 153001
					SET @VP_TURNO = '1'

				-- /////////SE OBTIENE LA UTILIDAD//////////////////////////////////
				DECLARE @VP_UTILIDAD_MINIMA DECIMAL(13,2) = 0
				SELECT @VP_UTILIDAD_MINIMA = User_Def_Fld_2
				FROM arcusfil_sql (NOLOCK)
				WHERE CUS_NO = @PP_CLIENTE

				IF @VP_UTILIDAD_MINIMA IS NULL
					SET @VP_UTILIDAD_MINIMA = 0

				SET @VP_UTILIDAD_MINIMA = @VP_UTILIDAD_MINIMA / 1000000						
								
				-- ///////SE CREA TABLA TEMPORAL /////////////////////////////////////////////	
				DECLARE @TBL_KIT_A_PROGRAMAR  TABLE (
						K_KIT_A_PROGRAMAR	INT IDENTITY(1,1),
						KIT					VARCHAR(50),
						ITEM_NO				VARCHAR(100),
						CANTIDAD			INT
					)
				SET NOCOUNT ON
								
				DECLARE @VP_POSICION_KIT		INT
				DECLARE @VP_POSICION_CANTIDAD	INT
				DECLARE @VP_KIT_VALOR			VARCHAR(20)
				DECLARE @VP_CANTIDAD_VALOR		VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_KIT_ARRAY		= @PP_KIT_ARRAY		+ '/'		
				SET	@PP_CANTIDAD_ARRAY	= @PP_CANTIDAD_ARRAY	+ '/'		
				
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_KIT_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_KIT			=	patindex('%/%' , @PP_KIT_ARRAY)
						SELECT @VP_POSICION_CANTIDAD	=	patindex('%/%' , @PP_CANTIDAD_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_KIT_VALOR		= LEFT(@PP_KIT_ARRAY, @VP_POSICION_KIT - 1)
						SELECT @VP_CANTIDAD_VALOR	= LEFT(@PP_CANTIDAD_ARRAY, @VP_POSICION_CANTIDAD - 1)

						-- /////////INSERTAMOS LA PIEL EN UNA TABLA TEMPORAL////////////////////////////////////////////////////////////
						INSERT	INTO	@TBL_KIT_A_PROGRAMAR
								VALUES	( 
											@VP_KIT_VALOR,
											(@VP_KIT_VALOR + @VP_COLOR_SIN_F),
											@VP_CANTIDAD_VALOR
											)

						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_KIT_ARRAY	= STUFF(@PP_KIT_ARRAY, 1, @VP_POSICION_KIT, '')
						SELECT @PP_CANTIDAD_ARRAY	= STUFF(@PP_CANTIDAD_ARRAY, 1, @VP_POSICION_CANTIDAD, '')
					END
			
				-- ///////SE VALIDA QUE EXISTA REGISTROS EN LA TABLA TEMPORAL///////////////////////////////////////////////////////
				DECLARE @VP_N_KIT_A_PROGRAMAR INT = 0
				SELECT @VP_N_KIT_A_PROGRAMAR = COUNT(K_KIT_A_PROGRAMAR)
				FROM @TBL_KIT_A_PROGRAMAR

				IF @VP_N_KIT_A_PROGRAMAR IS NULL OR @VP_N_KIT_A_PROGRAMAR = 0
					RAISERROR ('ERROR: No hay Kits para programar.', 16, 1 ) --MENSAJE - Severity -State.

				-- //////SE DECLARAN VARIABLES A USARSE/////////////////////////////////////
				DECLARE @VP_KIT VARCHAR(50) = '', @VP_ITEM_NO VARCHAR(100) = '', @VP_CANTIDAD INT = 0 ;
				DECLARE @VP_GROSS DECIMAL(16,4) = 0, @VP_NETO DECIMAL(16,4) = 0, @VP_PATRON INT = 0;
				DECLARE @VP_TOTAL_GROSS DECIMAL(16,4) = 0, @VP_TOTAL_NETO DECIMAL(16,4) = 0, @VP_TOTAL_PATRON INT = 0;
				DECLARE @VP_CONSECUTIVO INT = 1, @VP_NUMERO_RELOJ INT = 0;

				-- //////SE OBTIENE EL NUMERO DE RELOJ DEL USUARIO PEARL/////////////////////////////////////
				SELECT @VP_NUMERO_RELOJ = K_EMPLEADO_PEARL				
				FROM BD_GENERAL.DBO.USUARIO_PEARL  (NOLOCK)
				WHERE K_USUARIO_PEARL = @PP_K_USUARIO_ACCION

				-- //////SE CREA CURSOR PARA DARLE FORMATO A LOS DATOS/////////////////////////////////////
				DECLARE CU_KIT_A_PROGRAMAR CURSOR 
				FOR SELECT	KIT, ITEM_NO, CANTIDAD
					FROM	@TBL_KIT_A_PROGRAMAR

				OPEN CU_KIT_A_PROGRAMAR
				FETCH NEXT FROM CU_KIT_A_PROGRAMAR INTO @VP_KIT, @VP_ITEM_NO, @VP_CANTIDAD

				WHILE @@FETCH_STATUS = 0
					BEGIN
						DECLARE @VP_CUBE_LENGTH DECIMAL(13,4) = 0, @VP_CUBE_WIDTH DECIMAL(13,4) = 0, @VP_CUBE_QTY_PER DECIMAL(13,4) = 0;
						DECLARE @VP_D_ITEM	VARCHAR(255), @VP_CHANGE_LEVEL	VARCHAR(100), @VP_MODELO	VARCHAR(50), @VP_VERSION VARCHAR(50);
						DECLARE @VP_SERIAL VARCHAR(50) = ''

						-- ////////SE OBTIENE EL MODELO Y ULTIMA VERSION DEL KIT///////////////////////////////////
						SELECT	DISTINCT TOP (1) PERCENT 
							 @VP_VERSION = ccverhdr_sql.versionno, 
							 @VP_MODELO = ccverhdr_sql.modelno
						FROM	dbo.ccverhdr_sql (NOLOCK)
						INNER JOIN cccusitm_sql (NOLOCK) ON CONCAT(ccverhdr_sql.modelno, ccverhdr_sql.versionno ) = CONCAT(cccusitm_sql.modelno, cccusitm_sql.versionno ) 
							AND SUBSTRING(LTRIM(RTRIM(cccusitm_sql.item_no)) ,1 ,1)  = 'P' 
							AND cus_item_no <> ''
						INNER JOIN IMITMIDX_SQL (NOLOCK) ON IMITMIDX_SQL.item_no = cccusitm_sql.item_no
						INNER JOIN  IMCATFIL_SQL (NOLOCK) ON dbo.IMITMIDX_SQL.prod_cat = IMCATFIL_SQL.prod_cat 
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
								@VP_D_ITEM				= LTRIM(RTRIM(item_desc_1))--,
								--@VP_CHANGE_LEVEL		= LTRIM(RTRIM(Last_item_revision))
						FROM IMITMIDX_SQL   (NOLOCK)
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
												
						-- ////////SE OBTIENE EL STANDARD PACK DEL KIT///////////////////////////////////
						DECLARE @VP_STD_PACK INT = 0
						SELECT	TOP(1) 
								@VP_STD_PACK = user_def_fld_5 
						FROM ccitmidx_sql (NOLOCK)
						WHERE LTRIM(RTRIM(item_no)) = @VP_ITEM_NO
						ORDER BY versionno DESC
						
						IF @VP_STD_PACK IS NULL
							RAISERROR ('ERROR: No fue posible obtener el Estandar Pack en [ccitmidx_sql]', 16, 1 ) --MENSAJE - Severity -State.

						-- //////SE INGRESAN LOS KITS EN LA TABLA ccjoblin_sql/////////////////////////////////////
						IF @VP_CANTIDAD > @VP_STD_PACK
							BEGIN
								WHILE  @VP_CANTIDAD > 0
									BEGIN
										IF @VP_CANTIDAD > @VP_STD_PACK
											BEGIN
												INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
																			netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	
																		)
																VALUES(		@VP_ORDEN, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO, @VP_STD_PACK, @VP_STD_PACK, 0,
																			@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO
																		)
												
												IF @@ROWCOUNT = 0
													RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.
											END
										ELSE
											BEGIN
												INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
																			netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	)
																VALUES(		@VP_ORDEN, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO, @VP_CANTIDAD, @VP_CANTIDAD, 0,
																			@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO	)
												
												IF @@ROWCOUNT = 0
													RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.
											END

										-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
										SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 
									
										EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						10, @VP_SERIAL, @VP_ITEM_NO,
																						'MATERIALES', @PP_COMPUTER_NAME, @VP_NUMERO_RELOJ, ''
										
										-- ///////SE RESTA DEL STADANDARD PACK LO INGRESADO Y SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
										SET @VP_CANTIDAD = @VP_CANTIDAD - @VP_STD_PACK
										SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
									END
							END
						ELSE
							BEGIN
								INSERT INTO	ccjoblin_sql(	jobno, kit, kitdesc,item_no, PlannedQty, OriginalQty, CompletedQty, 
															netsqmper, stdsqmper, patternsper, customer, ChangeLevel, Ser_no	)
												VALUES(		@VP_ORDEN, @VP_KIT, @VP_D_ITEM, @VP_ITEM_NO, @VP_CANTIDAD, @VP_CANTIDAD, 0,
															@VP_CUBE_WIDTH, @VP_CUBE_LENGTH, @VP_CUBE_QTY_PER, @PP_CLIENTE, @VP_CHANGE_LEVEL, @VP_CONSECUTIVO	)
								
								IF @@ROWCOUNT = 0
									RAISERROR ('ERROR: No fue posible agregar el kit a la orden en [ccjoblin_sql]', 16, 1 ) --MENSAJE - Severity -State.

								-- ///////SE GUARDA EL REGISTRO DEL MATERIAL ESCANEADO//////////////////////////////////////////////
								SET @VP_SERIAL  = @VP_ORDEN + RIGHT('000'+ CONVERT(VARCHAR(10), @VP_CONSECUTIVO), 3) 
								
								EXECUTE [dbo].[PG_IN_MATERIAL_PROGRAMADO_LOG]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				10, @VP_SERIAL, @VP_ITEM_NO,
																				'MATERIALES', @PP_COMPUTER_NAME, @VP_NUMERO_RELOJ, ''
										
								-- ///////SE AUMENTA EL CONSECUTIVO//////////////////////////////////////////////
								SET @VP_CONSECUTIVO = @VP_CONSECUTIVO + 1
							END
						
						FETCH NEXT FROM CU_KIT_A_PROGRAMAR INTO @VP_KIT, @VP_ITEM_NO, @VP_CANTIDAD
					END
				
				CLOSE CU_KIT_A_PROGRAMAR
				DEALLOCATE CU_KIT_A_PROGRAMAR

				-- ///////SE INGRESA EL REGISTRO DE LA ORDEN EN CCJOBHDR_SQL//////////////////////////////////////////////
				INSERT INTO CCJOBHDR_SQL (	jobno, status, colour, colourdesc, machine, datecreated, dateplanned,
											printedflag, instruct1, instruct2, netsqm, standardsqm, targetutil,
											customer, patterns, plannedshift, plannedseq, startedflag, comments, lotno	)
                                  VALUES (	@VP_ORDEN, 'P', @VP_COLOR_SIN_F, @VP_D_COLOR, @PP_MESA, @VP_FECHA, @VP_FECHA, 
											'2', @PP_COMENTARIO, '', @VP_TOTAL_NETO, @VP_TOTAL_GROSS, @VP_UTILIDAD_MINIMA, 
											@PP_CLIENTE, @VP_TOTAL_PATRON, @VP_TURNO, '0', '', @PP_COMENTARIO, '' ) --, @PP_ORDEN_2_TONO	)

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible agregar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

				-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
				DECLARE @VP_DETAIL VARCHAR(100) = 'Creacion de Orden: ' + @VP_ORDEN
				EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_USER, @PP_COMPUTER_NAME, 'Planning',
													@VP_ORDEN, 'Crear orden',
													@VP_DETAIL, ''
			
			-- ///////SE VERIFICA SI LA ORDEN CREADA TIENE KITS (U) DOS TODOS//////////////////////////////////////////////
			DECLARE @VP_N_KITS_U INT = 0
			SELECT @VP_N_KITS_U = COUNT(A4GLIdentity) 
			FROM imkitfil_sql (NOLOCK)
			WHERE comp_item_no IN ( SELECT item_no 
									FROM ccjoblin_sql 
									WHERE JOBNO = @VP_ORDEN )
			
			IF @VP_N_KITS_U IS NULL
				SET @VP_N_KITS_U = 0

			-- ///////SE SI EXISTEN KITS (U) DOS TONOS SE GENERA LA ORDEN COMPLEMENTO//////////////////////////////////////////////
			IF @VP_N_KITS_U > 0
				EXECUTE [dbo].[PG_PR_PLANNING_CREAR_ORDER_2_TONO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@VP_ORDEN, @PP_CLIENTE, @PP_MESA, 
																	@PP_COMENTARIO, @PP_USER, @PP_COMPUTER_NAME

			-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_PR_PLANNING_CREAR_ORDER] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Crear la Orden: ' + '[' + @VP_ORDEN +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_ORDEN AS CLAVE
	
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
													0, 0, @VP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
