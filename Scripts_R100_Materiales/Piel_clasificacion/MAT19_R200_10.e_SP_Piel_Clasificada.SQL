-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	13/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO

-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / FICHA
-- //////////////////////////////////////////////////////////////
-- EXECUTE PG_UP_RP_SC_K_CLASIFICACION 0,0,'104313','0215',''
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_K_CLASIFICACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_K_CLASIFICACION]
GO

CREATE PROCEDURE [dbo].[PG_UP_RP_SC_K_CLASIFICACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(25),
	@PP_PIEL					VARCHAR(100),
	@PP_D_CLASIFICACION			VARCHAR(25)
	-- ===========================
AS			
	
	DECLARE @VP_MENSAJE			VARCHAR(300) = ''
	
	--IF @PP_PIEL = '000A'
	--	SET @VP_MENSAJE = ' MENSAJE 000A'

	--IF @PP_PIEL = '000B'
	--	SET @VP_MENSAJE = ' MENSAJE 000B'
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_RP_SC_UPDATE]  @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@PP_LOTE, @PP_PIEL,
											@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE=''
		BEGIN

			BEGIN TRANSACTION 
			BEGIN TRY

			DECLARE @VP_K_PIEL_CLASIFICACION	INT = 0

			SELECT	@VP_K_PIEL_CLASIFICACION = K_PIEL_CLASIFICACION
			FROM	PIEL_CLASIFICACION
			WHERE	D_PIEL_CLASIFICACION=@PP_D_CLASIFICACION

			IF @VP_K_PIEL_CLASIFICACION IS NULL
				SET @VP_K_PIEL_CLASIFICACION = 0
			
			UPDATE	RP_SC
			SET		
					K_CLASIFICACION = @VP_K_PIEL_CLASIFICACION
			-- ==================================
			WHERE	RTRIM(LTRIM(LOT))=@PP_LOTE
			AND		RTRIM(LTRIM(HIDE))=@PP_PIEL
			-- ==================================

			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC // '
			ELSE
				EXECUTE	[PG_IN_UP_PIEL_CLASIFICADA_PORCENTAJE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_LOTE

			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_UP_RP_SC_K_CLASIFICACION // ' + @VP_ERROR_TRANS

			END CATCH

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar la [Piel]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.' + @PP_PIEL +'] del '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOTE.' + @PP_LOTE +'] )'

		
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_PIEL AS CLAVE

	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_PIEL, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
