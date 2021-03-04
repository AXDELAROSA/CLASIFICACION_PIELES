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

 EXEC	[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF] 0,0, 3813391
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]	0,0, 3813391

 EXEC	[dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF] 0,0, 2137674
*/

CREATE PROCEDURE [dbo].[PG_FORMATO_FOLIO_ENCABEZADO_PDF]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_FOLIO							INT 
AS
	-- //////////////////////////////////////////////////////////////
	/*
	SELECT * FROM  ccjobhdr_sql WHERE jobno IN  ('25271')

	SELECT * FROM RP_FOLIOS WHERE TAG= 3813391 

	SELECT * FROM RP_SC WHERE TAGNO = 3813391 
	*/

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
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_FORMATO_FOLIO_DETALLE_PDF]
GO

/*
 EXEC	[dbo].[PG_FORMATO_FOLIO_DETALLE_PDF] 0,0, 3813391
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
	AND PIEL_LOG.K_TIPO_PIEL_LOG NOT IN (3, 10)
	ORDER BY K_PIEL_LOG, LOTE, PIEL ASC
	-- //////////////////////////////////////////////////////////////
GO

