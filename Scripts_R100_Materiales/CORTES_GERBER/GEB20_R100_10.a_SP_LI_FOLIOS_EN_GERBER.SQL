-- //////////////////////////////////////////////////////////////
-- // ARCHIVO:			
-- //////////////////////////////////////////////////////////////
-- // BASE DE DATOS:	[DATA_02Pruebas]
-- // MODULO:			PROYECTO/GERBER
-- // OPERACION:		LIBERACION / TABLAS
-- //////////////////////////////////////////////////////////////
-- // Autor:			FEG
-- // Fecha creación:	27/AGO/2020
-- ////////////////////////////////////////////////////////////// 

USE [DATA_02] 
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_FOLIO_EN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_FOLIO_EN_GERBER]
GO

--3793219
--2137674
/*
 EXEC PG_LI_FOLIO_EN_GERBER 0 ,0, 3806956
*/

CREATE PROCEDURE [dbo].[PG_LI_FOLIO_EN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_FOLIO					INT
AS

	-- ///////////////////////////////////////////
	DECLARE @VP_ORDEN_FOLIO VARCHAR(10)

	SELECT @VP_ORDEN_FOLIO = LTRIM(RTRIM(JOBNO))
	FROM RP_FOLIOS 
	WHERE TAG = @PP_FOLIO

	IF ( @VP_ORDEN_FOLIO IS NULL OR @VP_ORDEN_FOLIO = '' OR  @VP_ORDEN_FOLIO = '-' )
		BEGIN
			SELECT DISTINCT  ROW_NUMBER() OVER(ORDER BY RP_SC.ID ASC) AS [ROW],
					RP_SC.CDATE					AS CDATE,
					LTRIM(RTRIM(RP_SC.COLOUR))	AS COLOR,
					LTRIM(RTRIM(LOT))			AS LOTE,
					LTRIM(RTRIM(HIDE))			AS PIEL,
					LTRIM(RTRIM(SQF))			AS SQF,
					-- =======================
					0.00	AS SQF_CORTADO_ORIGINAL,
					0.00	AS SQF_CORTADO,
					-- =======================
					TAGNO					AS FOLIO,
					LTRIM(RTRIM(RP_SC.TYPE))	AS TYPE,
					LTRIM(RTRIM(MOVEMENT))					AS LOCACION,
						S_PIEL_CLASIFICACION,
						(CASE	WHEN RP_Folios.JOBNO IS NULL THEN 'SN/EVENT'
								WHEN RP_Folios.JOBNO = '-' THEN 'SN/EVENT'
								WHEN RP_Folios.JOBNO = '' THEN 'SN/EVENT'
								ELSE	LTRIM(RTRIM(RP_Folios.JOBNO)) END) AS EVENTO
			FROM	RP_SC 
			-- =======================
			INNER	JOIN	PIEL_CLASIFICACION ON RP_SC.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
			INNER	JOIN	RP_Folios ON RP_SC.TAGNO = RP_Folios.TAG
			WHERE	TAGNO = @PP_FOLIO
			AND		SUBSTRING(MOVEMENT, 1,2) = 'GT'
			AND RP_Folios.STATUS <> 'XX'
		END
	ELSE
		BEGIN 
			DECLARE @TBL_CORTES_PIEL_FOLIO TABLE(
				ID INT		IDENTITY (1,1),
				ORDEN		VARCHAR(10),
				LOTE		VARCHAR(50),
				PIEL		VARCHAR(20),
				SQF_CORTE	DECIMAL(13,2)
			)

			INSERT INTO @TBL_CORTES_PIEL_FOLIO
			SELECT JOBNO, LTRIM(RTRIM(LOTNO)), hideno, hidesqm
			FROM cccuthst_sql 
			WHERE jobno = @VP_ORDEN_FOLIO
			
			SELECT DISTINCT  ROW_NUMBER() OVER(ORDER BY RP_SC.ID ASC) AS [ROW],
					RP_SC.CDATE					AS CDATE,
					LTRIM(RTRIM(RP_SC.COLOUR))	AS COLOR,
					LTRIM(RTRIM(LOT))			AS LOTE,
					LTRIM(RTRIM(HIDE))			AS PIEL,
					LTRIM(RTRIM(SQF))			AS SQF,
					-- =======================
					CONVERT(DECIMAL(13,2),ISNULL(SQF_CORTE, 0.0000))	AS SQF_CORTADO_ORIGINAL,
					CONVERT(DECIMAL(13,2),ISNULL(SQF_CORTE, 0.0000))	AS SQF_CORTADO,
					TAGNO					AS FOLIO,
					LTRIM(RTRIM(RP_SC.TYPE))	AS TYPE,
					LTRIM(RTRIM(MOVEMENT))					AS LOCACION,
						S_PIEL_CLASIFICACION,
						(CASE	WHEN RP_Folios.JOBNO IS NULL THEN 'SN/EVENT'
								WHEN RP_Folios.JOBNO = '-' THEN 'SN/EVENT'
								WHEN RP_Folios.JOBNO = '' THEN 'SN/EVENT'
								ELSE	LTRIM(RTRIM(RP_Folios.JOBNO)) END) AS EVENTO
			FROM	RP_SC 
			-- =======================
			INNER	JOIN	PIEL_CLASIFICACION ON RP_SC.K_CLASIFICACION = PIEL_CLASIFICACION.K_PIEL_CLASIFICACION
			INNER	JOIN	RP_Folios ON RP_SC.TAGNO = RP_Folios.TAG
			LEFT	JOIN	@TBL_CORTES_PIEL_FOLIO AS PIEL_CORTE ON PIEL_CORTE.LOTE = RIGHT('000000' + LTRIM(RTRIM(RP_SC.LOT)), 6) 
							AND LTRIM(RTRIM(PIEL_CORTE.PIEL)) = LTRIM(RTRIM(HIDE))
							AND LTRIM(RTRIM(PIEL_CORTE.ORDEN)) = LTRIM(RTRIM(JOBNO))
			WHERE	TAGNO = @PP_FOLIO
			AND		SUBSTRING(MOVEMENT, 1,2) = 'GT'
			AND RP_Folios.STATUS <> 'XX'
			-- =======================
		END

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_GET_SQF_CORTADO_EN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_GET_SQF_CORTADO_EN_GERBER]
GO

--3793219
--2137674
/*
 EXEC PG_LI_FOLIO_EN_GERBER 0 ,0, 3793219 
*/

CREATE PROCEDURE [dbo].[PG_GET_SQF_CORTADO_EN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(10),
	@PP_FOLIO					INT,
	@PP_COLOR					VARCHAR(10),
	@PP_LOCACION				VARCHAR(5),
	@PP_PIEL					VARCHAR(5),
	@PP_LOTE					VARCHAR(15),
	@PP_PIEL_SQF_CORTADO		DECIMAL(13,4),
	-- ===========================
	@PP_USER					VARCHAR(25),
	@PP_COMPUTER_NAME			VARCHAR(25)
AS

	-- ///////////////////////////////////////////
	SELECT  * 
	FROM cccuthst_sql 
	WHERE	LTRIM(RTRIM(COLOUR)) = @PP_COLOR   
	AND	LTRIM(RTRIM(lotno)) = RIGHT('000000' + Ltrim(Rtrim(@PP_LOTE)), 6) 
	AND	LTRIM(RTRIM(hideno)) = @PP_PIEL
	AND	LTRIM(RTRIM(JOBNO)) = @PP_ORDEN 

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_LI_ORDEN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_LI_ORDEN_GERBER]
GO

/*
 EXEC [PG_LI_ORDEN_GERBER] 0 ,0, '' , 'FCPRDX9' , '( TODOS )' , 'MAGN03' ,0
*/

CREATE PROCEDURE [dbo].[PG_LI_ORDEN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_BUSCAR					VARCHAR(50),
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	@PP_ESTATUS					INT
AS

	-- ///////////////////////////////////////////

	SELECT	TOP 10000
			LTRIM(RTRIM(jobno))					AS ORDEN,
			LTRIM(RTRIM(status))				AS ESTATUS,
			CONCAT('F', LTRIM(RTRIM(COLOUR)))	AS COLOR,
			LTRIM(RTRIM(COLOURDESC))			AS DESCRIPCION_COLOR,
			LTRIM(RTRIM(customer))				AS CLIENTE,
			LTRIM(RTRIM(MACHINE))				AS LOCACION,
			-- =======================
			DATA_02.DBO.[CONVERT_INT_TO_DATE](ISNULL(datecreated, 19990101))	AS F_CREACION,
			-- =======================
			(CASE	WHEN datecompleted > 0 OR datecompleted IS NOT NULL
					THEN DATA_02.DBO.[CONVERT_INT_TO_DATE](ISNULL(datecompleted, 19990101))
			ELSE	'19990101' END )			AS F_FIN,
			-- =======================
			LTRIM(RTRIM(comments))				AS COMENTARIO,
			folio								AS FOLIO
	-- =======================
	FROM CCJOBHDR_SQL
	INNER JOIN ESTATUS_ORDEN ON LTRIM(RTRIM(ISNULL(CCJOBHDR_SQL.status,''))) = ESTATUS_ORDEN.S_ESTATUS_ORDEN
	-- =======================
	WHERE ( CONCAT('F', LTRIM(RTRIM(COLOUR)))	LIKE '%'+@PP_BUSCAR+'%'
			OR	MACHINE							LIKE '%'+@PP_BUSCAR+'%'
			OR	CUSTOMER						LIKE '%'+@PP_BUSCAR+'%'
			OR	JOBNO							LIKE '%'+@PP_BUSCAR+'%' )
	-- =============================
	AND		( @PP_COLOR = '( TODOS )'		OR	 CONCAT('F', LTRIM(RTRIM(COLOUR))) = @PP_COLOR  )
	AND		( @PP_LOCACION = '( TODOS )'	OR	LTRIM(RTRIM(MACHINE)) = @PP_LOCACION )
	AND		( @PP_CLIENTE = '( TODOS )'		OR	LTRIM(RTRIM(CUSTOMER)) = @PP_CLIENTE )
	AND		( @PP_ESTATUS = 0				OR	ESTATUS_ORDEN.K_ESTATUS_ORDEN = @PP_ESTATUS )
	-- ============================= 
	AND		SUBSTRING(LTRIM(RTRIM(MACHINE)),1,1) = 'G'
	ORDER BY jobno DESC

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_SK_ORDEN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_SK_ORDEN_GERBER]
GO

/*
 EXEC [PG_SK_ORDEN_GERBER] 0 ,0, '11619'
*/

CREATE PROCEDURE [dbo].[PG_SK_ORDEN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_JOBNO					VARCHAR(50)
AS

	-- ///////////////////////////////////////////

	SELECT	TOP 1500
			LTRIM(RTRIM(jobno))					AS ORDEN,
			K_ESTATUS_ORDEN						AS K_ESTATUS_ORDEN,
			S_ESTATUS_ORDEN,
			CONCAT('F', LTRIM(RTRIM(COLOUR)))	AS COLOR,
			LTRIM(RTRIM(COLOURDESC))			AS DESCRIPCION_COLOR,
			LTRIM(RTRIM(customer))				AS CLIENTE,
			LTRIM(RTRIM(MACHINE))				AS LOCACION,
			-- =======================
			LTRIM(RTRIM(comments))				AS COMENTARIO,
			ISNULL(folio, 0)					AS FOLIO
	-- =======================
	FROM CCJOBHDR_SQL
	INNER JOIN ESTATUS_ORDEN ON CCJOBHDR_SQL.status = ESTATUS_ORDEN.S_ESTATUS_ORDEN
	-- =======================
	WHERE LTRIM(RTRIM(JOBNO)) = @PP_JOBNO

	-----////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////////
GO



-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_IN_ORDEN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_IN_ORDEN_GERBER]
GO

/*
 EXEC [PG_IN_ORDEN_GERBER] 0 ,0, '00001'
*/

CREATE PROCEDURE [dbo].[PG_IN_ORDEN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	--@PP_ESTATUS					INT,
	@PP_COMENTARIO				VARCHAR(255)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''

	-- ///////////////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN
			BEGIN TRANSACTION 
				BEGIN TRY
					-- //////////SE OBTINE EL NUMERO DE ORDEN/////////////////////////////////
					DECLARE @VP_ORDEN	VARCHAR(10) = 0
					SELECT	TOP 1 @VP_ORDEN = CONVERT(INT, LTRIM(RTRIM(JOBNO)))
					FROM	CCJOBHDR_SQL 
					WHERE	JOBNO < '50000'
					ORDER BY JOBNO DESC

					IF @VP_ORDEN IS NULL
						RAISERROR ('ERROR: No fue posible obtener el numero de orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

					SET @VP_ORDEN = @VP_ORDEN + 1
					-- =====================

					SET @VP_ORDEN =RIGHT('00000' + @VP_ORDEN, 5)

					-- //////////SE OBTINE LA DESCRIPCION DEL COLOR/////////////////////////////////
					DECLARE @VP_COLOR_DESCRIPCION VARCHAR(100) = ''
					SELECT @VP_COLOR_DESCRIPCION = LTRIM(RTRIM(item_desc_1))
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR

					IF @VP_COLOR_DESCRIPCION IS NULL
						RAISERROR ('ERROR: No fue posible obtener la descripción del color en [IMITMIDX_SQL]', 16, 1 ) --MENSAJE - Severity -State.

					-- //////////SE INGRESA EL DATO DE LA ORDEN CCJOBHDR_SQL/////////////////////////////////
					DECLARE @VP_F_CREACION_INT	INT = DATA_02.DBO.[CONVERT_DATE_TO_INT](CONVERT(DATE, GETDATE()),'yyyyMMdd')
					SET @PP_COLOR =  SUBSTRING(@PP_COLOR, 2, 15)

					INSERT INTO CCJOBHDR_SQL (
												JOBNO,
												STATUS,
												COLOUR,
												COLOURDESC,
												MACHINE,
												DATECREATED,
												DATEPLANNED,
												CUSTOMER,
												COMMENTS)
										VALUES(
												@VP_ORDEN,
												'P',
												@PP_COLOR,
												@VP_COLOR_DESCRIPCION,
												@PP_LOCACION,
												@VP_F_CREACION_INT,
												@VP_F_CREACION_INT,
												@PP_CLIENTE,
												@PP_COMENTARIO
												)
			COMMIT TRANSACTION 
			END TRY
			
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_IN_ORDEN_GERBER // ' + @VP_ERROR_TRANS
			END CATCH
					
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Guardar la [ORDEN: '+CONVERT(VARCHAR(10),@VP_ORDEN)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @VP_ORDEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @VP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////					
	---////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////
GO




-- //////////////////////////////////////////////////////////////
-- // STORED PROCEDURE ---> SELECT / 
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_UP_ORDEN_GERBER]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_UP_ORDEN_GERBER]
GO

/*
 EXEC [PG_IN_ORDEN_GERBER] 0 ,0, '00001'
*/

CREATE PROCEDURE [dbo].[PG_UP_ORDEN_GERBER]
	@PP_K_SISTEMA_EXE			INT,
	@PP_K_USUARIO_ACCION		INT,
	-- ===========================
	@PP_ORDEN					VARCHAR(10),
	@PP_COLOR					VARCHAR(50),
	@PP_LOCACION				VARCHAR(50),
	@PP_CLIENTE					VARCHAR(50),
	--@PP_ESTATUS					INT,
	@PP_COMENTARIO				VARCHAR(255)
AS

	DECLARE @VP_MENSAJE VARCHAR(255) = ''
	-- //////////RN - VALIDACIONES/////////////////////////////////
	DECLARE @VP_N_JOBNO INT = 0
	SELECT	@VP_N_JOBNO = COUNT(JOBNO)
	FROM	RP_FOLIOS
	WHERE LTRIM(RTRIM(JOBNO)) = @PP_ORDEN

	IF @VP_N_JOBNO > 0
		SET @VP_MENSAJE = 'La orden ya fue asignada a un folio.'

	DECLARE @VP_ESTATUS_ORDEN VARCHAR(5) = ''
	SELECT	@VP_ESTATUS_ORDEN = LTRIM(RTRIM(STATUS))
	FROM	CCJOBHDR_SQL
	WHERE LTRIM(RTRIM(JOBNO)) = @PP_ORDEN

	IF @VP_ESTATUS_ORDEN = 'C'
		SET @VP_MENSAJE = 'Orden cerrada.'

	-- ///////////////////////////////////////////
	IF @VP_MENSAJE = ''
		BEGIN
			BEGIN TRANSACTION 
				BEGIN TRY
					-- //////////SE OBTINE EL NUMERO DE ORDEN/////////////////////////////////
					--DECLARE @VP_S_ESTATUS_ORDEN VARCHAR(5) = ''
					--SELECT @VP_S_ESTATUS_ORDEN = S_ESTATUS_ORDEN
					--FROM ESTATUS_ORDEN
					--WHERE K_ESTATUS_ORDEN = @PP_ESTATUS

					--IF @VP_S_ESTATUS_ORDEN IS NULL
					--	RAISERROR ('ERROR: No fue posible obtener el estatus de la orden en [ESTATUS_ORDEN]', 16, 1 ) --MENSAJE - Severity -State.

					-- //////////SE OBTINE LA DESCRIPCION DEL COLOR/////////////////////////////////
					DECLARE @VP_COLOR_DESCRIPCION VARCHAR(100) = ''
					SELECT @VP_COLOR_DESCRIPCION = LTRIM(RTRIM(item_desc_1))
					FROM IMITMIDX_SQL 
					WHERE LTRIM(RTRIM(item_no)) = @PP_COLOR

					IF @VP_COLOR_DESCRIPCION IS NULL
						RAISERROR ('ERROR: No fue posible obtener la descripción del color en [IMITMIDX_SQL]', 16, 1 ) --MENSAJE - Severity -State.

					-- //////////SE ACTUALIZA EL DATO DE LA ORDEN CCJOBHDR_SQL/////////////////////////////////
					SET @PP_COLOR =  SUBSTRING(@PP_COLOR, 2, 15)
					UPDATE CCJOBHDR_SQL
						SET --STATUS		= @VP_S_ESTATUS_ORDEN,
							COLOUR		= @PP_COLOR,
							COLOURDESC	= @VP_COLOR_DESCRIPCION,
							MACHINE		= @PP_LOCACION,
							CUSTOMER	= @PP_CLIENTE,
							comments	= @PP_COMENTARIO
					WHERE LTRIM(RTRIM(JOBNO)) = @PP_ORDEN

					IF @@ROWCOUNT = 0
						RAISERROR ('ERROR: No fue posible actualizar la orden en [CCJOBHDR_SQL]', 16, 1 ) --MENSAJE - Severity -State.

			COMMIT TRANSACTION 
			END TRY
			
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_UP_ORDEN_GERBER // ' + @VP_ERROR_TRANS
			END CATCH
					
	END
	-- /////////////////////////////////////////////////////////////////////
	-- /////////////////////////////////////////////////////////////////////
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible Guardar la [ORDEN: '+CONVERT(VARCHAR(10),@PP_ORDEN)+'] ' + @VP_MENSAJE 
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		--SET		@VP_MENSAJE = @VP_MENSAJE + '[#FOL.'+CONVERT(VARCHAR(10),@VP_TAGNO_DESTINO)+']'
		--SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
		
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_ORDEN AS CLAVE
	
	-- //////////////////////////////////////////////////////////////

	EXECUTE BD_GENERAL.[dbo].[PG_IN_BITACORA_SYS_OPERACION]	@PP_K_SISTEMA_EXE, @PP_K_USUARIO_ACCION,
													-- ===========================================
													2,		-- 0 al 6 // @PP_K_IMPORTANCIA_BITACORA_SYS	[INT],	
													'PROCESO',
													'',
													-- ===========================================
													'[PR]', -- @PP_STORED_PROCEDURE			[VARCHAR] (100),
													0, 0, 		-- @PP_K_FOLIO_1, @PP_K_FOLIO_2,
													-- === [INT], [INT], [VARCHAR](100), [VARCHAR](100), DECIMAL(19,4), DECIMAL(19,4),
													0, 0, @PP_ORDEN, '' , 0.00, 0.00,
													-- === @PP_VALOR_1 al 6_DATO
													'', '', '', '', '', ''

	-- ////////////////////////////////////////////////////////////////////					
	---////////////////////////////////////////////////////////////////
	-- ////////////////////////////////////////////////////////////////
GO


-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
