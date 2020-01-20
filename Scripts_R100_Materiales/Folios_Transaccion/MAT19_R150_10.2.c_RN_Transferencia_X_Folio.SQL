-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	PEARL19_V9999_R0
-- // MODULO:			[TRANSFER_PIEL_DEVOLUCION]
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	06/ENE/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02Pruebas] 
GO

-- //////////////////////////////////////////////////////////////





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_FOLIOS_DIFERENTES]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_FOLIOS_DIFERENTES]
GO


CREATE PROCEDURE [dbo].[PG_RN_VALIDA_FOLIOS_DIFERENTES]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_FOLIO_ORIGEN			INT,
	@PP_FOLIO_DESTINO			INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF ( @PP_FOLIO_ORIGEN = @PP_FOLIO_DESTINO )
			SET @VP_RESULTADO =  'No es posible transferir dentro del mismo <FOLIO>...' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_FOLIO_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_FOLIO					INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_TAG_NO		INT = 0
			
	SELECT	@VP_TAG_NO	=	TAGNO
							FROM	RP_SC
							WHERE	TAGNO=@PP_FOLIO
	-- ===========================


	IF @VP_RESULTADO=''
		IF ( @VP_TAG_NO IS NULL )
			SET @VP_RESULTADO =  'El <FOLIO> proporcionado no existe....' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_LOCACION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION]
GO


CREATE PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOCACION				VARCHAR(5),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////
				
	IF @VP_RESULTADO=''
		IF NOT  (LEN(@PP_LOCACION) = 3  AND (SUBSTRING(@PP_LOCACION,1,1)='T'	OR @PP_LOCACION = 'MHI'))
			SET @VP_RESULTADO =  '<LOCACION> no valida...Transferencia Cancelada. [#LOC.' + @PP_LOCACION + ']' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_COLOR]
GO


CREATE PROCEDURE [dbo].[PG_RN_VALIDA_COLOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_COLOR_ORIGEN			VARCHAR(20),
	@PP_COLOR_DESTINO			VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////
				
	IF @VP_RESULTADO=''
		IF @PP_COLOR_ORIGEN = @PP_COLOR_DESTINO
			BEGIN
				SET @VP_RESULTADO = ''
			END
		ELSE IF((@PP_COLOR_DESTINO = 'FCML5B8' And @PP_COLOR_ORIGEN = 'FCMP5B8') Or (@PP_COLOR_DESTINO = 'FCMP5B8' And @PP_COLOR_ORIGEN = 'FCML5B8') Or (@PP_COLOR_DESTINO = 'FNRUDX9' And @PP_COLOR_ORIGEN = 'FCNPDX9') Or (@PP_COLOR_DESTINO = 'FCNPDX9' And @PP_COLOR_ORIGEN = 'FNRUDX9'))
				BEGIN
					--SET @VP_RESULTADO =  'Advertencia, se estan mezclando pieles similares...'
					SET @VP_RESULTADO = ''
				END
			ELSE
				BEGIN
					SET @VP_RESULTADO =  'El <COLOR> del folio no coincide: [#Color Origen.' + @PP_COLOR_ORIGEN + '] - [#Color Destino.' + @PP_COLOR_DESTINO + ']'
				END 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]
GO

CREATE PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_JOBNO_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_ORDEN_DESTINO			VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF ( LTRIM(RTRIM(@PP_ORDEN_DESTINO)) = '' )
			SET @VP_RESULTADO =  'Numero de <ORDEN> no valido [Campo Vacio]...Transferencia cancelada' 
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF ( LEN(@PP_ORDEN_DESTINO) <> 5 )
			SET @VP_RESULTADO =  'Numero de <ORDEN> no valido [Cantidad de Caracteres No Valido]...Transferencia cancelada' 
	-- /////////////////////////////////////////////////////

	DECLARE @VP_JOBNO		INT = 0
	SELECT	@VP_JOBNO	=	JOBNO
							FROM	CCJOBHDR_SQL
							WHERE	JOBNO=@PP_ORDEN_DESTINO
	-- ===========================
	
	IF @VP_RESULTADO=''
		IF ( @VP_JOBNO IS NULL )
			SET @VP_RESULTADO =  'Numero de <ORDEN> no existente...Transferencia cancelada' 

	-- /////////////////////////////////////////////////////

	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]
GO


CREATE PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_ESTATUS]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_ORDEN_DESTINO			VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_ESTATUS		VARCHAR(3)
			
	SELECT	@VP_ESTATUS	=	LTRIM(RTRIM(STATUS))
							FROM	CCJOBHDR_SQL
							WHERE	JOBNO=@PP_ORDEN_DESTINO
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_ESTATUS='C' )
			SET @VP_RESULTADO =  'La <ORDEN> ya fue completada...Transferencia cancelada...' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]
GO


CREATE PROCEDURE [dbo].[PG_RN_CCJOBHDR_SQL_VALIDA_COLOR]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_ORDEN_DESTINO			VARCHAR(10),
	@PP_COLOR_ORIGEN			VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_COLOR_JOBNO_DESTINO		VARCHAR(3)
			
	SELECT	@VP_COLOR_JOBNO_DESTINO	=	LTRIM(RTRIM(COLOUR))
							FROM	CCJOBHDR_SQL
							WHERE	JOBNO=@PP_ORDEN_DESTINO
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_COLOR_JOBNO_DESTINO=@PP_COLOR_ORIGEN )
			SET @VP_RESULTADO =  'La <ORDEN> proporcionada corresponde a otro tipo de piel...Transferencia cancelada...' 

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- ===========================================================================================
-- ===========================================================================================
-- == REGLAS DE NEGOCIO BASICAS (INSERT / UPDATE / DELETE)
-- ===========================================================================================
-- ===========================================================================================


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]
GO


CREATE PROCEDURE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_FOLIO_ORIGEN			INT,
	@PP_FOLIO_DESTINO			INT,
	@PP_COLOR_ORIGEN			VARCHAR(20),
	@PP_COLOR_DESTINO			VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_VALIDA_FOLIOS_DIFERENTES]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_FOLIO_ORIGEN, @PP_FOLIO_DESTINO,
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_FOLIO_ORIGEN,
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_FOLIO_DESTINO,
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	IF @VP_RESULTADO=''
		EXECUTE	[dbo].[PG_RN_VALIDA_COLOR]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@PP_COLOR_ORIGEN, @PP_COLOR_DESTINO,
												@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	
	-- //////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //INS//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
