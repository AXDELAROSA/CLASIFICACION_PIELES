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

USE [DATA_02Pruebas] 
GO

-- //////////////////////////////////////////////////////////////
 --DROP TYPE dbo.TBL_PIEL_A_TRANSFERIR
 --IF (	SELECT COUNT(*) FROM sys.table_types
	--						WHERE name = 'TBL_PIEL_A_TRANSFERIR' AND schema_id = 1	) = 0
	--						CREATE TYPE dbo.TBL_PIEL_A_TRANSFERIR AS TABLE(	FOLIO		INT,
	--																		COLOR		VARCHAR(20),
	--																		LOTE		VARCHAR(20),
	--																		PIEL		VARCHAR(20),
	--																		SQF			VARCHAR(20)	)

-- //////////////////////////////////////////////////////////////

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_FOLIO]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_TRANSFERENCIA		VARCHAR(50),
	@PP_CB_COLOR				VARCHAR(20),
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_TAGNO_DESTINO			INT,
	-- ===========================
	@PP_LOCACION_ORIGEN			VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(10),
	-- ===========================
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_ORDEN_DESTINO			VARCHAR(10),
	-- ===========================
	--@TBL_PIEL_A_TRANFERIR		TBL_PIEL_A_TRANSFERIR READONLY
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX)
	-- ===========================
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
				DECLARE @VP_K_PIEL_A_TRANSFERIR_TRANSACCION		INT = 0
				EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																	'DATA_02Pruebas', 'PIEL_A_TRANSFERIR_TRANSACCION', 'K_PIEL_A_TRANSFERIR_TRANSACCION',
																	@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_A_TRANSFERIR_TRANSACCION	OUTPUT

				INSERT	INTO	[PIEL_A_TRANSFERIR_TRANSACCION] (
										[K_PIEL_A_TRANSFERIR_TRANSACCION],
										[TIPO_TRANSFERENCIA],
										-- ===========================	
										[FOLIO_ORIGEN],	[FOLIO_DESTINO],	
										-- ===========================	
										[LOCACION_ORIGEN], [LOCACION_DESTINO],	
										-- ===========================	
										[ORDEN_ORIGEN],	[ORDEN_DESTINO],		
										-- ===========================	
										[COLOR]	)
								VALUES	(
										@VP_K_PIEL_A_TRANSFERIR_TRANSACCION,
										@PP_TIPO_TRANSFERENCIA,
										-- ===========================	
										@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
										-- ===========================	
										@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO,
										-- ===========================	
										@PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
										-- ===========================	
										@PP_CB_COLOR)
				-- ==========================================
							
				DECLARE @VP_POSICION_PIEL			INT
				DECLARE @VP_POSICION_LOTE			INT
				DECLARE @VP_LOTE_VALOR				VARCHAR(20)
				DECLARE @VP_PIEL_VALOR				VARCHAR(20)
				DECLARE @VP_SQF_ORIGINAL			VARCHAR(20)
				DECLARE @VP_SQF_ENVIAR				VARCHAR(20)
				DECLARE @VP_SQF_RECIBIR				VARCHAR(20)	
				DECLARE @VP_SQF_CORTADO				DECIMAL(13,2)	= 0.00		
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_LOTE_ARRAY			= @PP_LOTE_ARRAY		+ '/'		
				SET	@PP_PIEL_ARRAY			= @PP_PIEL_ARRAY		+ '/'		
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_PIEL_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_PIEL	=	patindex('%/%' , @PP_PIEL_ARRAY)
						SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_PIEL_VALOR		= LEFT(@PP_PIEL_ARRAY, @VP_POSICION_PIEL - 1)
						SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION_LOTE - 1)
						
						SELECT @VP_SQF_ORIGINAL = ISNULL(SQF,'0.00') 
						FROM HIDESHDR_SQL   
						INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						AND	LTRIM(RTRIM(PLOT)) = @VP_LOTE_VALOR
						AND LTRIM(RTRIM(HIDE)) =  @VP_PIEL_VALOR

						SELECT	TOP 1 @VP_SQF_ENVIAR = LTRIM(RTRIM(SQF))
												FROM	RP_SC 
												WHERE	LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR 
												AND		LTRIM(RTRIM(TAGNO)) = @PP_TAGNO_ORIGEN
												AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_VALOR
												AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_VALOR
						
						SET @VP_SQF_RECIBIR = @VP_SQF_ENVIAR

						SELECT @VP_SQF_CORTADO = SUM(HIDESQM)
						FROM cccuthst_sql 
						WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR   
						AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_VALOR)), 6) 
						AND LTRIM(RTRIM(hideno))   = @VP_PIEL_VALOR

						IF @VP_SQF_CORTADO IS NULL
							SET @VP_SQF_CORTADO = 0.00

						IF @VP_SQF_CORTADO > 0
							BEGIN
								
								SET @VP_SQF_RECIBIR = CONVERT(DECIMAL(13,2),@VP_SQF_ORIGINAL) - @VP_SQF_CORTADO

								IF CONVERT(DECIMAL(13,2),@VP_SQF_RECIBIR) <= 0 
									BEGIN
										DECLARE @VP_MENSAJE_PIEL_CORTADA VARCHAR(255)= @VP_PIEL_VALOR + ' CORTADA COMPLETA.'
										RAISERROR (@VP_MENSAJE_PIEL_CORTADA, 16, 1 ) --MENSAJE - Severity -State.
									END
							END

						INSERT	INTO	[PIEL_A_TRANSFERIR] (
										[K_PIEL_A_TRANSFERIR_TRANSACCION],
										[TIPO_TRANSFERENCIA],
										-- ===========================	
										[FOLIO_ORIGEN],	[FOLIO_DESTINO],	
										-- ===========================	
										[LOCACION_ORIGEN], [LOCACION_DESTINO],	
										-- ===========================	
										[ORDEN_ORIGEN],	[ORDEN_DESTINO],		
										-- ===========================	
										[COLOR], [LOTE], [PIEL], [SQF_ORIGINAL],
										[SQF_ENVIAR], [SQF_CORTADO], [SQF_RECIBIR],
										-- ===========================	
										[K_USUARIO_ALTA], [F_ALTA],	
										[K_USUARIO_CAMBIO],	[F_CAMBIO],
										[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]	)	
								VALUES	(
										@VP_K_PIEL_A_TRANSFERIR_TRANSACCION,
										@PP_TIPO_TRANSFERENCIA,
										-- ===========================	
										@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
										-- ===========================	
										@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO,
										-- ===========================	
										@PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
										-- ===========================	
										@PP_CB_COLOR, @VP_LOTE_VALOR, @VP_PIEL_VALOR, @VP_SQF_ORIGINAL,
										@VP_SQF_ENVIAR, CONVERT(VARCHAR(10),@VP_SQF_CORTADO), @VP_SQF_RECIBIR,
										-- ===========================				
										@PP_K_USUARIO_ACCION, GETDATE(), 
										@PP_K_USUARIO_ACCION, GETDATE(),
										0, NULL, NULL	)
																								
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_PIEL_ARRAY	= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
						SELECT @PP_LOTE_ARRAY	= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')

					END
					-- /////////////////////////////////////////////////////////////////////
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				--SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE =  ERROR_MESSAGE() 
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Transferir el [FOLIO]: ' + CONVERT(VARCHAR(15),@PP_TAGNO_ORIGEN) + ' Piel:' + @VP_MENSAJE 
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
		END
	ELSE
		BEGIN
			SELECT [PIEL_A_TRANSFERIR].* , usuario
			FROM [PIEL_A_TRANSFERIR]
			INNER JOIN	users_pearl ON [PIEL_A_TRANSFERIR].K_USUARIO_ALTA = users_pearl.codigo
			WHERE	[TIPO_TRANSFERENCIA] =		@PP_TIPO_TRANSFERENCIA
			AND		[FOLIO_ORIGEN]		=		@PP_TAGNO_ORIGEN
			AND		[FOLIO_DESTINO]		= 		@PP_TAGNO_DESTINO
			AND		[LOCACION_ORIGEN]	=		@PP_LOCACION_ORIGEN
			AND		[LOCACION_DESTINO]	=		@PP_LOCACION_DESTINO
			AND		[ORDEN_ORIGEN]		=		@PP_ORDEN_ORIGEN
			AND		[ORDEN_DESTINO]		=		@PP_ORDEN_DESTINO
			AND		[COLOR]				=		@PP_CB_COLOR
			AND		[K_USUARIO_ALTA]    =		@PP_K_USUARIO_ACCION
			AND		[K_PIEL_A_TRANSFERIR_TRANSACCION] = @VP_K_PIEL_A_TRANSFERIR_TRANSACCION
		END
	
	
	
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
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA_X_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_TRANSFERENCIA		VARCHAR(50),
	@PP_CB_COLOR				VARCHAR(20),
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_TAGNO_DESTINO			INT,
	-- ===========================
	@PP_LOCACION_ORIGEN			VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(10),
	-- ===========================
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_ORDEN_DESTINO			VARCHAR(10)
	-- ===========================
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DECLARE @VP_K_PIEL_A_TRANSFERIR_TRANSACCION		INT = 0
				EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																	'DATA_02Pruebas', 'PIEL_A_TRANSFERIR_TRANSACCION', 'K_PIEL_A_TRANSFERIR_TRANSACCION',
																	@OU_K_TABLA_DISPONIBLE = @VP_K_PIEL_A_TRANSFERIR_TRANSACCION	OUTPUT

				INSERT	INTO	[PIEL_A_TRANSFERIR_TRANSACCION] (
										[K_PIEL_A_TRANSFERIR_TRANSACCION],
										[TIPO_TRANSFERENCIA],
										-- ===========================	
										[FOLIO_ORIGEN],	[FOLIO_DESTINO],	
										-- ===========================	
										[LOCACION_ORIGEN], [LOCACION_DESTINO],	
										-- ===========================	
										[ORDEN_ORIGEN],	[ORDEN_DESTINO],		
										-- ===========================	
										[COLOR]	)
								VALUES	(
										@VP_K_PIEL_A_TRANSFERIR_TRANSACCION,
										@PP_TIPO_TRANSFERENCIA,
										-- ===========================	
										@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
										-- ===========================	
										@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO,
										-- ===========================	
										@PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
										-- ===========================	
										@PP_CB_COLOR)
				-- ==========================================

				DECLARE @VP_SQF_ORIGINAL			VARCHAR(20)
				DECLARE @VP_SQF_ENVIAR				VARCHAR(20)
				DECLARE @VP_SQF_RECIBIR				VARCHAR(20)	
				DECLARE @VP_SQF_CORTADO				DECIMAL(13,2)	= 0.00		
				
				DECLARE @VP_COLOR_TBL	VARCHAR(10)
				DECLARE @VP_LOTE_TBL	VARCHAR(10)
				DECLARE @VP_PIEL_TBL	VARCHAR(10)

						
				DECLARE CU_PIEL_SELECCIONADA CURSOR 
				FOR SELECT	LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), LTRIM(RTRIM(HIDE)), ISNULL(LTRIM(RTRIM(SQF)),'0.00')
					FROM	RP_SC
					WHERE	LTRIM(RTRIM(COLOUR))	= @PP_CB_COLOR
					AND		LTRIM(RTRIM(TAGNO))		= @PP_TAGNO_ORIGEN
						
				OPEN CU_PIEL_SELECCIONADA
				FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_ENVIAR
				
				WHILE @@FETCH_STATUS = 0
					BEGIN

						SELECT @VP_SQF_ORIGINAL = ISNULL(SQF,'0.00') 
						FROM HIDESHDR_SQL   
						INNER JOIN HIDESLIN_SQL ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
						AND	LTRIM(RTRIM(PLOT)) = @VP_LOTE_TBL
						AND LTRIM(RTRIM(HIDE)) =  @VP_PIEL_TBL
						
						SET @VP_SQF_RECIBIR = @VP_SQF_ENVIAR
						
						SELECT @VP_SQF_CORTADO = SUM(HIDESQM)
						FROM cccuthst_sql 
						WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR   
						AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_TBL)), 6) 
						AND LTRIM(RTRIM(hideno))   = @VP_PIEL_TBL

						IF @VP_SQF_CORTADO IS NULL
							SET @VP_SQF_CORTADO = 0.00

						IF @VP_SQF_CORTADO > 0
							BEGIN
								SET @VP_SQF_RECIBIR = CONVERT(DECIMAL(13,2),@VP_SQF_ORIGINAL) - @VP_SQF_CORTADO

								IF CONVERT(DECIMAL(13,2),@VP_SQF_RECIBIR) <= 0 
									BEGIN
										DECLARE @VP_MENSAJE_PIEL_CORTADA VARCHAR(255)= @VP_PIEL_TBL + ' CORTADA COMPLETA.'
										RAISERROR (@VP_MENSAJE_PIEL_CORTADA, 16, 1 ) --MENSAJE - Severity -State.
									END
							END

						INSERT	INTO	[PIEL_A_TRANSFERIR] (
										[K_PIEL_A_TRANSFERIR_TRANSACCION],
										[TIPO_TRANSFERENCIA],
										-- ===========================	
										[FOLIO_ORIGEN],	[FOLIO_DESTINO],	
										-- ===========================	
										[LOCACION_ORIGEN], [LOCACION_DESTINO],	
										-- ===========================	
										[ORDEN_ORIGEN],	[ORDEN_DESTINO],		
										-- ===========================	
										[COLOR], [LOTE], [PIEL], [SQF_ORIGINAL],
										[SQF_ENVIAR], [SQF_CORTADO], [SQF_RECIBIR],
										-- ===========================	
										[K_USUARIO_ALTA], [F_ALTA],	
										[K_USUARIO_CAMBIO],	[F_CAMBIO],
										[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]	)	
								VALUES	(
										@VP_K_PIEL_A_TRANSFERIR_TRANSACCION,
										@PP_TIPO_TRANSFERENCIA,
										-- ===========================	
										@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
										-- ===========================	
										@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO,
										-- ===========================	
										@PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
										-- ===========================	
										@PP_CB_COLOR, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_ORIGINAL,
										@VP_SQF_ENVIAR, CONVERT(VARCHAR(10),@VP_SQF_CORTADO), @VP_SQF_RECIBIR,
										-- ===========================				
										@PP_K_USUARIO_ACCION, GETDATE(), 
										@PP_K_USUARIO_ACCION, GETDATE(),
										0, NULL, NULL	)
																								
					FETCH NEXT FROM CU_PIEL_SELECCIONADA INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_PIEL_TBL, @VP_SQF_ENVIAR
	
				END
	
			CLOSE CU_PIEL_SELECCIONADA
			DEALLOCATE CU_PIEL_SELECCIONADA
			-- /////////////////////////////////////////////////////////////////////
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				--SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE =  ERROR_MESSAGE() 
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Transferir el [FOLIO]: ' + CONVERT(VARCHAR(15),@PP_TAGNO_ORIGEN) + ' Piel:' + @VP_MENSAJE 
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
		END
	ELSE
		BEGIN
			SELECT [PIEL_A_TRANSFERIR].* , usuario
			FROM [PIEL_A_TRANSFERIR]
			INNER JOIN	users_pearl ON [PIEL_A_TRANSFERIR].K_USUARIO_ALTA = users_pearl.codigo
			WHERE	[TIPO_TRANSFERENCIA] =		@PP_TIPO_TRANSFERENCIA
			AND		[FOLIO_ORIGEN]		=		@PP_TAGNO_ORIGEN
			AND		[FOLIO_DESTINO]		= 		@PP_TAGNO_DESTINO
			AND		[LOCACION_ORIGEN]	=		@PP_LOCACION_ORIGEN
			AND		[LOCACION_DESTINO]	=		@PP_LOCACION_DESTINO
			AND		[ORDEN_ORIGEN]		=		@PP_ORDEN_ORIGEN
			AND		[ORDEN_DESTINO]		=		@PP_ORDEN_DESTINO
			AND		[COLOR]				=		@PP_CB_COLOR
			AND		[K_USUARIO_ALTA]    =		@PP_K_USUARIO_ACCION
			AND		[K_PIEL_A_TRANSFERIR_TRANSACCION] = @VP_K_PIEL_A_TRANSFERIR_TRANSACCION
		END
	
	
	
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
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_PIEL_A_TRANSFERIR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_PIEL_A_TRANSFERIR]
GO


CREATE PROCEDURE [dbo].[PG_DL_PIEL_A_TRANSFERIR]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_K_PIEL_A_TRANSFERIR_TRANSACCION		INT,
	@PP_TIPO_TRANSFERENCIA					VARCHAR(50),
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
	@PP_USER_NAME							VARCHAR(20)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	
	IF @VP_MENSAJE=''

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR

	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY

				DELETE	PIEL_A_TRANSFERIR
				WHERE	K_PIEL_A_TRANSFERIR_TRANSACCION = @PP_K_PIEL_A_TRANSFERIR_TRANSACCION
				AND		[TIPO_TRANSFERENCIA] =		@PP_TIPO_TRANSFERENCIA
				AND		[FOLIO_ORIGEN]		=		@PP_TAGNO_ORIGEN
				AND		[FOLIO_DESTINO]		= 		@PP_TAGNO_DESTINO
				AND		[LOCACION_ORIGEN]	=		@PP_LOCACION_ORIGEN
				AND		[LOCACION_DESTINO]	=		@PP_LOCACION_DESTINO
				AND		[ORDEN_ORIGEN]		=		@PP_ORDEN_ORIGEN
				AND		[ORDEN_DESTINO]		=		@PP_ORDEN_DESTINO
				AND		[COLOR]				=		@PP_CB_COLOR
				AND		[K_USUARIO_ALTA]    =		@PP_K_USUARIO_ACCION
				
				IF @@ROWCOUNT = 0
					BEGIN
						DECLARE @VP_MENSAJE_TRANSACCION VARCHAR(255)= CONVERT(VARCHAR(10), @PP_K_PIEL_A_TRANSFERIR_TRANSACCION)
						RAISERROR (@VP_MENSAJE_TRANSACCION, 16, 1 ) --MENSAJE - Severity -State.
					END

				COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				--SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE =  ERROR_MESSAGE() 


				DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx'
				DECLARE @VP_SUBJECT		VARCHAR(255) = 'Error al cancelar Transferencia...'
				DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)
				DECLARE @VP_BODY		NVARCHAR(MAX) 
				
				SET @VP_BODY =  N'<table  border="1" align="center" cellspacing="0">' + 
									N'<thead>' + 
									  N'<tr BGCOLOR="#ADD8E6">' + 
									    N'<th colspan="10">Se ha producido un error en la Transaccion... </th>' + 
									  N'</tr>' + 
									  N'<tr BGCOLOR="#48D1CC">' + 
									    N'<th>Transaccion</th><th>Movimiento</th><th>Color</th><th>Folio Ori.</th><th>Folio Des.</th><th>Locacion Ori.</th><th>Locacion Des.</th><th>Orden Ori.</th><th>Orden Des.</th><th>Usuario</th>' + 
									  N'</tr>' + 
									N'</thead>' + 
									N'<tbody>' + 
									  N'<tr>' + 
									  N'<td>'+ CONVERT(VARCHAR(10),@PP_K_PIEL_A_TRANSFERIR_TRANSACCION) +'</td><td>'+ @PP_TIPO_TRANSFERENCIA +'</td><td>'+ @PP_CB_COLOR +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TAGNO_ORIGEN) +'</td><td>'+ CONVERT(VARCHAR(10),@PP_TAGNO_DESTINO) +'</td><td>'+ @PP_LOCACION_ORIGEN+'</td><td>'+ @PP_LOCACION_DESTINO +'</td><td>'+ @PP_ORDEN_ORIGEN +'</td><td>'+ @PP_ORDEN_DESTINO +'</td><td>'+ CONVERT(VARCHAR(10),@PP_USER_NAME) +'</td>' + 
									  N'</tr>' + 
									N'</tbody>' + 
								N'</table>' ;
					SET ROWCOUNT 0
					 				
				EXECUTE	BD_GENERAL.[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

			END CATCH
	END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'A ocurrido un error en la [Transaccion]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[Notifique a Sistemas]'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PIEL_A_TRANSFERIR_TRANSACCION AS CLAVE

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> DELETE / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_PIEL_A_TRANSFERIR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_PIEL_A_TRANSFERIR]
GO

CREATE PROCEDURE [dbo].[PG_GET_PIEL_A_TRANSFERIR]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_TIPO_TRANSFERENCIA					VARCHAR(50),
	@PP_CB_COLOR							VARCHAR(20),
	-- ===========================
	@PP_TAGNO_ORIGEN						INT,
	@PP_TAGNO_DESTINO						INT,
	-- ===========================
	@PP_LOCACION_ORIGEN						VARCHAR(10),
	@PP_LOCACION_DESTINO					VARCHAR(10),
	-- ===========================
	@PP_ORDEN_ORIGEN						VARCHAR(10),
	@PP_ORDEN_DESTINO						VARCHAR(10)
	-- ===========================
	--@PP_USER_NAME							VARCHAR(20)
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	
	IF @VP_MENSAJE=''

	-- // SECCION#2 ////////////////////////////////////////////////////////// ACCION A REALIZAR

	IF @VP_MENSAJE=''
		BEGIN
			SELECT [PIEL_A_TRANSFERIR].* , usuario
			FROM [PIEL_A_TRANSFERIR]
			INNER JOIN	users_pearl ON [PIEL_A_TRANSFERIR].K_USUARIO_ALTA = users_pearl.codigo
			WHERE	[TIPO_TRANSFERENCIA] =		@PP_TIPO_TRANSFERENCIA
			AND		[FOLIO_ORIGEN]		=		@PP_TAGNO_ORIGEN
			AND		[FOLIO_DESTINO]		= 		@PP_TAGNO_DESTINO
			AND		[LOCACION_ORIGEN]	=		@PP_LOCACION_ORIGEN
			AND		[LOCACION_DESTINO]	=		@PP_LOCACION_DESTINO
			AND		[ORDEN_ORIGEN]		=		@PP_ORDEN_ORIGEN
			AND		[ORDEN_DESTINO]		=		@PP_ORDEN_DESTINO
			AND		[COLOR]				=		@PP_CB_COLOR
			AND		[K_USUARIO_ALTA]    =		@PP_K_USUARIO_ACCION
		END
	-- //////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
