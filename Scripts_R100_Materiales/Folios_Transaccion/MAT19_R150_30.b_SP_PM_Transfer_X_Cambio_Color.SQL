-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			TRANSFERENCIA DE FOLIOS
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	15/OCT/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_SQF_X_CAMBIO_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_SQF_X_CAMBIO_COLOR]
GO

CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_SQF_X_CAMBIO_COLOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_COLOR_DESTINO			VARCHAR(10),
	@PP_LOCACION_ORIGEN			VARCHAR(5),
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
	DECLARE @VP_COLOR_TBL	VARCHAR(10) = ''
	DECLARE @VP_LOTE_TBL	VARCHAR(10)	= ''
	DECLARE @VP_SQF_TBL		DECIMAL(13,4) = 0
	DECLARE @VP_CONTADOR INT = 0

	DECLARE CU_SQF_X_LOTE CURSOR 
	FOR SELECT  LTRIM(RTRIM(COLOUR)) , LTRIM(RTRIM(LOT)), SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF))))
		FROM RP_SC 
		WHERE TAGNO = @PP_TAGNO_ORIGEN
		GROUP BY COLOUR, LOT

	OPEN CU_SQF_X_LOTE
	FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @VP_INDICE	VARCHAR(10) = CONVERT(VARCHAR(10), @VP_CONTADOR)
		SET @VP_LOTE_TBL	= RIGHT( '000000' + @VP_LOTE_TBL, 6)
								
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_ORIGEN, @VP_COLOR_TBL,
																			@VP_LOTE_TBL, @VP_SQF_TBL
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_ORIGEN, @PP_LOCACION_ORIGEN, @PP_COLOR_DESTINO,
																			@VP_LOTE_TBL, @VP_SQF_TBL, @VP_TRANSACCION_DOC
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 0

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@PP_COLOR_DESTINO, @VP_LOTE_TBL, @VP_SQF_TBL, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 1

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_LOCACION_ORIGEN, @VP_COLOR_TBL, @VP_SQF_TBL

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_ORIGEN, @PP_COLOR_DESTINO, @VP_SQF_TBL

		-- ////////////////////////////////////////////////////////////////////
	
		DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
		DECLARE @VP_ORDERNO VARCHAR (50) =  '00000'

		EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
												@PP_LOCACION_ORIGEN, @VP_SQF_TBL, @VP_ORDERNO, 
												@PP_USER, @PP_COMENTARIO, 0, @VP_INDICE,
												'T', 'M', @VP_SQF_TBL
		
		-- ////////////////////////////////////////////////////////////////////

		SET @VP_TRXIDNO = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000010000'

		EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_TRXIDNO, @VP_TRANSACCION_DOC, @PP_COLOR_DESTINO, 
												@PP_LOCACION_ORIGEN, @VP_SQF_TBL, @VP_ORDERNO, 
												@PP_USER, @PP_COMENTARIO, 1, @VP_INDICE,
												'T', 'M', @VP_SQF_TBL

	-- ////////////////////////////////////////////////////////////////////
		-- ///////////////////////////////////////////
		SET @VP_CONTADOR = @VP_CONTADOR + 1
		-- ///////////////////////////////////////////
		
	    FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
	END
	
	CLOSE CU_SQF_X_LOTE
	DEALLOCATE CU_SQF_X_LOTE

	-- ////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
