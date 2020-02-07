-- //////////////////////////////////////////////////////////////
-- // DATA BASE:		MAT19
-- // MODULE:			
-- // OPERATION:		
-- //////////////////////////////////////////////////////////////
-- // AUTHOR:			FEG			
-- // CREATION DATE:	2019-12-27
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas]
GO

-- //////////////////////////////////////////////////////////////

-- EXECUTE [dbo].[PG_IN_PEARL_LOG] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_PEARL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_PEARL_LOG]
GO


CREATE PROCEDURE [dbo].[PG_IN_PEARL_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25),
	@PP_SCRREN_OPT				VARCHAR(30),
	@PP_JOB_NO					VARCHAR(10),
	@PP_MOVEMENT				VARCHAR(50),
	@PP_DETAIL					VARCHAR(150),
	@PP_HIDE					VARCHAR(10)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////

	DECLARE @VP_CDATE VARCHAR(10) = FORMAT(GETDATE(),  'dd/MM/yyyy')
	DECLARE @VP_CTIME VARCHAR(10) = FORMAT(GETDATE(),  'HHmmss')
	
	IF @VP_MENSAJE = ''
		BEGIN
			INSERT INTO pearl_log 
					VALUES(	@VP_CDATE,
							@VP_CTIME,
							@PP_USER,
							@PP_COMPUTER_NAME,
							@PP_SCRREN_OPT,
							@PP_JOB_NO,
							@PP_MOVEMENT,
							@PP_DETAIL,
							@PP_HIDE	)

			IF @@ROWCOUNT = 0
			SET @VP_MENSAJE = 'ERROR: // INSERT pearl_log  // '

		END
	-- /////////////////////////////////////////////////////////////////////

	--IF @VP_MENSAJE<>''
	--	BEGIN
		
	--	SET		@VP_MENSAJE = 'No es posible insert el [JOBNO]: ' + @VP_MENSAJE 
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
	--	SET		@VP_MENSAJE = @VP_MENSAJE + '[#JOB.'+CONVERT(VARCHAR(10),@PP_JOB_NO)+']'
	--	SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
	--	END
	
	--SELECT	@VP_MENSAJE AS MENSAJE, @PP_JOB_NO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_JOB_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO






-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////