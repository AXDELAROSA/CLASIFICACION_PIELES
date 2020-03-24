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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR]
GO
--SELECT * FROM PF_SC WHERE n_emb IN (10,11)
-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR] 0,0, 'RPMRAQBLNRUPD2,Q30-S11601005*184983C%MAGN03#PRA@66611','2020-03-24','E',10
-- EXEC [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR] 0,0, 'RUWD2TFBCNPLV5,Q30-S06259008~06258*186132A%MAGN03#WDM@12345!54321','2020-03-24','E',11
CREATE PROCEDURE [dbo].[PG_RN_ETIQUETA_EMBARQUE_OBTENER_VALOR]
	--@PP_K_SISTEMA_EXE			INT,
	--@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_ETIQUETA_EMBARQUE		VARCHAR(100),
	@PP_FECHA					DATE,
	@PP_TIPO_MOVIMIENTO			VARCHAR(10),
	@PP_NUMERO_EMBARQUE			INT
	-- ===========================	
AS
	
	DECLARE @VP_MENSAJE				VARCHAR(300) = ''
	DECLARE @VP_PART_NO				VARCHAR(15) = '' 
	DECLARE @VP_QTY					VARCHAR(10) = '' 
	DECLARE @VP_SERIAL_1			VARCHAR(15) = '' 
	DECLARE @VP_SERIAL_2			VARCHAR(15) = '' 
	DECLARE @VP_CUSTNO				VARCHAR(10) = '' 
	DECLARE @VP_CLIENTE				VARCHAR(10) = ''
	DECLARE @VP_PRODUCT_CAT			VARCHAR(10) = '' 
	DECLARE @VP_LOTE_1				VARCHAR(10) = '' 
	DECLARE @VP_LOTE_2				VARCHAR(10) = '' 

	DECLARE @VP_DELIMITADOR			VARCHAR(5) = ''
	DECLARE @VP_POSICION_COMA		INT
	DECLARE @VP_POSICION_GUION		INT
	DECLARE @VP_POSICION_ASTERISCO	INT 
	DECLARE @VP_POSICION_PORCENTAJE INT
	DECLARE @VP_POSICION_NUMERAL	INT
	DECLARE @VP_POSICION_ARROBA		INT
	DECLARE @VP_POSICION_TILDE		INT
	DECLARE @VP_POSICION_ADMIRACION	INT
	-- /////////////////////////////////////////////////////

	IF @VP_MENSAJE=''
		IF LTRIM(RTRIM(@PP_ETIQUETA_EMBARQUE)) = ''
			SET @VP_MENSAJE = 'El Numero de Piel no puede ser vacio'
			
	-- /////////////////////////////////////////////////////
	-- RPMRAQBLNRUPD2,Q30-S11601005*184983C%MAGN03#PRA@66611
	--SELECT SUBSTRING('RUWD2TFBCNPLV5',1,1)

	IF SUBSTRING(@PP_ETIQUETA_EMBARQUE,1,1) = 'R'
		SET @PP_ETIQUETA_EMBARQUE=SUBSTRING(@PP_ETIQUETA_EMBARQUE, 2,LEN(@PP_ETIQUETA_EMBARQUE))


	IF SUBSTRING(@PP_ETIQUETA_EMBARQUE,1,1) = 'P'
		BEGIN
			---------------------OBTENER Part No-----------------------------------------------
			SET @VP_DELIMITADOR = ','
			SET @VP_POSICION_COMA  = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PART_NO  = SUBSTRING(@PP_ETIQUETA_EMBARQUE, 1,@VP_POSICION_COMA - 1)
			
			 ----------------------OBTENER Qty--------------------------------------
			SET @VP_DELIMITADOR = '-'
			SET @VP_POSICION_GUION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_QTY =  SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_COMA), (@VP_POSICION_GUION - (@VP_POSICION_COMA + 1)))
			SET @VP_QTY =  SUBSTRING(@VP_QTY,2,10)

			 -------------------------OBTENER SERIAL---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '*'
			SET @VP_POSICION_ASTERISCO = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_GUION), (@VP_POSICION_ASTERISCO - (@VP_POSICION_GUION + 1)))
			
			 -------------------------OBTENER CUSTNO---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '%'
			SET @VP_POSICION_PORCENTAJE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CUSTNO = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ASTERISCO), (@VP_POSICION_PORCENTAJE - (@VP_POSICION_ASTERISCO + 1)))

			 -------------------------OBTENER CLIENTE---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '#'
			SET @VP_POSICION_NUMERAL = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CLIENTE = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_PORCENTAJE), (@VP_POSICION_NUMERAL - (@VP_POSICION_PORCENTAJE + 1)))

			-------------------------OBTENER PRODUCT CAT---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '@'
			SET @VP_POSICION_ARROBA = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PRODUCT_CAT = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_NUMERAL), (@VP_POSICION_ARROBA - (@VP_POSICION_NUMERAL + 1)))

			 -------------------------OBTENER LOTE_1---------------------------------------------------------------------------------

			SET @VP_LOTE_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ARROBA), 10)
		END
	ELSE
		BEGIN-- RUWD2TFBCNPLV5,Q30-S06259008~06258*186132A%MAGN03#WDM@12345!54321
			---------------------OBTENER Part No-----------------------------------------------
			SET @VP_DELIMITADOR = ','
			SET @VP_POSICION_COMA  = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PART_NO  = SUBSTRING(@PP_ETIQUETA_EMBARQUE, 1,@VP_POSICION_COMA - 1)
			
			 ----------------------OBTENER Qty--------------------------------------
			SET @VP_DELIMITADOR = '-'
			SET @VP_POSICION_GUION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_QTY =  SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_COMA), (@VP_POSICION_GUION - (@VP_POSICION_COMA + 1)))
			SET @VP_QTY =  SUBSTRING(@VP_QTY,2,10)
			 -------------------------OBTENER SERIAL_1---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '~'
			SET @VP_POSICION_TILDE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_GUION), (@VP_POSICION_TILDE - (@VP_POSICION_GUION + 1)))
			
			 -------------------------OBTENER SERIAL_2---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '*'
			SET @VP_POSICION_ASTERISCO = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_SERIAL_2 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_TILDE), (@VP_POSICION_ASTERISCO - (@VP_POSICION_TILDE + 1)))
			
			 -------------------------OBTENER CUSTNO---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '%'
			SET @VP_POSICION_PORCENTAJE = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CUSTNO = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ASTERISCO), (@VP_POSICION_PORCENTAJE - (@VP_POSICION_ASTERISCO + 1)))

			 -------------------------OBTENER PRODUCT CLIENTE---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '#'
			SET @VP_POSICION_NUMERAL = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_CLIENTE = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_PORCENTAJE), (@VP_POSICION_NUMERAL - (@VP_POSICION_PORCENTAJE + 1)))

			-------------------------OBTENER PRODUCT CATEGORY---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '@'
			SET @VP_POSICION_ARROBA = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_PRODUCT_CAT = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_NUMERAL), (@VP_POSICION_ARROBA - (@VP_POSICION_NUMERAL + 1)))

			-------------------------OBTENER LOTE 1---------------------------------------------------------------------------------
			SET @VP_DELIMITADOR = '!'
			SET @VP_POSICION_ADMIRACION = CHARINDEX(@VP_DELIMITADOR, @PP_ETIQUETA_EMBARQUE)
			
			SET @VP_LOTE_1 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ARROBA), (@VP_POSICION_ADMIRACION - (@VP_POSICION_ARROBA + 1)))

			 -------------------------OBTENER LOTE 2---------------------------------------------------------------------------------

			SET @VP_LOTE_2 = SUBSTRING(@PP_ETIQUETA_EMBARQUE, (1 + @VP_POSICION_ADMIRACION), 10)
						
		END
		
		DECLARE @VP_CDATE2 VARCHAR(8) = ''
		SET @VP_CDATE2 =	CONVERT(VARCHAR(8),dbo.[CONVERT_DATE_TO_INT](@PP_FECHA,'yyyyMMdd')) 
			
		INSERT INTO PF_SC(	cdate, 
							cdate2, 
							part_no, 
							qty, 
							serial1, 
							serial2, 
							cus_part_no, 
							cus_no,prod_cat, 
							lote1,lote2, 
							[type], 
							n_emb	) 
				VALUES(		@PP_FECHA, 
							@VP_CDATE2, 
							@VP_PART_NO, 
							CONVERT(INT,@VP_QTY), 
							@VP_SERIAL_1, 
							@VP_SERIAL_2, 
							@VP_CUSTNO, 
							@VP_CLIENTE, 
							@VP_PRODUCT_CAT, 
							@VP_LOTE_1, 
							@VP_LOTE_2, 
							@PP_TIPO_MOVIMIENTO,	
							@PP_NUMERO_EMBARQUE		)	
		
	--SELECT @PP_FECHA,			
		--	   @PP_TIPO_MOVIMIENTO,
		--	   @PP_NUMERO_EMBARQUE,
		--		@VP_CDATE2,
		--	   @VP_PART_NO,		
		--	   @VP_QTY,	
		--	   @VP_SERIAL_1,		
		--	   @VP_SERIAL_2,		
		--	   @VP_CUSTNO,			
		--	   @VP_CLIENTE,			
		--	   @VP_PRODUCT_CAT,		
		--	   @VP_LOTE_1,			
		--	   @VP_LOTE_2		

	

	-- /////////////////////////////////////////////////////
GO



-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
