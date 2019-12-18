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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_LOAD_DETALLE_SERVICIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_LOAD_DETALLE_SERVICIO]
GO

-- EXEC [dbo].[PG_CB_LOAD_DETALLE_SERVICIO] 0,0,0, 1, 0

CREATE PROCEDURE [dbo].[PG_CB_LOAD_DETALLE_SERVICIO]
	@PP_L_DEBUG						INT,
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_K_CENTRO_EMBARQUE			INT,
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
			SELECT	K_DETALLE_SERVICIO, 
					D_UNIDAD_SERVICIO_TALLER AS D_DETALLE_SERVICIO
			FROM	DETALLE_SERVICIO, SERVICIO_TALLER, PUNTO_SERVICIO, SERVICIO
			WHERE	DETALLE_SERVICIO.K_SERVICIO_TALLER=SERVICIO_TALLER.K_SERVICIO_TALLER
			AND		DETALLE_SERVICIO.K_PUNTO_SERVICIO=PUNTO_SERVICIO.K_PUNTO_SERVICIO
			AND		PUNTO_SERVICIO.K_SERVICIO=SERVICIO.K_SERVICIO
			AND		( @PP_K_CENTRO_EMBARQUE=-1	OR	K_CENTRO_EMBARQUE=@PP_K_CENTRO_EMBARQUE )
			AND		SERVICIO.K_SERVICIO=4 --LLANTAS
			ORDER BY K_DETALLE_SERVICIO
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


