-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			ESTRUCTURA / UNIDAD OPERATIVA
-- // OPERACION:		LIBERACION / VISTA
-- ////////////////////////////////////////////////////////////// 

USE [PEARL19_V9999_R0]
GO

-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- // 
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[VI_UNIDAD_OPERATIVA_CATALOGOS]'))
	DROP VIEW [dbo].[VI_UNIDAD_OPERATIVA_CATALOGOS]
GO


CREATE VIEW [dbo].[VI_UNIDAD_OPERATIVA_CATALOGOS]

AS

	SELECT	UNIDAD_OPERATIVA.K_ZONA_UO				AS VI_K_ZONA_UO, 
			UNIDAD_OPERATIVA.K_REGION				AS VI_K_REGION,		
			UNIDAD_OPERATIVA.K_RAZON_SOCIAL			AS VI_K_RAZON_SOCIAL, 
			UNIDAD_OPERATIVA.K_TIPO_UO				AS VI_K_TIPO_UO, 
			UNIDAD_OPERATIVA.K_UNIDAD_OPERATIVA		AS VI_K_UNIDAD_OPERATIVA, 
			-- =====================================
			D_UNIDAD_OPERATIVA, 
			D_TIPO_UO, D_ZONA_UO, D_RAZON_SOCIAL, D_REGION,
			S_UNIDAD_OPERATIVA, 
			S_TIPO_UO, S_ZONA_UO, S_RAZON_SOCIAL, S_REGION
			-- =====================================
	FROM	UNIDAD_OPERATIVA, 
			TIPO_UO, ZONA_UO, RAZON_SOCIAL, REGION
			-- =====================================
	WHERE	UNIDAD_OPERATIVA.K_TIPO_UO=TIPO_UO.K_TIPO_UO 
	AND		UNIDAD_OPERATIVA.K_ZONA_UO=ZONA_UO.K_ZONA_UO 
	AND		UNIDAD_OPERATIVA.K_RAZON_SOCIAL=RAZON_SOCIAL.K_RAZON_SOCIAL 
	AND		UNIDAD_OPERATIVA.K_REGION=REGION.K_REGION
			 
	-- ================================
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
