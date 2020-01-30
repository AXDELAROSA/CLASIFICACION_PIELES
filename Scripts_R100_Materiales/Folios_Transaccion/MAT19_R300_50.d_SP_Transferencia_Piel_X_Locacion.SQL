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
	@PP_VP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_VP_ORDEN_DESTINO		VARCHAR(10),
	@PP_VP_LOCACION_ORIGEN		VARCHAR(10),
	@PP_VP_LOCACION_DESTINO	VARCHAR(10),
	@PP_CARGAR_ORDEN			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
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
			If SUBSTRING(@PP_VP_LOCACION_DESTINO, 1, 1) = 'T' AND @PP_VP_ORDEN_DESTINO <> '' AND  @PP_CARGAR_ORDEN = 1
				BEGIN
					EXECUTE [dbo].[PG_UP_CCJOBHDR_SQL_Y_RP_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_TAGNO_ORIGEN, @PP_VP_ORDEN_DESTINO, 
																	@PP_VP_LOCACION_DESTINO, @PP_USER, @PP_COMPUTER_NAME		
																						
					-- /////////////////////////////////////////////////////////////////////

					--EXECUTE [dbo].[PG_PM_TRANSFER]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
					--									@PP_TAGNO_DESTINO, @PP_LOCACION_DESTINO, @PP_LOCACION_ORIGEN,
					--									@PP_ORDEN_DESTINO, @PP_ORDEN_ORIGEN,  @TBL_TOTAL_SQF_X_LOTE,						 	
					--									@PP_TB_SQF, @PP_COMENTARIO, @PP_USER
							-- /////////////////////////////////////////////////////////////////////

					DECLARE @VP_DETAIL VARCHAR(255)= 'from: ' + @PP_VP_LOCACION_ORIGEN + ' to: ' +@PP_VP_LOCACION_DESTINO + ' orden:' + @PP_VP_ORDEN_DESTINO
					EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
														@PP_TAGNO_ORIGEN, 'Transfer Folio',
														@VP_DETAIL, ''

					IF 	@PP_VP_LOCACION_DESTINO = 'MFP'
						BEGIN
							DECLARE @tableHTML  NVARCHAR(MAX) ;  
  
							SET @tableHTML =  
							    N'<H1>Work Order Report</H1>' + 
								 N'<B>TEST</B>' ; 
								SET ROWCOUNT 0
								 
							EXEC msdb.dbo.sp_send_dbmail @recipients='franciscoe@pearlleather.com.mx',  
							    @subject = 'Transferencia hacia MFP...',  
							    @body = @tableHTML,  
							    @body_format = 'HTML'

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
