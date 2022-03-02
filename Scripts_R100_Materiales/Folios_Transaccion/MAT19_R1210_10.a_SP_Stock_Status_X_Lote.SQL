-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	1/JUN/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
/*
 EXEC DBO.[PG_LI_STOCK_STATUS_X_LOTE] 0,0, '109573' 
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_STOCK_STATUS_X_LOTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_STOCK_STATUS_X_LOTE]
GO

CREATE PROCEDURE [dbo].[PG_LI_STOCK_STATUS_X_LOTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10)
AS

	SET @PP_LOTE =  RIGHT('000000' + @PP_LOTE, 6)

	-- ///////////////////////////////////////////
	SELECT	LTRIM(RTRIM([item_no])) AS COLOR
			,[item_filler]
			,LTRIM(RTRIM([loc])) AS LOC
			,[bin_no]
			,LTRIM(RTRIM([ser_lot_no])) AS LOT
			,[issue_priority]
			,[issue_pri_tm]
			,[mfg_ser_lot_no]
			,[pkg_id]
			,[status]
			,[ser_lot_dt]
			,[eff_dt]
			,[exp_dt]
			,[hold_rsn]
			,[xfer_frm_loc]
			,[xfer_to_loc]
			,[ser_lot_cost]
			,[orig_cost]
			,[orig_qty]
			,[qty_on_hand]
			,[qty_allocated]
			,[valid_fg]
			,[issue_ord_type]
			,[issue_ord_no]
			,[orig_ord_type]
			,[orig_ord_no]
			,[mfg_batch_no]
			,[prev_status]
			,[cycle_cnt_cd]
			,[dt_lst_cntd]
			,[times_cntd_ytd]
			,[pct_err_lst_cnt]
			,[frz_cst]
			,[frz_qty]
			,[frz_dt]
			,[frz_tm]
			,[tag_qty]
			,[filler_0004]
			,[A4GLIdentity]
	FROM [DATA_02].[dbo].[IMLSMST_SQL] (NOLOCK)
	WHERE LTRIM(RTRIM([ser_lot_no])) = @PP_LOTE
    AND qty_on_hand > 0
	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
