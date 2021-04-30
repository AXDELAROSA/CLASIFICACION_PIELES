-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	01/MAR/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IMPRIMIR_PIEL_IMPORTADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IMPRIMIR_PIEL_IMPORTADA]
GO
/*
EXECUTE  [dbo].[PG_IMPRIMIR_PIEL_IMPORTADA]	0,0,   '210226073445T1000001' 
*/
CREATE PROCEDURE [dbo].[PG_IMPRIMIR_PIEL_IMPORTADA]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	-- ////////SE OBTIENE LA LOCACION DONDE SE ENCUENTRAN LAS PIELES DEL TICKET IMPORTADO///////////////////////////////////
	DECLARE @VP_LOCACION VARCHAR(5) = ''
	
	SELECT @VP_LOCACION = LTRIM(RTRIM([STATUS]))
	FROM HIDESHDR_SQL 
	WHERE FILENO = @PP_FILE_NO

	IF @VP_LOCACION = 'MIT'
		SET @VP_MENSAJE = 'El Ticket se encuentra en MIT.'

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE ACTUALIZA EL CAMPO PRINTED EN HIDESLIN_SQL PARA QUE YA NO SE PUEDA IMPRIMIR TODO EL TICKET//////////////////////////////////////////////
				UPDATE HIDESLIN_SQL 
					SET printed = 1 
				WHERE FILENO = @PP_FILE_NO 

				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible Actualizar la piel en [HIDESLIN_SQL].', 16, 1 ) --MENSAJE - Severity -State.   
				
				-- ///////SE OBTIENEN VALORES REQUERIDOS PARA EL LOG DE REIMPRESION DE LA PIEL//////////////////////////////////////////////
				DECLARE @VP_PCOLOR		VARCHAR(50) = ''
				DECLARE @VP_PLOT		VARCHAR(50) = ''
				DECLARE @VP_TOTAL_PIEL	VARCHAR(50) = ''
				DECLARE @VP_TOTAL_SQF	VARCHAR(50) = ''

				SELECT	@VP_PCOLOR = LTRIM(RTRIM(PCOLOR)),
						@VP_PLOT = LTRIM(RTRIM(PLOT)),
						@VP_TOTAL_PIEL = LTRIM(RTRIM(THIDES)),
						@VP_TOTAL_SQF = LTRIM(RTRIM(TAREA))
				FROM HIDESHDR_SQL 
				WHERE 	FILENO = @PP_FILE_NO						

				-- /////SE INGRESA EL LOG DE LA IMPRESION DEL TICKET////////////////////////////////////////////////
				INSERT INTO PIEL_LOG (	[K_TIPO_PIEL_LOG], [COLOR], [LOTE],	[PIEL], [SQF], 
										[FOLIO_ORIGEN], [LOCACION_ORIGEN], [FOLIO_DESTINO], [LOCACION_DESTINO], [F_LOG],
										[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO], [L_BORRADO]
									) 
							VALUES (	13, @VP_PCOLOR, @VP_PLOT, @VP_TOTAL_PIEL, @VP_TOTAL_SQF, 
										0, 'MHI', 0, '', GETDATE(), 
										@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(), 0
									)

				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible agregar el log de la piel en [PIEL_LOG].', 16, 1 ) --MENSAJE - Severity -State.   	
				-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_IMPRIMIR_PIEL_IMPORTADA] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Imprimir el Ticket: ' + '[' + @PP_FILE_NO +'] ' + @VP_MENSAJE 
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
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_REIMPRIMIR_PIEL_IMPORTADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_REIMPRIMIR_PIEL_IMPORTADA]
GO
/*
EXECUTE  [dbo].[PG_REIMPRIMIR_PIEL_IMPORTADA]	0,0,   '210226073445T1000001' , '107612' , '0724' 
*/
CREATE PROCEDURE [dbo].[PG_REIMPRIMIR_PIEL_IMPORTADA]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50),
	@PP_LOTE								VARCHAR(20),
	@PP_PIEL								VARCHAR(20)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	EXECUTE [dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]			@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_FILE_NO, @PP_LOTE, @PP_PIEL,
															@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				-- ///////SE OBTIENE EL SQF ORIGINAL DE LA PIEL//////////////////////////////////////////////
				DECLARE @VP_SQF_ORIGINAL DECIMAL(13,2) = 0
				SELECT	@VP_SQF_ORIGINAL = SQF
				FROM	HIDESLIN_SQL
				WHERE	FILENO = @PP_FILE_NO
				AND		HIDE = @PP_PIEL

				IF @VP_SQF_ORIGINAL IS NULL
					SET @VP_SQF_ORIGINAL = 0

				-- ///////SE OBTIENE EL SQF CORTADO DE LA PIEL//////////////////////////////////////////////
				DECLARE @VP_SQF_CORTADO	DECIMAL(13,2) = 0
				SELECT	@VP_SQF_CORTADO = SUM(hidesqm) 
				FROM	cccuthst_sql 
				WHERE	LTRIM(RTRIM(lotno)) = RIGHT( '000000' + @PP_LOTE, 6)
				AND	hideno = @PP_PIEL

				IF @VP_SQF_CORTADO IS NULL
					SET @VP_SQF_CORTADO = 0
				
				-- /////SE OBTIENE EL SQF ACTUAL DE LA PIEL////////////////////////////////////////////////
				SET @VP_SQF_ORIGINAL = @VP_SQF_ORIGINAL - @VP_SQF_CORTADO

				-- ///////SE VALIDA SI YA SE IMPRIMIO LA ETIQUETA//////////////////////////////////////////////
				DECLARE @VP_N_IMPRESION			INT = 0
				SELECT	@VP_N_IMPRESION = COUNT(ID)
				FROM	HIDESLIN_SQL
				WHERE	FILENO = @PP_FILE_NO
				AND		HIDE = @PP_PIEL
				AND		PRINTED = 1

				IF @VP_N_IMPRESION IS NULL
					SET @VP_N_IMPRESION = 0

				IF @VP_N_IMPRESION > 0
					BEGIN
					-- ///////SE OBTIENEN VALORES REQUERIDOS PARA EL LOG DE REIMPRESION DE LA PIEL//////////////////////////////////////////////
						DECLARE @VP_PCOLOR VARCHAR(50) = ''
						SELECT	@VP_PCOLOR = LTRIM(RTRIM(PCOLOR)) 
						FROM HIDESHDR_SQL 
						WHERE 	FILENO = @PP_FILE_NO						

						-- /////SE INGRESA EL LOG DE LA REIMPRESION DE LA ETIQUETA DE LA PIEL////////////////////////////////////////////////
						INSERT INTO PIEL_LOG (	[K_TIPO_PIEL_LOG], [COLOR], [LOTE],	[PIEL], [SQF], 
												[FOLIO_ORIGEN], [LOCACION_ORIGEN], [FOLIO_DESTINO], [LOCACION_DESTINO], [F_LOG],
												[K_USUARIO_ALTA], [F_ALTA], [K_USUARIO_CAMBIO], [F_CAMBIO], [L_BORRADO]
											) 
									VALUES (	8, @VP_PCOLOR, @PP_LOTE, @PP_PIEL, @VP_SQF_ORIGINAL, 
												0, '', 0, '', GETDATE(), 
												@PP_K_USUARIO_ACCION, GETDATE(), @PP_K_USUARIO_ACCION, GETDATE(), 0
											)

						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible agregar el log de la piel en [PIEL_LOG].', 16, 1 ) --MENSAJE - Severity -State.   

					END
				ELSE
					BEGIN
						UPDATE HIDESLIN_SQL 
							SET printed = 1 
						WHERE FILENO = @PP_FILE_NO 
						AND hide= @PP_PIEL

						IF @@ROWCOUNT = 0
							RAISERROR ('NO fue posible Actualizar la piel en [HIDESLIN_SQL].', 16, 1 ) --MENSAJE - Severity -State.   
					END
					
				-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_REIMPRIMIR_PIEL_IMPORTADA] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Imprimir la piel: ' + '[' + @PP_PIEL +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_SQF_ORIGINAL AS CLAVE
	
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
