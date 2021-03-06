-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			EMBARQUES
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	16/11/2020
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / STOCK STATUS PDF
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF]
GO

/*

 EXEC	[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF] 0,0, 3813669
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]	0,0, 3813669

*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT 
AS
	-- //////////////////////////////////////////////////////////////

	DECLARE @VP_COLOUR VARCHAR(20) = '', @VP_LOCACION VARCHAR(5)  = '', @VP_ORDEN VARCHAR(10) = '', @VP_ESTATUS_ORDEN VARCHAR(10) = '';
	 
	SELECT	TOP 1 
			@VP_COLOUR = LTRIM(RTRIM(COLOUR)),
			@VP_LOCACION = LTRIM(RTRIM(MOVEMENT))
	FROM	RP_SC 
	WHERE TAGNO = @PP_FOLIO 
 
	IF SUBSTRING(@VP_LOCACION, 1, 1) IN ('T', 'G')
		BEGIN
			SELECT	@VP_ORDEN = LTRIM(RTRIM(jobno))
			FROM	RP_FOLIOS 
			WHERE TAG= @PP_FOLIO
			
			SELECT  @VP_ORDEN = LTRIM(RTRIM(jobno)),
					@VP_ESTATUS_ORDEN = LTRIM(RTRIM(STATUS))
			FROM  ccjobhdr_sql 
			WHERE FOLIO = @PP_FOLIO
		END

	SELECT	@PP_FOLIO			AS FOLIO,
			@VP_COLOUR			AS COLOR,
			@VP_LOCACION		AS LOCACION,
			@VP_ORDEN			AS ORDEN,
			@VP_ESTATUS_ORDEN	AS ESTATUS_ORDEN

	-- //////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / STOCK STATUS PDF
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]
GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF] 0,0, 3813669
 EXEC	[dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF] 0,0, 3813669
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]	0,0, 3813669
*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT
AS
	-- //////////////////////////////////////////////////////////////
	
	SELECT	LTRIM(RTRIM(LOT))	AS LOTE, 
			LTRIM(RTRIM(HIDE))	AS PIEL, 
			CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF)))	AS SQF 
	FROM	RP_SC 
	WHERE	TAGNO = @PP_FOLIO
	ORDER BY LOT, HIDE

	-- //////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / STOCK STATUS PDF
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]
GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF] 0,0, 3813669
*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT 
AS

	-- //////////////////////////////////////////////////////////////
	DECLARE @VP_TBL_FOLIO AS TABLE(
		ID INTEGER IDENTITY(1,1),
		D_TIPO_PIEL_LOG	VARCHAR(100),
		LOTE			VARCHAR(20),
		PIEL			VARCHAR(10),
		SQF				DECIMAL(13,2)
	)

	INSERT INTO @VP_TBL_FOLIO
	SELECT	'ACTUAL',
			LTRIM(RTRIM(LOT))	AS LOTE, 
			LTRIM(RTRIM(HIDE))	AS PIEL, 
			CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF)))	AS SQF 
	FROM	RP_SC 
	WHERE	TAGNO = @PP_FOLIO
	ORDER BY LOT, HIDE

	-- //////////////////////////////////////////////////////////////

	DECLARE @VP_TBL_FOLIO_MOVIMINETO_ORDEN AS TABLE(
		ID INTEGER IDENTITY(1,1),
		D_TIPO_PIEL_LOG	VARCHAR(100),
		LOTE			VARCHAR(20),
		PIEL			VARCHAR(10),
		SQF				DECIMAL(13,2)
	)

	INSERT INTO @VP_TBL_FOLIO_MOVIMINETO_ORDEN
	SELECT TOP 1000
		-- ===========================
		( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN <>  @PP_FOLIO THEN 'EXTRAS'
					WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
					WHEN D_TIPO_PIEL_LOG = 'FOLIO SCRAP' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
				ELSE D_TIPO_PIEL_LOG END ) AS D_TIPO_PIEL_LOG,
		-- ===========================
		--FOLIO_ORIGEN,
		--LOCACION_ORIGEN,
		--ORDEN_ORIGEN,
		-- ===========================
		--( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A ORDEN' AND FOLIO_DESTINO = 0 THEN FOLIO_ORIGEN
		--		ELSE FOLIO_DESTINO END ) AS FOLIO_DESTINO,
		-- ===========================
		--LOCACION_DESTINO,
		--ORDEN_DESTIDO AS ORDEN_DESTINO,
		--COLOR,
		LOTE,
		RIGHT('0000' + CONVERT(VARCHAR(4), PIEL), 4) AS PIEL, 
		CONVERT(DECIMAL(13,2), SQF) AS SQF
		--F_LOG,
		--D_USUARIO_PEARL
	FROM PIEL_LOG 
	--INNER JOIN BD_GENERAL.dbo.USUARIO_PEARL  ON PIEL_LOG.K_USUARIO_ALTA = USUARIO_PEARL.K_USUARIO_PEARL
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE (FOLIO_ORIGEN = @PP_FOLIO OR FOLIO_DESTINO = @PP_FOLIO)
	AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5, 6, 9) -- #5	TRANSFERENCIA A FOLIO	#6 DEVOLUCION	#9 FOLIO SCRAP
	--ORDER BY  LOTE, PIEL 
	ORDER BY K_PIEL_LOG, LOTE, PIEL ASC
	
	-- //////////////////////////////////////////////////////////////
	INSERT INTO @VP_TBL_FOLIO
	SELECT D_TIPO_PIEL_LOG, LOTE, PIEL, SQF  FROM @VP_TBL_FOLIO_MOVIMINETO_ORDEN ORDER BY D_TIPO_PIEL_LOG DESC

	
	-- //////////////////////////////////////////////////////////////
	SELECT * FROM @VP_TBL_FOLIO ORDER BY ID
	-- //////////////////////////////////////////////////////////////
GO






-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SK LOT_COMP, PARA OBTENER TODOS LOS 
-- //						LOTES COMPATIBLES CON @PP_LOTE
-- // SE UTILIZA EN:
-- //	1) LOT_COMP
-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PEDF]
GO
--		 EXECUTE [dbo].[[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]	0,139,	'401031','401071'
CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_LOTE					VARCHAR(10),
	@PP_LOTE_02					VARCHAR(10)

AS	

	SET	@PP_LOTE	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE))), 6)
	SET	@PP_LOTE_02	= RIGHT('000000' + CONVERT(VARCHAR(10),Ltrim(Rtrim(@PP_LOTE_02))), 6)

	DECLARE	@PP_TABLA_LOTES				AS TABLE
			(	 TA_LOTE_ID				INT
				,TA_LOTE_SERIE			VARCHAR(10)
				,TA_LOTE_L				INT
				,TA_LOTE_AUTORIZA_01	VARCHAR(250)
				,TA_LOTE_K_USUARIO_01	VARCHAR(250)
				,TA_LOTE_AUTORIZA_02	VARCHAR(250)
				,TA_LOTE_K_USUARIO_02	VARCHAR(250)
				,TA_LOTE_C				VARCHAR(250)
				,TA_L_COMENTARIO		INT
			)
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================
---===================================================================================================================================================	
	DECLARE	 @VP_CU_ID_LOTE_COMPATIBLE			INT
			-- =====================================================
			,@VP_CU_D_ITEM						VARCHAR(25)
			-- =====================================================
			,@VP_CU_S_LOTE_COMPATIBLE_01		VARCHAR(10)
			,@VP_CU_S_LOTE_COMPATIBLE_02		VARCHAR(10)
			-- =====================================================
			,@VP_CU_L_LOTE_COMPATIBLE			VARCHAR(10)
			,@VP_CU_A_LOTE_COMPATIBLE_01		VARCHAR(250)
			,@VP_CU_A_LOTE_COMPATIBLE_02		VARCHAR(250)
			,@VP_CU_K_LOTE_COMPATIBLE_01		INT
			,@VP_CU_K_LOTE_COMPATIBLE_02		INT
			-- =====================================================
			,@VP_CU_C_LOTE_COMPATIBLE			VARCHAR(250)


	DECLARE CU_COMPATIBLES CURSOR FOR  
		SELECT	 ID										--AS K_LOTE_COMPATIBLE		
				,LTRIM(RTRIM(ITEM_NO))					--AS D_ITEM
				,LTRIM(RTRIM(SER_LOT_NO1))				--AS S_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(SER_LOT_NO2))				--AS S_LOTE_COMPATIBLE_02
				,(CASE
					WHEN	LTRIM(RTRIM(COMP))	= 'Y'	THEN	1
					ELSE	0
				END)									--AS L_LOTE_COMPATIBLE
				,LTRIM(RTRIM(Aut1))						--AS A_LOTE_COMPATIBLE_01
				,LTRIM(RTRIM(Aut2))						--AS A_LOTE_COMPATIBLE_02
				,K_USUARIO_PEARL_01
				,K_USUARIO_PEARL_02
				,LTRIM(RTRIM(Comments))					--AS C_LOTE_COMPATIBLE
		-- ===============================================================
		FROM	SER_LOT_COMP_SQL
		-- ===============================================================
		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1))	= @PP_LOTE  
					OR	LTRIM(RTRIM(SER_LOT_NO2))	= @PP_LOTE 		)
		--AND		(		LTRIM(RTRIM(SER_LOT_NO1))	= @PP_LOTE  
		--			OR	LTRIM(RTRIM(SER_LOT_NO2))	= @PP_LOTE_02 		)
		---- ===============================================================
	OPEN			CU_COMPATIBLES;  
	FETCH NEXT FROM CU_COMPATIBLES INTO		@VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
											,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
											,@VP_CU_L_LOTE_COMPATIBLE			
											,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
											,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
											,@VP_CU_C_LOTE_COMPATIBLE		
	WHILE @@FETCH_STATUS = 0  
	   BEGIN
			DECLARE	 @VP_IN_LOTE_SERIE		VARCHAR(10)	= ''
			

			IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_01
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_02
			END
			ELSE IF @PP_LOTE	= @VP_CU_S_LOTE_COMPATIBLE_02
			BEGIN
				SET	@VP_IN_LOTE_SERIE	= @VP_CU_S_LOTE_COMPATIBLE_01
			END

			-- /////////////////////////////////////////////////////////////////////				
				INSERT INTO @PP_TABLA_LOTES	(
					TA_LOTE_ID		
					,TA_LOTE_SERIE	
					,TA_LOTE_L
					,TA_LOTE_AUTORIZA_01
					,TA_LOTE_K_USUARIO_01
					,TA_LOTE_AUTORIZA_02
					,TA_LOTE_K_USUARIO_02
					,TA_LOTE_C
					,TA_L_COMENTARIO						
				)	VALUES	(
					@VP_CU_ID_LOTE_COMPATIBLE
					,@VP_IN_LOTE_SERIE
					,@VP_CU_L_LOTE_COMPATIBLE
					,@VP_CU_A_LOTE_COMPATIBLE_01
					,@VP_CU_K_LOTE_COMPATIBLE_01
					,@VP_CU_A_LOTE_COMPATIBLE_02
					,@VP_CU_K_LOTE_COMPATIBLE_02
					,@VP_CU_C_LOTE_COMPATIBLE
					,0
				)
			-- /////////////////////////////////////////////////////////////////////

		FETCH NEXT FROM CU_COMPATIBLES INTO		 @VP_CU_ID_LOTE_COMPATIBLE		,@VP_CU_D_ITEM
												,@VP_CU_S_LOTE_COMPATIBLE_01	,@VP_CU_S_LOTE_COMPATIBLE_02
												,@VP_CU_L_LOTE_COMPATIBLE			
												,@VP_CU_A_LOTE_COMPATIBLE_01	,@VP_CU_A_LOTE_COMPATIBLE_02		
												,@VP_CU_K_LOTE_COMPATIBLE_01	,@VP_CU_K_LOTE_COMPATIBLE_02		
												,@VP_CU_C_LOTE_COMPATIBLE
	   END;  
	CLOSE		CU_COMPATIBLES;  
	DEALLOCATE	CU_COMPATIBLES;  

	SELECT
		 TA_LOTE_ID				AS	K_LOTE_COMPATIBLE
		,TA_LOTE_SERIE			AS	S_LOTE_COMPATIBLE
		,TA_LOTE_L				AS	L_LOTE_COMPATIBLE
		,TA_LOTE_AUTORIZA_01	AS	A_LOTE_COMPATIBLE_01
		,TA_LOTE_K_USUARIO_01	AS	K_LOTE_USUARIO_01		
		,TA_LOTE_AUTORIZA_02	AS	A_LOTE_COMPATIBLE_02
		,TA_LOTE_K_USUARIO_02	AS	K_LOTE_USUARIO_02		
		,TA_LOTE_C				AS	C_LOTE_COMPATIBLE
		,TA_L_COMENTARIO		AS	L_COMENTARIO
	FROM @PP_TABLA_LOTES	
	WHERE	(		LTRIM(RTRIM(TA_LOTE_SERIE))	<> @PP_LOTE_02	)
	ORDER	BY		TA_LOTE_SERIE	DESC
		-- ===============================================================
		-- ===============================================================
	-- ////////////////////////////////////////////////////////////////////
GO





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / STOCK STATUS PDF
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]
GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF] 0,0, 3813669
*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT 
AS
	-- //////////////////////////////////////////////////////////////
	SELECT TOP 1000
		--D_TIPO_PIEL_LOG,
		-- ===========================
		( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A ORDEN' AND LOCACION_ORIGEN = 'MHI' THEN 'FOLIO A MESA'
					WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN <>  @PP_FOLIO THEN 'EXTRAS'
					WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
					--WHEN D_TIPO_PIEL_LOG = 'FOLIO SCRAP' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
				ELSE D_TIPO_PIEL_LOG END ) AS D_TIPO_PIEL_LOG,
		-- ===========================
		FOLIO_ORIGEN,
		LOCACION_ORIGEN,
		ORDEN_ORIGEN,
		-- ===========================
		( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A ORDEN' AND FOLIO_DESTINO = 0 THEN FOLIO_ORIGEN
				ELSE FOLIO_DESTINO END ) AS FOLIO_DESTINO,
		-- ===========================
		LOCACION_DESTINO,
		ORDEN_DESTIDO AS ORDEN_DESTINO,
		COLOR,
		LOTE,
		RIGHT('0000' + CONVERT(VARCHAR(4), PIEL), 4) AS PIEL, 
		CONVERT(DECIMAL(13,2), SQF) AS SQF,
		F_LOG,
		D_USUARIO_PEARL
	FROM PIEL_LOG 
	INNER JOIN BD_GENERAL.dbo.USUARIO_PEARL  ON PIEL_LOG.K_USUARIO_ALTA = USUARIO_PEARL.K_USUARIO_PEARL
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	WHERE (FOLIO_ORIGEN = @PP_FOLIO OR FOLIO_DESTINO = @PP_FOLIO)
	--AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5, 6, 9)
	ORDER BY K_PIEL_LOG, LOTE, PIEL ASC
	-- //////////////////////////////////////////////////////////////
GO

