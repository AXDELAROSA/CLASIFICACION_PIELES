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

	DECLARE @VP_LI_N_REGISTROS		INT = 100

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

	IF @VP_MENSAJE = ''
		BEGIN
		
			IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [DOC_NO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TODOS)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
		SELECT	@VP_MENSAJE AS MENSAJE, 0 AS CLAVE
			
		END
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
		WHERE	LOC=@PP_LOCACION_ORIGEN
		AND		ITEM_NO=@PP_COLOR
		AND		SER_LOT_NO=@PP_LOTE

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
					WHERE	LOC=@PP_LOCACION_DESTINO
					AND		ITEM_NO=@PP_COLOR
					AND		SER_LOT_NO=@PP_LOTE

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
	@PP_TRANSACCION_NO			VARCHAR(10),
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
		WHERE	LOC=@PP_LOCACION_ORIGEN
		AND		ITEM_NO=@PP_COLOR

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


-- EXECUTE [dbo].[PG_IN_IMINVTRX_SQL] 0,0, 'TEST', 'TEST', 'TEST', 'TST', 10, 'TEST', 'TEST', 'TEST'

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
	@PP_COMENTARIO				VARCHAR(100),
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
										@PP_NIVEL_NO, 0, 0, 0, 0, 0, 0,
										0, 0, 0, 0, 0, 0,
										0, 0, 0, 00000000, 0, 0 ,
										'', '', '', @PP_COMENTARIO	)

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




-- EXECUTE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO] 0,0, 0
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]
GO


CREATE PROCEDURE [dbo].[PG_UP_RP_SC_MOVEMENT_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_TAG_NO					INT,
	@PP_TAG_NO_ACTUAL			INT,
	@PP_MOVEMENT				VARCHAR(10),
	@PP_UP_TAGNO				INT

AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	--SELECT * FROM RP_SC WHERE TAGNO =3777539
	
	UPDATE RP_SC 
	SET		MOVEMENT	=	@PP_MOVEMENT,
			TAGNO		=	( CASE	WHEN @PP_UP_TAGNO = 1 THEN @PP_TAG_NO_ACTUAL 
														  ELSE TAGNO	END		)
	-- ===========================
	WHERE	TAGNO=@PP_TAG_NO

	IF @@ROWCOUNT = 0
	SET @VP_MENSAJE = 'ERROR: // UPDATE RP_SC  // '

	-- /////////////////////////////////////////////////////////////////////
	
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible actualizar el [FOLIO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO AS CLAVE
	
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
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
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

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	-- =========================================
			
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
			
			IF @@ROWCOUNT = 0
				SET @VP_MENSAJE = 'ERROR: // INSERT RP_Folios // '
		END
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@PP_TAG_NO)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_TAG_NO AS CLAVE
	
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
													0, 0, @PP_TAG_NO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RP_SC]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RP_SC]
GO

-- EXEC PG_LI_RP_SC_Y_RP_FOLIO 0 ,0, '32291', '0023' 

CREATE PROCEDURE [dbo].[PG_LI_RP_SC]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT,
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20),
	@PP_PIEL					VARCHAR(10)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_LI_N_REGISTROS		INT = 10000

	IF	@PP_FOLIO = 0
		BEGIN
			
			SELECT	@PP_FOLIO=ISNULL(TAG, 0)
			-- =====================
			FROM	RP_Folios  
			-- =====================
			INNER JOIN RP_SC ON TAG=TAGNO AND RTRIM(LTRIM(STATUS))='B' AND COLOUR=@PP_COLOR
			GROUP BY TAG, COLOUR
					
			-- /////////////////////////////////////////////////////////////////////

			IF @PP_FOLIO IS NULL 
				BEGIN
					EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'RP_SC', 'TAGNO',
																@OU_K_TABLA_DISPONIBLE = @PP_FOLIO	OUTPUT
				END
			-- =========================================
		END

	SELECT 
			ISNULL(CDATE, '')		AS CDATE,
			ISNULL(COLOUR, '')		AS COLOUR,
			ISNULL(LOT, '')			AS LOT,
			ISNULL(HIDE, '')		AS HIDE,
			ISNULL(SQF, '')			AS SQF,
			ISNULL(TAGNO, 0)		AS TAGNO,
			ISNULL(YARDAS, '')		AS YARDAS,
			ISNULL(YLB, '')			AS YLB,
			ISNULL(PESO, '')		AS PESO,
			ISNULL(TYPE, '')		AS TYPE,
			ISNULL(MOVEMENT, '')	AS MOVEMENT
	FROM	RP_SC 
	-- =======================
	WHERE	TAGNO=@PP_FOLIO
	AND		COLOUR=@PP_COLOR
	AND		LOT=@PP_LOTE
	AND		HIDE=@PP_PIEL	
	-- =======================
	ORDER BY CDATE DESC
          

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
													0, 0, @PP_LOTE, '' , 0.00, 0.00,
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


CREATE PROCEDURE [dbo].[PG_PM_TRANSFER_PIEL_DEVOLUCION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ESTATUS					VARCHAR(5),
	@PP_COLOR					VARCHAR(20),
	@PP_TAGNO_ORIGEN			INT,
	@PP_LOCACION				VARCHAR(5),
	@PP_ORDEN_DESTINO			VARCHAR(10),
	@PP_PRT_FORM_DEV_EXT		INT, -- INPRIMIR FORMA #0 N0, #1 SI
	@PP_SELECT_TODOS			INT, -- SE SELECCIONARON TODAS LAS PIELES #0 N0, #1 SI
	@PP_COLOR_ARRAY				NVARCHAR(MAX),
	@PP_LOTE_ARRAY				NVARCHAR(MAX),
	@PP_PIEL_ARRAY				NVARCHAR(MAX),
	@PP_SQF_ARRAY				NVARCHAR(MAX),
	@PP_MOVIMIENTO_ARRAY		NVARCHAR(MAX),
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	
	-- ///////////////////////////////////////////
	DECLARE	@VP_TAGNO_DESTINO INT = 0

	SELECT	@VP_TAGNO_DESTINO=ISNULL(TAG, 0)
	-- =====================
	FROM	RP_Folios  
	-- =====================
	INNER JOIN RP_SC ON TAG=TAGNO AND STATUS=@PP_ESTATUS AND COLOUR=@PP_COLOR
	GROUP BY TAG, COLOUR
			
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_TAGNO_DESTINO IS NULL 
		BEGIN
			EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'RP_SC', 'TAGNO',
														@OU_K_TABLA_DISPONIBLE = @VP_TAGNO_DESTINO	OUTPUT
		END

		DECLARE @VP_MOVIMIENTO		VARCHAR(10)
		DECLARE @VP_COLOR_ORIGEN	VARCHAR(20)
		DECLARE @VP_COLOR_DESTINO	VARCHAR(20)

		SELECT	@VP_MOVIMIENTO		=	LTRIM(RTRIM(MOVEMENT)),
				@VP_COLOR_DESTINO	=	LTRIM(RTRIM(COLOUR))
									FROM	RP_SC
									WHERE	TAGNO=@VP_TAGNO_DESTINO
			-- =====================

		SELECT	@VP_COLOR_ORIGEN	=	LTRIM(RTRIM(COLOUR))
									FROM	RP_SC
									WHERE	TAGNO=@PP_TAGNO_ORIGEN
			-- =====================

	-- /////////////////////////// RN - VALIDACIONES //////////////////////////////////////////

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_TAGNO_ORIGEN, @VP_TAGNO_DESTINO,
														@VP_COLOR_ORIGEN, @VP_COLOR_DESTINO,
														@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
	-- ===============================================================

	IF @VP_MENSAJE=''
		BEGIN	
			IF @VP_MOVIMIENTO IS NULL
				BEGIN
					EXECUTE [dbo].[PG_RN_VALIDA_LOCACION]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
																@PP_LOCACION,
																@OU_RESULTADO_VALIDACION = @VP_MENSAJE		OUTPUT
				END
			ELSE
				BEGIN
					SELECT	@PP_LOCACION = LTRIM(RTRIM(IMINVTRX_SQL.Loc))
					FROM	IMLSTRX_SQL, IMINVTRX_SQL 
					WHERE	(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
					AND		IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No 
					AND		IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
					AND		IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No 
					AND		IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No 
					AND		IMINVTRX_SQL.ord_no=@VP_MOVIMIENTO 
					AND		(( IMLSTRX_SQL.lev_no='0' AND doc_type='R' ) 
							OR  ( IMLSTRX_SQL.lev_no='1' and doc_type='T' ))
				END
		END
		-- ===============================================================

		IF @VP_MENSAJE=''
			BEGIN
				IF @PP_LOCACION <> 'MHI'
					BEGIN
						SET @VP_MENSAJE='Favor de proporcionar el numero de <ORDEN> a la que desea cargar los pies cuadrados...'

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
		
				EXECUTE [dbo].[PG_IN_RP_FOLIOS]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													@VP_TAGNO_DESTINO, @PP_ESTATUS, NULL, NULL, NULL
				-- /////////////////////////////////////////////////////////////////////

				IF	@PP_SELECT_TODOS = 1
					EXECUTE	[dbo].[PG_UP_RP_FOLIO_X_FOLIO]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION, 
															@PP_TAGNO_ORIGEN, 'A', NULL, NULL
				-- /////////////////////////////////////////////////////////////////////
								
					--DECLARE @PP_COLOR_ARRAY				NVARCHAR(MAX) =	'1,2,3,4,5,6,7,8,9'
					--DECLARE @PP_LOTE_ARRAY				NVARCHAR(MAX) =	'A,B,C,D,E,F,G,H,I'
					--DECLARE @PP_PIEL_ARRAY				NVARCHAR(MAX) =	'1,2,3,4,5,6,7,8,9'
					--DECLARE @PP_SQF_ARRAY				NVARCHAR(MAX) =	'A,B,C,D,E,F,G,H,I'
					--DECLARE @PP_MOVIMIENTO_ARRAY		NVARCHAR(MAX) =	'1,2,3,4,5,6,7,8,9'
				
				DECLARE @TBL_PIEL_SELECCIONADAS TABLE (
						K_PIEL_SELECCIONADA INT IDENTITY(1,1),
						COLOR		VARCHAR(20),
						LOTE		VARCHAR(20),
						PIEL		VARCHAR(20),
						SQF			VARCHAR(20),
						MOVIMIENTO	VARCHAR(20)
					)
				SET NOCOUNT ON
				
				--@Posicion es la posicion de cada uno de nuestros separadores
				DECLARE @VP_POSICION	 INT
				
				--Contendran cada uno de los valores obtenidos que almacenaremos en las siguientes variables
				DECLARE @VP_COLOR_VALOR			VARCHAR(20)
				DECLARE @VP_LOTE_VALOR			VARCHAR(20)
				DECLARE @VP_PIEL_VALOR			VARCHAR(20)
				DECLARE @VP_SQF_VALOR			VARCHAR(20)
				DECLARE @VP_MOVIMIENTO_VALOR	VARCHAR(20)
				
				
				--Colocamos un separador al final de los parametros para que funcione bien nuestro codigo
				SET	@PP_COLOR_ARRAY			= @PP_COLOR_ARRAY		+ ',' 	
				SET	@PP_LOTE_ARRAY			= @PP_LOTE_ARRAY		+ ','		
				SET	@PP_PIEL_ARRAY			= @PP_PIEL_ARRAY		+ ','		
				SET	@PP_SQF_ARRAY			= @PP_SQF_ARRAY			+ ','	
				SET	@PP_MOVIMIENTO_ARRAY	= @PP_MOVIMIENTO_ARRAY	+ ','
			
				--Hacemos un bucle que se repite mientras haya separadores
				--patindex busca un patron en una cadena y nos devuelve su posicion
				WHILE patindex('%,%' , @PP_COLOR_ARRAY) <> 0
					BEGIN
						SELECT @VP_POSICION =  patindex('%,%' , @PP_COLOR_ARRAY)

						--Buscamos la posicion de la primera y obtenemos los caracteres hasta esa posicion
						SELECT @VP_COLOR_VALOR		= LEFT(@PP_COLOR_ARRAY, @VP_POSICION - 1)
						SELECT @VP_LOTE_VALOR		= LEFT(@PP_LOTE_ARRAY, @VP_POSICION - 1)
						SELECT @VP_PIEL_VALOR		= LEFT(@PP_PIEL_ARRAY, @VP_POSICION - 1)
						SELECT @VP_SQF_VALOR		= LEFT(@PP_SQF_ARRAY, @VP_POSICION - 1)
						SELECT @VP_MOVIMIENTO_VALOR = LEFT(@PP_MOVIMIENTO_ARRAY, @VP_POSICION - 1)
										
						--Los parámetros los guardamos en la tabla temporal
						INSERT	INTO	@TBL_PIEL_SELECCIONADAS
								VALUES	(
											@VP_COLOR_VALOR,
											@VP_LOTE_VALOR,
											@VP_PIEL_VALOR,
											@VP_SQF_VALOR,
											@VP_MOVIMIENTO_VALOR	)
						
						--Reemplazamos lo procesado con nada con la funcion stuff
						SELECT @PP_COLOR_ARRAY			= STUFF(@PP_COLOR_ARRAY, 1, @VP_POSICION, '')
						SELECT @PP_LOTE_ARRAY			= STUFF(@PP_LOTE_ARRAY, 1, @VP_POSICION, '')
						SELECT @PP_PIEL_ARRAY			= STUFF(@PP_PIEL_ARRAY, 1, @VP_POSICION, '')
						SELECT @PP_SQF_ARRAY			= STUFF(@PP_SQF_ARRAY, 1, @VP_POSICION, '')
						SELECT @PP_MOVIMIENTO_ARRAY		= STUFF(@PP_MOVIMIENTO_ARRAY, 1, @VP_POSICION, '')
					END
								
				--Cuando se han recorrido todos los parametros sacamos por pantalla el resultado
				--SELECT * FROM @TBL_PIEL_SELECCIONADAS


			
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				SET @VP_MENSAJE = 'ERROR: //TRASAC. PG_PM_TRANSFER_PIEL_DEVOLUCION // '
			END CATCH	
		END


	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible insertar el [FOLIO]: ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_TAGNO_DESTINO AS CLAVE
	
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
													0, 0, @VP_TAGNO_DESTINO, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '@PP_BUSCAR', '', '', ''

	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
