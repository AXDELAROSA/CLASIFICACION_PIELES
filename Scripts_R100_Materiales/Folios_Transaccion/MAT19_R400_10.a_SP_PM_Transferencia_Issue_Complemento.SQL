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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_ISSUE_COMPLEMENTO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE_COMPLEMENTO]
GO
-- EXECUTE   [dbo].[PG_GET_FOLIO_DESTINO] 0,0, 'B' , 'FCMKDX9' 
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_ISSUE_COMPLEMENTO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO_ORIGEN			INT,
	@PP_LOCACION_ORIGEN			VARCHAR(5),
	-- ===========================
	@PP_COMENTARIO				VARCHAR(MAX),
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
	DECLARE @VP_CONTADOR	INT = 0
	
	DECLARE CU_SQF_X_LOTE CURSOR 
	FOR SELECT	LTRIM(RTRIM(COLOUR)), LTRIM(RTRIM(LOT)), SUM(CONVERT(DECIMAL(13,4),LTRIM(RTRIM(SQF)))) AS SQF 
		FROM	RP_SC
		WHERE   TAGNO= @PP_FOLIO_ORIGEN
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
		EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
												@VP_TRANSACCION_DOC, @VP_INDICE, 0

		-- ///////////////////////////////////////////
		--EXECUTE [dbo].[PG_IN_IMLSTRX_SQL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
		--										@VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL, 
		--										@VP_TRANSACCION_DOC, @VP_INDICE, 1

		-- ///////////////////////////////////////////
		EXECUTE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@PP_LOCACION_ORIGEN, @VP_COLOR_TBL, @VP_SQF_TBL
		-- ///////////////////////////////////////////
		SET @VP_CONTADOR = @VP_CONTADOR + 1
		-- ///////////////////////////////////////////
		
	    FETCH NEXT FROM CU_SQF_X_LOTE INTO @VP_COLOR_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
	
	END
	
	CLOSE CU_SQF_X_LOTE
	DEALLOCATE CU_SQF_X_LOTE
			
	-- ////////////////////////////////////////////////////////////////////
	
	DECLARE @VP_TRXIDNO VARCHAR (50) = 'I' + CONVERT(VARCHAR(10),@VP_TRANSACCION_DOC) + '0000000000000000000'
	DECLARE @VP_ORDERNO VARCHAR (10) =  '00000'

	-- SE QUITO PORQUE NO RECIBE EL DOC_TYPE COMO PARAMETRO EN EL SEPE POR DEFAULT ES T Y SE NECESITABA PONER I
	--EXECUTE [dbo].[PG_IN_IMINVTRX_SQL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--										@VP_TRXIDNO, @VP_TRANSACCION_DOC, @VP_COLOR_TBL, 
	--										@PP_LOCACION_ORIGEN, 0, @VP_ORDERNO, 
	--										@PP_USER, @PP_COMENTARIO, 0
	
	-- ////////////////////////////////////////////////////////////////////

	DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
	DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
	
	INSERT INTO  IMINVTRX_SQL (	SOURCE, ORD_NO, ITEM_NO, LOC, TRX_DT, 

								TRX_TM, DOC_DT, DOC_TYPE, DOC_SOURCE, QUANTITY, 

								DOC_ORD_NO, OLD_QUANTITY, USER_NAME, ID_NO, PROMISE_DT,

								LEV_NO, SEQ_NO, CTL_NO, LINE_NO, FROM_CTL_NO, FROM_LINE_NO, 
								
								FROM_LEV_NO, FROM_SEQ_NO, UNIT_COST, OLD_UNIT_COST, NEW_UNIT_COST, 

								PRICE, BUILD_QTY, BUILD_QTY_PER, AMT, LANDED_COST, RECEIPT_ORD_NO, 

								TRX_QTY_BKORD, DEALL_AMT, batch_id, jnl, item_filler, comment	) 

					VALUES	  ( 'I', @VP_TRANSACCION_DOC, @VP_COLOR_TBL, @PP_LOCACION_ORIGEN, @VP_F_TRANSACCION,

								@VP_TIME, @VP_F_TRANSACCION, 'I', 'M', 0, 

								@VP_ORDERNO, 0, @PP_USER, @VP_TRXIDNO, @VP_F_TRANSACCION,

								0, 0, 0, 0, 0, 0,
								
								0, 0, 0, 0, 0, 
								
								0, 0, 0, 0, 0, '0', 
								
								00000000, 0, '' , '', '', @PP_COMENTARIO	)

	IF @@ROWCOUNT = 0
		RAISERROR ('ERROR SP: PG_PM_TRANSFER_ISSUE_COMPLEMENTO // INSERT INTO  IMINVTRX_SQL', 16, 1 ) --MENSAJE - Severity -State.	
	-- ////////////////////////////////////////////////////////////////////


	-- ////////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////

GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
