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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_A_FOLIO_NUEVO]	0,0,   FMCKTX7 , 3783329 , '07869' , 'Table 67' , 
													0 , '32701' , '1071' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_X_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ESTATUS					VARCHAR(3),
	@PP_TAGNO_ORIGEN			INT,
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_ORDEN_DESTINO		VARCHAR(10),
	@PP_LOCACION_ORIGEN		VARCHAR(10),
	@PP_LOCACION_DESTINO		VARCHAR(10),
	@PP_CARGAR_ORDEN			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_COLOR_PIEL				VARCHAR(20),
	@PP_TB_SQF						VARCHAR(10),
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF @VP_MENSAJE=''
		--EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--												@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
		--												@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
		--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
		
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- ////////////////////////////////////////////////////////////////////		
			If SUBSTRING(@PP_LOCACION_DESTINO, 1, 1) = 'T' AND @PP_LOCACION_DESTINO <> '' AND  @PP_CARGAR_ORDEN = 1
				BEGIN
					EXECUTE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, @PP_ORDEN_DESTINO, 
																	@PP_LOCACION_DESTINO, @PP_USER, @PP_COMPUTER_NAME		
																						
					-- /////////////////////////////////////////////////////////////////////
					IF (	SELECT COUNT(*) FROM sys.table_types
							WHERE name = 'TVPParam' AND schema_id = 1	) = 0
							CREATE TYPE dbo.TVPParam AS TABLE(	COLOR		VARCHAR(20),
																LOTE		VARCHAR(20),
																SQF			VARCHAR(20)	)
				
					DECLARE @TBL_TOTAL_SQF_X_LOTE	TVPParam 

					INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
					SELECT	COLOUR,
							RIGHT('000000' + Ltrim(Rtrim(LOT)), 6),
							SUM(CAST(SQF AS DECIMAL(4,2)))
					-- =====================
					FROM	RP_SC
					-- =====================
					WHERE	TAGNO=@PP_TAGNO_ORIGEN 
					-- =====================
					GROUP BY	COLOUR, LOT
					-- =====================

					EXECUTE [dbo].[PG_PM_TRANSFER]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_LOCACION_DESTINO, @PP_LOCACION_ORIGEN,
														@PP_ORDEN_DESTINO, @PP_ORDEN_ORIGEN,  @TBL_TOTAL_SQF_X_LOTE,						 	
														@PP_TB_SQF, @PP_COMENTARIO, @PP_USER
					-- /////////////////////////////////////////////////////////////////////

					DECLARE @VP_COLOR VARCHAR(10) 
					SELECT TOP 1 @VP_COLOR	= COLOR
											FROM	@TBL_TOTAL_SQF_X_LOTE

					IF @PP_ORDEN_ORIGEN = 'MIT' And @PP_LOCACION_DESTINO = 'MHI' 
						BEGIN
							IF EXISTS ( SELECT TOP 1 RP_Folios.ID FROM RP_Folios INNER JOIN RP_SC ON TAG=TAGNO and STATUS='B' AND COLOUR = @VP_COLOR)
								BEGIN
									DECLARE @VP_FOLIO	INT
									SELECT TOP 1 @VP_FOLIO = TAG from RP_Folios INNER JOIN RP_SC ON TAG=TAGNO and STATUS='B' AND COLOUR = @VP_COLOR 

									EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, @VP_FOLIO, @PP_LOCACION_DESTINO, 1
								END
							ELSE
								BEGIN
									EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, 0, @PP_LOCACION_DESTINO, 0
									
									EXECUTE [dbo].[PG_UP_RP_FOLIO_X_FOLIO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_TAGNO_ORIGEN, 'B', NULL, NULL
								END
						END


					DECLARE @VP_DETAIL VARCHAR(255)= 'from: ' + @PP_LOCACION_ORIGEN + ' to: ' +@PP_LOCACION_DESTINO + ' orden:' + @PP_ORDEN_DESTINO
					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
														@PP_TAGNO_ORIGEN, 'Transfer Folio',
														@VP_DETAIL, ''

					IF 	@PP_LOCACION_DESTINO = 'MFP'
						BEGIN
							DECLARE @VP_RECIPIENTS	NVARCHAR(MAX)  = 'franciscoe@pearlleather.com.mx;Alejandrod@pearlleather.com.mx'
							--SET @VP_RECIPIENTS = 'dianan@pearlleather.com.mx;manuelg@pearlleather.com.mx;fernandog@pearlleather.com.mx;pedrov@pearlleather.com.mx'
							
							DECLARE @VP_SUBJECT		VARCHAR(255) = 'Transferencia hacia MFP...'
							DECLARE @VP_BODY		NVARCHAR(MAX) 
							DECLARE @VP_FECHA		VARCHAR(10) = CONVERT(VARCHAR(10), GETDATE(),103)

							SET @VP_BODY =  
							    N'<H1>Se ha creado una nueva transferencia (Entrada a MFP)...</H1>' + 
								N'<table border="1">' +  
								N'<tr><th>Fecha</th><th>Color</th><th>Cantidad</th><th>Comentario</th><th>Usuario</th>' +  
								N'</tr>' +  
								N'<td>'+ @VP_FECHA +'</td><td>'+ @PP_COLOR_PIEL +'</td><td>'+ @PP_TB_SQF +'</td><td>'+ @PP_COMENTARIO+'</td><td>'+ @PP_USER +'</td>'+  
								N'</table>' ;
								SET ROWCOUNT 0
								 
							EXECUTE	[dbo].[PG_ENVIAR_CORREO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_RECIPIENTS, @VP_SUBJECT, @VP_BODY

					END
			END
		-- ////////////////////////////////////////////////////////////////////	
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @ErrorMessage NVARCHAR(4000);
				SET @ErrorMessage = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PM_TRANSFER_PIEL_DEVOLUCION // '
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
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_ORIGEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAGNO_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
