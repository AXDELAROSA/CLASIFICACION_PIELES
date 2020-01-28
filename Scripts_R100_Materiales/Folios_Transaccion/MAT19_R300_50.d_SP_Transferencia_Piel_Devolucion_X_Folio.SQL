-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			PIEL_CLASIFICADA
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
			RIGHT('00000000' + Ltrim(Rtrim(NEXT_DOC_NO)), 8)	 AS NEXT_DOC
	-- =====================
	FROM	IMCTLFIL_SQL
	-- =====================

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[LI]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
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
				SET @VP_MENSAJE = 'ERROR: // UPDATE IMCTLFIL_SQL // '
		END
	
	-- /////////////////////////////////////////////////////////////////////
	
		
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [DOC_NO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TODOS)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
		SELECT	@VP_MENSAJE AS MENSAJE, 0 AS CLAVE
			

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
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
	@PP_LOCACION_ORIGEN				VARCHAR(10),			
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
			SET @VP_MENSAJE = 'ERROR: // UPDATE IMLSMST_SQL // '

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [IMLSMST_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOC.'+ @PP_LOCACION_ORIGEN +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOCACION_ORIGEN AS CLAVE

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
													0, 0, @PP_LOCACION_ORIGEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> UPDATE-INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_UP_IMLSMST_SQL_X_LOCACION_COLOR_LOTE_AGREGAR] 0,0, 'TST', 'TST', 'TEST', 'TEST', 10, 0 

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
			IF EXISTS( SELECT ITEM_NO FROM IMLSMST_SQL WHERE LOC=@PP_LOCACION_DESTINO AND ITEM_NO=@PP_COLOR AND SER_LOT_NO=@PP_LOTE )
				BEGIN
					UPDATE	IMLSMST_SQL
					SET		
							QTY_ON_HAND =  QTY_ON_HAND + @PP_SQF
					-- ==================
					WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION_DESTINO
					AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
					AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE

					IF @@ROWCOUNT = 0
						SET @VP_MENSAJE = 'ERROR: // UPDATE IMLSMST_SQL // '

				END
			ELSE
				BEGIN
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
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [IMLSMST_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOC.'+ @PP_LOCACION_DESTINO +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOCACION_DESTINO AS CLAVE

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
													0, 0, @PP_LOCACION_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_IMLSTRX_SQL] 0,0, 'TEST', 'TEST', 10, 'TEST', 0, 1

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

			DECLARE @VP_F_TRANSACCION INT = DATA_02.[dbo].CONVERT_DATE_TO_INT(GETDATE(),'yyyyMMdd')
			DECLARE @VP_TIME INT = FORMAT(GETDATE(),  'HHmmss')
			
			INSERT INTO IMLSTRX_SQL ( SOURCE, ORD_NO, CTL_NO, LINE_NO,
                                      LEV_NO, SEQ_NO, SER_LOT_NO, TRX_DT,
                                      TRX_TM, TRX_QTY, EFF_DT, EXP_DT,
                                      EXP_DAYS, ITEM_NO, MFG_SER_LOT_NO, BIN_NO,
                                      TRX_COST, SER_LOT_QTY_SELECT, MFG_BATCH_NO, ITEM_FILLER)
                             VALUES ( 'I', @PP_TRANSACCION_NO, '0', '0', 
                                      @PP_NIVEL_NO, '0', @PP_LOTE, @VP_F_TRANSACCION,
                                      @VP_TIME, @PP_SQF, @VP_F_TRANSACCION, @VP_F_TRANSACCION, 
                                      '30', @PP_COLOR, '   ', @PP_INDICE, 
                                      '0.000000', '0.000000', '0', '' )

			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT IMLSTRX_SQL // '
				
		END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar en [IMLSTRX_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#TRA.'+ @PP_TRANSACCION_NO +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TRANSACCION_NO AS CLAVE

	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
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
			SET @VP_MENSAJE = 'ERROR: // UPDATE IMINVLOC_SQL // '

		END

	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [IMINVLOC_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOC.'+ @PP_LOCACION_ORIGEN +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOCACION_ORIGEN AS CLAVE

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
			IF EXISTS( SELECT ITEM_NO FROM IMLSMST_SQL WHERE LOC=@PP_LOCACION_DESTINO AND ITEM_NO=@PP_COLOR )
				BEGIN
					UPDATE	IMINVLOC_SQL
					SET		
							QTY_ON_HAND =  QTY_ON_HAND + @PP_SQF
					WHERE	LOC=@PP_LOCACION_DESTINO
					AND		ITEM_NO=@PP_COLOR

					IF @@ROWCOUNT = 0
						SET @VP_MENSAJE = 'ERROR: // UPDATE IMINVLOC_SQL // '

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
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [IMINVLOC_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOC.'+ @PP_LOCACION_DESTINO +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_LOCACION_DESTINO AS CLAVE

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
													0, 0, @PP_LOCACION_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> INSERT / 
-- //////////////////////////////////////////////////////////////


-- EXECUTE [dbo].[PG_IN_IMINVTRX_SQL] 0,0, 'TEST', 'TEST', 'TEST', 'TST', 10, 'TEST', 'TEST', 'TEST', 0

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

										@VP_TIME, @VP_F_TRANSACCION, 'T', 'M', @PP_SQF, 

										@PP_ORDEN_NO, @PP_SQF, @PP_USERNAME, @PP_ID_NO, @VP_F_TRANSACCION,

										@PP_NIVEL_NO, 0, 0, 0, 0, 0,
										
										0, 0, 0, 0, 0, 
										
										0, 0, 0, 0, 0, '0', 
										
										00000000, 0, '' , '', '', @PP_COMENTARIO	)

			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT IMINVTRX_SQL // '
				
		END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar en [IMINVTRX_SQL]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#TRA.'+ @PP_TRANSACCION_NO +']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TRANSACCION_NO AS CLAVE

	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
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
	INNER JOIN RP_SC ON TAG=TAGNO AND STATUS=@PP_STATUS
	-- =====================
	
	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_STATUS, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

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

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_SER_LOT_NO_1, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]
GO

-- EXEC [PG_SK_CCJOBHDR_SQL_X_ORDEN] 0,0,'00001'

CREATE PROCEDURE [dbo].[PG_SK_CCJOBHDR_SQL_X_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN_NO				VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
			-- SELECT TOP 100 * FROM CCJOBHDR_SQL
	SELECT	*
	-- =====================
	FROM	CCJOBHDR_SQL
	WHERE	JOBNO = @PP_ORDEN_NO
	-- =====================

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_ORDEN_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]
GO

-- EXEC [PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN] 0,0,'00001'

CREATE PROCEDURE [dbo].[PG_LI_IMLSTRX_SQL_Y_IMINVTRX_SQL_X_COLOR_LOCACION_Y_ORDEN]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(20),
	@PP_LOCACION				VARCHAR(5),
	@PP_ORDEN_NO				VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
		SELECT	IMLSTRX_SQL.ser_lot_no, IMLSTRX_SQL.lev_no, IMINVTRX_SQL.doc_type, 
				IMINVTRX_SQL.doc_ord_no, IMINVTRX_SQL.quantity, IMLSTRX_SQL.trx_qty 
		-- =====================
        FROM	IMLSTRX_SQL 
		INNER	JOIN	IMINVTRX_SQL	ON	IMLSTRX_SQL.source = IMINVTRX_SQL.source 
										AND IMLSTRX_SQL.ord_no = IMINVTRX_SQL.ord_no 
										AND IMLSTRX_SQL.ctl_no = IMINVTRX_SQL.ctl_no 
										AND IMLSTRX_SQL.line_no = IMINVTRX_SQL.line_no 
										AND IMLSTRX_SQL.lev_no = IMINVTRX_SQL.lev_no 
										AND IMLSTRX_SQL.seq_no = IMINVTRX_SQL.seq_no 
        -- =====================
		WHERE IMINVTRX_SQL.item_no = Ltrim(Rtrim(@PP_COLOR))
        AND IMINVTRX_SQL.loc = Ltrim(Rtrim(@PP_LOCACION)) 
        AND (IMINVTRX_SQL.doc_ord_no = Ltrim(Rtrim(@PP_ORDEN_NO))
			OR IMINVTRX_SQL.doc_ord_no = 'J' + Ltrim(Rtrim(@PP_ORDEN_NO))
		--	OR IMINVTRX_SQL.doc_ord_no =  Ltrim(Rtrim(@PP_ORDEN_NO))
        ) 
		 -- =====================
		ORDER BY IMLSTRX_SQL.ser_lot_no, IMINVTRX_SQL.lev_no DESC

	-----////////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_ORDEN_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION]
GO
/*
EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION] 0,0,  'B' , 'FMCKTX7' , 3783390 , 2137674 , 'MCT' , 'T62' , 
												'07861' , '07927' , 0 , 0 , '32701' , '0496' , 39.80 , 0 , 0 , 
												'' , 'franciscoe' , 'ITX-002' 

EXECUTE  [dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION] 0,0, 'B' , 'FMCKTX7' , 3783390 , 2137674 , 'MCT' , 'T62' , 
												'' , '07927' , 0 , 0 , '32701' , '1155' , 38.00 , 0 , 0 , 
												'' , 'franciscoe' , 'ITX-002' 

*/
CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ESTATUS					VARCHAR(5),
	@PP_CB_COLOR				VARCHAR(20),
	-- ===========================
	@PP_TAGNO_ORIGEN			INT,
	@PP_TAGNO_DESTINO			INT,
	-- ===========================
	@PP_CB_LOCACION				VARCHAR(5),
	@PP_TB_LOCACION				VARCHAR(5),
	-- ===========================
	@PP_ORDEN_DESTINO			VARCHAR(10),
	@PP_CB_ORDEN				VARCHAR(10),
	-- ===========================
	@PP_PRT_FORM_DEV_EXT		INT, -- INPRIMIR FORMA #0 N0, #1 SI
	@PP_SELECT_TODOS			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	-- ===========================
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
	-- ===========================
	@PP_TB_SQF					DECIMAL(13,2),
	-- ===========================
	@PP_LOTE_PIEL_EXISTE		INT, -- SI EXISTE #
	@PP_LOTE_PIEL_EXISTE_ADD	INT, -- SI EXISTE Y DESEA ACTUALIZAR #1
	-- ===========================
	@PP_COMENTARIO				VARCHAR(255),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	
	-- ///////////////////////////////////////////
	
	DECLARE @VP_MOVIMIENTO		VARCHAR(10)
	DECLARE @VP_COLOR_ORIGEN	VARCHAR(20)
	DECLARE @VP_COLOR_DESTINO	VARCHAR(20) = @PP_CB_COLOR

	SELECT	TOP 1 @VP_MOVIMIENTO		=	LTRIM(RTRIM(MOVEMENT))
								FROM	RP_SC
								WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAGNO_DESTINO
	--=====================
		
	SELECT	TOP 1 @VP_COLOR_ORIGEN	=	LTRIM(RTRIM(COLOUR))
									FROM	RP_SC
									WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAGNO_ORIGEN
	-- =====================
	
	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////
	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_TAGNO_ORIGEN, @PP_TAGNO_DESTINO,
														@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- ===============================================================
		
	IF @VP_MENSAJE=''
		BEGIN	
			IF @VP_MOVIMIENTO IS NULL OR @VP_MOVIMIENTO = '' -- Si el Folio destino no tiene un movimineto/transaccion toma el valor del Combo CB_LOC
				BEGIN
					EXECUTE [dbo].[PG_RN_VALIDA_LOCACION]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_CB_LOCACION,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
				END
			ELSE
				BEGIN
					SELECT	@PP_CB_LOCACION = LTRIM(RTRIM(IMINVTRX_SQL.Loc))
					FROM	IMLSTRX_SQL, IMINVTRX_SQL 
					WHERE	(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
					AND		IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No 
					AND		IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
					AND		IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No 
					AND		IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No 
					AND		LTRIM(RTRIM(IMINVTRX_SQL.ord_no))=@VP_MOVIMIENTO 
					AND		(( IMLSTRX_SQL.lev_no='0' AND doc_type='R' ) 
							OR  ( IMLSTRX_SQL.lev_no='1' and doc_type='T' ))
				END
		END
		-- ===============================================================

		IF @VP_MENSAJE=''
			IF @PP_CB_LOCACION = @PP_TB_LOCACION
				SET @VP_MENSAJE='La Locacion origen: '+ @PP_TB_LOCACION + 'No puede ser igual a la Locacion destino: ' + @PP_CB_LOCACION
		-- ===============================================================

		IF @VP_MENSAJE=''
			BEGIN
				IF @PP_CB_LOCACION <> 'MHI'
					BEGIN
						IF @PP_ORDEN_DESTINO = ''
						SET @VP_MENSAJE='Proporcione el numero de <ORDEN> a la que desea cargar los pies cuadrados...'

						IF @VP_MENSAJE=''
							EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_ORDEN_DESTINO,
																				@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
						
						IF @VP_MENSAJE=''
							EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_ORDEN_DESTINO,
																				@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
						
						IF @VP_MENSAJE=''
							EXECUTE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																				@PP_ORDEN_DESTINO, @VP_COLOR_ORIGEN,
																				@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
					END
			END
	-- /////////////////////////////////////////////////////////////////////
	
	IF @VP_MENSAJE=''
		BEGIN
		
			BEGIN TRANSACTION 
			BEGIN TRY

				IF NOT EXISTS(	SELECT	TOP 1 TAG	
								FROM RP_Folios  INNER JOIN RP_SC ON TAG=TAGNO 
								WHERE TAGNO = @PP_TAGNO_DESTINO AND STATUS=@PP_ESTATUS AND COLOUR = @PP_CB_COLOR	)
					BEGIN
						EXECUTE [dbo].[PG_IN_RP_FOLIOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_TAGNO_DESTINO, @PP_ESTATUS, NULL, NULL, NULL
					END
				-- /////////////////////////////////////////////////////////////////////

				IF	@PP_SELECT_TODOS = 1
					EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
															@PP_TAGNO_ORIGEN, 'A', NULL, NULL
				-- /////////////////////////////////////////////////////////////////////
													
				--DECLARE	@PP_COLOR_ARRAY				NVARCHAR(MAX)='FMCKTX7'
				--DECLARE	@PP_LOTE_ARRAY				NVARCHAR(MAX)='32701'
				--DECLARE	@PP_PIEL_ARRAY				NVARCHAR(MAX)='0496'
				--DECLARE	@PP_SQF_ARRAY				NVARCHAR(MAX)='39.80'
				--DECLARE	@PP_MOVIMIENTO_ARRAY		NVARCHAR(MAX)='04246651'
								
				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(20),
						LOTE		VARCHAR(20),
						PIEL		VARCHAR(20),
						SQF			VARCHAR(20),
						MOVIMIENTO	VARCHAR(20)
					)
				SET NOCOUNT ON
				
				DECLARE @VP_POSICION_PIEL			INT
				DECLARE @VP_POSICION_COLOR			INT
				DECLARE @VP_POSICION_LOTE			INT
				DECLARE @VP_POSICION_SQF			INT
				DECLARE @VP_POSICION_MOVIMIENTO		INT

				DECLARE @VP_LOTE_VALOR				VARCHAR(20)
				DECLARE @VP_PIEL_VALOR				VARCHAR(20)
				DECLARE @VP_SQF_VALOR				VARCHAR(20)
				DECLARE @VP_MOVIMIENTO_VALOR		VARCHAR(20)
								
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_LOTE_ARRAY			= @PP_LOTE_ARRAY		+ '/'		
				SET	@PP_PIEL_ARRAY			= @PP_PIEL_ARRAY		+ '/'		
			
				--Hacemos un bucle que se repite mientras haya separadores, patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%/%' , @PP_PIEL_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION_PIEL	=	patindex('%/%' , @PP_PIEL_ARRAY)
						SELECT @VP_POSICION_LOTE	=	patindex('%/%' , @PP_LOTE_ARRAY)
						
						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_PIEL_VALOR		= LEFT(@PP_PIEL_ARRAY, @VP_POSICION_PIEL - 1)
						SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION_LOTE - 1)
						
						SELECT	TOP 1 @VP_SQF_VALOR = SQF,
								@VP_MOVIMIENTO_VALOR = MOVEMENT
												FROM	RP_SC 
												WHERE	LTRIM(RTRIM(COLOUR)) = @PP_CB_COLOR 
												AND		LTRIM(RTRIM(TAGNO)) = @PP_TAGNO_ORIGEN
												AND		LTRIM(RTRIM(LOT)) = @VP_LOTE_VALOR
												AND		LTRIM(RTRIM(HIDE)) = @VP_PIEL_VALOR

						INSERT	INTO	@TBL_PIEL_SELECCIONADAS
								VALUES	(
											@PP_CB_COLOR,
											@VP_LOTE_VALOR,
											@VP_PIEL_VALOR,
											@VP_SQF_VALOR,
											@VP_MOVIMIENTO_VALOR	)
																								
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_PIEL_ARRAY			= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION_PIEL, '')
						SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION_LOTE, '')

					END
								
				DECLARE @VP_N_PIEL INT = 0
				DECLARE @VP_CONTADOR INT = 1 

				SELECT @VP_N_PIEL = COUNT(K_PIEL_SELECCIONADA) FROM @TBL_PIEL_SELECCIONADAS

				-- /////////////////////////SI NO HAY PIELES SELECCIONADAS GENERAMOS UN ERROR DE TRANSACCION////////////////////////////////////////////
				IF @VP_N_PIEL IS NULL
					RAISERROR ('Error raised in TRY block.', 16, 1 ) --MENSAJE - Severity -State.
									
				DECLARE @VP_COLOR_TBL VARCHAR(10)
				DECLARE @VP_LOTE_TBL VARCHAR(10)
				DECLARE @VP_PIEL_TBL VARCHAR(10)
				DECLARE @VP_SQF_TBL	 VARCHAR(10)
				DECLARE @VP_TOTAL_SQF DECIMAL(13,2)

				-- /////////////////////////SI LAS PIELES A TRANSFERIR SON MAS DE UNA////////////////////////////////////////////
				IF @VP_N_PIEL > 1
					BEGIN
						WHILE @VP_CONTADOR <= @VP_N_PIEL
							BEGIN
								DECLARE @VP_F_ACTUAL	AS DATE = GETDATE()
							
								SELECT	@VP_LOTE_TBL	= LOTE,
										@VP_PIEL_TBL	= PIEL,
										@VP_SQF_TBL		= SQF
														FROM @TBL_PIEL_SELECCIONADAS
														WHERE K_PIEL_SELECCIONADA = @VP_CONTADOR

								-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
								EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@VP_F_ACTUAL, @PP_CB_COLOR, @VP_LOTE_TBL, 
																@VP_PIEL_TBL, @VP_SQF_TBL, @PP_TAGNO_DESTINO, 
																NULL, NULL, NULL, 'E', @PP_CB_LOCACION, 0

								-- /////////////////////////ACTUALIZO EL FOLIO ANTERIOR////////////////////////////////////////////

								EXECUTE [dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, 'D', @VP_PIEL_TBL, @VP_LOTE_TBL
							
								-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////

								DECLARE @VP_DETAIL VARCHAR(100) = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO) + ' Lot: ' + RIGHT('000000' + Ltrim(Rtrim(@VP_LOTE_TBL)), 6)
								EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																	@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																	@PP_TAGNO_ORIGEN, 'Transfer',
																	@VP_DETAIL, @VP_PIEL_TBL

								-- /////////////////////////SI DESEA IMPRIMIR EL FORMATO DE DEVOLUCION Y EXTRAS////////////////////////////////////////////
								IF @PP_PRT_FORM_DEV_EXT = 1 -- SI
									BEGIN
										DECLARE	@VP_ESTATUS	VARCHAR(5)

										-- /////////////////VALIDA ESTATUS FOLIO ORIGEN////////////////////////////////////////////////////
										SELECT	@VP_ESTATUS	= LTRIM(RTRIM(STATUS))
															FROM RP_Folios
															WHERE LTRIM(RTRIM(TAG)) = @PP_TAGNO_ORIGEN

										IF @VP_ESTATUS <> 'B'
											BEGIN
												EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, 5
											END
										ELSE
											BEGIN
												EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_ORIGEN, 'D'
											END

										-- /////////////////VALIDA ESTATUS FOLIO DESTINO////////////////////////////////////////////////////
										SET	@VP_ESTATUS = ''
										SELECT	@VP_ESTATUS	= LTRIM(RTRIM(STATUS))
															FROM RP_Folios
															WHERE LTRIM(RTRIM(TAG)) = @PP_TAGNO_DESTINO

										IF @VP_ESTATUS <> 'B'
											BEGIN
												EXECUTE [dbo].[PG_IN_RP_SC_PRT]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_DESTINO, 4
											END
										ELSE
											BEGIN
												EXECUTE	[dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_TAGNO_DESTINO, 'E', 'C'
											END
									END	
								ELSE
									BEGIN
										-- //////////////////////////////BORRA EL FOLIO ORIGEN///////////////////////////////////////
										EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_Y_TIPO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_TAGNO_ORIGEN, 'D'

										-- ////////////////////////////INGRESA EL LOG/////////////////////////////////////////
										
										SET @VP_DETAIL = 'Delete hides por devolucion (ya se agrego al nuevo folio) Lot:' + @VP_LOTE_TBL
		
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																			@PP_TAGNO_ORIGEN, 'Delete hides',
																			@VP_DETAIL, @VP_PIEL_TBL

										-- //////////////////////////////ACTUALIZA EL FOLIO DESTINO A TIPO C ///////////////////////////////////////
										EXECUTE	[dbo].[PG_UP_RP_SC_TYPE_X_FOLIO_Y_TIPO]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																							@PP_TAGNO_DESTINO, 'E', 'C'
									
									END
									-- ///////////////////////////////////////////
								SET @VP_CONTADOR = @VP_CONTADOR + 1			
								-- ///////////////////////////////////////////				
							END
					END
				ELSE IF @VP_N_PIEL = 1
					BEGIN
						SELECT	TOP 1
								@VP_COLOR_TBL	= COLOR,
								@VP_LOTE_TBL	= LOTE,
								@VP_PIEL_TBL	= PIEL,
								@VP_SQF_TBL		= SQF
								-- =======================
						FROM	@TBL_PIEL_SELECCIONADAS

						-- /////////////////////////////////////////////////////////////////////
						-- /////////////////////////////////////////////////////////////////////
						IF (CAST(@VP_SQF_TBL AS DECIMAL(13,2)) = @PP_TB_SQF)
							BEGIN
								IF (@PP_LOTE_PIEL_EXISTE=1)
									BEGIN
										IF  @PP_LOTE_PIEL_EXISTE_ADD = 1
											BEGIN
												DECLARE @VP_SQF		VARCHAR(10)
												SELECT  @VP_SQF		= SQF 
																	FROM RP_SC
																	WHERE	LTRIM(RTRIM(TAGNO))=@PP_TAGNO_DESTINO
																	AND		LTRIM(RTRIM(COLOUR))=@PP_CB_COLOR
																	AND		LTRIM(RTRIM(HIDE))=@VP_PIEL_TBL
																	AND		LTRIM(RTRIM(LOT))=@VP_LOTE_TBL
												-- /////////////////////////////////////////////////////////////////////
												     										
												SET @VP_TOTAL_SQF = CAST(@VP_SQF AS DECIMAL(13,2)) + @PP_TB_SQF
												
												-- /////////////////////////SUMA AL FOLIO DESTINO LOS SQF////////////////////////////////
												EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																										@VP_TOTAL_SQF, @PP_TAGNO_DESTINO, 
																										@VP_LOTE_TBL, @VP_PIEL_TBL
												-- /////////////////////////BORRA EL FOLIO ORIGEN////////////////////////////////////////////
												EXECUTE	[dbo].[PG_DL_RP_SC_X_FOLIO_LOTE_PIEL]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																								@PP_TAGNO_ORIGEN, @VP_LOTE_TBL, @VP_PIEL_TBL 
												
												-- /////////////////////////INGRESA EL LOG////////////////////////////////////////////
												SET @VP_DETAIL = 'Delete hide sqf restantes en 0 Lot: ' + @VP_LOTE_TBL
												EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																					@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																					@PP_TAGNO_ORIGEN, 'Delete hide',
																					@VP_DETAIL, @VP_PIEL_TBL
											END
									END
								ELSE
									BEGIN
										-- /////////////////////////REEMPLAZO EL FOLIO ORIGEN POR FOLIO EL DESTINO///////////////
										EXECUTE	[dbo].[PG_UP_RP_SC_TAGNO_X_FOLIO_PIEL_LOTE_SQF]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																									@PP_TAGNO_DESTINO, @PP_TAGNO_ORIGEN,
																									@VP_PIEL_TBL, @VP_LOTE_TBL, @VP_SQF_TBL
			
										-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'Transfer hide: ' + @VP_PIEL_TBL + ' to: ' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO) + 'Lot:' + @VP_LOTE_TBL
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																			@PP_TAGNO_ORIGEN, 'Transfer',
																			@VP_DETAIL, @VP_PIEL_TBL															
									END
								-- /////////////////////////////////////////////////////////////////////
								-- /////////////////////////////////////////////////////////////////////							
							END
						ELSE
							BEGIN
								SET @VP_TOTAL_SQF =  CAST(@VP_SQF_TBL AS DECIMAL(13,2)) - @PP_TB_SQF

								-- ///////////////RESTA AL FOLIO ORIGEN EL SQF QUE SE AGREGO AL FOLIO DESTINO ///////////////
								EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																						@VP_TOTAL_SQF, @PP_TAGNO_ORIGEN,
																						@VP_LOTE_TBL, @VP_PIEL_TBL

								IF (@PP_LOTE_PIEL_EXISTE=1)
									BEGIN
										IF  @PP_LOTE_PIEL_EXISTE_ADD = 1
											BEGIN
												-- /////////////////////////SUMA AL FOLIO DESTINO LOS SQF////////////////////////////////
												EXECUTE	[dbo].[PG_UP_RP_SC_SQF_X_FOLIO_LOTE_Y_PIEL]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																										@PP_TB_SQF, @PP_TAGNO_DESTINO, 
																										@VP_LOTE_TBL, @VP_PIEL_TBL
											END
									END
								ELSE
									BEGIN
										-- /////////////////////////INGRESO EL FOLIO NUEVO////////////////////////////////////////////
										EXECUTE [dbo].[PG_IN_RP_SC]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																		@VP_F_ACTUAL, @VP_COLOR_TBL, @VP_LOTE_TBL, 
																		@VP_PIEL_TBL, @PP_TB_SQF, @PP_TAGNO_DESTINO, 
																		NULL, NULL, NULL, 'C', @PP_CB_LOCACION, 0	
																		
											-- /////////////////////////INGRESO EL LOG////////////////////////////////////////////
										SET @VP_DETAIL = 'New part hide: ' + @VP_PIEL_TBL + ' / ' + CONVERT(VARCHAR(20),@PP_TB_SQF) + 'from:' + CONVERT(VARCHAR(20),@PP_TAGNO_DESTINO)
										EXECUTE [dbo].[PG_IN_PEARL_LOG]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																			@PP_USER, @PP_COMPUTER_NAME, 'FoliosN',
																			@PP_TAGNO_ORIGEN, 'Add',
																			@VP_DETAIL, @VP_PIEL_TBL
                    								
									END
							END
						-- /////////////////////////////////////////////////////////////////////
						-- /////////////////////////////////////////////////////////////////////
					END
					-- ///////////////OBTENEMOS LOS SQF DE LOS DIFERENTES LOTES A TRANSFERIR//////////////////////////////////////////////////////
					
					IF (	SELECT COUNT(*) FROM sys.table_types
							WHERE name = 'TVPParam' AND schema_id = 1	) = 0
							CREATE TYPE dbo.TVPParam AS TABLE(	COLOR		VARCHAR(20),
																LOTE		VARCHAR(20),
																SQF			VARCHAR(20)	)
				
					DECLARE @TBL_TOTAL_SQF_X_LOTE	TVPParam 

					INSERT INTO  @TBL_TOTAL_SQF_X_LOTE 
					SELECT COLOR, LOTE, SUM(CONVERT(DECIMAL(13,4),SQF)) AS SQF 
					FROM @TBL_PIEL_SELECCIONADAS
					GROUP BY COLOR, LOTE
									
					-- /////////////////////////////////////////////////////////////////////

					EXECUTE [dbo].[PG_PM_TRANSFER]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_TAGNO_DESTINO, @PP_CB_LOCACION, @PP_TB_LOCACION,
														@PP_ORDEN_DESTINO, @PP_CB_ORDEN,  @TBL_TOTAL_SQF_X_LOTE,
													--	@PP_DG2_COLOR_ARRAY, @PP_DG2_LOTE_ARRAY, @PP_DG2_SQF_ARRAY,						 	
														@PP_TB_SQF, @PP_COMENTARIO, @PP_USER
																			
					-- /////////////////////////////////////////////////////////////////////
								
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PM_TRANSFER_PIEL_DEVOLUCION // '
			END CATCH
			
		END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAGNO_DESTINO AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE COT19_Cotizaciones_V9999_R0.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'SELECT',
													'',
													-- ===========================================
													'[SK]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_TAGNO_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
