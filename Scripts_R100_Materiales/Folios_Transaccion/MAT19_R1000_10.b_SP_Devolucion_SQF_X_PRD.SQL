-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			DEVOLUCION DE PIEL POR PRODUCCION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/JUN/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE [DATA_02PRUEBAS] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PR_TRANSFER_SQF_X_DEVOLUCION_MESA_A_MHI]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PR_TRANSFER_SQF_X_DEVOLUCION_MESA_A_MHI]
GO

/*
EXECUTE  [dbo].[PG_PR_TRANSFER_SQF_X_DEVOLUCION_MESA_A_MHI] 0,0, 46 , 'DEVOLUCION' , 'B' , 'FMCKTX7' , 3788360 , 
					2137674 , 'T17' , 'MHI' , '11611' , '-' , 0 , 0 , 0 , 0 , 0 , '' , 'franciscoe' , 'IT-010' 

*/
CREATE PROCEDURE [dbo].[PG_PR_TRANSFER_SQF_X_DEVOLUCION_MESA_A_MHI]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO_ORIGEN			INT,
	@PP_COLOR					VARCHAR(20),
	-- ===========================
	@PP_ORDEN_ORIGEN			VARCHAR(10),
	@PP_LOCACION_ORIGEN			VARCHAR(20),
	-- ===========================
	@PP_ORDEN_DESTINO			VARCHAR(20),
	@PP_LOCACION_DESTINO		VARCHAR(20),
	-- ===========================
	@PP_USER					VARCHAR(50),
	@PP_COMPUTER_NAME			VARCHAR(50)
AS

								
	DECLARE @VP_TRANSACCION_DOC	INT = 0
	SELECT	TOP 1
			@VP_TRANSACCION_DOC  = RIGHT('00000000' + Ltrim(Rtrim(NEXT_DOC_NO)), 8)
	-- =====================
	FROM	IMCTLFIL_SQL
	-- ///////////////////////////////////////////

	EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														1 
	-- ///////////////////////////////////////////
	DECLARE @VP_COLOR_TBL VARCHAR(50) = ''
	DECLARE @VP_LOTE VARCHAR(20) = ''
	DECLARE @VP_SQF_X_LOTE DECIMAL(13,4) = 0
	DECLARE @VP_CONTADOR INT = 0

	DECLARE CU_SQF_X_LOTE_DEVOLUCION CURSOR 
	FOR SELECT LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF)))) AS SQF 
	FROM	RP_SC (NOLOCK)
	WHERE	TAGNO = @PP_FOLIO_ORIGEN
	AND TYPE = 'D'
	GROUP BY COLOUR, LOT	
	ORDER BY LOT
	
	OPEN CU_SQF_X_LOTE_DEVOLUCION
	FETCH NEXT FROM CU_SQF_X_LOTE_DEVOLUCION INTO @VP_COLOR_TBL, @VP_LOTE, @VP_SQF_X_LOTE
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
	
		DECLARE @VP_INDICE	VARCHAR(10) = CONVERT(VARCHAR(10), @VP_CONTADOR)
		SET @VP_LOTE	= RIGHT( '000000' + @VP_LOTE, 6)
								
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_ORIGEN, @VP_COLOR_TBL,
																			@VP_LOTE, @VP_SQF_X_LOTE
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO, @VP_COLOR_TBL,
																			@VP_LOTE, @VP_SQF_X_LOTE, @VP_TRANSACCION_DOC
		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE, @VP_SQF_X_LOTE, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 0

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE, @VP_SQF_X_LOTE, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 1

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_LOCACION_ORIGEN, @VP_COLOR_TBL, @VP_SQF_X_LOTE

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_LOCACION_DESTINO, @VP_COLOR_TBL, @VP_SQF_X_LOTE

		-- ////////////////////////////////////////////////////////////////////
	
		DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
		DECLARE @VP_ORDERNO VARCHAR (50) =  LEFT(@PP_ORDEN_ORIGEN + '00000' , 5)

		EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
												@PP_LOCACION_ORIGEN, @VP_SQF_X_LOTE, @VP_ORDERNO, 
												@PP_USER, 'DEVOLUCION/TRASPASO DE MESAS', 0, @VP_INDICE,
												'T', 'M', @VP_SQF_X_LOTE
		
		-- ////////////////////////////////////////////////////////////////////
		SET	@VP_ORDERNO = @PP_ORDEN_DESTINO

		IF @PP_ORDEN_DESTINO = '-'
			SET	@VP_ORDERNO = '00000'

		SET @VP_TRXIDNO = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000010000'

		EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
												@PP_LOCACION_DESTINO, @VP_SQF_X_LOTE, @VP_ORDERNO, 
												@PP_USER, 'DEVOLUCION/TRASPASO DE MESAS', 1, @VP_INDICE,
												'T', 'M', @VP_SQF_X_LOTE
		-- ////////////////////////////////////////////////////////////////////

			SET @VP_CONTADOR = @VP_CONTADOR + 1
		-- ///////////////////////////////////////////
		
	    FETCH NEXT FROM CU_SQF_X_LOTE_DEVOLUCION INTO  @VP_COLOR_TBL, @VP_LOTE, @VP_SQF_X_LOTE
	
	END
	
	CLOSE CU_SQF_X_LOTE_DEVOLUCION
	DEALLOCATE CU_SQF_X_LOTE_DEVOLUCION			

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
