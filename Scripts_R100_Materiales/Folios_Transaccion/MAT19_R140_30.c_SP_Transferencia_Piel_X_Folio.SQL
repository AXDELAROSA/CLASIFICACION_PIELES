-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			Transaccion de Folios
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	18/DIC/2019
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [dbo].[PG_LI_IMCTLFIL_SQL_NEXT_DOC_NO] 0,0, -1
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMCTLFIL_SQL_NEXT_DOC_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMCTLFIL_SQL_NEXT_DOC_NO]
GO


CREATE PROCEDURE [dbo].[PG_LI_IMCTLFIL_SQL_NEXT_DOC_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TODOS					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 1

	-- =========================================
		
	SELECT	TOP (@VP_LI_N_REGISTROS)
			IMCTLFIL_SQL.*,
			RIGHT('00000000' + LTRIM(RTRIM(NEXT_DOC_NO)), 8)	 AS NEXT_DOC
	-- =====================
	FROM	IMCTLFIL_SQL
	-- =====================

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO] 0,0, -1
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]
GO


CREATE PROCEDURE [dbo].[PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TODOS					INT
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE		VARCHAR(255) = ''

	-- =========================================
	IF @VP_MENSAJE = ''
		BEGIN
			UPDATE	IMCTLFIL_SQL
				SET NEXT_DOC_NO = NEXT_DOC_NO + 1
			-- =====================

			IF @@ROWCOUNT = 0
				BEGIN
					RAISERROR ('ERROR SP: PG_UP_IMCTLFIL_SQL_NEXT_DOC_NO', 16, 1 ) --MENSAJE - Severity -State.
					--SET @VP_MENSAJE = 'ERROR: // UPDATE IMCTLFIL_SQL // '
				END
		END
	
	-- /////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'UPDATE',
													'',
													-- ===========================================
													'[UP]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TODOS, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]
GO

CREATE PROCEDURE [dbo].[PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================
	@PP_LOCACION_ORIGEN			VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4)
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@PP_LOCACION_ORIGEN, @PP_COLOR, @PP_LOTE, @PP_SQF,
													@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN

		UPDATE	IMLSMST_SQL
		SET		
				QTY_ON_HAND =  QTY_ON_HAND - @PP_SQF
		WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION_ORIGEN
		AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
		AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE

		IF @@ROWCOUNT = 0
			BEGIN
				RAISERROR ('ERROR SP: PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR', 16, 1 ) --MENSAJE - Severity -State.
				--SET @VP_MENSAJE = 'ERROR: // UPDATE IMLSMST_SQL // '
			END

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = ' PG_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_QUITAR // PG_RN_IMLSMST_SQL_UPDATE ' + @VP_MENSAJE 
		
		RAISERROR (@VP_MENSAJE, 16, 1 ) --MENSAJE - Severity -State.
		
		END
	

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
													0, 0, @PP_LOCACION_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]
GO

CREATE PROCEDURE [dbo].[PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================
	@PP_LOCACION_ORIGEN			VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4)
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''

	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
	--	EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_LOCACION_ORIGEN, @PP_COLOR, @PP_LOTE, @PP_SQF,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN

		UPDATE	IMINVLOC_SQL
		SET		
				QTY_ON_HAND =  QTY_ON_HAND - @PP_SQF
		WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION_ORIGEN
		AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR

		IF @@ROWCOUNT = 0
			BEGIN
				RAISERROR ('ERROR SP: PG_UP_IMINVLOC_SQL_X_LOCACION_COLOR_QUITAR', 16, 1 ) --MENSAJE - Severity -State.		
				--SET @VP_MENSAJE = 'ERROR: // UPDATE IMINVLOC_SQL // '
			END
		END

	-- ///////////////////////////////////////////////////////////////
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
													0, 0, @PP_LOCACION_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE-INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR] 0,0, 'TST', 'TST', 'TEST', 'TEST', 10, 0 

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]
GO

CREATE PROCEDURE [dbo].[PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================		
	@PP_LOCACION_DESTINO		VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4)
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
		
	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
	--	EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			--IF EXISTS( SELECT ITEM_NO FROM IMINVLOC_SQL WHERE LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO AND LTRIM(RTRIM(ITEM_NO))=@PP_COLOR )
			--	BEGIN

			DECLARE @VP_COLOR VARCHAR(20)

			SELECT @VP_COLOR = LTRIM(RTRIM(ITEM_NO)) 
			FROM IMINVLOC_SQL 
			WHERE LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO 
			AND LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
			
			IF @VP_COLOR IS NULL
				SET @VP_COLOR = ''

			IF @VP_COLOR <> ''
				BEGIN
					UPDATE	IMINVLOC_SQL
					SET		
							QTY_ON_HAND =  QTY_ON_HAND + @PP_SQF
					WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO
					AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR

					IF @@ROWCOUNT = 0
						BEGIN
							RAISERROR ('ERROR SP: PG_IN_UP_IMINVLOC_SQL_X_LOCACION_COLOR_AGREGAR', 16, 1 ) --MENSAJE - Severity -State.	
							--SET @VP_MENSAJE = 'ERROR: // UPDATE IMINVLOC_SQL // '
						END

				END
			ELSE
				BEGIN
					
					INSERT	INTO IMINVLOC_SQL (	ITEM_NO, LOC, STATUS, MULT_BIN_FG, QTY_ON_HAND, 
												QTY_ALLOCATED, PROD_CAT, item_filler, std_cost	) 
									VALUES	  ( @PP_COLOR, @PP_LOCACION_DESTINO, 'A', 'N', @PP_SQF,
												'0.0000','LFU','               ', '0.000000'		)
                
					IF @@ROWCOUNT = 0
						SET @VP_MENSAJE = 'ERROR: // INSERT IMINVLOC_SQL // '
				END
		END
	-- ///////////////////////////////////////////////////////////////
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
													0, 0, @PP_LOCACION_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE-INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR] 0,0, 'TST', 'TST', 'TEST', 'TEST', 10, 0 
-- USE DATA_02Pruebas
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]
GO

CREATE PROCEDURE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================
	@PP_LOCACION_ORIGEN			VARCHAR(10),		
	@PP_LOCACION_DESTINO		VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4),
	@PP_TRANSACCION_NO			INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
		
	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
	--	EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			--IF EXISTS( SELECT ITEM_NO FROM IMLSMST_SQL WHERE LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO AND LTRIM(RTRIM(ITEM_NO))=@PP_COLOR AND LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE )
			--	BEGIN
			DECLARE @VP_COLOR VARCHAR(20)

			SELECT @VP_COLOR =LTRIM(RTRIM(ITEM_NO)) 
			FROM IMLSMST_SQL 
			WHERE LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO 
			AND LTRIM(RTRIM(ITEM_NO))=@PP_COLOR 
			AND LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE
			
			IF @VP_COLOR IS NULL
				SET @VP_COLOR = ''

			IF @VP_COLOR <> ''
				BEGIN
					UPDATE	IMLSMST_SQL
					SET		
							QTY_ON_HAND =  QTY_ON_HAND + @PP_SQF
					-- ==================
					WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO
					AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
					AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE

					IF @@ROWCOUNT = 0
						BEGIN
							RAISERROR ('ERROR SP: PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR', 16, 1 ) --MENSAJE - Severity -State.
							--SET @VP_MENSAJE = 'ERROR: // UPDATE IMLSMST_SQL // '
						END

				END
			ELSE
				BEGIN
					-- AGREGADO POR LO DE LOS KITS
					IF LEN(@PP_LOTE) < 7
						SET @PP_LOTE = CONCAT('         ',@PP_LOTE)

					DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
					DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
			
					INSERT	INTO IMLSMST_SQL ( item_no, item_filler, loc, bin_no, 
                                               ser_lot_no, issue_priority, issue_pri_tm, mfg_ser_lot_no,
                                               pkg_id, status, ser_lot_dt, eff_dt,exp_dt, xfer_frm_loc, 
                                               xfer_to_loc, ser_lot_cost, orig_cost, orig_qty, 
                                               qty_on_hand, qty_allocated, issue_ord_no, orig_ord_no, 
                                               mfg_batch_no, dt_lst_cntd, times_cntd_ytd, pct_err_lst_cnt, 
                                               frz_cst, frz_qty, frz_dt, frz_tm, tag_qty, filler_0004 )
									VALUES	( @PP_COLOR, '   ', @PP_LOCACION_DESTINO,'   ',
                                              @PP_LOTE, @VP_F_TRANSACCION, @VP_TIME, '   ',
                                              'IM', 'A', @VP_F_TRANSACCION, @VP_F_TRANSACCION, @VP_F_TRANSACCION,
                                               @PP_LOCACION_ORIGEN, @PP_LOCACION_DESTINO, '0.000000', '0.000000',
                                               @PP_SQF, @PP_SQF, '0.000000', '00000000', 
                                               @PP_TRANSACCION_NO, 0, 0, 0, 
                                               '0.000000', '0.000000', '0.000000', 0, 0, '0.000000', 0 )

					IF @@ROWCOUNT = 0
						SET @VP_MENSAJE = 'ERROR: // INSERT IMLSMST_SQL // '
				END
		END
	-- ///////////////////////////////////////////////////////////////
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
													0, 0, @PP_LOCACION_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_IMLSTRX_SQL] 0,0, 'TEST', 'TEST', 10, 'TEST', 0, 1
-- USE DATA_02Pruebas
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_IMLSTRX_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_IMLSTRX_SQL]
GO

CREATE PROCEDURE [dbo].[PG_IN_IMLSTRX_SQL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_SQF						DECIMAL(13,4),
	@PP_TRANSACCION_NO			INT,
	@PP_INDICE					VARCHAR(10),
	@PP_NIVEL_NO				INT
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
		
	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
	--	EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
			-- AGREGADO POR LO DE LOS KITS
			IF LEN(@PP_LOTE) < 7
				SET @PP_LOTE = CONCAT('         ',@PP_LOTE)

			DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
			DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
			
			INSERT INTO IMLSTRX_SQL ( SOURCE, ORD_NO, CTL_NO, LINE_NO,
                                      LEV_NO, SEQ_NO, SER_LOT_NO, TRX_DT,
                                      TRX_TM, TRX_QTY, EFF_DT, EXP_DT,
                                      EXP_DAYS, ITEM_NO, MFG_SER_LOT_NO, BIN_NO,
                                      TRX_COST, SER_LOT_QTY_SELECT, MFG_BATCH_NO, ITEM_FILLER)
                             VALUES ( 'I', @PP_TRANSACCION_NO, '0', '0', 
                                      @PP_NIVEL_NO, @PP_INDICE, @PP_LOTE, @VP_F_TRANSACCION,
                                      @VP_TIME, @PP_SQF, @VP_F_TRANSACCION, @VP_F_TRANSACCION, 
                                      '30', @PP_COLOR, '   ', @PP_INDICE, 
                                      '0.000000', '0.000000', '0', '' )

			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT IMLSTRX_SQL // '
				
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
													0, 0, @PP_TRANSACCION_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_IMINVTRX_SQL] 0,0, 'TEST', 'TEST', 'TEST', 'TST', 10, 'TEST', 'TEST', 'TEST', 0
-- USE [DATA_02Pruebas] 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_IMINVTRX_SQL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_IMINVTRX_SQL]
GO

CREATE PROCEDURE [dbo].[PG_IN_IMINVTRX_SQL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ========================================			
	@PP_ID_NO					VARCHAR(50),
	@PP_TRANSACCION_NO			VARCHAR(10),
	@PP_COLOR					VARCHAR(20),
	@PP_LOCACION				VARCHAR(5),		
	@PP_SQF						DECIMAL(13,4),
	@PP_ORDEN_NO				VARCHAR(10),
	@PP_USERNAME				VARCHAR(15),
	@PP_COMENTARIO				VARCHAR(255),
	@PP_NIVEL_NO				INT,
	@PP_SEQ_NO					INT,
	@PP_DOC_TYPE				VARCHAR(10), -- 'T' VALOR PARA TRANSACCION POR FOLIO
	@PP_DOC_SOURCE				VARCHAR(10), --	'M' VALOR PARA TRANSACCION POR FOLIO
	@PP_OLD_QUANTITY			DECIMAL(13,4) -- @PP_SQF VALOR PARA TRANSACCION POR FOLIO
AS			

	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
		
	-- /////////////////////////////////////////////////////////////////////
	
	--IF @VP_MENSAJE=''
	--	EXECUTE [dbo].[PG_RN_IMLSMST_SQL_UPDATE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
	--												@PP_LOCACION, @PP_COLOR, @PP_LOTE, @PP_SQF,
	--												@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN

			DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
			DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
			
			INSERT INTO  IMINVTRX_SQL (	SOURCE, ORD_NO, ITEM_NO, LOC, TRX_DT, 

										TRX_TM, DOC_DT, DOC_TYPE, DOC_SOURCE, QUANTITY, 

										DOC_ORD_NO, OLD_QUANTITY, USER_NAME, ID_NO, PROMISE_DT,

										LEV_NO, SEQ_NO, CTL_NO, LINE_NO, FROM_CTL_NO, FROM_LINE_NO, 
										
										FROM_LEV_NO, FROM_SEQ_NO, UNIT_COST, OLD_UNIT_COST, NEW_UNIT_COST, 

										PRICE, BUILD_QTY, BUILD_QTY_PER, AMT, LANDED_COST, RECEIPT_ORD_NO, 

										TRX_QTY_BKORD, DEALL_AMT, batch_id, jnl, item_filler, comment	) 

							VALUES	  ( 'I', @PP_TRANSACCION_NO, @PP_COLOR, @PP_LOCACION, @VP_F_TRANSACCION,

										@VP_TIME, @VP_F_TRANSACCION, @PP_DOC_TYPE, @PP_DOC_SOURCE, @PP_SQF, 

										@PP_ORDEN_NO, @PP_OLD_QUANTITY, @PP_USERNAME, @PP_ID_NO, @VP_F_TRANSACCION,

										@PP_NIVEL_NO, @PP_SEQ_NO, 0, 0, 0, 0,
										
										0, 0, 0, 0, 0, 
										
										0, 0, 0, 0, 0, '0', 
										
										00000000, 0, '' , '', '', @PP_COMENTARIO	)

			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT IMINVTRX_SQL // '
				
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
													0, 0, @PP_TRANSACCION_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_RP_FOLIO_Y_RP_SC_X_FOLIO_Y_STATUS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_RP_FOLIO_Y_RP_SC_X_FOLIO_Y_STATUS]
GO


CREATE PROCEDURE [dbo].[PG_SK_RP_FOLIO_Y_RP_SC_X_FOLIO_Y_STATUS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_STATUS					VARCHAR(5)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
			
	SELECT	DISTINCT
			ISNULL(TAG, 0)		AS TAG, 
			ISNULL(LOT, '')		AS LOT,
			ISNULL(COLOUR, '')  AS COLOUR
	-- =====================
	FROM	RP_Folios 
	INNER JOIN RP_SC ON TAG=TAGNO AND LTRIM(RTRIM(STATUS))=@PP_STATUS
	-- =====================
	
	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- EXEC PG_SK_SER_LOT_COMP_SQL_X_LOTE 0,0,  '032761' , '59071' 
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_SER_LOT_COMP_SQL_X_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_SER_LOT_COMP_SQL_X_LOTE]
GO


CREATE PROCEDURE [dbo].[PG_SK_SER_LOT_COMP_SQL_X_LOTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_SER_LOT_NO_1			VARCHAR(15),
	@PP_SER_LOT_NO_2			VARCHAR(15)
AS

	-- ///////////////////////////////////////////
			
	SELECT	*
	-- =====================
	FROM	SER_LOT_COMP_SQL 
	WHERE	(	LTRIM(RTRIM(SER_LOT_NO1)) = @PP_SER_LOT_NO_1	AND	LTRIM(RTRIM(SER_LOT_NO2)) = @PP_SER_LOT_NO_2	) 
		OR (	LTRIM(RTRIM(SER_LOT_NO1)) = @PP_SER_LOT_NO_2	AND	LTRIM(RTRIM(SER_LOT_NO2)) = @PP_SER_LOT_NO_1	)
	-- =====================

	-- ////////////////////////////////////////////////////////////////
	-- ///////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]
GO

-- EXEC [PG_SK_CCJOBHDR_SQL_X_ORDEN] 0,144, '44801'

CREATE PROCEDURE [dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN_NO				VARCHAR(10)
AS

	-- ////////////////SE OBTIENE LA FECHA ACTUAL ENTERA/////////////////////////////////////////////////////
	DECLARE @VP_F_ACTUAL INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')

	-- ///////////////////////////////////////////
	SELECT	TOP 1 
		ISNULL(FOLIO, 0) AS folio,
		CCJOBHDR_SQL.*,
		IMLOCFIL_SQL.*,
		CONCAT('F',LTRIM(RTRIM(CCJOBHDR_SQL.colour))) AS COLOR_COMPUESTO,
	-- =====================
		( CASE WHEN ISNULL(CCJOBHDR_SQL.datecompleted, 0) = 0	 THEN @VP_F_ACTUAL
			ELSE datecompleted	END) FECHA_COMPLETADA
	-- =====================
	FROM	CCJOBHDR_SQL
	INNER	JOIN IMLOCFIL_SQL ON CCJOBHDR_SQL.machine = IMLOCFIL_SQL.loc_desc
	WHERE	LTRIM(RTRIM(JOBNO)) = @PP_ORDEN_NO
	-- =====================

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]
GO

-- EXEC [PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN] 0,0,   'FMCKTX7' , 'T17' , '09489' 

CREATE PROCEDURE [dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(20),
	@PP_LOCACION				VARCHAR(5),
	@PP_ORDEN_NO				VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_FECHA DATE = GETDATE()
	DECLARE @VP_FECHA_YEAR_ANTES DATE =  DATEADD(YEAR, -1, @VP_FECHA)
	DECLARE @VP_FECHA_MINIMA_BUSQUEDA INT = [dbo].[CONVERT_DATE_TO_INT](@VP_FECHA_YEAR_ANTES, 'yyyyMMdd')

	-- =========================================
		SELECT	IMLSTRX_SQL.ser_lot_no, IMLSTRX_SQL.lev_no, IMINVTRX_SQL.doc_type, 
				IMINVTRX_SQL.doc_ord_no, IMINVTRX_SQL.quantity, IMLSTRX_SQL.trx_qty 
		-- =====================
        FROM	IMLSTRX_SQL 
		INNER	JOIN	IMINVTRX_SQL	ON	Ltrim(Rtrim(IMLSTRX_SQL.source)) = Ltrim(Rtrim(IMINVTRX_SQL.source))
										AND Ltrim(Rtrim(IMLSTRX_SQL.ord_no)) = Ltrim(Rtrim(IMINVTRX_SQL.ord_no)) 
										AND Ltrim(Rtrim(IMLSTRX_SQL.ctl_no)) = Ltrim(Rtrim(IMINVTRX_SQL.ctl_no)) 
										AND Ltrim(Rtrim(IMLSTRX_SQL.line_no)) =Ltrim(Rtrim(IMINVTRX_SQL.line_no)) 
										AND Ltrim(Rtrim(IMLSTRX_SQL.lev_no)) = Ltrim(Rtrim(IMINVTRX_SQL.lev_no)) 
										AND Ltrim(Rtrim(IMLSTRX_SQL.seq_no)) = Ltrim(Rtrim(IMINVTRX_SQL.seq_no)) 
        -- =====================
		WHERE Ltrim(Rtrim(IMINVTRX_SQL.item_no)) = Ltrim(Rtrim(@PP_COLOR))
        AND Ltrim(Rtrim(IMINVTRX_SQL.loc)) = Ltrim(Rtrim(@PP_LOCACION)) 
        AND (Ltrim(Rtrim(IMINVTRX_SQL.doc_ord_no)) = Ltrim(Rtrim(@PP_ORDEN_NO))
			OR Ltrim(Rtrim(IMINVTRX_SQL.doc_ord_no)) = 'J' + Ltrim(Rtrim(@PP_ORDEN_NO))
        ) 
		 -- =====================
		 AND IMLSTRX_SQL.trx_dt >= @VP_FECHA_MINIMA_BUSQUEDA
		 -- =====================
		ORDER BY IMLSTRX_SQL.ser_lot_no, IMINVTRX_SQL.lev_no DESC

	-- ////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
