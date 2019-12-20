-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	TRA19_Transportadora_V9999_R0
-- // MODULO:			Taller 
-- // OPERACION:		LIBERACION / STORED PROCEDURES 
-- ////////////////////////////////////////////////////////////// 
-- // AUTOR:		FRANCISCO ESTEBAN
-- // FECHA:		29/OCT/2019
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> CARGA COMBO CON SP PUNTO DE VENTA EN BASE AL TIPO DE VENTA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_LOAD_LLANTA]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_LOAD_LLANTA]
GO

-- EXEC [dbo].[PG_CB_LOAD_LLANTA] 0,0,0, 5, 1, 0

CREATE PROCEDURE [dbo].[PG_CB_LOAD_LLANTA]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_K_CENTRO_EMBARQUE			INT,
	@PP_K_ESTATUS_LLANTA			INT,
	@PP_L_CON_TODOS					INT
	-- ===========================
AS

	--EXECUTE [dbo].[PG_SK_CONFIGURACION_COMBO_SHOW_K_GET]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
	--															@OU_SHOW_K = @VP_INT_SHOW_K			OUTPUT
	-- ==========================================
	
	CREATE TABLE	#VP_TA_CATALOGO		
					(	TA_K_CATALOGO		INT,
					-- =========================
						D_CATALOGO			VARCHAR(200)
					)

	-- ==========================================

		INSERT INTO #VP_TA_CATALOGO 
			(		TA_K_CATALOGO,
				-- =========================
					[D_CATALOGO]
			)
			SELECT	K_LLANTA, 
					D_LLANTA
			FROM	LLANTA
			WHERE	( @PP_K_CENTRO_EMBARQUE=-1	OR	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE )
			AND		( @PP_K_ESTATUS_LLANTA=-1	OR	K_ESTATUS_LLANTA=@PP_K_ESTATUS_LLANTA )
			AND		L_BORRADO=0
			ORDER BY K_LLANTA DESC
	-- ==========================================

	IF @PP_L_CON_TODOS=1
		INSERT INTO #VP_TA_CATALOGO
				(	TA_K_CATALOGO,	
					-- =========================
					[D_CATALOGO]
				)
			VALUES
				(	-1,						 					
					'(TODOS)'
				)
	SELECT	TA_K_CATALOGO	AS K_COMBOBOX,
			[D_CATALOGO] 
			+ (  ' [#'+CONVERT(VARCHAR(100),TA_K_CATALOGO)+'] ') AS D_COMBOBOX
	FROM	#VP_TA_CATALOGO
	ORDER BY	TA_K_CATALOGO,
				[D_CATALOGO] 

	-- ==========================================

	DROP TABLE #VP_TA_CATALOGO

	-- ==========================================
	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	-- // NO ES REQUERIDA LA SECCION #3

	-- ////////////////////////////////////////////////
GO


