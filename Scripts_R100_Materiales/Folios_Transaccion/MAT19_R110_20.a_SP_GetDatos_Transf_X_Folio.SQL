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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_FOLIO_DESTINO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_FOLIO_DESTINO]
GO
-- EXECUTE   [dbo].[PG_GET_FOLIO_DESTINO] 0,0, 'B' , 'FMCKTX7' 
CREATE PROCEDURE [dbo].[PG_GET_FOLIO_DESTINO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ESTATUS					VARCHAR(5),
	@PP_COLOR					VARCHAR(20)
AS
	-- ///////////////////////////////////////////
	DECLARE @VP_FOLIO	INT = 0
	
	SELECT	TOP 1 @VP_FOLIO=TAG
	-- =====================
	FROM	RP_Folios  
	-- =====================
	INNER JOIN RP_SC ON TAG=TAGNO AND RTRIM(LTRIM(STATUS))=@PP_ESTATUS AND COLOUR=@PP_COLOR
	GROUP BY TAG, COLOUR

	IF @VP_FOLIO IS NULL OR @VP_FOLIO = ''
		BEGIN
			EXECUTE BD_GENERAL.[dbo].[PG_SK_CATALOGO_K_MAX_GET]	@PP_K_SISTEMA_EXE, 
																'DATA_02', 'RP_SC', 'TAGNO',
																@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT
		END
	-- =========================================
		
	SELECT LTRIM(RTRIM(@VP_FOLIO)) AS FOLIO_DESTINO
      
	-- ////////////////////////////////////////////////////////////////////
GO



IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_IMLSMST_SQL_QTY_ON_HAND]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_IMLSMST_SQL_QTY_ON_HAND]
GO
-- EXECUTE [dbo].[PG_GET_IMLSMST_SQL_QTY_ON_HAND] 0,0, 'T62' , 'FMCKTX7' , '032701' 
CREATE PROCEDURE [dbo].[PG_GET_IMLSMST_SQL_QTY_ON_HAND]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOCACION				VARCHAR(10),			
	@PP_COLOR					VARCHAR(20),
	@PP_LOTE					VARCHAR(20)
AS
	-- ///////////////////////////////////////////

	
	-- =========================================
	
	SELECT	TOP (1) 
			QTY_ON_HAND
	FROM	IMLSMST_SQL
	WHERE	LTRIM(RTRIM(LOC))=@PP_LOCACION
	AND		LTRIM(RTRIM(ITEM_NO))=@PP_COLOR
	AND		LTRIM(RTRIM(SER_LOT_NO))=@PP_LOTE

	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								
-- //////////////////////////////////////////////////////////////
-- EXEC [PG_GET_VALOR_LOCACION] 0, 0, 2137674
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_VALOR_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_VALOR_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_GET_VALOR_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_MOVIMIENTO		VARCHAR(10)
	DECLARE	@VP_LOCACION		VARCHAR(50)
	-- ///////////////////////////////////////////

	SELECT	@VP_MOVIMIENTO		=	LTRIM(RTRIM(MOVEMENT))
								FROM	RP_SC
								WHERE	LTRIM(RTRIM(TAGNO))=@PP_FOLIO
	-- =========================================

	IF @VP_MOVIMIENTO IS NULL
		BEGIN
			SET @VP_LOCACION = ''
		END
	ELSE IF ISNUMERIC(@VP_MOVIMIENTO) = 1
		BEGIN
			SELECT	TOP 1 @VP_LOCACION = LTRIM(RTRIM(IMINVTRX_SQL.Loc))
			FROM	IMLSTRX_SQL, IMINVTRX_SQL 
			WHERE	(IMLSTRX_SQL.Source = IMINVTRX_SQL.Source And IMLSTRX_SQL.Ord_No = IMINVTRX_SQL.Ord_No)
			AND		IMLSTRX_SQL.Ctl_No = IMINVTRX_SQL.Ctl_No 
			AND		IMLSTRX_SQL.Line_No = IMINVTRX_SQL.Line_No 
			AND		IMLSTRX_SQL.Lev_No = IMINVTRX_SQL.Lev_No 
			AND		IMLSTRX_SQL.Seq_No = IMINVTRX_SQL.Seq_No 
			AND		LTRIM(RTRIM(IMINVTRX_SQL.ord_no))=@VP_MOVIMIENTO 
			AND		(( IMLSTRX_SQL.lev_no='0' AND doc_type='R' ) 
					OR  ( IMLSTRX_SQL.lev_no='1' and doc_type='T' ))

			IF @VP_LOCACION IS NULL
				SET @VP_LOCACION = ''
		END
	ELSE
		BEGIN
			SET @VP_LOCACION = @VP_MOVIMIENTO
		END

	SELECT @VP_LOCACION AS LOCACION
      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_IMINVTRX_SQL_LOTE_X_COLOR_LOCACION_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_IMINVTRX_SQL_LOTE_X_COLOR_LOCACION_ORDEN]
GO

-- EXEC [PG_GET_IMINVTRX_SQL_LOTE_X_COLOR_LOCACION_ORDEN] 0,0,  'FMCKTX7' , 'T17' , '09489' 

CREATE PROCEDURE [dbo].[PG_GET_IMINVTRX_SQL_LOTE_X_COLOR_LOCACION_ORDEN]
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
		SELECT	DISTINCT LTRIM(RTRIM(IMLSTRX_SQL.ser_lot_no)) AS LOTE
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
		--ORDER BY IMLSTRX_SQL.ser_lot_no

	-- ////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
