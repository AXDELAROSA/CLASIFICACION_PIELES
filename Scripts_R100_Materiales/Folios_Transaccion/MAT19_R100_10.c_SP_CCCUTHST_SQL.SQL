-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO

-- ////////////////////////////////////////////////////////////// 
-- ////////////////////////////////////////////////////////////// 



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(5),
	@PP_ORDEN					VARCHAR(10)
AS

	-- ///////////////////////////////////////////
	DELETE	cccuthst_sql 
	WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
	AND LTRIM(RTRIM(hideno))   = @PP_PIEL
	AND	LTRIM(RTRIM(JOBNO))   = @PP_ORDEN
	-- ===========================

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_DL_CCCUTHST_SQL_X_PIEL', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // DELETE RP_SC  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////

	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'DELETE',
													'',
													-- ===========================================
													'[DL]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_CCCUTHST_HIDESQM_X_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_CCCUTHST_HIDESQM_X_PIEL]
GO


CREATE PROCEDURE [dbo].[PG_UP_CCCUTHST_HIDESQM_X_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(5),
	@PP_ORDEN					VARCHAR(10),
	@PP_PIEL_SQM				DECIMAL(8,4)
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_PIEL_SQM_TOTAL	DECIMAL(8,4) = 0
	DECLARE @VP_PIEL_SQM		DECIMAL(8,4) = 0

	SELECT @VP_PIEL_SQM = hidesqm
	FROM cccuthst_sql 
	WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
	AND LTRIM(RTRIM(hideno))   = @PP_PIEL
	AND	LTRIM(RTRIM(JOBNO))   = @PP_ORDEN

	IF @VP_PIEL_SQM IS NULL
		SET @VP_PIEL_SQM = 0
	-- ===========================

	SET @VP_PIEL_SQM_TOTAL = @VP_PIEL_SQM - @PP_PIEL_SQM

	IF @VP_PIEL_SQM_TOTAL > 0
		BEGIN
			-- ///////////////////SE ACTUALIZA EL REGISTRO DE DE LA PIEL CORTADA//////////////////////////////////////////////////
			UPDATE	cccuthst_sql 
				SET hidesqm = @VP_PIEL_SQM_TOTAL
			WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
			AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
			AND LTRIM(RTRIM(hideno))   = @PP_PIEL
			AND	LTRIM(RTRIM(JOBNO))   = @PP_ORDEN
			
			IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR SP: PG_UP_CCCUTHST_HIDESQM_X_PIEL', 16, 1 ) --MENSAJE - Severity -State.
					--SET @VP_MENSAJE = 'ERROR: // DELETE RP_SC  // '
				END
		END
	ELSE
		BEGIN
			-- ///////////////////SE BORRA EL REGISTRO DE DE LA PIEL CORTADA//////////////////////////////////////////////////
			EXECUTE [dbo].[PG_DL_CCCUTHST_SQL_X_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
														@PP_COLOR, @PP_LOTE, @PP_PIEL, @PP_ORDEN
		END

	
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////

	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
