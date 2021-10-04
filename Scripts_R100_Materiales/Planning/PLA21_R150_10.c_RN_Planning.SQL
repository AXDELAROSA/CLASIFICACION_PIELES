-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PLANNING
-- // OPERACION:		LIBERACION / REGLAS DE NEGOCIO
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	26/MAY/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO


-- //////////////////////////////////////////////////////////////


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PLANNING_VALIDA_ORDEN_ABIERTA_X_COLOR_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PLANNING_VALIDA_ORDEN_ABIERTA_X_COLOR_LOCACION]
GO
/*
	 EXEC [PG_RN_PLANNING_VALIDA_ORDEN_ABIERTA_X_COLOR_LOCACION] 0, 144, 'FCNPDX9', 'Table 37'
	 EXEC [PG_RN_PLANNING_VALIDA_ORDEN_ABIERTA_X_COLOR_LOCACION] 0, 144, 'FCNPDX9', 'TABLE 40'
*/
CREATE PROCEDURE [dbo].[PG_RN_PLANNING_VALIDA_ORDEN_ABIERTA_X_COLOR_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(50),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 	
	DECLARE @VP_MENSAJE			VARCHAR(255) = ''
	DECLARE @VP_COLOR_SIN_F VARCHAR(25) = SUBSTRING(@PP_COLOR, 2 , 10)
	-- /////////////////////////////////////////////////////

	DECLARE @VP_N_ORDEN_ABIERTA INT = 0
	SELECT @VP_N_ORDEN_ABIERTA = COUNT(JOBNO) 
	FROM ccjobhdr_sql
	WHERE status = 'P' 
	AND machine = @PP_LOCACION 
	AND COLOUR = @VP_COLOR_SIN_F 
	AND ( LOTNO IS NULL OR LOTNO = '' )
	
	IF @VP_N_ORDEN_ABIERTA IS NULL
		SET @VP_N_ORDEN_ABIERTA = 0

	IF ( @PP_COLOR = 'FCNPDX9' OR @PP_COLOR = 'FNRUDX9' )
		BEGIN
			IF @VP_N_ORDEN_ABIERTA > 49
				SET @VP_RESULTADO = 'Existen ' + CONVERT(VARCHAR(10), @VP_N_ORDEN_ABIERTA) + ' ordenes abiertas para el Color: ' + @PP_COLOR + ' en la Locación: ' + @PP_LOCACION + '.'
		END

	IF ( @PP_COLOR = 'FCPRHL1' OR @PP_COLOR = 'FCPRDX9'  )
		BEGIN
			IF @VP_N_ORDEN_ABIERTA > 99
				SET @VP_RESULTADO = 'Existen ' + CONVERT(VARCHAR(10), @VP_N_ORDEN_ABIERTA) + ' ordenes abiertas para el Color: ' + @PP_COLOR + ' en la Locación: ' + @PP_LOCACION + '.'
		END

	-- /////////////////////////////////////////////////////
	--SELECT @VP_RESULTADO
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_PLANNING_VALIDA_SQF_TRANSFERIDO_A_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_PLANNING_VALIDA_SQF_TRANSFERIDO_A_LOCACION]
GO


CREATE PROCEDURE [dbo].[PG_RN_PLANNING_VALIDA_SQF_TRANSFERIDO_A_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_ORDEN					VARCHAR(10),
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(50),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 	

	-- //////////SE OBTIENE LAS TRANSACCIONES A LA ORDEN/////////////////////////////////
		DECLARE @VP_LOTE VARCHAR(20) = '', @VP_LEVEL VARCHAR(20) = '', @VP_DOC_TYPE VARCHAR(5) = '', @VP_DOC_ORD_NO	VARCHAR(10) = '';
		DECLARE @VP_TRX_QTY DECIMAL(13,4) = 0, @VP_SQF_TRANSFERIDO DECIMAL(13,4) = 0;

		DECLARE @TBL_SQF_TRANSFERIDO_A_ORDEN TABLE(
					LOTE				VARCHAR(20),
					SQF_TRANSFER		DECIMAL(13,4)
				)
		SET NOCOUNT ON

		DECLARE CU_SQF_TRANSFERIDO_A_ORDEN CURSOR 
		FOR	SELECT IMLSTRX_SQL.ser_lot_no, IMLSTRX_SQL.lev_no, IMINVTRX_SQL.doc_type, LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)), IMLSTRX_SQL.trx_qty
			-- ===========================
			 FROM IMLSTRX_SQL 
				-- ===========================
				INNER JOIN IMINVTRX_SQL ON IMLSTRX_SQL.source = IMINVTRX_SQL.source 
					AND IMLSTRX_SQL.ord_no = IMINVTRX_SQL.ord_no 
			     AND IMLSTRX_SQL.ctl_no = IMINVTRX_SQL.ctl_no 
			     AND IMLSTRX_SQL.line_no = IMINVTRX_SQL.line_no 
			     AND IMLSTRX_SQL.lev_no = IMINVTRX_SQL.lev_no 
			     AND IMLSTRX_SQL.seq_no = IMINVTRX_SQL.seq_no
			-- ===========================
			 WHERE IMINVTRX_SQL.item_no = @PP_COLOR
			 AND LTRIM(RTRIM(IMINVTRX_SQL.loc)) = @PP_LOCACION
			 -- ===========================
			 AND (	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @PP_ORDEN
					OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = 'J' + @PP_ORDEN
					OR	LTRIM(RTRIM(IMINVTRX_SQL.doc_ord_no)) = @PP_ORDEN
					)
			-- ===========================  
			ORDER BY IMLSTRX_SQL.ser_lot_no, IMINVTRX_SQL.lev_no DESC
		-- ///////////////////////////////////////////
				
		OPEN CU_SQF_TRANSFERIDO_A_ORDEN
		FETCH NEXT FROM CU_SQF_TRANSFERIDO_A_ORDEN INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY
				
		WHILE @@FETCH_STATUS = 0
			BEGIN
				-- ///////////////////////////////////////////
				DECLARE @VP_LOTE_ACTUAL VARCHAR(20) = @VP_LOTE

				-- /////////// TRANSFERENCIA A LA ORDEN ///////////////////////
				IF @VP_DOC_TYPE = 'R' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
					BEGIN
						SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
					END

				IF @VP_DOC_TYPE = 'I' --AND SUBSTRING(@VP_DOC_ORD_NO, 1, 1) <> 'J'
					BEGIN
					 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
					END

				IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 1
					BEGIN
						SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO + @VP_TRX_QTY
					END

				IF @VP_DOC_TYPE = 'T' AND @VP_LEVEL = 0
					BEGIN
					 SET @VP_SQF_TRANSFERIDO = @VP_SQF_TRANSFERIDO - @VP_TRX_QTY 
					END

				-- ///////////////////////////////////////////
				FETCH NEXT FROM CU_SQF_TRANSFERIDO_A_ORDEN INTO @VP_LOTE, @VP_LEVEL, @VP_DOC_TYPE, @VP_DOC_ORD_NO, @VP_TRX_QTY

				-- ///////////////////////////////////////////
				IF ( @VP_LOTE_ACTUAL <> @VP_LOTE OR @@FETCH_STATUS <> 0 )
					BEGIN
						INSERT INTO @TBL_SQF_TRANSFERIDO_A_ORDEN
						SELECT	RIGHT( '000000' + @VP_LOTE_ACTUAL, 6),
								@VP_SQF_TRANSFERIDO

						SET @VP_SQF_TRANSFERIDO = 0
					END
			END
		
		CLOSE CU_SQF_TRANSFERIDO_A_ORDEN
		DEALLOCATE CU_SQF_TRANSFERIDO_A_ORDEN	

	-- ///////SE OBTIENE EL TOTAL DE SQF EN LA ORDEN///////////////////////////////////////////////////////
	DECLARE @VP_TOTAL_SQF DECIMAL(13,4) = 0
	SELECT @VP_TOTAL_SQF = SUM(SQF_TRANSFER)
	FROM @TBL_SQF_TRANSFERIDO_A_ORDEN

	IF @VP_TOTAL_SQF IS NULL
	 SET @VP_TOTAL_SQF = 0

	 IF @VP_TOTAL_SQF > 0
		SET @VP_RESULTADO = 'ERROR: No fue posible Cambiar de locacion la Orden porque tiene Pies Cuadrados asignados.'


	-- ===========================
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
