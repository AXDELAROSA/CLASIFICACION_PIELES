-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_Folios / Folio Transaccion
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	20/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO




-- EXECUTE [dbo].[PG_SK_RP_FOLIO_X_TAG] 0,0,  'FNLGPS4' 

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FICHA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_FOLIO_X_TAG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_FOLIO_X_TAG]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_FOLIO_X_TAG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG						INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		
	SELECT	ID,
			ISNULL(TAG, 0)		AS ID,
			ISNULL(STATUS,'')	AS STATUS,
			ISNULL(MACHINE,'')	AS MACHINE,
			ISNULL(JOBNO,'')	AS JOBNO,
			ISNULL(JOBNO2,'')	AS JOBNO2
	-- =====================
	FROM	RP_Folios 
	WHERE	TAG = @PP_TAG
	-- =====================

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- EXECUTE [dbo].[PG_IN_RP_FOLIOS] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_RP_FOLIOS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_RP_FOLIOS]
GO


CREATE PROCEDURE [dbo].[PG_IN_RP_FOLIOS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_ESTATUS					VARCHAR(5),
	@PP_MAQUINA					VARCHAR(15),
	@PP_JOBNO					VARCHAR(10),
	@PP_JOBNO2					VARCHAR(10)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
		
	IF @VP_MENSAJE = ''
		BEGIN
			INSERT INTO RP_Folios (	
					TAG, STATUS, MACHINE, JOBNO, JOBNO2	) 
			VALUES(
					@PP_TAG_NO, @PP_ESTATUS, @PP_MAQUINA, @PP_JOBNO, @PP_JOBNO2	)
			
		END
	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'INSERT',
													'',
													-- ===========================================
													'[IN]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- EXECUTE [dbo].[PG_UP_RP_FOLIO_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_FOLIO_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_FOLIO_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_FOLIO_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_STATUS					VARCHAR(5),
	@PP_JOB_NO					VARCHAR(10),
	@PP_MACHINE					VARCHAR(15)

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////

	DECLARE @VP_COLOUR VARCHAR(50)

	-- /////////////////////////////////////////////////////////////////////

	UPDATE RP_Folios 
	SET
		STATUS	=	@PP_STATUS,
		JOBNO	=	@PP_JOB_NO,
		MACHINE	=	@PP_MACHINE 
	WHERE LTRIM(RTRIM(TAG))=@PP_TAG_NO

	IF @@ROWCOUNT = 0
		BEGIN
			RAISERROR ('ERROR SP: PG_UP_RP_FOLIO_X_FOLIO', 16, 1 ) --MENSAJE - Severity -State.
			--SET @VP_MENSAJE = 'ERROR: // UPDATE RP_Folios  // '
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
