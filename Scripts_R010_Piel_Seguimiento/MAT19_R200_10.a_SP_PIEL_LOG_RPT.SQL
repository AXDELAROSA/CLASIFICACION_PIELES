-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			RP_SC / CLASIFICACION
-- // OPERACION:		LIBERACION / STORED PROCEDURES
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	06/JUL/2021
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////
/*
 EXEC DBO.[PG_RPT_PIEL_LOG] 0,144, 0, 34991, 0, 0
*/

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_RPT_PIEL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_RPT_PIEL_LOG]
GO

CREATE PROCEDURE [dbo].[PG_RPT_PIEL_LOG]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================					
	@PP_FOLIO					INT,			
	@PP_ORDEN					INT,
	--@PP_LOCACION				VARCHAR(50),
	@PP_LOTE					INT,
	@PP_PIEL					INT
AS

	-- ///////////////////////////////////////////
	SELECT TOP 10000 
		--=============================== 
		--D_TIPO_PIEL_LOG, 
		( CASE WHEN D_TIPO_PIEL_LOG = 'CAMBIO COLOR' AND COLOR = COLOR_DESTINO THEN 'TRANSFERENCIA A FOLIO'
			ELSE D_TIPO_PIEL_LOG END ) D_TIPO_PIEL_LOG,
		--=============================== 
		COLOR, 
		LOCACION_ORIGEN,
		--=============================== 
		(  CASE WHEN FOLIO_ORIGEN = 0 THEN ' '
				ELSE CONVERT(VARCHAR(20), FOLIO_ORIGEN) END) FOLIO_ORIGEN,
		--=============================== 
		(  CASE WHEN ORDEN_ORIGEN = 0 THEN ' '
				ELSE CONVERT(VARCHAR(20), ORDEN_ORIGEN) END) ORDEN_ORIGEN,
		--=============================== 
		(  CASE WHEN ORDEN_ORIGEN = 0 THEN ''
			ELSE ISNULL(( SELECT TOP 1 LTRIM(RTRIM(STATUS)) FROM ccjobhdr_sql WHERE JOBNO = CONVERT(VARCHAR(20), ORDEN_ORIGEN) ), 'D')  END) AS ESTATUS_ORDEN_ORIGEN,
		--=============================== 
		LOTE, 
		PIEL,
		SQF,
		LOCACION_DESTINO,
		--=============================== 
		(  CASE WHEN FOLIO_DESTINO = 0 THEN ' '
				ELSE CONVERT(VARCHAR(20), FOLIO_DESTINO) END) FOLIO_DESTINO,
		--=============================== 
		(  CASE WHEN ORDEN_DESTIDO = 0 THEN ' '
				ELSE CONVERT(VARCHAR(20), ORDEN_DESTIDO) END) ORDEN_DESTIDO,
		--=============================== 
		(  CASE WHEN ORDEN_DESTIDO = 0 THEN ''
			ELSE ISNULL(( SELECT TOP 1 LTRIM(RTRIM(STATUS)) FROM ccjobhdr_sql WHERE JOBNO = CONVERT(VARCHAR(20), ORDEN_DESTIDO) ), 'D')  END) AS ESTATUS_ORDEN_DESTINO,
		--=============================== 
		( CASE WHEN COLOR_DESTINO = '' THEN COLOR
			ELSE COLOR_DESTINO END ) COLOR_DESTINO,
		--=============================== 
		(CASE WHEN usuario IS NULL THEN (	SELECT UPPER(CONCAT(LTRIM(RTRIM(EP_NOMBRE)), ' ', LTRIM(RTRIM(EP_APELLIDO_PATERNO))))
											FROM HOWE.dbo.VISTA_GAFETES (NOLOCK)
											WHERE EN_NUM_EMP = K_USUARIO_ALTA)
			ELSE UPPER(LTRIM(RTRIM(usuario))) END) AS USUARIO,
		--=============================== 
		CONVERT(VARCHAR(50), F_LOG, 20) AS FECHA
	FROM PIEL_LOG 
	LEFT JOIN users_pearl ON PIEL_LOG.K_USUARIO_ALTA = users_pearl.codigo
	INNER JOIN TIPO_PIEL_LOG ON PIEL_LOG.K_TIPO_PIEL_LOG = TIPO_PIEL_LOG.K_TIPO_PIEL_LOG
	--=============================== 
	WHERE ( FOLIO_ORIGEN = ( CASE WHEN @PP_FOLIO = 0 THEN FOLIO_ORIGEN
									ELSE @PP_FOLIO END ) 
			OR FOLIO_DESTINO = ( CASE WHEN @PP_FOLIO = 0 THEN FOLIO_DESTINO
									ELSE @PP_FOLIO END )  		
			)					
	AND ( ORDEN_ORIGEN = ( CASE WHEN @PP_ORDEN = 0 THEN ORDEN_ORIGEN
									ELSE @PP_ORDEN END ) 
			OR ORDEN_DESTIDO = ( CASE WHEN @PP_ORDEN = 0 THEN ORDEN_DESTIDO
									ELSE @PP_ORDEN END )  		
			)
	--=============================== 
	--AND ( LOCACION_ORIGEN = ( CASE WHEN @PP_LOCACION = '' THEN LOCACION_ORIGEN
	--								ELSE @PP_LOCACION END ) 
	--		OR LOCACION_DESTINO = ( CASE WHEN @PP_LOCACION = '' THEN LOCACION_DESTINO
	--								ELSE @PP_LOCACION END )  		
	--		)
	--=============================== 
	AND LOTE = ( CASE WHEN @PP_LOTE = 0 THEN LOTE
									ELSE @PP_LOTE END ) 
	--=============================== 
	AND PIEL = ( CASE WHEN @PP_PIEL = 0 THEN PIEL
									ELSE @PP_PIEL END ) 
	ORDER BY K_PIEL_LOG, PIEL ASC
          
	-----////////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
