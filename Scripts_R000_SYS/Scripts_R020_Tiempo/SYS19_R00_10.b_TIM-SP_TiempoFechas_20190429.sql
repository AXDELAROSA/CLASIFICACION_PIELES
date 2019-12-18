-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	SYS19_BasicBD_20190325
-- // MODULO:			CONFIGURACION - SPs MANEJO DE FECHAS   		
-- // OPERACION:		LIBERACION    
-- //////////////////////////////////////////////////////////////

USE [PEARL19_V9999_R0]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_FECHA_FORMATEAR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_FECHA_FORMATEAR]
GO


CREATE PROCEDURE [dbo].[PG_RN_FECHA_FORMATEAR]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_F_FECHA				DATE,
	@PP_FECHA_FORMATEADA	VARCHAR(50)		OUTPUT
AS

	DECLARE @VP_S_MES VARCHAR(10)

	DECLARE @VP_FECHA_DDMMMYYYY VARCHAR(50)

	-- ==============================================

	IF @PP_F_FECHA IS NULL
		SET @VP_FECHA_DDMMMYYYY = 'S/F'
	ELSE
		BEGIN
		
		SELECT @VP_S_MES =	S_MES 
							FROM	MES
							WHERE	K_MES=DATEPART(MM,@PP_F_FECHA) 

		-- ==============================================
				
		SET @VP_FECHA_DDMMMYYYY	=	CASE WHEN LEN(LTRIM(RTRIM(STR(DATEPART(DD,@PP_F_FECHA))))) = 1 
											THEN '0' + LTRIM(RTRIM(STR(DATEPART(DD,@PP_F_FECHA)))) 
											ELSE LTRIM(RTRIM(STR(DATEPART(DD,@PP_F_FECHA)))) 
									END 
		SET @VP_FECHA_DDMMMYYYY	= @VP_FECHA_DDMMMYYYY + '/' + LEFT(@VP_S_MES,3) 
		SET @VP_FECHA_DDMMMYYYY	= @VP_FECHA_DDMMMYYYY + '/' + LTRIM(RTRIM(STR(DATEPART(YY,@PP_F_FECHA)))) 

		END

	-- ==============================================
	
	SET @PP_FECHA_FORMATEADA = @VP_FECHA_DDMMMYYYY

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
-- EXECUTE [PG_RN_FECHA_FORMATEAR_GET] 1, '2015-01-03'

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_FECHA_FORMATEAR_GET]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_FECHA_FORMATEAR_GET]
GO

CREATE PROCEDURE [dbo].[PG_RN_FECHA_FORMATEAR_GET]
	@PP_L_DEBUG			INT,
	@PP_K_SISTEMA_EXE	INT,
	@PP_F_FECHA			DATE
AS
	
	DECLARE @VP_FECHA_FORMATEADA	VARCHAR(50)

	SET @VP_FECHA_FORMATEADA = ''

	-- ================================

	EXECUTE [dbo].[PG_RN_FECHA_FORMATEAR]	@PP_L_DEBUG, @PP_K_SISTEMA_EXE,
											@PP_F_FECHA,
											@PP_FECHA_FORMATEADA=@VP_FECHA_FORMATEADA		OUTPUT

	-- ================================

	SELECT	@VP_FECHA_FORMATEADA AS FECHA_FORMATEADA

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / COMBO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_FILTRO_YYYY]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_FILTRO_YYYY]
GO


CREATE PROCEDURE [dbo].[PG_CB_FILTRO_YYYY]
	@PP_L_DEBUG			INT,
	@PP_K_SISTEMA_EXE	INT
AS

	SELECT	K_FILTRO_YYYY		AS K_CATALOGO,
			D_FILTRO_YYYY		AS D_CATALOGO
	FROM	FILTRO_YYYY
	ORDER BY O_FILTRO_YYYY

GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / COMBO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_CB_MES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_CB_MES]
GO


CREATE PROCEDURE [dbo].[PG_CB_MES]
	@PP_L_DEBUG			INT,
	@PP_K_SISTEMA_EXE	INT
AS

	SELECT	K_MES		AS K_CATALOGO,
			D_MES		AS D_CATALOGO
	FROM	MES
	ORDER BY O_MES

GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

-- EXECUTE [PG_RN_FECHA_HOY_YYYY_MM_GET]	0,0,0

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_FECHA_HOY_YYYY_MM_GET]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_GET]
GO


CREATE PROCEDURE [dbo].[PG_RN_FECHA_HOY_YYYY_MM_GET]
	@PP_L_DEBUG				INT,
	@PP_K_SISTEMA_EXE		INT,
	@PP_K_USUARIO_ACCION	INT
	-- ===========================
AS
	
	DECLARE @VP_K_YYYY	INT

	DECLARE @VP_K_MES	INT

	-- ================================

	SET		@VP_K_YYYY =	YEAR( GETDATE() )

	SET		@VP_K_MES =		MONTH( GETDATE() )

	-- ================================

	SELECT	@VP_K_YYYY	AS K_YYYY,
			@VP_K_MES	AS K_MES

	-- ================================
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FG_RN_FECHA_X_YYYY_MM_DD]') AND type in (N'P', N'PC'))
	DROP FUNCTION [dbo].[FG_RN_FECHA_X_YYYY_MM_DD]
GO


CREATE FUNCTION [dbo].[FG_RN_FECHA_X_YYYY_MM_DD]
(	@PP_L_DEBUG					INT,
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ==============================
	@PP_K_YYYY		INT,	
	@PP_K_MES		INT,	
	@PP_K_DIA		INT		)
	RETURNS DATE
AS
BEGIN

	DECLARE @VP_F_SERVICIO_TRANSPORTE		DATE

	SELECT	@VP_F_SERVICIO_TRANSPORTE =		F_TIEMPO_FECHA
											FROM	TIEMPO_FECHA
											WHERE	FECHA_YYYY=@PP_K_YYYY
											AND		K_TIEMPO_MES=@PP_K_MES
											AND		FECHA_DD=@PP_K_DIA
	RETURN @VP_F_SERVICIO_TRANSPORTE

END

GO


-- ///////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////
-- ///////////////////////////////////////////////////////////////////////////////////////////
