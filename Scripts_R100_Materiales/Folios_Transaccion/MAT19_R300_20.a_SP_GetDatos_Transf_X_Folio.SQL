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
	
	SELECT	@VP_FOLIO=TAG
	-- =====================
	FROM	RP_Folios  
	-- =====================
	INNER JOIN RP_SC ON TAG=TAGNO AND RTRIM(LTRIM(STATUS))=@PP_ESTATUS AND COLOUR=@PP_COLOR
	GROUP BY TAG, COLOUR

	IF @VP_FOLIO IS NULL OR @VP_FOLIO = ''
		BEGIN
			EXECUTE [dbo].[PG_SK_CATALOGO_K_MAX_GET]	0, 'RP_SC', 'TAGNO',
														@OU_K_TABLA_DISPONIBLE = @VP_FOLIO	OUTPUT
		END
	-- =========================================
		
	SELECT LTRIM(RTRIM(@VP_FOLIO)) AS FOLIO_DESTINO
      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT /								*NO SE USA POR EL MOMENTO*
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_VALOR_CB_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_VALOR_CB_LOCACION]
GO

CREATE PROCEDURE [dbo].[PG_GET_VALOR_CB_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					VARCHAR(20)
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
	ELSE
		BEGIN
			SELECT	@VP_LOCACION = LTRIM(RTRIM(IMINVTRX_SQL.Loc))
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

	SELECT @VP_LOCACION AS LOCACION
      
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
