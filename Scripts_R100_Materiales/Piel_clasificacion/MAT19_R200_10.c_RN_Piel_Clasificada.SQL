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

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_EXISTE]
GO


CREATE PROCEDURE [dbo].[PG_RN_RP_SC_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================	
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = '' 
	
	-- /////////////////////////////////////////////////////

	DECLARE @VP_K_RP_SC		INT
			
	SELECT	@VP_K_RP_SC	=	ID
							FROM	RP_SC
							WHERE	RTRIM(LTRIM(LOT))=@PP_LOTE
							AND		RTRIM(LTRIM(HIDE))=@PP_PIEL
	-- ===========================

	IF @VP_RESULTADO=''
		IF ( @VP_K_RP_SC IS NULL )
			SET @VP_RESULTADO =  'No existe.' 

	-- ===========================

	-- /////////////////////////////////////////////////////
	
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_PIEL_ESTA_CLASIFICADA
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_PIEL_CLASIFICADA_EXISTE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_PIEL_CLASIFICADA_EXISTE]
GO
 -- EXECUTE PG_RN_RP_SC_PIEL_CLASIFICADA_EXISTE 0,0,'FCPRDX9,104313-0215*37.50'

CREATE PROCEDURE [dbo].[PG_RN_RP_SC_PIEL_CLASIFICADA_EXISTE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_ETIQUETA_PIEL		VARCHAR(100)
	-- ===========================		
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	DECLARE @VP_COLOR		VARCHAR(10) = ''
	DECLARE @VP_LOTE		VARCHAR(10) = ''
	DECLARE @VP_PIEL		VARCHAR(10) = ''
	DECLARE @VP_SQF			VARCHAR(10) = ''
	-- /////////////////////////////////////////////////////////////////////

	IF @VP_MENSAJE=''
		IF LTRIM(RTRIM(@PP_ETIQUETA_PIEL)) = ''
			SET @VP_MENSAJE = 'El Numero de Piel no puede ser vacio'
			
	IF @VP_MENSAJE=''
		IF NOT (@PP_ETIQUETA_PIEL LIKE '%_______,______-____*%')
			SET @VP_MENSAJE = 'Ingrese Numero de Piel Valido'

	-- /////////////////////////OBTENER VALORES DE LA ETIQUETA PIEL////////////////////////////////////////////

	IF @VP_MENSAJE=''
		EXECUTE [dbo].[PG_RN_ETIQUETA_PIEL_OBTENER_VALOR]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
															@PP_ETIQUETA_PIEL,
															@OU_COLOR	 = @VP_COLOR	OUTPUT,
															@OU_LOTE	 = @VP_LOTE		OUTPUT,
															@OU_PIEL	 = @VP_PIEL		OUTPUT,
															@OU_SQF		 = @VP_SQF		OUTPUT

	SET @VP_LOTE = RTRIM(LTRIM(@VP_LOTE))
	SET @VP_PIEL = RTRIM(LTRIM(@VP_PIEL))

	-- ///////////////////////////////////////////

	IF @VP_MENSAJE='' 
		BEGIN

		DECLARE @VP_PIEL_CLASIFICADA_EXISTE	INT = 0

		SELECT	@VP_PIEL_CLASIFICADA_EXISTE =	COUNT(ID)
											FROM	RP_SC
											WHERE	RTRIM(LTRIM(LOT))=@VP_LOTE
											AND		RTRIM(LTRIM(HIDE))=@VP_PIEL
											AND		K_CLASIFICACION <> 0
										
		IF @VP_PIEL_CLASIFICADA_EXISTE IS NULL
			SET @VP_PIEL_CLASIFICADA_EXISTE = 0

		IF @VP_PIEL_CLASIFICADA_EXISTE>0
			BEGIN
				
				DECLARE @VP_D_PIEL_CLASIFICACION	VARCHAR(50)

				SELECT @VP_D_PIEL_CLASIFICACION = D_PIEL_CLASIFICACION
												FROM	PIEL_CLASIFICACION
												WHERE K_PIEL_CLASIFICACION = (	SELECT TOP 1 K_CLASIFICACION
																				FROM	RP_SC
																				WHERE	RTRIM(LTRIM(LOT))=@VP_LOTE
																				AND		RTRIM(LTRIM(HIDE))=@VP_PIEL )

				SET		@VP_MENSAJE = 'Piel clasificada como: ' 
				SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
				SET		@VP_MENSAJE = @VP_MENSAJE + @VP_D_PIEL_CLASIFICACION +' '
				--SET		@VP_MENSAJE = @VP_MENSAJE + '[#PIEL.' + @VP_PIEL +'] del '
				--SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOTE.' + @VP_LOTE +']'
								
				SET		@VP_MENSAJE = @VP_MENSAJE + ') '
				SET		@VP_MENSAJE = @VP_MENSAJE + 'Desea Actualizarla?'

			END	
	END
	-- ///////////////////////////////////////////
		
	SELECT	@VP_MENSAJE AS MENSAJE,  @VP_LOTE AS LOTE, @VP_PIEL AS PIEL

	-- /////////////////////////////////////////////////////
GO



/*

-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN_DESCRIPCION_EXISTE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_VALIDA_CANTIDAD_PIEL]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_VALIDA_CANTIDAD_PIEL]
GO

CREATE PROCEDURE [dbo].[PG_RN_RP_SC_VALIDA_CANTIDAD_PIEL]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================			
	@PP_K_PIEL_LOTE				INT,
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR (300)		OUTPUT
AS	
	DECLARE @VP_RESULTADO		VARCHAR(300)= ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO='' 
		BEGIN
			DECLARE	@VP_PIEL_LOTE_CANTIDAD		INT = 0
			DECLARE	@VP_D_PIEL_LOTE_CANTIDAD	VARCHAR(100)
			SELECT	@VP_D_PIEL_LOTE_CANTIDAD	= D_PIEL_LOTE,
					@VP_PIEL_LOTE_CANTIDAD		= PIEL_LOTE_CANTIDAD
												FROM PIEL_LOTE  
												WHERE K_PIEL_LOTE=@PP_K_PIEL_LOTE

			IF @VP_PIEL_LOTE_CANTIDAD IS NULL
				SET @VP_PIEL_LOTE_CANTIDAD = 0

			DECLARE	@VP_RP_SC_CANTIDAD		INT
			SELECT	@VP_RP_SC_CANTIDAD =	COUNT(K_RP_SC )
										FROM RP_SC  
										WHERE K_PIEL_LOTE =	@PP_K_PIEL_LOTE

			IF @VP_RP_SC_CANTIDAD IS NULL
				SET @VP_RP_SC_CANTIDAD = 0

			IF @VP_PIEL_LOTE_CANTIDAD = @VP_RP_SC_CANTIDAD
				SET	@VP_RESULTADO = @VP_RESULTADO +CHAR(13)+CHAR(10) + 'Ya se han clasificado todas las Pieles para este ' + '[#LOTE:' + @VP_D_PIEL_LOTE_CANTIDAD + ']'
		END	
		
	-- ///////////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DESC//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO
*/



-- ===========================================================================================
-- ===========================================================================================
-- == REGLAS DE NEGOCIO BASICAS (INSERT / UPDATE / DELETE)
-- ===========================================================================================
-- ===========================================================================================


-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION INSERT
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_INSERT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_INSERT]
GO


CREATE PROCEDURE [dbo].[PG_RN_RP_SC_INSERT]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(10),
	-- ===========================			
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO		VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		--EXECUTE [dbo].[PG_RN_DATA_ACCESO_INSERT]		@PP_L_DEBUG, @PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,	
		--												1, -- @PP_K_DATA_SISTEMA,	
		--												@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- //////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //INS//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION UPDATE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_UPDATE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_UPDATE]
GO

CREATE PROCEDURE [dbo].[PG_RN_RP_SC_UPDATE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(10),
	-- ===========================		
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
	
	-- ///////////////////////////////////////////
	-- ///////////////////////////////////////////
	
	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_EXISTE]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
											@PP_LOTE, @PP_PIEL,	 
											@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT

	-- ///////////////////////////////////////////
	
	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO --+ ' //UPD//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> RN // VALIDACION DELETE
-- //////////////////////////////////////////////////////////////


IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RN_RP_SC_DELETE]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RN_RP_SC_DELETE]
GO


CREATE PROCEDURE [dbo].[PG_RN_RP_SC_DELETE]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================		
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL					VARCHAR(10),
	-- ===========================			
	@OU_RESULTADO_VALIDACION	VARCHAR(300)	OUTPUT
AS

	DECLARE @VP_RESULTADO			VARCHAR(300) = ''
		
	-- ///////////////////////////////////////////

	IF @VP_RESULTADO=''
		EXECUTE [dbo].[PG_RN_RP_SC_EXISTE]		@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
												@PP_LOTE, @PP_PIEL,
												@OU_RESULTADO_VALIDACION = @VP_RESULTADO		OUTPUT
	-- ///////////////////////////////////////////




	-- ///////////////////////////////////////////

	IF	@VP_RESULTADO<>''
		SET	@VP_RESULTADO = @VP_RESULTADO + ' //DEL//'
	
	-- ///////////////////////////////////////////
		
	SET @OU_RESULTADO_VALIDACION = @VP_RESULTADO

	-- /////////////////////////////////////////////////////
GO





-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- ////////////////////////////////////////////////////////////////////////////////////////////////////////////
