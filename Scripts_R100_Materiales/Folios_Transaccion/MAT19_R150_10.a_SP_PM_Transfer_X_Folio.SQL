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
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER]
GO
-- EXECUTE   [dbo].[PG_GET_FOLIO_DESTINO] 0,0, 'B' , 'FCMKDX9' 
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_CB_LOCACION				VARCHAR(5),
	@PP_TB_LOCACION				VARCHAR(5),
	-- ===========================
	@PP_ORDEN_DESTINO			VARCHAR(10),
	@PP_CB_ORDEN				VARCHAR(10),
	-- ===========================
	@TBL_TOTAL_SQF_X_LOTE		TVPParam READONLY,
	-- ===========================
	@PP_TB_SQF					DECIMAL(13,2),
	-- ===========================
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25)
AS
	-- ///////////////////////////////////////////

	DECLARE @VP_TRANSACCION_DOC	INT = 0

	SELECT	TOP 1
			@VP_TRANSACCION_DOC  = RIGHT('00000000' + Ltrim(Rtrim(NEXT_DOC_NO)), 8)
	-- =====================
	FROM	IMCTLFIL_SQL
	-- ///////////////////////////////////////////

	EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														1 
	-- ///////////////////////////////////////////
	DECLARE @VP_COLOR_TBL	VARCHAR(10)
	DECLARE @VP_LOTE_TBL	VARCHAR(10)
	DECLARE @VP_SQF_TBL		VARCHAR(10)
	DECLARE @VP_CONTADOR INT = 0

	DECLARE CU_SQF_X_LOTE CURSOR 
	FOR SELECT COLOR, LOTE, SQF FROM @TBL_TOTAL_SQF_X_LOTE
	
	OPEN CU_SQF_X_LOTE
	FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @VP_INDICE	VARCHAR(10) = CONVERT(VARCHAR(10), @VP_CONTADOR)
		SET @VP_LOTE_TBL	= RIGHT( '000000' + @VP_LOTE_TBL, 6)
								
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_TB_LOCACION, @VP_COLOR_TBL,
																			@VP_LOTE_TBL, @VP_SQF_TBL
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_TB_LOCACION, @PP_CB_LOCACION, @VP_COLOR_TBL,
																			@VP_LOTE_TBL, @VP_SQF_TBL, @VP_TRANSACCION_DOC
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 0

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 1

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_TB_LOCACION, @VP_COLOR_TBL, @VP_SQF_TBL

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_CB_LOCACION, @VP_COLOR_TBL, @VP_SQF_TBL
		-- ///////////////////////////////////////////
		SET @VP_CONTADOR = @VP_CONTADOR + 1
		-- ///////////////////////////////////////////
		
	    FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
	END
	
	CLOSE CU_SQF_X_LOTE
	DEALLOCATE CU_SQF_X_LOTE
			
	-- ////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
	DECLARE @VP_ORDERNO VARCHAR (50) =  LEFT(@PP_CB_ORDEN + '00000' , 5)

	EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
											@PP_TB_LOCACION, @PP_TB_SQF, @VP_ORDERNO, 
											@PP_USER, @PP_COMENTARIO, 0,
											'T', 'M', @PP_TB_SQF
	
	-- ////////////////////////////////////////////////////////////////////

	SET @PP_CB_ORDEN = '00000'

	IF @PP_ORDEN_DESTINO <> '' 
		BEGIN
             SET	@VP_ORDERNO = @PP_ORDEN_DESTINO
		END
    ELSE
		BEGIN
             SET	@VP_ORDERNO = LEFT(@PP_CB_ORDEN + '00000' , 5)
        END

	SET @VP_TRXIDNO = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000010000'

	EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
											@PP_CB_LOCACION, @PP_TB_SQF, @VP_ORDERNO, 
											@PP_USER, @PP_COMENTARIO, 1,
											'T', 'M', @PP_TB_SQF
	-- ////////////////////////////////////////////////////////////////////


	-- ////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
