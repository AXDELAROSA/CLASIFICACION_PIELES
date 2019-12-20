-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	TRA19
-- // MODULO:			FECHA
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			AX DE LA ROSA
-- // Fecha creación:	27/MAY/2019
-- ////////////////////////////////////////////////////////////// 

USE [TRA19_Transportadora_V9999_R0] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FECHA
-- //////////////////////////////////////////////////////////////


-- EXECUTE [PG_RN_FECHA_HOY_YYYY_MM_DAY_GET] 0,0,0

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY_GET]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY_GET]
GO


CREATE PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY_GET]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT
	-- ===========================
AS	
	DECLARE @VP_K_YYYY	INT
	DECLARE @VP_K_MES	INT
	DECLARE @VP_K_DIA	INT
		
	-- ================================

	SET		@VP_K_YYYY =	YEAR(GETDATE())
	SET		@VP_K_MES =		MONTH(GETDATE())
	SET		@VP_K_DIA =		DAY(GETDATE())
	
	SELECT	@VP_K_YYYY	AS K_YYYY,
			@VP_K_MES	AS K_MES,
			@VP_K_DIA	AS K_DIA
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / FECHA				PARA CARGAR EN MASKEDTEXTBOX
-- //////////////////////////////////////////////////////////////


-- EXECUTE [PG_RN_FECHA_HOY_YYYY_MM_DAY]	0,0,0

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY]
GO


CREATE PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_DAY]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT
	-- ===========================
AS	
	DECLARE @VP_K_YYYY	INT
	DECLARE @VP_K_MES	INT
	DECLARE @VP_K_DIA	INT
	DECLARE @OU_FECHA	DATE
	
	-- ================================

	SET		@VP_K_YYYY =	YEAR(GETDATE())
	SET		@VP_K_MES =		MONTH(GETDATE())
	SET		@VP_K_DIA =		DAY(GETDATE())
	
	SELECT @OU_FECHA  = F_TIEMPO_FECHA
						FROM	TIEMPO_FECHA
						WHERE	FECHA_YYYY=@VP_K_YYYY
						AND		K_TIEMPO_MES=@VP_K_MES
						AND		FECHA_DD=@VP_K_DIA
	-- ================================
	SELECT @OU_FECHA AS FECHA
GO



-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
