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
 EXEC DBO.[PG_RPT_PIEL_LOG] 0,144, 0, 0, 403291, 172
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
	@PP_LOTE					INT,
	@PP_PIEL					INT
AS

	-- ///////////////////////////////////////////
	SELECT TOP 10000 
		--=============================== 
		K_PIEL_LOG, 
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
-- // STORED PROCEDURE ---> INSERT / UPDATE
-- //////////////////////////////////////////////////////////////

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[PG_DL_PIEL_LOG]') AND type in (N'P', N'PC'))
	DROP PROCEDURE [dbo].[PG_DL_PIEL_LOG]
GO
/*
	EXEC  [dbo].[PG_DL_PIEL_LOG] 0, 144, 3500362
	EXEC  [dbo].[PG_DL_PIEL_LOG] 0, 144, 3465885

*/
CREATE PROCEDURE [dbo].[PG_DL_PIEL_LOG]
	@PP_K_SISTEMA_EXE					INT,
	@PP_K_USUARIO_ACCION				INT,
	-- ===========================
	@PP_K_PIEL_LOG						INT								
AS

	DECLARE @VP_MENSAJE		VARCHAR(300) = ''
	IF @VP_MENSAJE=''
		BEGIN
			BEGIN TRANSACTION 
			BEGIN TRY			
				-- ////////RN VALIDACIONES/////////////////////////////////////////////////////////
				DECLARE @VP_K_TIPO_PIEL_LOG INT = 0, @PP_LOTE VARCHAR(20) = '', @PP_COLOR VARCHAR(50) = '', @PP_PIEL VARCHAR(10) = ''; 

				SELECT	@VP_K_TIPO_PIEL_LOG = K_TIPO_PIEL_LOG,
						@PP_COLOR = COLOR,
						@PP_LOTE = LOTE,
						@PP_PIEL = PIEL
				FROM PIEL_LOG (NOLOCK)
				WHERE K_PIEL_LOG = @PP_K_PIEL_LOG

				IF @VP_K_TIPO_PIEL_LOG <> 8  -- REIMPRESION
					RAISERROR ('ERROR: Solo se pueden eliminar los registros de Reimpresión.', 16, 1 ) --MENSAJE - Severity -State.

				-- ///////////////////////////////////////////////////////////////	
				DECLARE @VP_N_COLOR_CONTROLADO INT = 0
				SELECT @VP_N_COLOR_CONTROLADO = COUNT(ID)
				FROM COLORES_CONTROLADOS
				WHERE COLOR = @PP_COLOR
					
				IF	@VP_N_COLOR_CONTROLADO IS NULL
					SET @VP_N_COLOR_CONTROLADO = 0

				IF @VP_N_COLOR_CONTROLADO > 0
					BEGIN
						DECLARE @VP_N_PIEL_MHI INT = 0
						SELECT @VP_N_PIEL_MHI = COUNT(ID)
						FROM RP_SC (NOLOCK)
						WHERE LTRIM(RTRIM(LOT)) = CONVERT(VARCHAR(20), @PP_LOTE)
						AND CONVERT(INT, LTRIM(RTRIM(HIDE))) = @PP_PIEL
						AND MOVEMENT = 'MHI'

						IF @VP_N_PIEL_MHI IS NULL OR @VP_N_PIEL_MHI = 0
							RAISERROR ('ERROR: La piel no se encuentra en MHI.', 16, 1 ) --MENSAJE - Severity -State.
					END

				-- ///////////////////////////////////////////////////////////////		
				DECLARE @VP_SQF_ORIGINAL DECIMAL(13,2) = 0
				SELECT	@VP_SQF_ORIGINAL = SQF
				FROM HIDESHDR_SQL (NOLOCK)  
				INNER JOIN HIDESLIN_SQL (NOLOCK) ON  HIDESLIN_SQL.FILENO = HIDESHDR_SQL.FILENO
				WHERE  LTRIM(RTRIM(PLOT)) = CONVERT(VARCHAR(20), @PP_LOTE)
				AND CONVERT(INT, LTRIM(RTRIM(HIDE))) = @PP_PIEL

				IF @VP_SQF_ORIGINAL IS NULL
					SET @VP_SQF_ORIGINAL = 0

				-- /////////////////////////////////////////////////////
				DECLARE @VP_SQF_CORTADO	DECIMAL(13,2) = 0
				SELECT	@VP_SQF_CORTADO = SUM(hidesqm) 
				FROM	cccuthst_sql (NOLOCK)
				WHERE	LTRIM(RTRIM(LOTNO)) = RIGHT('000000' + CONVERT(VARCHAR(20), @PP_LOTE), 6)
				AND CONVERT(INT, LTRIM(RTRIM(HIDENO))) = @PP_PIEL

				IF @VP_SQF_CORTADO IS NULL
					SET @VP_SQF_CORTADO = 0

				-- /////////////////////////////////////////////////////
				SET @VP_SQF_ORIGINAL = @VP_SQF_ORIGINAL - @VP_SQF_CORTADO

				IF @VP_SQF_ORIGINAL <= 0
					RAISERROR ('ERROR: La piel ya fue cortada.', 16, 1 ) --MENSAJE - Severity -State.

				-- ////////SE ACTUALIZA EL REGISTRO DE REIMPRESION A REIMPRESION BORADA///////////////////////////////////////////////////////				
				UPDATE PIEL_LOG
					SET K_TIPO_PIEL_LOG = 16 -- BORRAR REIMPRESION
				WHERE K_PIEL_LOG = @PP_K_PIEL_LOG
				AND K_TIPO_PIEL_LOG = 8 -- REIMPRESION

				IF @@ROWCOUNT = 0
					RAISERROR ('ERROR: No fue posible Borrar el Log de la piel. ', 16, 1 ) --MENSAJE - Severity -State.
				
			COMMIT TRANSACTION 
			END TRY
	
			BEGIN CATCH
				/* Ocurrió un error, deshacemos los cambios*/ 
				ROLLBACK TRANSACTION
				DECLARE @VP_ERROR_TRANS NVARCHAR(4000);
				SET @VP_ERROR_TRANS = ERROR_MESSAGE() 
				SET @VP_MENSAJE = 'ERROR: //TRANSAC. PG_DL_PIEL_LOG // ' + @VP_ERROR_TRANS
			END CATCH
				
		END

	-- // SECCION#3 ////////////////////////////////////////////////////////// MENSAJE DE SALIDA
	
	IF @VP_MENSAJE<>''
		BEGIN
		
		SET		@VP_MENSAJE = 'No es posible [ELIMINAR] el [Log]: ' + @VP_MENSAJE 
		SET		@VP_MENSAJE = @VP_MENSAJE + ' ( '
		SET		@VP_MENSAJE = @VP_MENSAJE + '[#LOG.'+CONVERT(VARCHAR(10),@PP_K_PIEL_LOG)+']'
		SET		@VP_MENSAJE = @VP_MENSAJE + ' )'
	
		END
	
	SELECT	@VP_MENSAJE AS MENSAJE, @PP_K_PIEL_LOG AS CLAVE

	-- ///////////////////////////////////////////////////////////////
	-- //////////////////////////////////////////////////////////////

GO

-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
-- //////////////////////////////////////////////////////////////
