-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC
-- // OPERACION:		LIBERACION / REGLAS DE NEGOCIO
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	13/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO


-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_ETIQUETA_PIEL_OBTENER_VALOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_ETIQUETA_PIEL_OBTENER_VALOR]
GO


CREATE PROCEDURE [dbo].[PG_RN_ETIQUETA_PIEL_OBTENER_VALOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_ETIQUETA_PIEL			VARCHAR(100),
	-- ===========================		
	@OU_COLOR					VARCHAR(10)	OUTPUT,
	@OU_LOTE					VARCHAR(10)	OUTPUT,
	@OU_PIEL					VARCHAR(10)	OUTPUT,
	@OU_SQF						VARCHAR(10)	OUTPUT
AS

	DECLARE @VP_COLOR		VARCHAR(10) = '' 
	DECLARE @VP_LOTE		VARCHAR(10) = '' 
	DECLARE @VP_PIEL		VARCHAR(10) = '' 
	DECLARE @VP_SQF			VARCHAR(10) = '' 
	
	-- /////////////////////////////////////////////////////

	
	---------------------OBTENER COLOR-----------------------------------------------
	DECLARE @VP_DELIMITADOR VARCHAR(5) = ','
	DECLARE @VP_POSICION_COMA INT = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_PIEL)
	
	 SET @VP_COLOR  = SUBSTRING(@PP_ETIQUETA_PIEL, 1,@VP_POSICION_COMA - 1)
	
	 ----------------------OBTENER LOTE--------------------------------------
	SET @VP_DELIMITADOR = '-'
	DECLARE @VP_POSICION_GUION INT = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_PIEL)
	
	SET @VP_LOTE =  SUBSTRING(@PP_ETIQUETA_PIEL, (1 + @VP_POSICION_COMA), (@VP_POSICION_GUION - (@VP_POSICION_COMA + 1)))
	
	 -------------------------OBTENER PIEL---------------------------------------------------------------------------------
	SET @VP_DELIMITADOR = '*'
	DECLARE @VP_POSICION_ASTERISCO INT = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_PIEL)
	
	SET @VP_PIEL = SUBSTRING(@PP_ETIQUETA_PIEL, (1 + @VP_POSICION_GUION), (@VP_POSICION_ASTERISCO - (@VP_POSICION_GUION + 1)))
	
	 -------------------------OBTENER SQF---------------------------------------------------------------------------------

	SET @VP_SQF = SUBSTRING(@PP_ETIQUETA_PIEL, (1 + @VP_POSICION_ASTERISCO), 10)

	-- /////////////////////////////////////////////////////
	
	SET @OU_COLOR	 = @VP_COLOR	
	SET @OU_LOTE	 = @VP_LOTE	
	SET @OU_PIEL	 = @VP_PIEL	
	SET @OU_SQF		 = @VP_SQF		

	-- /////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
