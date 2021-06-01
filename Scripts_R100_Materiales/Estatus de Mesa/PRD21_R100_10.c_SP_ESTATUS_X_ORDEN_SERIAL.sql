-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02]
-- // MODULO:			ESTATUS POR ORDEN/SERIAL
-- // OPERACION:		LIBERACION / STORED PROCEDURE
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	31/MAY/2021
-- //////////////////////////////////////////////////////////////  

USE [DATA_02]
GO

-- //////////////////////////////////////////////////////////////



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
GO

/*
												  (ORDEN)
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, '31980'
 EXEC	[dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN] 0,0, ''
*/


CREATE PROCEDURE [dbo].[PG_LI_ESTATUS_X_SERIAL_ORDEN]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_ORDEN						VARCHAR(50)
AS

	-- /////////SE DECLARA LAS VARIABLES Y EL CURSOSR A USAR/////////////////////////////////////////////////////////////////////////////
	SELECT	ccjoblin_sql.jobno, 
			-- ===========================
			LTRIM(RTRIM(ccjoblin_sql.kit))			AS KIT, 
			LTRIM(RTRIM(ccjoblin_sql.kitdesc))		AS KIT_DESC, 
			CONVERT(INT,ccjoblin_sql.originalqty)	AS ORIGINAL_QTY, 
			LTRIM(RTRIM(ccjoblin_sql.customer))		AS CUSTOMER, 
			ccjoblin_sql.item_no					AS ITEM_NO,
			ccjoblin_sql.Ser_No						AS SER_NO,
			-- ===========================
			LTRIM(RTRIM(cccusitm_sql.cus_item_no))	AS CUS_ITEM_NO,
			LTRIM(RTRIM(cccusitm_sql.modelno))		AS MODELNO,
			LTRIM(RTRIM(cccusitm_sql.versionno))	AS VERSIONNO,
			LTRIM(RTRIM(MACHINE))					AS MESA,
			[dbo].[CONVERT_INT_TO_DATE](ccjobhdr_sql.datecreated) AS F_CREACION
			-- ===========================
	FROM ccjoblin_sql  (NOLOCK)
	INNER JOIN ccjobhdr_sql (NOLOCK) ON ccjoblin_sql.jobno = ccjobhdr_sql.jobno 
		AND status = 'P' AND folio IS NOT NULL AND ccjobhdr_sql.JOBNO < 50000
	-- ===========================
	INNER JOIN	cccusitm_sql (NOLOCK) ON ccjoblin_sql.Item_No = cccusitm_sql.item_no 
	AND		ccjoblin_sql.customer = cccusitm_sql.cus_no
	AND		cccusitm_sql.versionno = (	SELECT	MAX(CONVERT(INT, versionno)) 
													FROM	cccusitm_sql (NOLOCK)
													WHERE	cccusitm_sql.Item_No = ccjoblin_sql.item_no  
													AND		cccusitm_sql.cus_no = ccjoblin_sql.customer)
	-- ===========================

	WHERE	ccjoblin_sql.jobno = ( CASE WHEN @PP_ORDEN <> '' THEN @PP_ORDEN
										ELSE ccjoblin_sql.jobno END )
	-- ===========================
    ORDER BY ccjoblin_sql.jobno, SER_NO

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / LISTADO
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_RUTA_KIT]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_RUTA_KIT]
GO
/*
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWGLFCCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBRCNPDX9', 'WKG', '0024'
 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMJYFBLCNPDX9', 'WKG', '0024'

 EXEC	[dbo].[PG_LI_RUTA_KIT] 0,0, 'PMWDZBRCNPDX9', 'WKZ', '0015'


   
*/

CREATE PROCEDURE [dbo].[PG_LI_RUTA_KIT]
	@PP_K_SISTEMA_EXE				INT,
	@PP_K_USUARIO_ACCION			INT,
	@PP_KIT							VARCHAR(50),
	@PP_MODELO						VARCHAR(50),
	@PP_VERSION						VARCHAR(50)
AS

	-- /////////SE DECLARA LAS VARIABLES Y EL CURSOSR A USAR/////////////////////////////////////////////////////////////////////////////
	DECLARE @VP_SECUENCIA_EVENTO VARCHAR(255) = ''

	DECLARE @TBL_PROCESO_X_PATRON AS TABLE(
		ID				INT IDENTITY(1,1),
		D_PROCESO		VARCHAR(100),
		ESTATUS			INT
	)


	DECLARE CU_RUTA_KIT CURSOR 
	FOR SELECT LTRIM(RTRIM(USER_DEF_FLD_4)) FROM [DATA_02].[DBO].ccitmidx_sql
	INNER JOIN [DATA_02].[DBO].ccprdstr_sql ON ccitmidx_sql.ITEM_NO = ccprdstr_sql.comp_item_no
		AND ccitmidx_sql.modelno = ccprdstr_sql.modelno AND ccitmidx_sql.versionno = ccprdstr_sql.versionno 
	WHERE ccprdstr_sql.ITEM_NO = @PP_KIT   
	AND ccprdstr_sql.modelno = @PP_MODELO
	AND ccprdstr_sql.versionno = @PP_VERSION

	OPEN CU_RUTA_KIT
	FETCH NEXT FROM CU_RUTA_KIT INTO @VP_SECUENCIA_EVENTO
	
	WHILE @@FETCH_STATUS = 0
		BEGIN	
			--    ES EL ORDEN CORRECTO DE LOS SPECIAL PROCESS
			--    PERFO03 + SHAVE01 + EMBOS06 + LAMIN02 + RECUT04 + QULTN05 + SHAVE07 + LAMIN08 + LAMIN09 + PERFO10 + LAMIN11 + LAMIN12 + LAMIN13 + QULTN14 + ENESPERAUSO
			DECLARE @VP_PERF CHAR(1) = '', @VP_SHAVE CHAR(1) = '', @VP_EMBOS CHAR(1) = '', @VP_LAMIN CHAR(1) = '', @VP_RECUT CHAR(1) = ''
			DECLARE @VP_QULTN CHAR(1) = '', @VP_SHAVE02 CHAR(1) = '', @VP_LAMIN02 CHAR(1) = '', @VP_LAMIN03 CHAR(1) = '', @VP_PERFO02 CHAR(1) = ''
			DECLARE @VP_LAMIN04 CHAR(1) = '', @VP_LAMIN05 CHAR(1) = '', @VP_LAMIN06 CHAR(1) = '', @VP_QULTN02 CHAR(1) = ''

			IF LEN(@VP_SECUENCIA_EVENTO) = 3
				BEGIN
					SET @VP_PERF = SUBSTRING(@VP_SECUENCIA_EVENTO, 1,1)
					SET @VP_SHAVE = SUBSTRING(@VP_SECUENCIA_EVENTO, 2,1)
					SET @VP_EMBOS = SUBSTRING(@VP_SECUENCIA_EVENTO, 3,1)
				END

			IF LEN(@VP_SECUENCIA_EVENTO) > 3
				BEGIN
					SET @VP_PERF = SUBSTRING(@VP_SECUENCIA_EVENTO, 1,1)
					SET @VP_SHAVE = SUBSTRING(@VP_SECUENCIA_EVENTO, 2,1)
					SET @VP_EMBOS = SUBSTRING(@VP_SECUENCIA_EVENTO, 3,1)
					SET @VP_LAMIN = SUBSTRING(@VP_SECUENCIA_EVENTO, 4,1)
					SET @VP_RECUT = SUBSTRING(@VP_SECUENCIA_EVENTO, 5,1)
					SET @VP_QULTN = SUBSTRING(@VP_SECUENCIA_EVENTO, 6,1)
					SET @VP_SHAVE02 = SUBSTRING(@VP_SECUENCIA_EVENTO, 7,1)
					SET @VP_LAMIN02 = SUBSTRING(@VP_SECUENCIA_EVENTO, 8,1)
					SET @VP_LAMIN03 = SUBSTRING(@VP_SECUENCIA_EVENTO, 9,1)
					SET @VP_PERFO02 = SUBSTRING(@VP_SECUENCIA_EVENTO, 10,1)
					SET @VP_LAMIN04 = SUBSTRING(@VP_SECUENCIA_EVENTO, 11,1)
					SET @VP_LAMIN05 = SUBSTRING(@VP_SECUENCIA_EVENTO, 12,1)
					SET @VP_LAMIN06 = SUBSTRING(@VP_SECUENCIA_EVENTO, 13,1)
					SET @VP_QULTN02 = SUBSTRING(@VP_SECUENCIA_EVENTO, 14,1)
				END

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'PERFORACION', (CASE WHEN @VP_PERF = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'SHAVE', (CASE WHEN @VP_SHAVE = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'EMBOSSING', (CASE WHEN @VP_EMBOS = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION', (CASE WHEN @VP_LAMIN = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'RECUTING', (CASE WHEN @VP_RECUT = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'QUILTING', (CASE WHEN @VP_QULTN = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'SHAVE2', (CASE WHEN @VP_SHAVE02 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION2', (CASE WHEN @VP_LAMIN02 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION3', (CASE WHEN @VP_LAMIN03 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'PERFORACION2', (CASE WHEN @VP_PERFO02 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION4', (CASE WHEN @VP_LAMIN04 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION5', (CASE WHEN @VP_LAMIN05 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'LAMINACION6', (CASE WHEN @VP_LAMIN06 = 'Y' THEN 1 ELSE 0 END )

				INSERT INTO @TBL_PROCESO_X_PATRON
				SELECT 'QUILTING2', (CASE WHEN @VP_QULTN02 = 'Y' THEN 1 ELSE 0 END )

			FETCH NEXT FROM CU_RUTA_KIT INTO @VP_SECUENCIA_EVENTO							
		END

	CLOSE CU_RUTA_KIT
	DEALLOCATE CU_RUTA_KIT


	SELECT DISTINCT D_PROCESO FROM @TBL_PROCESO_X_PATRON WHERE ESTATUS = 1

	-- ////////////////////////////////////////////////
	-- ////////////////////////////////////////////////
GO


