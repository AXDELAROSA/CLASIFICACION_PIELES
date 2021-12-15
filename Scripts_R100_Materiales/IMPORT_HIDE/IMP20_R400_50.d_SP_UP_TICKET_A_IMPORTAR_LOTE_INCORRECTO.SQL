-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			IMPORTACION DE PIELES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	15/DIC/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_TICKET_A_IMPORTAR_LOTE_INCORRECTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_TICKET_A_IMPORTAR_LOTE_INCORRECTO]
GO
/*
EXECUTE  [dbo].[PG_UP_TICKET_A_IMPORTAR_LOTE_INCORRECTO]	0,0,   '210226073445T1000001' 
*/
CREATE PROCEDURE [dbo].[PG_UP_TICKET_A_IMPORTAR_LOTE_INCORRECTO]
	@PP_K_SISTEMA_EXE						INT,
	@PP_K_USUARIO_ACCION					INT,
	-- ===========================
	@PP_FILE_NO								VARCHAR(50),
	@PP_LOTE_ANTERIOR						VARCHAR(50),
	@PP_LOTE_NUEVO							VARCHAR(50)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MENSAJE	VARCHAR(255) = ''

	-- // SECCION#1 /////////////////////////////////////////////////////////// VALIDACIONES + REGLAS DE NEGOCIO 
	DECLARE @VP_TICKET_PENDIENTE_IMPORTAR INT = 0	
	SELECT @VP_TICKET_PENDIENTE_IMPORTAR = COUNT([K_TICKET_A_IMPORTAR])
	FROM [TICKET_A_IMPORTAR] 
	WHERE FILE_NO = @PP_FILE_NO  
	AND LOTE = @PP_LOTE_ANTERIOR 
	AND L_BORRADO = 0  -- #0 TICKET NO IMPORTADO
	
	IF ( @VP_TICKET_PENDIENTE_IMPORTAR IS NULL OR @VP_TICKET_PENDIENTE_IMPORTAR = 0 )
		SET @VP_MENSAJE = 'El ticket ya fue importado o no existe!'

	IF @VP_MENSAJE <> ''
		IF SUBSTRING(@PP_LOTE_NUEVO, 1, 1) = '0'
			SET @VP_MENSAJE = 'El lote nuevo no debe empezar con 0!'
		
	IF @VP_MENSAJE <> ''
		IF LEN(@PP_LOTE_NUEVO) > 6 OR  LEN(@PP_LOTE_NUEVO) < 5
			SET @VP_MENSAJE = 'El lote nuevo debe tener de 5 a 6 digitos!'

	-- //////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY
			-- /////////SE ACTUALIZA EL LOTE DEL TICKET EN TICKET_A_IMPORTAR//////////////////////////////////
				UPDATE [TICKET_A_IMPORTAR] 
					SET LOTE = @PP_LOTE_NUEVO,
						F_CAMBIO = GETDATE(),
						K_USUARIO_CAMBIO = @PP_K_USUARIO_ACCION
				WHERE FILE_NO = @PP_FILE_NO  
				AND LOTE = @PP_LOTE_ANTERIOR 
				AND L_BORRADO = 0  -- #0 TICKET NO IMPORTADO

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
				SET @VP_MENSAJE = 'ERROR: // TRANS: [PG_UP_TICKET_A_IMPORTAR_LOTE_INCORRECTO] // ' + @VP_ERROR_TRANS
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No fue posible modificar el Ticket del Lote: ' + '[' + @PP_LOTE_ANTERIOR +'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_FILE_NO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	--EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												-- ===========================================
	--												2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
	--												'PROCESO',
	--												'',
	--												-- ===========================================
	--												'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
	--												0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
	--												-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
	--												0, 0, @PP_FILE_NO, '' , 0.00, 0.00,
	--												-- === @PP_VALOR_1 al 6_DATO
	--												'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
