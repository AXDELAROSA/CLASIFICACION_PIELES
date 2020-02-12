-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_CLASIFICADA
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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_AUTORIZAR_TRANSFERENCIA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_AUTORIZAR_TRANSFERENCIA]
GO
/*
EXECUTE  [dbo].[PG_AUTORIZAR_TRANSFERENCIA]	0,0,  'FOLIO_EXISTENTE' , 'B' , 'FMCKTX7' , 3785629 , 3785640 , 'MHI' , 'T38' , 
														'' , '09490' , 1 , 0 , '32782/32782/32782' , '0368/0367/0366' , 0 , 0 , 0 , 
														'' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_AUTORIZAR_TRANSFERENCIA]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_MOVIMIENTO				VARCHAR(50),
	@PP_APROBADOR				VARCHAR(50),
	-- ===========================
	@PP_LOTE_A_ARRAY			NVARCHAR(MAX),
	@PP_LOTE_B_ARRAY			NVARCHAR(MAX),
	-- ===========================
	@PP_ORDEN					VARCHAR(10),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
								
				DECLARE @TBL_LOTE_COMPATIBLE TABLE (
						K_LOTE_COMPATIBLE  INT IDENTITY(1,1),
						LOTE_A		VARCHAR(20),
						LOTE_B		VARCHAR(20)
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_LOTE_A			INT
				DECLARE @VP_POSICION_LOTE_B			INT

				DECLARE @VP_LOTE_A_VALOR				VARCHAR(20)
				DECLARE @VP_LOTE_B_VALOR				VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_LOTE_A_ARRAY			= @PP_LOTE_A_ARRAY		+ '/'		
				SET	@PP_LOTE_B_ARRAY			= @PP_LOTE_B_ARRAY		+ '/'		
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_LOTE_A_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_LOTE_A	=	patindex('%/%' , @PP_LOTE_A_ARRAY)
						SELECT @VP_POSICION_LOTE_B	=	patindex('%/%' , @PP_LOTE_B_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_LOTE_A_VALOR		= LEFT(@PP_LOTE_A_ARRAY, @VP_POSICION_LOTE_A - 1)
						SELECT @VP_LOTE_B_VALOR		= LEFT(@PP_LOTE_B_ARRAY, @VP_POSICION_LOTE_B - 1)
						
						
						INSERT	INTO	@TBL_LOTE_COMPATIBLE
								VALUES	(
											@VP_LOTE_A_VALOR,
											@VP_LOTE_B_VALOR	)
																								
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_LOTE_A_ARRAY			= STUFF(@PP_LOTE_A_ARRAY, 1, @VP_POSICION_LOTE_A, '')
						SELECT @PP_LOTE_B_ARRAY			= STUFF(@PP_LOTE_B_ARRAY, 1, @VP_POSICION_LOTE_B, '')

					END
								
				DECLARE @VP_N_LOTE INT = 0
				SELECT @VP_N_LOTE = COUNT(K_LOTE_COMPATIBLE) FROM @TBL_LOTE_COMPATIBLE

				-- ////////////////////SI NO HAY LOTES SELECCIONADA GENERAMOS UN ERROR DE TRANSACCION//////////////////////////
				IF @VP_N_LOTE IS NULL
					RAISERROR ('NO hay Lotes seleccionados.', 16, 1 ) --MENSAJE - Severity -State.
				-- /////////////////////////////////////////////////////////////////////////////////////
									
				DECLARE @VP_LOTE_A_TBL VARCHAR(10)
				DECLARE @VP_LOTE_B_TBL VARCHAR(10)
				
				DECLARE CU_LOTE_SELECCIONADO CURSOR 
				FOR SELECT  LOTE_A, LOTE_B FROM @TBL_LOTE_COMPATIBLE
				
				OPEN CU_LOTE_SELECCIONADO
				FETCH NEXT FROM CU_LOTE_SELECCIONADO INTO @VP_LOTE_A_TBL, @VP_LOTE_B_TBL
				
				WHILE @@FETCH_STATUS = 0
					BEGIN
					
						DECLARE @VP_DETAIL VARCHAR(100) 
						IF @PP_MOVIMIENTO = 'Cuarentena'
							SET @VP_DETAIL = @PP_APROBADOR
						ELSE
							SET @VP_DETAIL = @PP_APROBADOR + ' / ' + @VP_LOTE_A_TBL + ' no compatible ' + @VP_LOTE_B_TBL

						
						EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_USER, @PP_COMPUTER_NAME, 'Transactions',
															@PP_ORDEN, @PP_MOVIMIENTO,
															@VP_DETAIL, ''

						-- /////////////////////////////////////////////////////////////////////
						
						FETCH NEXT FROM CU_LOTE_SELECCIONADO INTO @VP_LOTE_A_TBL, @VP_LOTE_B_TBL
	
					END
	
				CLOSE CU_LOTE_SELECCIONADO
				DEALLOCATE CU_LOTE_SELECCIONADO
					-- ////////////////////////////////////////////////////////////////////	
					
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_AUTORIZAR_TRANSFERENCIA // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [LOG]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_USER AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'TRANSACCION',
													'',
													-- ===========================================
													'[TR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_MOVIMIENTO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
