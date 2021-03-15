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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_TICKET_A_IMPORTAR_PROCESADO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_TICKET_A_IMPORTAR_PROCESADO]
GO
/*
EXECUTE  [dbo].[PG_UP_TICKET_A_IMPORTAR_PROCESADO]	0,0,   '210226073445T1000001' 
*/
CREATE PROCEDURE [dbo].[PG_UP_TICKET_A_IMPORTAR_PROCESADO]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 	
	--EXECUTE [dbo].[PG_RN_VALIDA_PIEL_A_REIMPRIMIR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--														@PP_FILE_NO, @PP_LOTE, @PP_PIEL,
	--														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	
	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- /////////SE ACTUALIZA EL EL TICKET EN TICKET_A_IMPORTAR//////////////////////////////////
				UPDATE	TICKET_A_IMPORTAR
					SET	L_BORRADO = 1,
						[K_USUARIO_CAMBIO] = @PP_K_USUARIO_ACCION, 
						[F_CAMBIO] = GETDATE()
				WHERE	FILE_NO = @PP_FILE_NO

				IF @@ROWCOUNT = 0
					RAISERROR ('NO fue posible actualizar el Ticket en [TICKET_A_IMPORTAR].', 16, 1 ) --MENSAJE - Severity -State.	
										
				-- ///////////////////////////////////////////
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_UP_TICKET_A_IMPORTAR_PROCESADO] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No fue posible mover el Ticket: ' + '[' + @PP_FILE_NO +'] ' + @VP_MENSAJE 
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
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
