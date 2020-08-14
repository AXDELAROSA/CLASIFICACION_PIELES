-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
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
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_LOCACION_ORDEN_X_FOLIO]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION_ORDEN_X_FOLIO]
GO
/*
 USE [DATA_02Pruebas] 
	EXEC [PG_RN_VALIDA_PIEL_SCRAP] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_LOCACION_ORDEN_X_FOLIO]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_COLOR					VARCHAR(50),
	@PP_FOLIO					INT,
	@PP_LOCACION				VARCHAR(5),
	@PP_ORDEN					VARCHAR(10),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = '' 
	DECLARE @VP_LOCACION_ORIGINAL	VARCHAR(5)
	DECLARE @VP_ORDEN_ORIGINAL		VARCHAR(10)

	-- /////////////////////////////////////////////////////
	SELECT	@VP_LOCACION_ORIGINAL = (CASE WHEN ISNUMERIC(MOVEMENT)  = 1 THEN (	SELECT TOP 1	LTRIM(RTRIM(IMINVTRX_SQL.Loc))
															-- ===================== 
													FROM	IMLSTRX_SQL, IMINVTRX_SQL 
															-- =====================
													WHERE	(IMLSTRX_SQL.Source	= IMINVTRX_SQL.Source 
													AND		IMLSTRX_SQL.Ord_No	= IMINVTRX_SQL.Ord_No)
													AND		IMLSTRX_SQL.Ctl_No	= IMINVTRX_SQL.Ctl_No 
													AND		IMLSTRX_SQL.Line_No	= IMINVTRX_SQL.Line_No 
													AND		IMLSTRX_SQL.Lev_No	= IMINVTRX_SQL.Lev_No 
													AND		IMLSTRX_SQL.Seq_No	= IMINVTRX_SQL.Seq_No 
													AND		IMINVTRX_SQL.ord_no	= MOVEMENT
													-- =====================
													AND		((IMLSTRX_SQL.lev_no	= '0' AND doc_type	= 'R') 
															OR  (IMLSTRX_SQL.lev_no	= '1' AND doc_type	= 'T'))
													)
										ELSE	LTRIM(RTRIM(MOVEMENT)) END )
	-- =====================
	FROM	RP_SC
	WHERE	TAGNO=@PP_FOLIO 
	AND LTRIM(RTRIM(COLOUR)) = @PP_COLOR
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO = ''
		IF @VP_LOCACION_ORIGINAL IS NULL OR @VP_LOCACION_ORIGINAL = ''
			SET @VP_RESULTADO = 'No fue posible obtener locacion del folio: '+ CONVERT(VARCHAR(15), @PP_FOLIO) + '.'
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO = ''
		IF @VP_LOCACION_ORIGINAL <> @PP_LOCACION
			SET @VP_RESULTADO = 'La locacion: ' + @PP_LOCACION + ' no corresponde al folio: '+ CONVERT(VARCHAR(15), @PP_FOLIO) + '.'
	-- /////////////////////////////////////////////////////
	
	IF @VP_RESULTADO = ''
		IF SUBSTRING(@VP_LOCACION_ORIGINAL, 1, 1) <> 'T' AND LEN(@PP_ORDEN) = 5
			SET @VP_RESULTADO = 'El folio: '+ CONVERT(VARCHAR(15), @PP_FOLIO) + ' no deberia tener orden asignada'	
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO = ''
		IF SUBSTRING (@VP_LOCACION_ORIGINAL, 1, 1) = 'T' AND LEN(@PP_ORDEN) <> 5
			SET @VP_RESULTADO = 'La orden: ' + @PP_ORDEN + ' no corresponde al folio: '+ CONVERT(VARCHAR(15), @PP_FOLIO) + '.'
	-- /////////////////////////////////////////////////////

	SELECT	@VP_ORDEN_ORIGINAL = ISNULL(LTRIM(RTRIM(JOBNO)), '')
	FROM	RP_Folios 
	WHERE	TAG = @PP_FOLIO

	IF @VP_RESULTADO = ''
		IF SUBSTRING (@VP_LOCACION_ORIGINAL, 1, 1) = 'T' AND @VP_ORDEN_ORIGINAL <> @PP_ORDEN
			SET @VP_RESULTADO = 'La orden: ' + @PP_ORDEN + ' no corresponde al folio: '+ CONVERT(VARCHAR(15), @PP_FOLIO) + '.'
	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_PIEL_SCRAP]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_SCRAP]
GO
/*
 USE [DATA_02Pruebas] 
	EXEC [PG_RN_VALIDA_PIEL_SCRAP] 0,0, 'FMCKTX7' , '33012' , '0487' , '11551' 
*/

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_PIEL_SCRAP]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_COLOR					VARCHAR(10),
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(5),
	@PP_ORDEN					VARCHAR(10),
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	DECLARE @VP_N_PIEL_CORTADA	INT

	-- /////////////////////////////////////////////////////

	SELECT @VP_N_PIEL_CORTADA = COUNT(hideno)
						FROM cccuthst_sql 
						WHERE LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
						AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
						AND LTRIM(RTRIM(hideno))   = @PP_PIEL
						AND	LTRIM(RTRIM(JOBNO))   = @PP_ORDEN

	IF @VP_N_PIEL_CORTADA IS NULL
		SET @VP_N_PIEL_CORTADA = 0
	-- /////////////////////////////////////////////////////
	
	IF @VP_N_PIEL_CORTADA = 0
		SET @VP_RESULTADO = 'La [PIEL]: ' + @PP_PIEL + ' no esta cortada.'

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_VALIDA_USUARIO_MQU]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_VALIDA_USUARIO_MQU]
GO

--	EXEC [PG_RN_VALIDA_USUARIO_MQU] 0,0,89

CREATE PROCEDURE [dbo].[PG_RN_VALIDA_USUARIO_MQU]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_CODIGO_USUARIO			INT
	-- ===========================		
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	IF @VP_RESULTADO=''
		IF NOT EXISTS(	SELECT	K_GRUPO_APROBADOR 
					FROM	BD_GENERAL.DBO.[GRUPO_APROBADOR] 
					WHERE	K_USUARIO = @PP_CODIGO_USUARIO	
					AND		D_GRUPO_APROBADOR = 'AUTORIZAR SALIDA MQU'
					AND		K_ESTATUS_GRUPO_APROBADOR = 1 -- ACTIVO
					AND		K_TIPO_GRUPO_APROBADOR = 21 --  MQU SALIDA
				)
			BEGIN
				SET @VP_RESULTADO =  'No es posible transferir: Usuario  <NO AUTORIZADO>...' 
			END
	-- /////////////////////////////////////////////////////
	
	SELECT @VP_RESULTADO AS MENSAJE

	-- /////////////////////////////////////////////////////
GO



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
	@PP_COLOR					VARCHAR(20),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_TAG_NO		INT = 0
			
	SELECT	@VP_TAG_NO	=	TAGNO
							FROM	RP_SC
							WHERE	TAGNO=@PP_FOLIO
							AND		LTRIM(RTRIM(COLOUR))=@PP_COLOR
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
			SET @VP_RESULTADO =  'Proporcione una Locacion valida [#LOC.' + @PP_LOCACION + ']' 

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

	DECLARE @VP_JOBNO		VARCHAR(10)
	SELECT TOP 1 @VP_JOBNO	=	JOBNO
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

	DECLARE @VP_COLOR_JOBNO_DESTINO		VARCHAR(20)
			
	SELECT	@VP_COLOR_JOBNO_DESTINO	= CONCAT('F', LTRIM(RTRIM(COLOUR)))
							FROM	CCJOBHDR_SQL
							WHERE	JOBNO=@PP_ORDEN_DESTINO
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_COLOR_JOBNO_DESTINO<>@PP_COLOR_ORIGEN )
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
/*
EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	0, 0,
														3777539 , 3784457,
														'FCMKDX9', 'FCMKDX9'
														
*/
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
														@PP_FOLIO_ORIGEN, @PP_COLOR_ORIGEN,
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






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_TRANSFER_PIEL_A_FOLIO_EXISTENTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_TRANSFER_PIEL_A_FOLIO_EXISTENTE]
GO
/*
EXECUTE [dbo].[PG_RN_TRANSFER_PIEL_DEVOLUCION]	0, 0,
														3777539 , 3784457,
														'FCMKDX9', 'FCMKDX9'
														
*/
CREATE PROCEDURE [dbo].[PG_RN_TRANSFER_PIEL_A_FOLIO_EXISTENTE]
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
														@PP_FOLIO_ORIGEN, @PP_COLOR_ORIGEN,
														@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_FOLIO_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
														@PP_FOLIO_DESTINO, @PP_COLOR_DESTINO,
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
