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
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDAR_PIEL_CORTADA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_EXISTENTE]	0,0,   'FOLIO_EXISTENTE' , 'B' , 'FMCKTX7' , 3785644 , 2137674 , 'T17' , 'MHI' , 
														'09404' , '' , 0 , 1 , '32641/32641/32641/59071/59071/59071' , 
														'0371/0333/0295/0258/0120/0152' , 0 , 0 , 0 , '' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_RN_VALIDAR_PIEL_CORTADA]
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
					
				DECLARE @VP_POSICION_PIEL			INT
				DECLARE @VP_POSICION_LOTE			INT

				DECLARE @VP_LOTE_VALOR				VARCHAR(20)
				DECLARE @VP_PIEL_VALOR				VARCHAR(20)
				DECLARE @VP_SQF_VALOR				VARCHAR(20)
								
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
						
						SELECT	TOP 1 @VP_SQF_VALOR = LTRIM(RTRIM(SQF))
												FROM	RP_SC 
												WHERE	LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR 
												AND		LTRIM(RTRIM(TAGNO)) = @PP_TAGNO_ORIGEN
												AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_VALOR
												AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_VALOR
						
						--IF @PP_TIPO_TRANSFERENCIA = 'DEVOLUCION' AND SUBSTRING(@PP_LOCACION_ORIGEN,1,1) = 'T'
						--	BEGIN
								IF  EXISTS (	SELECT JOBNO 
												FROM cccuthst_sql 
												WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR   
												AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_VALOR)), 6) 
												AND LTRIM(RTRIM(hideno))   = @VP_PIEL_VALOR
												)
									BEGIN
										DECLARE @VP_SQF_CORTADO DECIMAL(13,2)
										SELECT @VP_SQF_CORTADO = SUM(HIDESQM)
												FROM cccuthst_sql 
												WHERE LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR   
												AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_VALOR)), 6) 
												AND LTRIM(RTRIM(hideno))   = @VP_PIEL_VALOR

										SET @VP_SQF_VALOR = CONVERT(DECIMAL(13,2),@VP_SQF_VALOR) - @VP_SQF_CORTADO

										IF @VP_SQF_VALOR <= 0 
											BEGIN
												DECLARE @VP_MENSAJE_PIEL_CORTADA VARCHAR(255)= @VP_PIEL_VALOR + ': PIEL CORTADA COMPLETA.'
												RAISERROR (@VP_MENSAJE_PIEL_CORTADA, 16, 1 ) --MENSAJE - Severity -State.
											END
									END
							--END

						INSERT	INTO	[PIEL_A_TRANSFERIR] (
										[TIPO_TRANSFERENCIA],
										-- ===========================	
										[FOLIO_ORIGEN],	[FOLIO_DESTINO],	
										-- ===========================	
										[LOCACION_ORIGEN], [LOCACION_DESTINO],	
										-- ===========================	
										[ORDEN_ORIGEN],	[ORDEN_DESTINO],		
										-- ===========================	
										[COLOR], [LOTE],				
										[PIEL],	[SQF],	
										-- ===========================	
										[K_USUARIO_ALTA], [F_ALTA],	
										[K_USUARIO_CAMBIO],	[F_CAMBIO],
										[L_BORRADO], [K_USUARIO_BAJA], [F_BAJA]	)	
								VALUES	(
										@PP_TIPO_TRANSFERENCIA,
										-- ===========================	
										@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
										-- ===========================	
										@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO,
										-- ===========================	
										@PP_ORDEN_ORIGEN, @PP_ORDEN_DESTINO,
										-- ===========================	
										@PP_CB_COLOR, @VP_LOTE_VALOR,
										@VP_PIEL_VALOR, @VP_SQF_VALOR,
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
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. [PG_RN_VALIDAR_PIEL_CORTADA] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
		END
	ELSE
		BEGIN
			SELECT [PIEL_A_TRANSFERIR].* , usuario
			FROM [PIEL_A_TRANSFERIR]
			INNER JOIN users_pearl ON [PIEL_A_TRANSFERIR].K_USUARIO_ALTA = users_pearl.codigo
			WHERE	[TIPO_TRANSFERENCIA] =		@PP_TIPO_TRANSFERENCIA
			AND		[FOLIO_ORIGEN]		=		@PP_TAGNO_ORIGEN
			AND		[FOLIO_DESTINO]		= 		@PP_TAGNO_DESTINO
			AND		[LOCACION_ORIGEN]	=		@PP_LOCACION_ORIGEN
			AND		[LOCACION_DESTINO]	=		@PP_LOCACION_DESTINO
			AND		[ORDEN_ORIGEN]		=		@PP_ORDEN_ORIGEN
			AND		[ORDEN_DESTINO]		=		@PP_ORDEN_DESTINO
			AND		[LOTE]				=		@VP_LOTE_VALOR
			AND		[COLOR]				=		@PP_CB_COLOR
			AND		[K_USUARIO_ALTA]    =		@PP_K_USUARIO_ACCION
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
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
