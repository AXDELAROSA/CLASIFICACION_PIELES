-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			ELIMINAR FOLIOS PENDIENTES DE IMPRESION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	25/ABR/2022
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
/*
	EXEC DBO.[PG_LI_RP_SC_PRT] 0,0, 0
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RP_SC_PRT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RP_SC_PRT]
GO

CREATE PROCEDURE [dbo].[PG_LI_RP_SC_PRT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_IMPRESION			INT
AS

	-- ///////////////////////////////////////////
	SELECT  ID,
			TAG		AS FOLIO,
			[TYPE]	AS TIPO
	FROM	RP_SC_PRT (NOLOCK)
	WHERE [TYPE] = (	CASE WHEN @PP_TIPO_IMPRESION = 0 THEN [TYPE]
							ELSE @PP_TIPO_IMPRESION END )

	-- ////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_RP_SC_PRT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_RP_SC_PRT]
GO

CREATE PROCEDURE [dbo].[PG_DL_RP_SC_PRT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TIPO_IMPRESION			INT
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	BEGIN TRANSACTION 
	BEGIN TRY

		DELETE	RP_SC_PRT 

		IF @@ROWCOUNT = 0
			RAISERROR ('No se encontraron folios', 16, 1 ) --MENSAJE - Severity -State.

	COMMIT TRANSACTION 
	END TRY
	
	BEGIN CATCH
		/* Ocurrió un error, deshacemos los cambios*/ 
		ROLLBACK TRANSACTION
		DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
		SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
		SET @VP_MENSAJE = 'ERROR: ' + @VP_ERROR_TRANS
	END CATCH
		
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		SET @VP_MENSAJE = 'No es posible Eliminar los [FOLIOS]: '+CONVERT(VARCHAR(10), 0)+'] ' + @VP_MENSAJE 

	-- /////////////////////////////////////////////////////////////////////
	SELECT	@VP_MENSAJE AS MENSAJE, 0 AS CLAVE

	-- ////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
