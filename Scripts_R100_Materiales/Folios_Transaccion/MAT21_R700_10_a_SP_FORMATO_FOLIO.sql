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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]
GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF] 0,0, 3794597
 EXEC	[dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF] 0,0, 3813669
*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_DEV_EXTRA_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT 
AS

	-- //////////////////////////////////////////////////////////////
	DECLARE @VP_LOCACION	VARCHAR(5) = '', @VP_TIPO VARCHAR(5) = ''

	SELECT	@VP_TIPO = ISNULL(STATUS, ''),
			@VP_LOCACION = ISNULL(MACHINE, '') 
	FROM RP_Folios WHERE TAG = @PP_FOLIO

	IF @VP_TIPO <> 'B'
		BEGIN
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
			DECLARE @VP_TBL_FOLIO_MOVIMIENTO_ORDEN AS TABLE(
				ID INTEGER IDENTITY(1,1),
				D_TIPO_PIEL_LOG	VARCHAR(100),
				LOTE			VARCHAR(20),
				PIEL			VARCHAR(10),
				SQF				DECIMAL(13,2)
			)

			-- //////////////////////////////////////////////////////////////
			IF SUBSTRING(@VP_LOCACION, 1,1) IN ('T', 'G')
				BEGIN
					INSERT INTO @VP_TBL_FOLIO_MOVIMIENTO_ORDEN
					SELECT TOP 1000
						-- ===========================
						( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN <>  @PP_FOLIO THEN 'EXTRAS'
									WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
									WHEN D_TIPO_PIEL_LOG = 'FOLIO SCRAP' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
								ELSE D_TIPO_PIEL_LOG END ) AS D_TIPO_PIEL_LOG,
						-- ===========================
						LOTE,
						RIGHT('0000' + CONVERT(VARCHAR(4), PIEL), 4) AS PIEL, 
						CONVERT(DECIMAL(13,2), SQF) AS SQF
					FROM PIEL_LOG 
					INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
					WHERE (FOLIO_ORIGEN = @PP_FOLIO OR FOLIO_DESTINO = @PP_FOLIO)
					AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5, 6, 9) -- #5	TRANSFERENCIA A FOLIO	#6 DEVOLUCION	#9 FOLIO SCRAP
					ORDER BY K_PIEL_LOG, LOTE, PIEL ASC
				END
			ELSE
				BEGIN
					INSERT INTO @VP_TBL_FOLIO_MOVIMIENTO_ORDEN
					SELECT TOP 1000
						-- ===========================
						( CASE WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN <>  @PP_FOLIO THEN 'EXTRAS'
									WHEN D_TIPO_PIEL_LOG = 'TRANSFERENCIA A FOLIO' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
									WHEN D_TIPO_PIEL_LOG = 'FOLIO SCRAP' AND FOLIO_ORIGEN =  @PP_FOLIO THEN 'DEVOLUCION'
								ELSE D_TIPO_PIEL_LOG END ) AS D_TIPO_PIEL_LOG,
						-- ===========================
						LOTE,
						RIGHT('0000' + CONVERT(VARCHAR(4), PIEL), 4) AS PIEL, 
						CONVERT(DECIMAL(13,2), SQF) AS SQF
					FROM PIEL_LOG 
					INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
					WHERE (FOLIO_ORIGEN = @PP_FOLIO OR FOLIO_DESTINO = @PP_FOLIO)
					--AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5, 6, 9) -- #5	TRANSFERENCIA A FOLIO	#6 DEVOLUCION	#9 FOLIO SCRAP
					--ORDER BY  LOTE, PIEL 
					ORDER BY K_PIEL_LOG, LOTE, PIEL ASC
				END

			-- //////////////////////////////////////////////////////////////
			INSERT INTO @VP_TBL_FOLIO
			SELECT D_TIPO_PIEL_LOG, LOTE, PIEL, SQF  FROM @VP_TBL_FOLIO_MOVIMIENTO_ORDEN ORDER BY D_TIPO_PIEL_LOG DESC

			
			-- //////////////////////////////////////////////////////////////
			SELECT * FROM @VP_TBL_FOLIO ORDER BY ID
			-- //////////////////////////////////////////////////////////////
		END
GO




-- //////////////////////////////////////////////////////////////
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]
GO
/*
		 EXECUTE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]	0,144,	3813773
		  EXECUTE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]	0,144,	3813669
*/
CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_LOTE_COMPATIBLE_PDF]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT

AS	
	
	-- //////////////////////////////////////////////////////////////
	DECLARE @VP_TBL_FOLIO_LOTE AS TABLE(
		ID INTEGER IDENTITY(1,1),
		LOTE			VARCHAR(20)
	)

	INSERT INTO @VP_TBL_FOLIO_LOTE
	SELECT DISTINCT	 RIGHT('000000' + LTRIM(RTRIM(LOT)), 6)
	FROM	RP_SC 
	WHERE	TAGNO = @PP_FOLIO

	-- //////////////////////////////////////////////////////////////

	INSERT INTO @VP_TBL_FOLIO_LOTE
	SELECT	DISTINCT RIGHT('000000' + CONVERT(VARCHAR(10),LTRIM(RTRIM(LOTE))), 6)
	FROM PIEL_LOG 
	WHERE (FOLIO_ORIGEN = @PP_FOLIO OR FOLIO_DESTINO = @PP_FOLIO)
	--AND PIEL_LOG.K_TIPO_PIEL_LOG IN (5, 6, 9) -- #5	TRANSFERENCIA A FOLIO	#6 DEVOLUCION	#9 FOLIO SCRAP
	AND LOTE NOT IN (SELECT LOTE FROM  @VP_TBL_FOLIO_LOTE)
	
	-- //////////////////////////////////////////////////////////////
	--SELECT * FROM @VP_TBL_FOLIO_LOTE ORDER BY ID
	-- //////////////////////////////////////////////////////////////
	DECLARE @VP_TBL_FOLIO_LOTE_COMPATIBLES AS TABLE(
		ID INTEGER IDENTITY(1,1),
		LOTE			VARCHAR(20),
		COMPATIBLE		VARCHAR(20),
		NO_COMPATIBLE	VARCHAR(20)
	)

	DECLARE @VP_LOTE_PRINCIPAL VARCHAR(20) = ''
	DECLARE CU_LOTES_ASIGNADOS_FOLIO CURSOR FOR 
		SELECT LOTE FROM @VP_TBL_FOLIO_LOTE ORDER BY ID

	OPEN	CU_LOTES_ASIGNADOS_FOLIO  
	FETCH NEXT FROM CU_LOTES_ASIGNADOS_FOLIO	INTO	@VP_LOTE_PRINCIPAL

	WHILE @@FETCH_STATUS = 0  
	   BEGIN
			DECLARE @VP_LOTE_1 VARCHAR(20) = '',  @VP_LOTE_2 VARCHAR(20) = '', @VP_COMPATIBLE VARCHAR(5) = ''

			DECLARE CU_COMPATIBLES_X_LOTE CURSOR FOR 
			SELECT	LTRIM(RTRIM(SER_LOT_NO1)),				
					LTRIM(RTRIM(SER_LOT_NO2)),				
					LTRIM(RTRIM(COMP))
			-- ===============================================================
			FROM	SER_LOT_COMP_SQL
			-- =============================================================== 
			WHERE	(		LTRIM(RTRIM(SER_LOT_NO1)) = @VP_LOTE_PRINCIPAL 
					OR	LTRIM(RTRIM(SER_LOT_NO2)) = @VP_LOTE_PRINCIPAL  		)
			ORDER BY COMP DESC


			OPEN	CU_COMPATIBLES_X_LOTE  
			FETCH NEXT FROM CU_COMPATIBLES_X_LOTE	INTO	@VP_LOTE_1, @VP_LOTE_2, @VP_COMPATIBLE

			WHILE @@FETCH_STATUS = 0  
			   BEGIN
					DECLARE @VP_LOTE_COMPATIBLE VARCHAR(20) = ''
					DECLARE @VP_LOTE_NO_COMPATIBLE VARCHAR(20) = ''

					IF @VP_LOTE_1 <> @VP_LOTE_PRINCIPAL
						BEGIN
							IF @VP_COMPATIBLE = 'Y'
								SET @VP_LOTE_COMPATIBLE = @VP_LOTE_1
							ELSE
								SET @VP_LOTE_NO_COMPATIBLE = @VP_LOTE_1
						END

					IF @VP_LOTE_2 <> @VP_LOTE_PRINCIPAL
						BEGIN
							IF @VP_COMPATIBLE = 'Y'
								SET @VP_LOTE_COMPATIBLE = @VP_LOTE_2
							ELSE
								SET @VP_LOTE_NO_COMPATIBLE = @VP_LOTE_2
						END

					INSERT INTO @VP_TBL_FOLIO_LOTE_COMPATIBLES
					SELECT @VP_LOTE_PRINCIPAL, @VP_LOTE_COMPATIBLE, @VP_LOTE_NO_COMPATIBLE

					FETCH NEXT FROM CU_COMPATIBLES_X_LOTE	INTO	@VP_LOTE_1, @VP_LOTE_2, @VP_COMPATIBLE
				END  
			CLOSE		CU_COMPATIBLES_X_LOTE;  
			DEALLOCATE	CU_COMPATIBLES_X_LOTE; 


			FETCH NEXT FROM CU_LOTES_ASIGNADOS_FOLIO	INTO	@VP_LOTE_PRINCIPAL
		END  
	CLOSE		CU_LOTES_ASIGNADOS_FOLIO;  
	DEALLOCATE	CU_LOTES_ASIGNADOS_FOLIO; 

	-- ////////////////////////////////////////////////////////////////////
	SELECT ( CASE WHEN SUBSTRING(LTRIM(RTRIM(LOTE)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(LOTE)),2, 10) ELSE LTRIM(RTRIM(LOTE)) END )  AS LOTE,
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(COMPATIBLE)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(COMPATIBLE)),2, 10) ELSE LTRIM(RTRIM(COMPATIBLE)) END )  AS COMPATIBLE,
			( CASE WHEN SUBSTRING(LTRIM(RTRIM(NO_COMPATIBLE)),1,1) = '0' THEN SUBSTRING(LTRIM(RTRIM(NO_COMPATIBLE)),2, 10) ELSE LTRIM(RTRIM(NO_COMPATIBLE)) END )  AS NO_COMPATIBLE
	FROM @VP_TBL_FOLIO_LOTE_COMPATIBLES
	-- ////////////////////////////////////////////////////////////////////

	--SELECT	*
	--		-- ===============================================================
	--		FROM	SER_LOT_COMP_SQL
	--		-- =============================================================== 034331
	--		WHERE	(		LTRIM(RTRIM(SER_LOT_NO1)) = '034331' 
	--				OR	LTRIM(RTRIM(SER_LOT_NO2)) = '034331'  		)
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





-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / STOCK STATUS PDF
-- //////////////////////////////////////////////////////////////
-- USE DATA_02
--IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]') AND type in (N'P', N'PC'))
--	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]
--GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF] 0,0, 3813669
 EXEC	[dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF] 0,0, 3813669
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]	0,0, 3813669
*/

--CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_PIEL_CARGADA_PDF]
--	@PP_K_SISTEMA_EXE					INT,
--	@PP_K_USUARIO_ACCION				INT,
--	-- ===========================
--	@PP_FOLIO							INT
--AS
--	-- //////////////////////////////////////////////////////////////
	
--	SELECT	LTRIM(RTRIM(LOT))	AS LOTE, 
--			LTRIM(RTRIM(HIDE))	AS PIEL, 
--			CONVERT(DECIMAL(13,2),LTRIM(RTRIM(SQF)))	AS SQF 
--	FROM	RP_SC 
--	WHERE	TAGNO = @PP_FOLIO
--	ORDER BY LOT, HIDE

--	-- //////////////////////////////////////////////////////////////
--GO
